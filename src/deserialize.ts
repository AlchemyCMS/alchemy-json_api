/*
 * JSON:API deserializer.
 *
 * Resolves a JSON:API document (data + included) into plain objects: each
 * resource's attributes are flattened with its id, and relationships become
 * nested objects or `{ id }` stubs (when the target isn't in `included`). The
 * result is always acyclic and safe to JSON.stringify.
 *
 * Two resolution strategies:
 *
 *   - default (shared): every resource is resolved once and shared by
 *     reference; a reference back to a resource still being resolved (a true
 *     cycle) becomes an `{ id }` stub. Compact and fast — cost scales with the
 *     number of resources, not the number of paths to them. Object identity is
 *     shared, and each resource is fully expanded at its first-resolved
 *     location (referenced elsewhere as the same object, or an `{ id }` stub at
 *     a cycle-closing edge).
 *
 *   - `{ expand: true }`: every reference is resolved independently, so a
 *     resource reached via multiple paths is fully expanded at each one.
 *     Faithful per path, but re-expands shared subtrees, so cost scales with the
 *     number of paths — densely cross-linked documents can blow up. Cycles are
 *     still cut to `{ id }` stubs (a reference to an ancestor on the path).
 *
 * Both clone the input up front, so neither the argument nor any nested
 * attribute object is aliased by, or mutable through, the returned graph.
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

const keyOf = ({ type, id }: JsonApiResourceIdentifier): string =>
  `${type}:${id}`

const stub = ({ id }: JsonApiResourceIdentifier): Deserialized => ({ id })

/** Build the `type:id -> resource` lookup for the document's `included` array. */
const indexResources = (included: readonly JsonApiResource[]): ResourceIndex =>
  new Map(included.map((resource) => [keyOf(resource), resource]))

// --- default: shared resolution (grey/black) ------------------------------
// `resolving` (grey) is the set of resources on the current resolution stack;
// a reference to one would close a cycle, so it is stubbed. `cache` (black)
// memoises fully-resolved resources — a black resource can never be a current
// ancestor, so sharing it never re-introduces a cycle.

const resolveSharedRef = (
  index: ResourceIndex,
  cache: Map<string, Deserialized>,
  resolving: Set<string>,
  ref: JsonApiResourceIdentifier
): Deserialized => {
  const key = keyOf(ref)
  if (resolving.has(key)) return stub(ref)
  const black = cache.get(key)
  if (black) return black
  const target = index.get(key)
  return target
    ? resolveSharedResource(index, cache, resolving, target)
    : stub(ref)
}

const resolveSharedRelationship = (
  index: ResourceIndex,
  cache: Map<string, Deserialized>,
  resolving: Set<string>,
  data: JsonApiResourceIdentifier | JsonApiResourceIdentifier[] | null
): Deserialized | Deserialized[] | null => {
  if (Array.isArray(data))
    return data.map((ref) => resolveSharedRef(index, cache, resolving, ref))
  if (data) return resolveSharedRef(index, cache, resolving, data)
  return null
}

const resolveSharedResource = (
  index: ResourceIndex,
  cache: Map<string, Deserialized>,
  resolving: Set<string>,
  resource: JsonApiResource
): Deserialized => {
  const key = keyOf(resource)
  const cached = cache.get(key)
  if (cached) return cached

  resolving.add(key)
  const result: Deserialized = { ...resource.attributes, id: resource.id }
  for (const [name, rel] of Object.entries(resource.relationships ?? {})) {
    result[name] = resolveSharedRelationship(
      index,
      cache,
      resolving,
      rel?.data ?? null
    )
  }
  resolving.delete(key)
  cache.set(key, result)
  return result
}

// --- opt-in: full expansion ({ expand: true }) ----------------------------
// Every reference is resolved independently against the set of ancestors on the
// current path; a reference to an ancestor is stubbed. No memoisation, so a
// resource reached via N paths is rebuilt N times.

type Path = ReadonlySet<string>

const resolveExpandedRef = (
  index: ResourceIndex,
  path: Path,
  ref: JsonApiResourceIdentifier
): Deserialized => {
  const key = keyOf(ref)
  const target = path.has(key) ? undefined : index.get(key)
  return target ? resolveExpandedResource(index, path, target) : stub(ref)
}

const resolveExpandedRelationship = (
  index: ResourceIndex,
  path: Path,
  data: JsonApiResourceIdentifier | JsonApiResourceIdentifier[] | null
): Deserialized | Deserialized[] | null => {
  if (Array.isArray(data))
    return data.map((ref) => resolveExpandedRef(index, path, ref))
  if (data) return resolveExpandedRef(index, path, data)
  return null
}

const resolveExpandedResource = (
  index: ResourceIndex,
  path: Path,
  resource: JsonApiResource
): Deserialized => {
  const childPath = new Set(path).add(keyOf(resource))
  const relationships = Object.entries(resource.relationships ?? {}).map(
    ([name, rel]) =>
      [
        name,
        resolveExpandedRelationship(index, childPath, rel?.data ?? null)
      ] as const
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
 * parameter is `unknown`. The caller names the shape it expects out via `T`.
 *
 * By default resources are resolved once and shared by reference (compact and
 * fast). Pass `{ expand: true }` to fully expand every reference path instead —
 * faithful per path, but far more expensive on densely cross-linked documents.
 *
 * @example
 *   const product = deserialize<Product>(apiResponse)
 */
export function deserialize<T = unknown>(
  document: unknown,
  options: { expand?: boolean } = {}
): T {
  const { data = null, included = [] } = (
    document == null ? {} : structuredClone(document)
  ) as JsonApiDocument
  const index = indexResources(included)

  let resolve: (resource: JsonApiResource) => Deserialized
  if (options.expand) {
    resolve = (resource) =>
      resolveExpandedResource(index, new Set<string>(), resource)
  } else {
    const cache = new Map<string, Deserialized>()
    const resolving = new Set<string>()
    resolve = (resource) =>
      resolveSharedResource(index, cache, resolving, resource)
  }

  if (Array.isArray(data)) return data.map(resolve) as T
  if (data) return resolve(data) as T
  return null as T
}

export default deserialize
