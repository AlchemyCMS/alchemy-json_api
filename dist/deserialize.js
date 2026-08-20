//#region src/deserialize.js
function e({ type: e, id: t }) {
	return `${e}:${t}`;
}
function t({ id: e }) {
	return { id: e };
}
function n(t) {
	let n = /* @__PURE__ */ new Map();
	for (let r of t) {
		let t = e(r);
		n.has(t) || n.set(t, r);
	}
	return n;
}
function r(n, r, i) {
	let o = e(i), s = r.has(o) ? void 0 : n.get(o);
	return s ? a(n, r, s) : t(i);
}
function i(e, t, n) {
	return Array.isArray(n) ? n.map((n) => r(e, t, n)) : n ? r(e, t, n) : null;
}
function a(t, n, r) {
	let a = new Set(n).add(e(r)), o = Object.entries(r.relationships ?? {}).map(([e, n]) => [e, i(t, a, n?.data ?? null)]);
	return {
		...r.attributes,
		id: r.id,
		...Object.fromEntries(o)
	};
}
function o(e) {
	let { data: t = null, included: r = [] } = e == null ? {} : structuredClone(e), i = n(r), o = (e) => a(i, /* @__PURE__ */ new Set(), e);
	return Array.isArray(t) ? t.map(o) : t ? o(t) : null;
}
//#endregion
export { o as deserialize };
