/*
 * JSON:API deserializer.
 *
 * A resource is typically referenced from many places in one document (menu
 * nodes point at their `parent` and list their `children`, several elements
 * link to the same page, a page's `ancestors` are shared by its siblings).
 * Each resource is therefore materialized exactly once and the same object is
 * shared by every reference to it, so the output is linear in the size of the
 * document.
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
 *   1. Shared references: every `type:id` in `included` resolves to one object.
 *      The object is registered before its relationships are resolved, so a
 *      back-reference (e.g. a menu node's `parent`, which lists the node among
 *      its `children`) is a real reference to that same object, and the
 *      graph may therefore contain cycles. Consumers that walk it must track
 *      visited objects; `structuredClone`, devalue (Nuxt payloads) and Vue
 *      reactivity all do. Plain `JSON.stringify` does not.
 *   2. O(1) relationship lookups: `included` is indexed once by `type:id`.
 *   3. Input is never touched: the document is cloned up front, so neither the
 *      argument nor any nested attribute object is aliased by, or mutable
 *      through, the returned graph.
 *
 * Why not break cycles with stubs? 4.0.0 did, by re-resolving a resource at
 * every place it was referenced and stubbing only references to its own
 * ancestors. That keeps the graph acyclic, but the output then grows with the
 * number of *paths* through the relationship graph rather than the number of
 * resources, which is exponential once resources cross-reference each other
 * (see the "output size" specs).
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

/** Every resource materialized so far, by `type:id`. */
type Cache = Map<string, Deserialized>

const keyOf = ({ type, id }: JsonApiResourceIdentifier): string =>
  `${type}:${id}`

const stub = ({ id }: JsonApiResourceIdentifier): Deserialized => ({ id })

/** Build the `type:id -> resource` lookup for the document's `included` array. */
const indexResources = (included: readonly JsonApiResource[]): ResourceIndex =>
  new Map(included.map((resource) => [keyOf(resource), resource]))

/**
 * Resolve one relationship identifier to the shared object for that resource,
 * or to an `{ id }` stub when it is not present in `included`.
 */
const resolveRef = (
  index: ResourceIndex,
  cache: Cache,
  ref: JsonApiResourceIdentifier
): Deserialized => {
  const target = index.get(keyOf(ref))
  return target ? resolveResource(index, cache, target) : stub(ref)
}

/** Resolve a relationship's `data` (to-one, to-many, or null) to its value. */
const resolveRelationship = (
  index: ResourceIndex,
  cache: Cache,
  data: JsonApiResourceIdentifier | JsonApiResourceIdentifier[] | null
): Deserialized | Deserialized[] | null => {
  if (Array.isArray(data))
    return data.map((ref) => resolveRef(index, cache, ref))
  if (data) return resolveRef(index, cache, data)
  return null
}

/**
 * Flatten a resource into `{ ...attributes, id, ...resolvedRelationships }`,
 * once per `type:id`. The object is cached before its relationships are
 * resolved, so a reference back to it (directly or through a cycle) returns
 * this same object instead of building another copy.
 */
const resolveResource = (
  index: ResourceIndex,
  cache: Cache,
  resource: JsonApiResource
): Deserialized => {
  const key = keyOf(resource)
  const cached = cache.get(key)
  if (cached) return cached

  const result: Deserialized = { ...resource.attributes, id: resource.id }
  cache.set(key, result)

  for (const [name, rel] of Object.entries(resource.relationships ?? {})) {
    result[name] = resolveRelationship(index, cache, rel?.data ?? null)
  }
  return result
}

/**
 * Deserialize a JSON:API document into plain objects, sharing one object per
 * resource. The result may contain reference cycles.
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
  const cache: Cache = new Map()
  const resolve = (resource: JsonApiResource) =>
    resolveResource(index, cache, resource)

  if (Array.isArray(data)) return data.map(resolve) as T
  if (data) return resolve(data) as T
  return null as T
}

export default deserialize
