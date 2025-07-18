export function deserialize(originalResponse: JsonApiResponse) {
  const response = structuredClone(originalResponse)

  const included = response.included || []

  if (Array.isArray(response.data)) {
    return response.data.map((data) => {
      return parseJsonApiSimpleResourceData(data, included, false)
    })
  } else {
    return parseJsonApiSimpleResourceData(response.data, included, false)
  }
}

function parseJsonApiSimpleResourceData(
  ressourceData: JsonApiRessource,
  included: any,
  useCache: any
) {
  if (!included.cached) {
    included.cached = {}
  }

  if (!(ressourceData.type in included.cached)) {
    included.cached[ressourceData.type] = {}
  }

  if (useCache && ressourceData.id in included.cached[ressourceData.type]) {
    return included.cached[ressourceData.type][ressourceData.id]
  }

  const attributes = ressourceData.attributes || {}

  const resource = attributes
  resource.id = ressourceData.id

  included.cached[ressourceData.type][ressourceData.id] = resource

  if (ressourceData.relationships) {
    for (const relationName of Object.keys(ressourceData.relationships)) {
      const relationRef = ressourceData.relationships[relationName]

      if (Array.isArray(relationRef.data)) {
        const items = relationRef.data.map((relationData) =>
          findJsonApiIncluded(included, relationData.type, relationData.id)
        )
        resource[relationName] = items
      } else if (relationRef && relationRef.data) {
        resource[relationName] = findJsonApiIncluded(
          included,
          relationRef.data.type,
          relationRef.data.id
        )
      } else {
        resource[relationName] = null
      }
    }
  }

  return resource
}

function findJsonApiIncluded(
  included: JsonApiRessource[],
  type: string,
  id: string
) {
  let found = null

  included.forEach((item) => {
    if (item.type === type && item.id === id) {
      found = parseJsonApiSimpleResourceData(item, included, true)
    }
  })

  if (!found) {
    found = { id }
  }

  return found
}
