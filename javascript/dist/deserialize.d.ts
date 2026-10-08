/** A meta object: free-form, non-standard meta-information. */
export type JsonApiMeta = Record<string, unknown>;
/** A link object (https://jsonapi.org/format/#document-links-link-object). */
export interface JsonApiLinkObject {
    href: string;
    rel?: string;
    describedby?: JsonApiLink;
    title?: string;
    type?: string;
    hreflang?: string | string[];
    meta?: JsonApiMeta;
}
/** A link: a URI-reference, a link object, or `null` if it does not exist. */
export type JsonApiLink = string | JsonApiLinkObject | null;
/**
 * A links object. The members the specification defines are listed; others
 * (from extensions, or implementation-specific ones such as the `current`
 * page link jsonapi.rb emits) are allowed through the index signature.
 */
export interface JsonApiLinks {
    self?: JsonApiLink;
    related?: JsonApiLink;
    describedby?: JsonApiLink;
    first?: JsonApiLink;
    last?: JsonApiLink;
    prev?: JsonApiLink;
    next?: JsonApiLink;
    [name: string]: JsonApiLink | undefined;
}
/** A resource identifier object: `type` and `id` are always strings. */
export interface JsonApiResourceIdentifier {
    type: string;
    id: string;
    meta?: JsonApiMeta;
}
/**
 * Resource linkage: `null` or `[]` when empty, otherwise one identifier
 * (to-one) or an array of them (to-many).
 */
export type JsonApiResourceLinkage = JsonApiResourceIdentifier | JsonApiResourceIdentifier[] | null;
/**
 * A relationship object. The specification requires at least one of `data`,
 * `links` or `meta`, but none of them individually, so `data` is optional: a
 * relationship that only carries links (or that a server leaves empty, e.g.
 * jsonapi-serializer's `lazy_load_data`) has no linkage to resolve.
 */
export interface JsonApiRelationship {
    data?: JsonApiResourceLinkage;
    links?: JsonApiLinks;
    meta?: JsonApiMeta;
}
/** A resource object. */
export interface JsonApiResource extends JsonApiResourceIdentifier {
    attributes?: Record<string, unknown>;
    /**
     * `undefined` values are accepted because a JSON import of an array of
     * resources with differing relationship names is widened by TypeScript to
     * records whose missing names are `undefined`; it never occurs on the wire.
     */
    relationships?: Record<string, JsonApiRelationship | undefined>;
    links?: JsonApiLinks;
}
/**
 * A JSON:API document carrying primary data, which is what `deserialize`
 * turns into plain objects. `data` is a resource object or `null` for
 * single-resource requests, and an array (possibly empty) for collections.
 * Error documents (`errors` instead of `data`) are not deserializable.
 */
export interface JsonApiDocument {
    data: JsonApiResource | JsonApiResource[] | null;
    included?: JsonApiResource[];
    meta?: JsonApiMeta;
    links?: JsonApiLinks;
    jsonapi?: {
        version?: string;
        ext?: string[];
        profile?: string[];
        meta?: JsonApiMeta;
    };
}
/**
 * Deserialize a JSON:API document into plain, acyclic objects.
 *
 * The input is typed as the JSON:API document it is: type the API response
 * as `JsonApiDocument`, and name the shape you expect out via `T`.
 *
 * `T` is deliberately unconstrained. Which shape comes out depends on the
 * endpoint that was called (and whether `data` was an array on the wire),
 * which the type system cannot infer from the document. Those shapes are the
 * caller's documented resource types, so the caller must always pass one;
 * without it, the result is `unknown`.
 *
 * @example
 *   const response: JsonApiDocument = await (await fetch(url)).json()
 *   const page = deserialize<Page>(response)
 */
export declare function deserialize<T>(document: JsonApiDocument): T;
export default deserialize;
