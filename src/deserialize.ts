export function deserialize(originalResponse: any, options = {}) {
  const response = structuredClone(originalResponse)
  if (!options) {
    options = {}
  }

  const included = response.included || []

  if (Array.isArray(response.data)) {
    return response.data.map((data: any) => {
      return parseJsonApiSimpleResourceData(data, included, false, options)
    })
  } else {
    return parseJsonApiSimpleResourceData(
      response.data,
      included,
      false,
      options
    )
  }
}

function parseJsonApiSimpleResourceData(
  data: any,
  included: any,
  useCache: any,
  options: any
) {
  if (!included.cached) {
    included.cached = {}
  }

  if (!(data.type in included.cached)) {
    included.cached[data.type] = {}
  }

  if (useCache && data.id in included.cached[data.type]) {
    return included.cached[data.type][data.id]
  }

  const attributes = data.attributes || {}

  const resource = attributes
  resource.id = data.id

  included.cached[data.type][data.id] = resource

  if (data.relationships) {
    for (const relationName of Object.keys(data.relationships)) {
      const relationRef = data.relationships[relationName]

      if (Array.isArray(relationRef.data)) {
        const items: any = []

        relationRef.data.forEach((relationData: any) => {
          const item = findJsonApiIncluded(
            included,
            relationData.type,
            relationData.id,
            options
          )

          items.push(item)
        })

        resource[relationName] = items
      } else if (relationRef && relationRef.data) {
        resource[relationName] = findJsonApiIncluded(
          included,
          relationRef.data.type,
          relationRef.data.id,
          options
        )
      } else {
        resource[relationName] = null
      }
    }
  }

  return resource
}

function findJsonApiIncluded(included: any, type: any, id: any, options: any) {
  let found = null

  included.forEach((item: any) => {
    if (item.type === type && item.id === id) {
      found = parseJsonApiSimpleResourceData(item, included, true, options)
    }
  })

  if (!found) {
    found = { id }
  }

  return found
}
