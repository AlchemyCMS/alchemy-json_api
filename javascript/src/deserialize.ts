/*
 * JSON:API deserializer.
 *
 * A resource's relationships routinely form cycles (e.g. a taxon's `children`
 * each carry an `ancestors` array pointing back to the taxon). Resolving those
 * naively yields a circular object graph, which cannot be serialized with
 * `JSON.stringify` and throws `RangeError: Maximum call stack size exceeded`
 * when walked recursively. This produces an acyclic graph instead.
 *
 * Observable contract:
 *
 *   - A single `data` object yields a single object; an array `data` yields an
 *     array.
 *   - Each resource's `attributes` are flattened onto the result and its `id`
 *     is injected. `type` is intentionally not kept.
 *   - Every relationship the resource declares is kept on the result. A
 *     relationship whose target is present in `included` is expanded; one whose
 *     target is absent becomes a `{ id }` stub.
 *
 * Deliberate features:
 *
 *   1. Cycle-safe by construction: each resource carries the set of ancestor
 *      keys currently being resolved; a relationship that would revisit an
 *      ancestor is emitted as a `{ id }` stub rather than recursed into, so the
 *      result is always acyclic. This generalises to any back-reference.
 *   2. O(1) relationship lookups: `included` is indexed once by `type:id`.
 *   3. Input is never touched: the document is cloned up front, so neither the
 *      argument nor any nested attribute object is aliased by, or mutable
 *      through, the returned graph.
 *
 * The implementation is a set of small pure functions: nothing mutates shared
 * state, and the ancestor `path` is passed down by value (a new Set per hop)
 * rather than mutated in place.
 */

// The JSON:API v1.1 document shapes `deserialize` consumes
// (https://jsonapi.org/format/#document-structure). They are exported so
// callers can type the raw response they hand in; being module exports, they
// only enter a consumer's scope when imported, so they cannot collide with a
// consumer's own global definitions.

/** A meta object: free-form, non-standard meta-information. */
export type JsonApiMeta = Record<string, unknown>

/** A link object (https://jsonapi.org/format/#document-links-link-object). */
export interface JsonApiLinkObject {
  href: string
  rel?: string
  describedby?: JsonApiLink
  title?: string
  type?: string
  hreflang?: string | string[]
  meta?: JsonApiMeta
}

/** A link: a URI-reference, a link object, or `null` if it does not exist. */
export type JsonApiLink = string | JsonApiLinkObject | null

/**
 * A links object. The members the specification defines are listed; others
 * (from extensions, or implementation-specific ones such as the `current`
 * page link jsonapi.rb emits) are allowed through the index signature.
 */
export interface JsonApiLinks {
  self?: JsonApiLink
  related?: JsonApiLink
  describedby?: JsonApiLink
  first?: JsonApiLink
  last?: JsonApiLink
  prev?: JsonApiLink
  next?: JsonApiLink
  [name: string]: JsonApiLink | undefined
}

/** A resource identifier object: `type` and `id` are always strings. */
export interface JsonApiResourceIdentifier {
  type: string
  id: string
  meta?: JsonApiMeta
}

/**
 * Resource linkage: `null` or `[]` when empty, otherwise one identifier
 * (to-one) or an array of them (to-many).
 */
export type JsonApiResourceLinkage =
  JsonApiResourceIdentifier | JsonApiResourceIdentifier[] | null

/**
 * A relationship object. The specification requires at least one of `data`,
 * `links` or `meta`, but none of them individually, so `data` is optional: a
 * relationship that only carries links (or that a server leaves empty, e.g.
 * jsonapi-serializer's `lazy_load_data`) has no linkage to resolve.
 */
export interface JsonApiRelationship {
  data?: JsonApiResourceLinkage
  links?: JsonApiLinks
  meta?: JsonApiMeta
}

/** A resource object. */
export interface JsonApiResource extends JsonApiResourceIdentifier {
  attributes?: Record<string, unknown>
  /**
   * `undefined` values are accepted because a JSON import of an array of
   * resources with differing relationship names is widened by TypeScript to
   * records whose missing names are `undefined`; it never occurs on the wire.
   */
  relationships?: Record<string, JsonApiRelationship | undefined>
  links?: JsonApiLinks
}

/**
 * A JSON:API document carrying primary data, which is what `deserialize`
 * turns into plain objects. `data` is a resource object or `null` for
 * single-resource requests, and an array (possibly empty) for collections.
 * Error documents (`errors` instead of `data`) are not deserializable.
 */
export interface JsonApiDocument {
  data: JsonApiResource | JsonApiResource[] | null
  included?: JsonApiResource[]
  meta?: JsonApiMeta
  links?: JsonApiLinks
  jsonapi?: {
    version?: string
    ext?: string[]
    profile?: string[]
    meta?: JsonApiMeta
  }
}

type Deserialized = Record<string, unknown>

/** A `type:id` map of every sideloaded resource. */
type ResourceIndex = Map<string, JsonApiResource>

/** The set of `type:id` keys currently on the resolution path (ancestors). */
type Path = ReadonlySet<string>

const keyOf = ({ type, id }: JsonApiResourceIdentifier): string =>
  `${type}:${id}`

const stub = ({ id }: JsonApiResourceIdentifier): Deserialized => ({ id })

/** Build the `type:id -> resource` lookup for the document's `included` array. */
const indexResources = (included: readonly JsonApiResource[]): ResourceIndex =>
  new Map(included.map((resource) => [keyOf(resource), resource]))

/**
 * Resolve one relationship identifier to a full object or an `{ id }` stub.
 * Stubs when the target is on the current path (would close a cycle) or is not
 * present in `included`.
 */
const resolveRef = (
  index: ResourceIndex,
  path: Path,
  ref: JsonApiResourceIdentifier
): Deserialized => {
  const key = keyOf(ref)
  const target = path.has(key) ? undefined : index.get(key)
  return target ? resolveResource(index, path, target) : stub(ref)
}

/** Resolve a relationship's `data` (to-one, to-many, or null) to its value. */
const resolveRelationship = (
  index: ResourceIndex,
  path: Path,
  data: JsonApiResourceIdentifier | JsonApiResourceIdentifier[] | null
): Deserialized | Deserialized[] | null => {
  if (Array.isArray(data))
    return data.map((ref) => resolveRef(index, path, ref))
  if (data) return resolveRef(index, path, data)
  return null
}

/**
 * Flatten a resource into `{ ...attributes, id, ...resolvedRelationships }`.
 * The resource's own key is added to `path` for its descendants so a cycle back
 * to it resolves as a stub.
 */
const resolveResource = (
  index: ResourceIndex,
  path: Path,
  resource: JsonApiResource
): Deserialized => {
  const childPath = new Set(path).add(keyOf(resource))
  const relationships = Object.entries(resource.relationships ?? {}).map(
    ([name, rel]) =>
      [name, resolveRelationship(index, childPath, rel?.data ?? null)] as const
  )

  return {
    ...resource.attributes,
    id: resource.id,
    ...Object.fromEntries(relationships)
  }
}

/**
 * Deserialize a JSON:API document into plain, acyclic objects.
 *
 * The input is typed as the JSON:API document it is: type the API response
 * as `JsonApiDocument`, and name the shape you expect out via `T`.
 *
 * `T` is deliberately unconstrained. Which shape comes out depends on the
 * endpoint that was called (and whether `data` was an array on the wire),
 * which the type system cannot infer from the document. Those shapes are the
 * caller's documented resource types, so the caller must always pass one;
 * without it, the result is `unknown`.
 *
 * @example
 *   const response: JsonApiDocument = await (await fetch(url)).json()
 *   const page = deserialize<Page>(response)
 */
export function deserialize<T>(document: JsonApiDocument): T {
  return deserializeDocument(document)
}

/**
 * The implementation behind `deserialize`. It returns `any` on purpose: the
 * result's shape is named by the caller of `deserialize<T>`, so describing a
 * structure here would only have to be cast away again.
 */
function deserializeDocument(
  document: JsonApiDocument | null | undefined
): any {
  // Untyped JavaScript callers may still pass `null`/`undefined`.
  if (document == null) return null

  const { data = null, included = [] } = structuredClone(document)
  const index = indexResources(included)
  const resolve = (resource: JsonApiResource) =>
    resolveResource(index, new Set<string>(), resource)

  if (Array.isArray(data)) return data.map(resolve)
  if (data) return resolve(data)
  return null
}

export default deserialize
