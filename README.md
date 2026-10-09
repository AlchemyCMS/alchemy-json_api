# Alchemy::JsonApi

[![Test](https://github.com/AlchemyCMS/alchemy-json_api/actions/workflows/ci.yml/badge.svg)](https://github.com/AlchemyCMS/alchemy-json_api/actions/workflows/ci.yml) [![JavaScript](https://github.com/AlchemyCMS/alchemy-json_api/actions/workflows/javascript.yml/badge.svg)](https://github.com/AlchemyCMS/alchemy-json_api/actions/workflows/javascript.yml)

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

A JavaScript/TypeScript deserializer is published as
[`@alchemy_cms/json_api`](https://www.npmjs.com/package/@alchemy_cms/json_api).
See [`javascript/README.md`](javascript/README.md) for installation and usage.

## Usage

### In your Rails app

Mount the engine in your Alchemy Rails app like this:

```rb
# config/routes.rb
mount Alchemy::JsonApi::Engine => "/jsonapi/"
```

> __NOTE__ Pick any path you like. This will be the **prefix** of your API URLs

### TypeScript types

Generate TypeScript types of your elements and page layouts for the deserialized API responses with

```bash
$ bin/rails alchemy:json_api:generate_types
```

This writes them to `app/javascript/types/alchemy.d.ts`. Set `OUTPUT` to write them somewhere else, e.g. into your frontend app:

```bash
$ bin/rails alchemy:json_api:generate_types OUTPUT=../frontend/src/types/alchemy.d.ts
```

Re-run the task whenever you change your `elements.yml` or `page_layouts.yml`.

The types let you narrow pages by their page layout and elements by their name:

```ts
import { deserialize } from "@alchemy_cms/json_api"
import type { AlchemyPage } from "./types/alchemy"

const page = deserialize<AlchemyPage>(data)

if (page.page_layout === "standard") {
  page.elements.forEach((element) => {
    if (element.name === "article") {
      element.ingredients // only the ingredients of the article element, if included
    }
  })
}
```

> [!NOTE]
> Relationships are typed as complete objects. Relationships that are not part of the `include` parameter of your query only contain the `id`. Relationships that are only serialized if included, like the `ingredients` of an element, are `null` otherwise and typed accordingly.

If you add your own ingredient serializers, declare the TypeScript types of their attributes. Undeclared attributes are typed as `unknown`.

```rb
# app/serializers/alchemy/json_api/ingredient_rating_serializer.rb
module Alchemy
  module JsonApi
    class IngredientRatingSerializer < BaseSerializer
      include IngredientSerializer

      attribute :max_stars

      typelize(value: "number | null", max_stars: "number")
    end
  end
end
```

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
