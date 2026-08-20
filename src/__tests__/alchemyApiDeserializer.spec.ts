import { deserializePage, deserializePages } from "../alchemyApiDeserializer"

describe("deserializePage", () => {
  it("returns all elements, including deprecated ones and their nested elements", () => {
    const pageData = {
      data: {
        type: "page",
        id: "1",
        attributes: {
          name: "Homepage"
        },
        relationships: {
          elements: {
            data: [
              { type: "element", id: "1" },
              { type: "element", id: "2" }
            ]
          }
        }
      },
      included: [
        {
          type: "element",
          id: "1",
          attributes: {
            name: "article",
            deprecated: false
          },
          relationships: {
            nested_elements: {
              data: [
                { type: "element", id: "3" },
                { type: "element", id: "4" }
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
        }
      ]
    }

    expect(deserializePage(pageData)).toEqual({
      id: "1",
      name: "Homepage",
      elements: [
        {
          id: "1",
          name: "article",
          deprecated: false,
          nested_elements: [
            { id: "3", name: "image", deprecated: true },
            { id: "4", name: "text", deprecated: false }
          ]
        },
        {
          id: "2",
          name: "old",
          deprecated: true
        }
      ]
    })
  })
})

describe("deserializePages", () => {
  it("returns all elements, including deprecated ones", () => {
    const pagesData = {
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
                { type: "element", id: "1" },
                { type: "element", id: "2" }
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
          relationships: {}
        },
        {
          type: "element",
          id: "2",
          attributes: {
            name: "old",
            deprecated: true
          },
          relationships: {}
        }
      ]
    }

    expect(deserializePages(pagesData)).toEqual([
      {
        id: "1",
        name: "Homepage",
        elements: [
          { id: "1", name: "article", deprecated: false },
          { id: "2", name: "old", deprecated: true }
        ]
      }
    ])
  })
})
