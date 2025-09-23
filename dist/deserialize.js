function y(e, t = {}) {
  const s = structuredClone(e);
  t || (t = {});
  const o = s.included || [];
  return Array.isArray(s.data) ? s.data.map((i) => f(i, o, !1)) : f(
    s.data,
    o,
    !1
  );
}
function f(e, t, s, o) {
  if (t.cached || (t.cached = {}), e.type in t.cached || (t.cached[e.type] = {}), s && e.id in t.cached[e.type])
    return t.cached[e.type][e.id];
  const r = e.attributes || {};
  if (r.id = e.id, t.cached[e.type][e.id] = r, e.relationships)
    for (const c of Object.keys(e.relationships)) {
      const n = e.relationships[c];
      if (Array.isArray(n.data)) {
        const p = [];
        n.data.forEach((a) => {
          const h = u(
            t,
            a.type,
            a.id
          );
          p.push(h);
        }), r[c] = p;
      } else n && n.data ? r[c] = u(
        t,
        n.data.type,
        n.data.id
      ) : r[c] = null;
    }
  return r;
}
function u(e, t, s, o) {
  let i = null;
  return e.forEach((r) => {
    r.type === t && r.id === s && (i = f(r, e, !0));
  }), i || (i = { id: s }), i;
}
export {
  y as deserialize
};
