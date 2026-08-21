/**
 * Deserialize a JSON:API document into plain, acyclic objects.
 *
 * The `document` is a raw API response with no compile-time shape, so the
 * parameter is `unknown`. The caller names the shape it expects out via `T`.
 *
 * By default resources are resolved once and shared by reference (compact and
 * fast). Pass `{ expand: true }` to fully expand every reference path instead —
 * faithful per path, but far more expensive on densely cross-linked documents.
 *
 * @example
 *   const product = deserialize<Product>(apiResponse)
 */
export declare function deserialize<T = unknown>(document: unknown, options?: {
    expand?: boolean;
}): T;
export default deserialize;
