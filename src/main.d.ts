interface JsonApiRessource {
  id: string
  type: string
  attributes?: {
    [key: string]: any
  }
  relationships?: {
    [key: string]: { data: JsonApiRessource | JsonApiRessource[] }
  }
}

interface JsonApiResponse {
  data: JsonApiRessource | JsonApiRessource[]
  included?: JsonApiRessource[]
}

interface AlchemyElement {
  id: string
  name: string
  deprecated?: boolean
  ingredients: AlchemyIngredient[]
  nestedElements?: AlchemyElement[]
}

interface AlchemyPage {
  id: string
  elements: AlchemyElement[]
  allElements: AlchemyElement[]
  fixedElements?: AlchemyElement[]
}

interface AlchemyIngredient {
  id: string
  role: string
  element: AlchemyElement
  deprecated?: boolean
}
