# Alchemy::JsonApi

A JSON-API based API for AlchemyCMS

## Installation

### In your Alchemy Rails project

Add this line to your application's Gemfile:

```ruby
gem 'alchemy-json_api'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install alchemy-json_api
```

### In your JS/Frontend app

Run this in your application:

```
npm install @alchemy_cms/json_api --save
```

or with the package manager of your choice

## Usage

### In your Rails app

Mount the engine in your Alchemy Rails app like this:

```rb
# config/routes.rb
mount Alchemy::JsonApi::Engine => "/jsonapi/"
```

> __NOTE__ Pick any path you like. This will be the **prefix** of your API URLs

### In your frontend app

This repo provides an NPM package with a `deserialize` function that converts a JSON:API response into plain JS objects.

```js
import { deserialize } from "@alchemy_cms/json_api"

const response = await fetch("/jsonapi/pages/homepage.json")
const page = deserialize(await response.json())

console.log(page.name) // => Homepage
console.log(page.elements[0].ingredients) // relationships are resolved inline
```

`deserialize` flattens each resource's `attributes` onto the returned object (injecting its `id`, dropping `type`) and resolves every relationship inline: a related resource present in the response's `included` becomes a nested object, and one that is absent becomes an `{ id }` stub you can use to fetch it later.

> [!NOTE]
> `deserializePage` and `deserializePages` still exist as thin, **deprecated** aliases for `deserialize`. Prefer `deserialize`.

#### Reference resolution (acyclic by design)

JSON:API graphs are routinely cyclic: a taxon's `children` link back through `ancestors`, a variant points at its `product` which lists that same `variant`, a navigation node references both its `parent` and its `children`. Resolved naively this yields a **circular** object graph — one that cannot be passed to `JSON.stringify` and overflows the stack (`RangeError: Maximum call stack size exceeded`) when walked recursively.

`deserialize` always returns an **acyclic** graph, using the classic depth-first three-colour marking to decide what to do with each reference:

- **grey** — a resource currently being resolved (on the resolution stack). A reference to it is a _back-edge_ that would close a cycle, so it is emitted as an `{ id }` stub.
- **black** — a resource already fully resolved. It is memoised and shared by reference; because a finished resource can never be one of your ancestors, reusing it can never reintroduce a cycle.
- **white** — a resource not yet seen; it is resolved on first encounter.

So **each resource is resolved once and shared by reference**: cost scales with the number of resources, not the number of paths that reach them, and the result is always safe to serialize. Every resource is fully expanded at its first-resolved location; elsewhere it appears as the same object, or as an `{ id }` stub at a reference that would have closed a cycle.

> [!TIP]
> Pass `{ expand: true }` to fully expand every reference path instead — a resource reached through several paths is materialised in full at each one:
>
> ```js
> const page = deserialize(response, { expand: true })
> ```
>
> This is faithful per path but re-expands shared subtrees, so on densely cross-linked documents (large menus, product graphs) the output can grow by orders of magnitude. Reach for it only when a consumer needs a fully-expanded object at every path.

## HTTP Caching

Alchemy::JsonApi allows for caching API responses. It respects the caching configuration of your Rails app and of your Alchemy configuration and settings in the pages page layout configuration. Restricted pages are never cached.

By default it sets the `max-age` `Cache-Control` header to 10 minutes (`600` seconds). You can change this by configuring the `Alchemy::JsonApi.page_cache_max_age` setting. It is recommended to set this via an environment variable like this:

```rb
# config/initializers/alchemy_json_api.rb
Alchemy::JsonApi.page_cache_max_age = ENV.fetch("ALCHEMY_JSON_API_CACHE_DURATION", 600).to_i
```

### Edge Caching

Alchemy sets the `must-revalidate` directive if caching is enabled. If your CDN supports it, you can change that to use the much more efficient `stale-while-revalidate` directive by changing the `Alchemy::JsonApi.page_caching_options` setting to any integer value.

```rb
# config/initializers/alchemy_json_api.rb
Alchemy::JsonApi.page_caching_options = {
  stale_while_revalidate: ENV.fetch("ALCHEMY_JSON_API_CACHE_STALE_WHILE_REVALIDATE", 60).to_i
}
```

> [!TIP]
> You can set any caching option that [`ActionController::ConditionalGet#expires_in` supports](https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-expires_in), like `stale_if_error`, `public` or `immutable`.

## Key transforms

If you ever want to change how Alchemy serializes attributes you can set

```rb
# config/initializers/alchemy_json_api.rb
Alchemy::JsonApi.key_transform = :camel_lower
```

It defaults to `:underscore`.

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [BSD-3-Clause license](https://opensource.org/licenses/BSD-3-Clause).
