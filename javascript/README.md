# @alchemy_cms/json_api

The JavaScript/TypeScript deserializer for [AlchemyCMS](https://github.com/AlchemyCMS/alchemy_cms)'s JSON:API.

## Installation

```bash
npm install @alchemy_cms/json_api --save
```

or with the package manager of your choice.

## Usage

`deserialize` converts a JSON:API response into plain, acyclic JS objects:
each resource's attributes are flattened with its `id`, and relationships
present in `included` become nested objects (absent ones become `{ id }`
stubs). Reference cycles are broken automatically, so the result is always
safe to `JSON.stringify`.

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
