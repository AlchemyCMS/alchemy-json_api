/**
 * Deserializes a JSON:API page document.
 *
 * @deprecated Use `deserialize` instead. `deserializePage` used to strip
 * deprecated elements, but `deprecated` is an admin-only hint and must not
 * alter the serialized output, so this is now only a thin wrapper around
 * `deserialize`.
 */
export declare function deserializePage<T = unknown>(pageData: unknown): T;
/**
 * Deserializes a collection of JSON:API page documents.
 *
 * @deprecated Use `deserialize` instead; see `deserializePage`.
 */
export declare function deserializePages<T = unknown>(pagesData: unknown): T[];
