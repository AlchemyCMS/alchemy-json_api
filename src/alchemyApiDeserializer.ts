import { deserialize } from "./deserialize"

// Recursively filters all deprecated elements and essences from collection
function filterDeprecatedElements(elements: AlchemyElement[]) {
  return elements
    .map((element) => {
      if (element.nestedElements?.length > 0) {
        element.nestedElements = filterDeprecatedElements(
          element.nestedElements
        )
      }

      if (element.ingredients?.length > 0) {
        element.ingredients = element.ingredients.filter((ingredients) => {
          return !ingredients.deprecated
        })
      }

      if (!element.deprecated) {
        return element
      }
    })
    .filter((element) => element !== undefined)
}

// Returns deserialized page without deprecated content
export function deserializePage(pageData: JsonApiResponse) {
  const page = deserialize(pageData)
  page.elements = filterDeprecatedElements(page.elements)
  return page
}

// Returns deserialized pages without deprecated content
export function deserializePages(pagesData: JsonApiResponse) {
  const pages = deserialize(pagesData) as AlchemyPage[]
  pages.forEach((page) => {
    page.elements = filterDeprecatedElements(page.elements)
  })
  return pages
}
