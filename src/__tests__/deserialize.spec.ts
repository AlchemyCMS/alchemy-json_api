import { deserialize } from "../deserialize"
import { describe, it, expect } from "vitest"

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

    expect(deserialize(serialized as any)).toEqual([
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
})
