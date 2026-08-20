// Deserializes a JSON:API document into plain objects, flattening each
// resource's attributes and resolving its relationships from `included`.
//
// The result is acyclic by construction: while a resource is being resolved,
// its own `type:id` is held on a `path` set, and any relationship that would
// point back to a resource already on that path is emitted as an `{ id }` stub
// instead of being recursed into. Without this guard a back-reference (e.g. a
// taxon whose `children` link back to it via `ancestors`) produces a circular
// graph, which overflows the stack when later walked or serialized.

function keyOf({ type, id }) {
  return `${type}:${id}`
}

function stub({ id }) {
  return { id }
}

function indexResources(included) {
  const index = new Map()
  for (const resource of included) {
    const key = keyOf(resource)
    if (!index.has(key)) index.set(key, resource)
  }
  return index
}

function resolveRef(index, path, ref) {
  const key = keyOf(ref)
  const target = path.has(key) ? undefined : index.get(key)
  return target ? resolveResource(index, path, target) : stub(ref)
}

function resolveRelationship(index, path, data) {
  if (Array.isArray(data)) {
    return data.map((ref) => resolveRef(index, path, ref))
  }
  if (data) {
    return resolveRef(index, path, data)
  }
  return null
}

function resolveResource(index, path, resource) {
  const childPath = new Set(path).add(keyOf(resource))
  const relationships = Object.entries(resource.relationships ?? {}).map(
    ([name, rel]) => [
      name,
      resolveRelationship(index, childPath, rel?.data ?? null)
    ]
  )

  return {
    ...resource.attributes,
    id: resource.id,
    ...Object.fromEntries(relationships)
  }
}

export function deserialize(document) {
  const { data = null, included = [] } =
    document == null ? {} : structuredClone(document)
  const index = indexResources(included)
  const resolve = (resource) => resolveResource(index, new Set(), resource)

  if (Array.isArray(data)) {
    return data.map(resolve)
  }
  if (data) {
    return resolve(data)
  }
  return null
}
