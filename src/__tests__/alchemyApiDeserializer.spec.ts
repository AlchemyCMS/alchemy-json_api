import { deserializePage, deserializePages } from "../alchemyApiDeserializer"
import { describe, it, expect } from "vitest"

describe("deserializePage", () => {
  it("does not return any deprecated elements for single page", () => {
    const pageData = {
      data: {
        id: "1",
        type: "page",
        attributes: {
          name: "Homepage"
        },
        relationships: {
          elements: {
            data: [
              {
                type: "element",
                id: "1"
              },
              {
                type: "element",
                id: "2"
              }
            ]
          }
        }
      },
      included: [
        {
          type: "element",
          id: "1",
          attributes: {
            name: "article"
          }
        },
        {
          type: "element",
          id: "2",
          attributes: {
            name: "old",
            deprecated: true
          }
        }
      ]
    }
    const page = deserializePage(pageData)
    expect(page).toEqual({
      name: "Homepage",
      id: "1",
      elements: [{ name: "article", id: "1" }]
    })
  })

  it("does not return any deprecated nestedElements for single page", () => {
    const pageData = {
      data: {
        id: "1",
        type: "page",
        attributes: {
          name: "Homepage"
        },
        relationships: {
          elements: {
            data: [
              {
                type: "element",
                id: "1"
              }
            ]
          }
        }
      },
      included: [
        {
          id: "1",
          type: "element",
          attributes: {
            name: "article"
          },
          nestedElements: [
            {
              id: "2",
              type: "element"
            },
            {
              id: "3",
              type: "element"
            }
          ]
        },
        {
          id: "2",
          type: "element",
          attributes: {
            name: "old",
            deprecated: true
          }
        },
        {
          id: "3",
          type: "element",
          attributes: {
            name: "title",
            deprecated: false
          }
        }
      ]
    }
    const page = deserializePage(pageData)
    expect(page).toEqual({
      name: "Homepage",
      id: "1",
      elements: [{ name: "article", id: "1" }]
    })
  })

  it("does not return any deprecated elements for pages", () => {
    const pageData = {
      data: [
        {
          type: "page",
          id: "1",
          attributes: {
            name: "Homepage"
          },
          relationships: {
            elements: {
              data: [
                {
                  type: "element",
                  id: "1"
                },
                {
                  type: "element",
                  id: "2"
                }
              ]
            }
          }
        }
      ],
      included: [
        {
          type: "element",
          id: "1",
          attributes: {
            name: "article",
            deprecated: false
          },
          relationships: {
            ingredients: {
              data: [
                {
                  id: "1",
                  type: "text"
                },
                {
                  id: "1",
                  type: "picture"
                }
              ]
            },
            nestedElements: {
              data: [
                {
                  id: "3",
                  type: "element"
                },
                {
                  id: "4",
                  type: "element"
                }
              ]
            }
          }
        },
        {
          type: "element",
          id: "2",
          attributes: {
            name: "old",
            deprecated: true
          },
          relationships: {}
        },
        {
          type: "element",
          id: "3",
          attributes: {
            name: "image",
            deprecated: true
          },
          relationships: {}
        },
        {
          type: "element",
          id: "4",
          attributes: {
            name: "text",
            deprecated: false
          },
          relationships: {}
        },
        {
          type: "text",
          id: "1",
          attributes: {
            name: "text",
            deprecated: true
          }
        },
        {
          type: "picture",
          id: "1",
          attributes: {
            name: "image",
            deprecated: false
          }
        }
      ]
    }
    const pages = deserializePages(pageData)
    expect(pages[0].elements).toEqual([
      {
        id: "1",
        name: "article",
        deprecated: false,
        ingredients: [
          {
            id: "1",
            name: "image",
            deprecated: false
          }
        ],
        nestedElements: [
          {
            id: "4",
            name: "text",
            deprecated: false
          }
        ]
      }
    ])
  })
})
