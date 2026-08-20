//#region src/deserialize.js
function e(e, n = {}) {
	let r = structuredClone(e);
	n ||= {};
	let i = r.included || [];
	return Array.isArray(r.data) ? r.data.map((e) => t(e, i, !1, n)) : t(r.data, i, !1, n);
}
function t(e, t, r, i) {
	if (t.cached ||= {}, e.type in t.cached || (t.cached[e.type] = {}), r && e.id in t.cached[e.type]) return t.cached[e.type][e.id];
	let a = e.attributes || {};
	if (a.id = e.id, t.cached[e.type][e.id] = a, e.relationships) for (let r of Object.keys(e.relationships)) {
		let o = e.relationships[r];
		if (Array.isArray(o.data)) {
			let e = [];
			o.data.forEach((r) => {
				let a = n(t, r.type, r.id, i);
				e.push(a);
			}), a[r] = e;
		} else a[r] = o && o.data ? n(t, o.data.type, o.data.id, i) : null;
	}
	return a;
}
function n(e, n, r, i) {
	let a = null;
	return e.forEach((o) => {
		o.type === n && o.id === r && (a = t(o, e, !0, i));
	}), a ||= { id: r }, a;
}
//#endregion
export { e as deserialize };
