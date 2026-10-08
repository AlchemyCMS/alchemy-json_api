# @alchemy_cms/json_api

The JavaScript/TypeScript deserializer for [AlchemyCMS](https://github.com/AlchemyCMS/alchemy_cms)'s JSON:API.

## Installation

```bash
npm install @alchemy_cms/json_api --save
```

or with the package manager of your choice.

## Usage

`deserialize` converts a JSON:API response into plain JS objects: each
resource's attributes are flattened with its `id`, and relationships present in
`included` become nested objects (absent ones become `{ id }` stubs).

Each included resource is materialized **once** and shared by every reference
to it, so the result stays proportional to the size of the response even when
resources reference each other heavily. A consequence is that back-references
(e.g. a menu node's `parent`, which lists the node among its `children`) are
real references, and the result may contain **cycles**:

- `structuredClone`, [devalue](https://github.com/sveltejs/devalue) (Nuxt
  payloads) and Vue/React state handle this fine.
- `JSON.stringify` does not. If you need JSON, serialize a projection of the
  fields you need, or use a cycle-aware serializer.
- Mutating a resource is visible everywhere it is referenced. Copy before
  mutating.

```js
import { deserialize } from "@alchemy_cms/json_api"

const response = await fetch("/jsonapi/pages/homepage.json")
const page = deserialize(await response.json())

console.log(page.name) // => "Homepage"
```

`deserializePage` and `deserializePages` still exist as thin, **deprecated**
aliases for `deserialize`; prefer `deserialize`.

## Contributing

This package lives in the [`javascript/`](https://github.com/AlchemyCMS/alchemy-json_api/tree/main/javascript)
directory of the `alchemy-json_api` monorepo. Releases are automated with
release-please and tagged `package-vX.Y.Z`.
