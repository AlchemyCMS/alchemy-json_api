import { deserialize as e } from "./deserialize.js";
//#region src/alchemyApiDeserializer.js
var t = /* @__PURE__ */ new Set();
function n(e) {
	t.has(e) || (t.add(e), console.warn(`[@alchemy_cms/json_api] \`${e}\` is deprecated; use \`deserialize\` instead.`));
}
function r(t) {
	return n("deserializePage"), e(t);
}
function i(t) {
	return n("deserializePages"), e(t);
}
//#endregion
export { e as deserialize, r as deserializePage, i as deserializePages };
