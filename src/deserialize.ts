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

// Internal shapes describing the JSON:API document we consume. They are not
// exported: the public entry point takes `unknown`, so these would only add
// generically-named types (JsonApiResource, JsonApiDocument, ...) to the
// package surface that could collide with a consumer's own definitions.
interface JsonApiResourceIdentifier {
  type: string
  id: string
}

interface JsonApiResource extends JsonApiResourceIdentifier {
  attributes?: Record<string, unknown>
  relationships?: Record<
    string,
    { data?: JsonApiResourceIdentifier | JsonApiResourceIdentifier[] | null }
  >
}

interface JsonApiDocument {
  data: JsonApiResource | JsonApiResource[] | null
  included?: JsonApiResource[]
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
 * The `document` is a raw API response with no compile-time shape, so the
 * parameter is `unknown`. The caller names the shape it expects out via `T`;
 * this function is the boundary that turns the untyped response into it.
 *
 * @example
 *   const product = deserialize<Product>(apiResponse)
 */
export function deserialize<T = unknown>(document: unknown): T {
  const { data = null, included = [] } = (
    document == null ? {} : structuredClone(document)
  ) as JsonApiDocument
  const index = indexResources(included)
  const resolve = (resource: JsonApiResource) =>
    resolveResource(index, new Set<string>(), resource)

  if (Array.isArray(data)) return data.map(resolve) as T
  if (data) return resolve(data) as T
  return null as T
}

export default deserialize
