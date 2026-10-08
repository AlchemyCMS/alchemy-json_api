//#region src/deserialize.ts
var e = ({ type: e, id: t }) => `${e}:${t}`, t = ({ id: e }) => ({ id: e }), n = (t) => new Map(t.map((t) => [e(t), t])), r = (n, r, i) => {
	let o = n.get(e(i));
	return o ? a(n, r, o) : t(i);
}, i = (e, t, n) => Array.isArray(n) ? n.map((n) => r(e, t, n)) : n ? r(e, t, n) : null, a = (t, n, r) => {
	let a = e(r), o = n.get(a);
	if (o) return o;
	let s = {
		...r.attributes,
		id: r.id
	};
	n.set(a, s);
	for (let [e, a] of Object.entries(r.relationships ?? {})) s[e] = i(t, n, a?.data ?? null);
	return s;
};
function o(e) {
	let { data: t = null, included: r = [] } = e == null ? {} : structuredClone(e), i = n(r), o = /* @__PURE__ */ new Map(), s = (e) => a(i, o, e);
	return Array.isArray(t) ? t.map(s) : t ? s(t) : null;
}
//#endregion
export { o as default, o as deserialize };
