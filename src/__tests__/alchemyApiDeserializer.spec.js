import { deserializePage, deserializePages } from "../alchemyApiDeserializer"

describe("deserializePage", () => {
  it("does not return any deprecated elements for single page", () => {
    const pageData = {
      data: {
        type: "page",
        id: "1",
        attributes: {
          name: "Homepage",
        },
        relationships: {
          elements: {
            data: [
              {
                type: "element",
                id: "1",
              },
              {
                type: "element",
                id: "2",
              },
            ],
          },
        },
      },
      included: [
        {
          type: "element",
          id: "1",
          attributes: {
            name: "article",
            deprecated: false,
          },
          relationships: {
            essences: {
              data: [
                {
                  id: "1",
                  type: "essence_text",
                },
                {
                  id: "1",
                  type: "essence_picture",
                },
              ],
            },
            nested_elements: {
              data: [
                {
                  id: "3",
                  type: "element",
                },
                {
                  id: "4",
                  type: "element",
                },
              ],
            },
          },
        },
        {
          type: "element",
          id: "2",
          attributes: {
            name: "old",
            deprecated: true,
          },
          relationships: {
            essences: {
              data: [],
            },
            nested_elements: {
              data: [],
            },
          },
        },
        {
          type: "element",
          id: "3",
          attributes: {
            name: "image",
            deprecated: true,
          },
          relationships: {
            essences: {
              data: [],
            },
            nested_elements: {
              data: [],
            },
          },
        },
        {
          type: "element",
          id: "4",
          attributes: {
            name: "text",
            deprecated: false,
          },
          relationships: {
            essences: {
              data: [],
            },
            nested_elements: {
              data: [],
            },
          },
        },
        {
          type: "essence_text",
          id: "1",
          attributes: {
            name: "text",
            deprecated: true,
          },
        },
        {
          type: "essence_picture",
          id: "1",
          attributes: {
            name: "image",
            deprecated: false,
          },
        },
      ],
    }
    const page = deserializePage(pageData)
    expect(page.elements).toEqual([
      {
        id: "1",
        name: "article",
        deprecated: false,
        essences: [
          {
            id: "1",
            name: "image",
            deprecated: false,
          },
        ],
        nested_elements: [
          {
            id: "4",
            name: "text",
            deprecated: false,
            essences: [],
            nested_elements: [],
          },
        ],
      },
    ])
  })

  it("does not return any deprecated elements for pages", () => {
    const pageData = {
      data: [
        {
          type: "page",
          id: "1",
          attributes: {
            name: "Homepage",
          },
          relationships: {
            elements: {
              data: [
                {
                  type: "element",
                  id: "1",
                },
                {
                  type: "element",
                  id: "2",
                },
              ],
            },
          },
        },
      ],
      included: [
        {
          type: "element",
          id: "1",
          attributes: {
            name: "article",
            deprecated: false,
          },
          relationships: {
            essences: {
              data: [
                {
                  id: "1",
                  type: "essence_text",
                },
                {
                  id: "1",
                  type: "essence_picture",
                },
              ],
            },
            nested_elements: {
              data: [
                {
                  id: "3",
                  type: "element",
                },
                {
                  id: "4",
                  type: "element",
                },
              ],
            },
          },
        },
        {
          type: "element",
          id: "2",
          attributes: {
            name: "old",
            deprecated: true,
          },
          relationships: {
            essences: {
              data: [],
            },
            nested_elements: {
              data: [],
            },
          },
        },
        {
          type: "element",
          id: "3",
          attributes: {
            name: "image",
            deprecated: true,
          },
          relationships: {
            essences: {
              data: [],
            },
            nested_elements: {
              data: [],
            },
          },
        },
        {
          type: "element",
          id: "4",
          attributes: {
            name: "text",
            deprecated: false,
          },
          relationships: {
            essences: {
              data: [],
            },
            nested_elements: {
              data: [],
            },
          },
        },
        {
          type: "essence_text",
          id: "1",
          attributes: {
            name: "text",
            deprecated: true,
          },
        },
        {
          type: "essence_picture",
          id: "1",
          attributes: {
            name: "image",
            deprecated: false,
          },
        },
      ],
    }
    const pages = deserializePages(pageData)
    expect(pages[0].elements).toEqual([
      {
        id: "1",
        name: "article",
        deprecated: false,
        essences: [
          {
            id: "1",
            name: "image",
            deprecated: false,
          },
        ],
        nested_elements: [
          {
            id: "4",
            name: "text",
            deprecated: false,
            essences: [],
            nested_elements: [],
          },
        ],
      },
    ])
  })
})
