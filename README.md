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

## Key transforms

If you ever want to change how Alchemy serializes attributes you can set

```rb
Alchemy::JsonApi.key_transform = :camel_lower
```

It defaults to `:underscore`.

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [BSD-3-Clause license](https://opensource.org/licenses/BSD-3-Clause).
