//#region src/deserialize.ts
var e = ({ type: e, id: t }) => `${e}:${t}`, t = ({ id: e }) => ({ id: e }), n = (t) => new Map(t.map((t) => [e(t), t])), r = (n, r, i) => {
	let o = e(i), s = r.has(o) ? void 0 : n.get(o);
	return s ? a(n, r, s) : t(i);
}, i = (e, t, n) => Array.isArray(n) ? n.map((n) => r(e, t, n)) : n ? r(e, t, n) : null, a = (t, n, r) => {
	let a = new Set(n).add(e(r)), o = Object.entries(r.relationships ?? {}).map(([e, n]) => [e, i(t, a, n?.data ?? null)]);
	return {
		...r.attributes,
		id: r.id,
		...Object.fromEntries(o)
	};
};
function o(e) {
	let { data: t = null, included: r = [] } = e == null ? {} : structuredClone(e), i = n(r), o = (e) => a(i, /* @__PURE__ */ new Set(), e);
	return Array.isArray(t) ? t.map(o) : t ? o(t) : null;
}
//#endregion
export { o as default, o as deserialize };
