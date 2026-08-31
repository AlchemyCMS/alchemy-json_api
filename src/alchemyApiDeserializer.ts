import { deserialize } from "./deserialize"

const warned = new Set<string>()

// Warn once per function so callers notice the deprecation without spamming the
// console on every call.
function warnDeprecated(name: string): void {
  if (warned.has(name)) return
  warned.add(name)
  console.warn(
    `[@alchemy_cms/json_api] \`${name}\` is deprecated; use \`deserialize\` instead.`
  )
}

/**
 * Deserializes a JSON:API page document.
 *
 * @deprecated Use `deserialize` instead. `deserializePage` used to strip
 * deprecated elements, but `deprecated` is an admin-only hint and must not
 * alter the serialized output, so this is now only a thin wrapper around
 * `deserialize`.
 */
export function deserializePage<T = unknown>(pageData: unknown): T {
  warnDeprecated("deserializePage")
  return deserialize<T>(pageData)
}

/**
 * Deserializes a collection of JSON:API page documents.
 *
 * @deprecated Use `deserialize` instead; see `deserializePage`.
 */
export function deserializePages<T = unknown>(pagesData: unknown): T[] {
  warnDeprecated("deserializePages")
  return deserialize<T[]>(pagesData)
}
