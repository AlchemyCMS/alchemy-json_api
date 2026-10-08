import { describe, expectTypeOf, it } from "vitest"

import {
  deserialize,
  type JsonApiDocument,
  type JsonApiRelationship
} from "../deserialize"
import { deserializePage, deserializePages } from "../alchemyApiDeserializer"

// Type-level specs for the public signature. `pnpm typecheck` compiles this
// file; the runtime assertions are no-ops.

interface Page {
  id: string
  name: string
}

const document: JsonApiDocument = {
  data: { type: "page", id: "1", attributes: { name: "Homepage" } }
}

describe("deserialize types", () => {
  it("returns the type the caller names", () => {
    expectTypeOf(deserialize<Page>(document)).toEqualTypeOf<Page>()
    expectTypeOf(deserialize<Page[]>(document)).toEqualTypeOf<Page[]>()
  })

  it("returns unknown when no type is named", () => {
    expectTypeOf(deserialize(document)).toBeUnknown()
  })

  it("accepts only JSON:API documents", () => {
    expectTypeOf(deserialize<Page>)
      .parameter(0)
      .toEqualTypeOf<JsonApiDocument>()

    // @ts-expect-error -- not a JSON:API document
    deserialize<Page>({ name: "Homepage" })
    // @ts-expect-error -- `id` must be a string
    deserialize<Page>({ data: { type: "page", id: 1 } })
    // @ts-expect-error -- error documents have no primary data
    deserialize<Page>({ errors: [{ status: "404" }] })
  })

  it("accepts the document variants the specification allows", () => {
    deserialize<null>({ data: null })
    deserialize<Page[]>({ data: [] })
    deserialize<Page>({
      jsonapi: { version: "1.1" },
      links: {
        self: "/jsonapi/pages/1",
        related: { href: "/jsonapi/pages/1/elements", meta: { count: 2 } },
        // implementation-defined pagination link, as emitted by jsonapi.rb
        current: "/jsonapi/pages?page[number]=1",
        next: null
      },
      meta: { total: 1 },
      data: {
        type: "page",
        id: "1",
        links: { self: "/jsonapi/pages/1" },
        meta: { cached: true },
        relationships: {
          // linkage-less relationship: links only
          children: { links: { related: "/jsonapi/pages/1/children" } },
          // empty relationship object (`lazy_load_data` when not included)
          ancestors: {},
          language: {
            data: { type: "language", id: "1", meta: { default: true } }
          },
          elements: { data: [] },
          parent: { data: null }
        }
      },
      included: [{ type: "language", id: "1" }]
    })
  })

  it("lets a relationship carry only links or meta", () => {
    expectTypeOf<{
      links: { related: string }
    }>().toExtend<JsonApiRelationship>()
    expectTypeOf<{ meta: { count: number } }>().toExtend<JsonApiRelationship>()
  })

  it("types the deprecated aliases the same way", () => {
    expectTypeOf(deserializePage<Page>(document)).toEqualTypeOf<Page>()
    expectTypeOf(deserializePages<Page>(document)).toEqualTypeOf<Page[]>()
  })
})
