import { describe, it, expect } from "vitest"

import { deserialize } from "../deserialize"

describe("deserialize", () => {
  it("flattens attributes and injects id for a single resource", () => {
    const doc = {
      data: {
        type: "product",
        id: "1",
        attributes: { name: "Smoke Element", stars: 4.8 }
      }
    }

    expect(deserialize(doc)).toEqual({
      id: "1",
      name: "Smoke Element",
      stars: 4.8
    })
  })

  it("returns an array when data is an array", () => {
    const doc = {
      data: [
        { type: "product", id: "1", attributes: { name: "A" } },
        { type: "product", id: "2", attributes: { name: "B" } }
      ]
    }

    expect(deserialize(doc)).toEqual([
      { id: "1", name: "A" },
      { id: "2", name: "B" }
    ])
  })

  it("returns null when data is null", () => {
    expect(deserialize({ data: null })).toBeNull()
  })

  it("resolves a to-one relationship from included", () => {
    const doc = {
      data: {
        type: "product",
        id: "1",
        attributes: { name: "Product" },
        relationships: { fragrance: { data: { type: "fragrance", id: "9" } } }
      },
      included: [
        { type: "fragrance", id: "9", attributes: { name: "Vanilla" } }
      ]
    }

    expect(deserialize(doc)).toEqual({
      id: "1",
      name: "Product",
      fragrance: { id: "9", name: "Vanilla" }
    })
  })

  it("resolves a to-many relationship from included", () => {
    const doc = {
      data: {
        type: "product",
        id: "1",
        attributes: {},
        relationships: {
          variants: {
            data: [
              { type: "variant", id: "10" },
              { type: "variant", id: "11" }
            ]
          }
        }
      },
      included: [
        { type: "variant", id: "10", attributes: { sku: "A" } },
        { type: "variant", id: "11", attributes: { sku: "B" } }
      ]
    }

    expect(deserialize<{ variants: unknown[] }>(doc).variants).toEqual([
      { id: "10", sku: "A" },
      { id: "11", sku: "B" }
    ])
  })

  it("emits an { id } stub when a relationship target is not in included", () => {
    const doc = {
      data: {
        type: "product",
        id: "1",
        attributes: {},
        relationships: {
          replacementProduct: { data: { type: "product", id: "99" } }
        }
      },
      included: []
    }

    expect(deserialize<{ replacementProduct: unknown }>(doc)).toEqual({
      id: "1",
      replacementProduct: { id: "99" }
    })
  })

  it("sets a null relationship to null", () => {
    const doc = {
      data: {
        type: "product",
        id: "1",
        attributes: {},
        relationships: { fragrance: { data: null } }
      }
    }

    expect(deserialize<{ fragrance: unknown }>(doc).fragrance).toBeNull()
  })

  // Carried over from the original JS suite: numeric ids are preserved, and a
  // to-many whose targets are absent from `included` becomes an array of
  // `{ id }` stubs (alongside an expanded to-one).
  it("preserves numeric ids and stubs absent to-many targets", () => {
    const doc = {
      data: [
        {
          type: "users",
          id: 1,
          attributes: { "first-name": "Joe", "last-name": "Doe" },
          relationships: {
            address: { data: { type: "addr", id: 1 } },
            images: {
              data: [
                { type: "img", id: 1 },
                { type: "img", id: 2 }
              ]
            }
          }
        }
      ],
      included: [{ type: "addr", id: 1, attributes: { street: "Street 1" } }]
    }

    expect(deserialize(doc)).toEqual([
      {
        id: 1,
        "first-name": "Joe",
        "last-name": "Doe",
        address: { id: 1, street: "Street 1" },
        images: [{ id: 1 }, { id: 2 }]
      }
    ])
  })

  describe("cycles and shared references", () => {
    // Models the real taxonomy shape: a root taxon whose children each point
    // back to it via `ancestors`, which closes a cycle.
    const buildTaxonomyDoc = () => ({
      data: {
        type: "product",
        id: "1987",
        attributes: { name: "Smoke Element" },
        relationships: {
          primaryTaxon: { data: { type: "taxon", id: "child" } }
        }
      },
      included: [
        {
          type: "taxon",
          id: "child",
          attributes: { name: "BlendingElements", urlPath: "/be/" },
          relationships: {
            ancestors: { data: [{ type: "taxon", id: "root" }] }
          }
        },
        {
          type: "taxon",
          id: "root",
          attributes: { name: "Storefront", urlPath: null },
          relationships: {
            // The back-edge: root lists the child (and itself) as children.
            children: {
              data: [
                { type: "taxon", id: "child" },
                { type: "taxon", id: "root" }
              ]
            }
          }
        }
      ]
    })

    it("terminates on cyclic documents and yields a graph structuredClone can copy", () => {
      const result = deserialize(buildTaxonomyDoc())
      expect(() => structuredClone(result)).not.toThrow()
    })

    it("preserves ancestor names and urlPaths used by breadcrumbs", () => {
      const result = deserialize<{
        primaryTaxon: {
          name: string
          ancestors: { name: string; urlPath: string | null }[]
        }
      }>(buildTaxonomyDoc())

      expect(result.primaryTaxon.name).toBe("BlendingElements")
      const ancestors = result.primaryTaxon.ancestors
      expect(ancestors).toHaveLength(1)
      expect(ancestors[0]!.name).toBe("Storefront")
      expect(ancestors[0]!.urlPath).toBeNull()
    })

    it("resolves back-references to the same shared object", () => {
      type Taxon = { id: string; children?: Taxon[]; ancestors?: Taxon[] }
      const result = deserialize<{ primaryTaxon: Taxon }>(buildTaxonomyDoc())

      const child = result.primaryTaxon
      const root = child.ancestors![0]!
      // root.children lists the child and root itself; both are the very
      // objects already reachable from the product, not copies or stubs.
      expect(root.children![0]).toBe(child)
      expect(root.children![1]).toBe(root)
    })

    it("materializes a resource referenced from many places only once", () => {
      // Two pages whose page ingredients link to the same page.
      const doc = {
        data: [
          {
            type: "ingredient",
            id: "1",
            relationships: { page: { data: { type: "page", id: "9" } } }
          },
          {
            type: "ingredient",
            id: "2",
            relationships: { page: { data: { type: "page", id: "9" } } }
          }
        ],
        included: [{ type: "page", id: "9", attributes: { name: "About us" } }]
      }

      const [a, b] = deserialize<{ page: unknown }[]>(doc)
      expect(a!.page).toEqual({ id: "9", name: "About us" })
      expect(a!.page).toBe(b!.page)
    })

    it("stubs references back to the primary resource, which is not in included", () => {
      // A -> B -> A chain, where A is the primary `data`.
      const doc = {
        data: {
          type: "node",
          id: "A",
          attributes: {},
          relationships: { next: { data: { type: "node", id: "B" } } }
        },
        included: [
          {
            type: "node",
            id: "B",
            attributes: {},
            relationships: { next: { data: { type: "node", id: "A" } } }
          }
        ]
      }

      const result = deserialize<{ next: { next: unknown } }>(doc)
      expect(() => JSON.stringify(result)).not.toThrow()
      // Only `included` is resolvable, so B.next is a stub for A.
      expect(result.next.next).toEqual({ id: "A" })
    })
  })

  describe("output size", () => {
    // Count distinct objects reachable from the result.
    const countObjects = (root: unknown): number => {
      const seen = new Set<object>()
      const stack = [root]
      while (stack.length) {
        const value = stack.pop()
        if (value === null || typeof value !== "object" || seen.has(value))
          continue
        seen.add(value)
        stack.push(...Object.values(value))
      }
      return seen.size
    }

    // A menu tree: `depth` levels of `branching` nodes, each listing its
    // `children` and pointing back at its `parent`, all of them included.
    // Resolving it per path (as 4.0.0 did) re-expands every subtree through
    // each node's parent, which grows exponentially with the depth.
    const menu = (depth: number, branching: number) => {
      const included: {
        type: string
        id: string
        attributes: { name: string }
        relationships: {
          parent: { data: { type: string; id: string } | null }
          children: { data: { type: string; id: string }[] }
        }
      }[] = []
      const build = (parent: string | null, level: number): string => {
        const id = String(included.length + 1)
        const node = {
          type: "node",
          id,
          attributes: { name: `Node ${id}` },
          relationships: {
            parent: { data: parent ? { type: "node", id: parent } : null },
            children: { data: [] as { type: string; id: string }[] }
          }
        }
        included.push(node)
        if (level < depth) {
          for (let i = 0; i < branching; i++) {
            node.relationships.children.data.push({
              type: "node",
              id: build(id, level + 1)
            })
          }
        }
        return id
      }
      const root = build(null, 0)
      return {
        data: {
          type: "language",
          id: "en",
          relationships: { menus: { data: [{ type: "node", id: root }] } }
        },
        included
      }
    }

    it("is linear in the number of resources for cyclic trees", () => {
      // 1 + 5 + 25 + 125 = 156 nodes; 4.0.0 materialized 73k objects here.
      const document = menu(3, 5)
      const result = deserialize(document)

      // language + menus array + per node: node and children array.
      expect(countObjects(result)).toBe(2 + document.included.length * 2)
    })

    it("shares parent and children references", () => {
      type MenuNode = { parent: MenuNode | null; children: MenuNode[] }
      const result = deserialize<{ menus: MenuNode[] }>(menu(2, 2))
      const root = result.menus[0]!
      const child = root.children[0]!

      expect(root.parent).toBeNull()
      expect(child.parent).toBe(root)
      expect(child.children[0]!.parent).toBe(child)
    })
  })

  it("shares no mutation with the input document", () => {
    const doc = {
      data: { type: "product", id: "1", attributes: { name: "Original" } }
    }
    const result = deserialize<{ name: string }>(doc)
    result.name = "Mutated"
    expect(
      doc.data && !Array.isArray(doc.data) && doc.data.attributes?.name
    ).toBe("Original")
  })

  describe("end-to-end: a real product document (api /products/2333)", () => {
    // A trimmed-but-faithful slice of the live JSON:API response for product
    // 2333 ("Gatsby Reed Diffuser Bottle"), using the real ids, names and
    // shapes returned by api.candlescience.com. It exercises every case the PDP
    // relies on:
    //   - flattened attributes + injected id
    //   - null to-one relationships (fragrance, replacementProduct are null)
    //   - a to-many relationship (variants) whose member has its own to-many
    //     (optionValues) and a `product` back-edge to `data` -> stub
    //   - a real 4-level taxon ancestor chain (primaryTaxon -> ancestors)
    const document = {
      data: {
        type: "product",
        id: "2333",
        attributes: {
          name: "Gatsby Reed Diffuser Bottle",
          urlPath: "/reed-diffusers/gatsby-reed-diffuser-bottle/",
          stars: 5,
          unitOfSale: "pc"
        },
        relationships: {
          fragrance: { data: null },
          replacementProduct: { data: null },
          variants: { data: [{ type: "variant", id: "9945" }] },
          primaryTaxon: { data: { type: "taxon", id: "376" } }
        }
      },
      included: [
        {
          type: "variant",
          id: "9945",
          attributes: {
            sku: "93492",
            optionsText: "12 pc Case, Champagne Luster",
            inStock: true
          },
          relationships: {
            optionValues: {
              data: [
                { type: "optionValue", id: "8" },
                { type: "optionValue", id: "96" }
              ]
            },
            // Points back at the product that owns this variant.
            product: { data: { type: "product", id: "2333" } }
          }
        },
        {
          type: "optionValue",
          id: "8",
          attributes: { name: "case", presentation: "Case", position: 9 }
        },
        {
          type: "optionValue",
          id: "96",
          attributes: {
            name: "champagne luster",
            presentation: "Champagne Luster",
            position: 25
          }
        },
        // primaryTaxon (376) -> ancestors [204 Storefront, 411 Flameless, 248 Reed Diffusers]
        {
          type: "taxon",
          id: "376",
          attributes: { name: "Diffuser Bottles" },
          relationships: {
            ancestors: {
              data: [
                { type: "taxon", id: "204" },
                { type: "taxon", id: "411" },
                { type: "taxon", id: "248" }
              ]
            }
          }
        },
        {
          type: "taxon",
          id: "204",
          attributes: { name: "Storefront", urlPath: null }
        },
        {
          type: "taxon",
          id: "411",
          attributes: { name: "Flameless", urlPath: "/flameless-supplies/" }
        },
        {
          type: "taxon",
          id: "248",
          attributes: { name: "Reed Diffusers", urlPath: "/reed-diffusers/" }
        }
      ]
    }

    it("deserializes to the exact expected object graph", () => {
      const result = deserialize(document)

      expect(result).toEqual({
        id: "2333",
        name: "Gatsby Reed Diffuser Bottle",
        urlPath: "/reed-diffusers/gatsby-reed-diffuser-bottle/",
        stars: 5,
        unitOfSale: "pc",
        // null relationships stay null
        fragrance: null,
        replacementProduct: null,
        // to-many, expanded; the member keeps its own relationships
        variants: [
          {
            id: "9945",
            sku: "93492",
            optionsText: "12 pc Case, Champagne Luster",
            inStock: true,
            optionValues: [
              { id: "8", name: "case", presentation: "Case", position: 9 },
              {
                id: "96",
                name: "champagne luster",
                presentation: "Champagne Luster",
                position: 25
              }
            ],
            // variant.product points back to the primary product, which is
            // `data` rather than `included`, so it resolves as an { id } stub.
            product: { id: "2333" }
          }
        ],
        // real 4-level taxon breadcrumb chain, fully expanded
        primaryTaxon: {
          id: "376",
          name: "Diffuser Bottles",
          ancestors: [
            { id: "204", name: "Storefront", urlPath: null },
            { id: "411", name: "Flameless", urlPath: "/flameless-supplies/" },
            { id: "248", name: "Reed Diffusers", urlPath: "/reed-diffusers/" }
          ]
        }
      })
    })

    it("is JSON-serializable, as its only back-edge targets `data`", () => {
      expect(() => JSON.stringify(deserialize(document))).not.toThrow()
    })
  })
})
