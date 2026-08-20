import { deserialize as e } from "./deserialize.js";
//#region src/alchemyApiDeserializer.js
function t(e) {
	let n = [];
	return e.forEach((e) => {
		e.nested_elements?.length > 0 && (e.nested_elements = t(e.nested_elements)), e.nestedElements?.length > 0 && (e.nestedElements = t(e.nestedElements)), e.essences?.length > 0 && (e.essences = e.essences.filter((e) => !e.deprecated)), e.deprecated || n.push(e);
	}), n;
}
function n(n) {
	let r = e(n);
	return r.elements = t(r.elements), r;
}
function r(n) {
	let r = e(n);
	return r.forEach((e) => {
		e.elements = t(e.elements);
	}), r;
}
//#endregion
export { e as deserialize, n as deserializePage, r as deserializePages };
