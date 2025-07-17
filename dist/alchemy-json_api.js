import { deserialize as r } from "./deserialize.js";
function n(t) {
  const s = [];
  return t.forEach((e) => {
    e.nested_elements?.length > 0 && (e.nested_elements = n(
      e.nested_elements
    )), e.nestedElements?.length > 0 && (e.nestedElements = n(e.nestedElements)), e.essences?.length > 0 && (e.essences = e.essences.filter((i) => !i.deprecated)), e.deprecated || s.push(e);
  }), s;
}
function d(t) {
  const s = r(t);
  return s.elements = n(s.elements), s;
}
function f(t) {
  const s = r(t);
  return s.forEach((e) => {
    e.elements = n(e.elements);
  }), s;
}
export {
  r as deserialize,
  d as deserializePage,
  f as deserializePages
};
