import y from "@ungap/structured-clone";
function A(e, r = {}) {
  const s = y(e);
  r || (r = {});
  const n = s.included || [];
  return Array.isArray(s.data) ? s.data.map((i) => f(i, n, !1)) : f(
    s.data,
    n,
    !1
  );
}
function f(e, r, s, n) {
  if (r.cached || (r.cached = {}), e.type in r.cached || (r.cached[e.type] = {}), s && e.id in r.cached[e.type])
    return r.cached[e.type][e.id];
  const t = e.attributes || {};
  if (t.id = e.id, r.cached[e.type][e.id] = t, e.relationships)
    for (const c of Object.keys(e.relationships)) {
      const o = e.relationships[c];
      if (Array.isArray(o.data)) {
        const p = [];
        o.data.forEach((a) => {
          const h = u(
            r,
            a.type,
            a.id
          );
          p.push(h);
        }), t[c] = p;
      } else o && o.data ? t[c] = u(
        r,
        o.data.type,
        o.data.id
      ) : t[c] = null;
    }
  return t;
}
function u(e, r, s, n) {
  let i = null;
  return e.forEach((t) => {
    t.type === r && t.id === s && (i = f(t, e, !0));
  }), i || (i = { id: s }), i;
}
export {
  A as deserialize
};
