# Changelog

## [5.0.0](https://github.com/AlchemyCMS/alchemy-json_api/compare/package-v4.0.0...package-v5.0.0) (2026-10-08)


### ⚠ BREAKING CHANGES

* **deserialize:** share resources instead of copying them per path ([#220](https://github.com/AlchemyCMS/alchemy-json_api/issues/220))
* **deserialize:** back-references between included resources are now the same object rather than `{ id }` stubs, so the result may contain cycles and is no longer guaranteed to be `JSON.stringify`-safe. structuredClone, devalue and Vue/React state handle cycles. References to the primary `data` resource are still `{ id }` stubs, as before.

### Bug Fixes

* **deserialize:** share resources instead of copying them per path ([8e2d073](https://github.com/AlchemyCMS/alchemy-json_api/commit/8e2d073960f754e8e985a9147f147b01a97e2f11))
* **deserialize:** share resources instead of copying them per path ([#220](https://github.com/AlchemyCMS/alchemy-json_api/issues/220)) ([0af5e01](https://github.com/AlchemyCMS/alchemy-json_api/commit/0af5e0181313f3c080313b6023b0b1eed209711f))

## [4.0.0](https://github.com/AlchemyCMS/alchemy-json_api/compare/package-v3.0.1...package-v4.0.0) (2026-09-01)


### ⚠ BREAKING CHANGES

* `deserializePage`/`deserializePages` no longer filter deprecated content; they are now deprecated aliases for `deserialize` ([#201](https://github.com/AlchemyCMS/alchemy-json_api/issues/201))
* an `exports` map restricts imports to the package root and `./deserialize` ([#202](https://github.com/AlchemyCMS/alchemy-json_api/issues/202))


### Bug Fixes

* **deserialize:** break reference cycles to prevent stack overflow ([#200](https://github.com/AlchemyCMS/alchemy-json_api/issues/200)) ([f7147ae](https://github.com/AlchemyCMS/alchemy-json_api/commit/f7147ae734cc3add4a635911bfed2f193f037a96))


### Code Refactoring

* **ts:** migrate deserializer to TypeScript with typed distribution ([#202](https://github.com/AlchemyCMS/alchemy-json_api/issues/202)) ([3b93397](https://github.com/AlchemyCMS/alchemy-json_api/commit/3b933975783c853f79da8fa4377ed301e8c6ba01))
* stop filtering deprecated content in the deserializer ([#201](https://github.com/AlchemyCMS/alchemy-json_api/issues/201)) ([40b9145](https://github.com/AlchemyCMS/alchemy-json_api/commit/40b9145d85fb7dbf6158d1379f3f05bc06f8bf82))
* move npm package into javascript/ ([#208](https://github.com/AlchemyCMS/alchemy-json_api/issues/208)) ([44fd9a6](https://github.com/AlchemyCMS/alchemy-json_api/commit/44fd9a6418cc204a9ca261ddb9e57ac2d463e2e9))
