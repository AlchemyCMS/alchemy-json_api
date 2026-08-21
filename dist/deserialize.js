//#region src/deserialize.ts
var e = ({ type: e, id: t }) => `${e}:${t}`, t = ({ id: e }) => ({ id: e }), n = (t) => new Map(t.map((t) => [e(t), t])), r = (n, r, i, o) => {
	let s = e(o);
	if (i.has(s)) return t(o);
	let c = r.get(s);
	if (c) return c;
	let l = n.get(s);
	return l ? a(n, r, i, l) : t(o);
}, i = (e, t, n, i) => Array.isArray(i) ? i.map((i) => r(e, t, n, i)) : i ? r(e, t, n, i) : null, a = (t, n, r, a) => {
	let o = e(a), s = n.get(o);
	if (s) return s;
	r.add(o);
	let c = {
		...a.attributes,
		id: a.id
	};
	for (let [e, o] of Object.entries(a.relationships ?? {})) c[e] = i(t, n, r, o?.data ?? null);
	return r.delete(o), n.set(o, c), c;
}, o = (n, r, i) => {
	let a = e(i), o = r.has(a) ? void 0 : n.get(a);
	return o ? c(n, r, o) : t(i);
}, s = (e, t, n) => Array.isArray(n) ? n.map((n) => o(e, t, n)) : n ? o(e, t, n) : null, c = (t, n, r) => {
	let i = new Set(n).add(e(r)), a = Object.entries(r.relationships ?? {}).map(([e, n]) => [e, s(t, i, n?.data ?? null)]);
	return {
		...r.attributes,
		id: r.id,
		...Object.fromEntries(a)
	};
};
function l(e, t = {}) {
	let { data: r = null, included: i = [] } = e == null ? {} : structuredClone(e), o = n(i), s;
	if (t.expand) s = (e) => c(o, /* @__PURE__ */ new Set(), e);
	else {
		let e = /* @__PURE__ */ new Map(), t = /* @__PURE__ */ new Set();
		s = (n) => a(o, e, t, n);
	}
	return Array.isArray(r) ? r.map(s) : r ? s(r) : null;
}
//#endregion
export { l as default, l as deserialize };
