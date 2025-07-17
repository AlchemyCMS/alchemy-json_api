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

This repo provides an NPM package with deserializers to help you convert the response into JS objects.

```js
import { deserializePages } from "@alchemy_cms/json_api"

const response = await fetch("/jsonapi/pages.json")
const data = await response.json()
const pages = deserializePages(data)

console.log(pages[0].name) // => Homepage
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
