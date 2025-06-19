import { deserialize } from "./deserialize"

// Recursively filters all deprecated elements and essences from collection
function filterDeprecatedElements(elements: any) {
  const els: any = []

  elements.forEach((element: any) => {
    if (element.nested_elements?.length > 0) {
      element.nested_elements = filterDeprecatedElements(
        element.nested_elements
      )
    }
    if (element.nestedElements?.length > 0) {
      element.nestedElements = filterDeprecatedElements(element.nestedElements)
    }
    if (element.essences?.length > 0) {
      element.essences = element.essences.filter((essence: any) => {
        return !essence.deprecated
      })
    }
    if (!element.deprecated) {
      els.push(element)
    }
  })

  return els
}

// Returns deserialized page without deprecated content
export function deserializePage(pageData: any) {
  const page = deserialize(pageData)
  page.elements = filterDeprecatedElements(page.elements)
  return page
}

// Returns deserialized pages without deprecated content
export function deserializePages(pagesData: any) {
  const pages = deserialize(pagesData)
  pages.forEach((page: any) => {
    page.elements = filterDeprecatedElements(page.elements)
  })
  return pages
}
