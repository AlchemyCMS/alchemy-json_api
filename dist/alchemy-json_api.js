import { deserialize as d } from "./deserialize.js";
function n(t) {
  const s = [];
  return t.forEach((e) => {
    var r, i, c;
    ((r = e.nested_elements) == null ? void 0 : r.length) > 0 && (e.nested_elements = n(
      e.nested_elements
    )), ((i = e.nestedElements) == null ? void 0 : i.length) > 0 && (e.nestedElements = n(e.nestedElements)), ((c = e.essences) == null ? void 0 : c.length) > 0 && (e.essences = e.essences.filter((f) => !f.deprecated)), e.deprecated || s.push(e);
  }), s;
}
function o(t) {
  const s = d(t);
  return s.elements = n(s.elements), s;
}
function l(t) {
  const s = d(t);
  return s.forEach((e) => {
    e.elements = n(e.elements);
  }), s;
}
export {
  d as deserialize,
  o as deserializePage,
  l as deserializePages
};
