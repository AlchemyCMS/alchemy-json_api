/**
 * Deserialize a JSON:API document into plain, acyclic objects.
 *
 * The `document` is a raw API response with no compile-time shape, so the
 * parameter is `unknown`. The caller names the shape it expects out via `T`;
 * this function is the boundary that turns the untyped response into it.
 *
 * @example
 *   const product = deserialize<Product>(apiResponse)
 */
export declare function deserialize<T = unknown>(document: unknown): T;
export default deserialize;
