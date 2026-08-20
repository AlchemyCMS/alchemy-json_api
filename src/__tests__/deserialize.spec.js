import { deserialize } from "../deserialize"

describe("deserialize", () => {
  it("Complex serialize", () => {
    const serialized = {
      data: [
        {
          type: "users",
          id: 1,
          attributes: {
            "first-name": "Joe",
            "last-name": "Doe"
          },
          relationships: {
            address: {
              data: {
                type: "addr",
                id: 1
              }
            },
            images: {
              data: [
                { type: "img", id: 1 },
                { type: "img", id: 2 }
              ]
            }
          }
        }
      ],
      included: [
        {
          type: "addr",
          id: 1,
          attributes: {
            street: "Street 1"
          }
        }
      ]
    }

    expect(deserialize(serialized)).toEqual([
      {
        id: 1,
        "first-name": "Joe",
        "last-name": "Doe",
        address: {
          id: 1,
          street: "Street 1"
        },
        images: [{ id: 1 }, { id: 2 }]
      }
    ])
  })

  it("breaks reference cycles into { id } stubs instead of overflowing", () => {
    const serialized = {
      data: {
        type: "product",
        id: "1",
        relationships: {
          primaryTaxon: { data: { type: "taxon", id: "t1" } }
        }
      },
      included: [
        {
          type: "taxon",
          id: "t1",
          attributes: { name: "root" },
          relationships: {
            children: { data: [{ type: "taxon", id: "t2" }] }
          }
        },
        {
          type: "taxon",
          id: "t2",
          attributes: { name: "child" },
          relationships: {
            ancestors: { data: [{ type: "taxon", id: "t1" }] }
          }
        }
      ]
    }

    const result = deserialize(serialized)

    expect(() => JSON.stringify(result)).not.toThrow()
    // t1 -> children -> t2 -> ancestors -> t1 would close a cycle, so the
    // back-reference to the in-progress t1 is emitted as an { id } stub.
    expect(result.primaryTaxon.children[0].ancestors[0]).toEqual({ id: "t1" })
  })
})
