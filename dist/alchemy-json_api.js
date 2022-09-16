'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var structuredClone = require('@ungap/structured-clone');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

var structuredClone__default = /*#__PURE__*/_interopDefaultLegacy(structuredClone);

function deserialize(originalResponse) {
  var response = structuredClone__default["default"](originalResponse);

  var included = response.included || [];

  if (Array.isArray(response.data)) {
    return response.data.map(function (data) {
      return parseJsonApiSimpleResourceData(data, included, false);
    });
  } else {
    return parseJsonApiSimpleResourceData(response.data, included, false);
  }
}

function parseJsonApiSimpleResourceData(data, included, useCache, options) {
  if (!included.cached) {
    included.cached = {};
  }

  if (!(data.type in included.cached)) {
    included.cached[data.type] = {};
  }

  if (useCache && data.id in included.cached[data.type]) {
    return included.cached[data.type][data.id];
  }

  var attributes = data.attributes || {};
  var resource = attributes;
  resource.id = data.id;
  included.cached[data.type][data.id] = resource;

  if (data.relationships) {
    for (var _i = 0, _Object$keys = Object.keys(data.relationships); _i < _Object$keys.length; _i++) {
      var relationName = _Object$keys[_i];
      var relationRef = data.relationships[relationName];

      if (Array.isArray(relationRef.data)) {
        (function () {
          var items = [];
          relationRef.data.forEach(function (relationData) {
            var item = findJsonApiIncluded(included, relationData.type, relationData.id);
            items.push(item);
          });
          resource[relationName] = items;
        })();
      } else if (relationRef && relationRef.data) {
        resource[relationName] = findJsonApiIncluded(included, relationRef.data.type, relationRef.data.id);
      } else {
        resource[relationName] = null;
      }
    }
  }

  return resource;
}

function findJsonApiIncluded(included, type, id, options) {
  var found = null;
  included.forEach(function (item) {
    if (item.type === type && item.id === id) {
      found = parseJsonApiSimpleResourceData(item, included, true);
    }
  });

  if (!found) {
    found = {
      id: id
    };
  }

  return found;
}

function filterDeprecatedElements(elements) {
  var els = [];
  elements.forEach(function (element) {
    var _element$nested_eleme, _element$nestedElemen, _element$essences;

    if (((_element$nested_eleme = element.nested_elements) === null || _element$nested_eleme === void 0 ? void 0 : _element$nested_eleme.length) > 0) {
      element.nested_elements = filterDeprecatedElements(element.nested_elements);
    }

    if (((_element$nestedElemen = element.nestedElements) === null || _element$nestedElemen === void 0 ? void 0 : _element$nestedElemen.length) > 0) {
      element.nestedElements = filterDeprecatedElements(element.nestedElements);
    }

    if (((_element$essences = element.essences) === null || _element$essences === void 0 ? void 0 : _element$essences.length) > 0) {
      element.essences = element.essences.filter(function (essence) {
        return !essence.deprecated;
      });
    }

    if (!element.deprecated) {
      els.push(element);
    }
  });
  return els;
} // Returns deserialized page without deprecated content


function deserializePage(pageData) {
  var page = deserialize(pageData);
  page.elements = filterDeprecatedElements(page.elements);
  return page;
} // Returns deserialized pages without deprecated content

function deserializePages(pagesData) {
  var pages = deserialize(pagesData);
  pages.forEach(function (page) {
    page.elements = filterDeprecatedElements(page.elements);
  });
  return pages;
}

exports.deserialize = deserialize;
exports.deserializePage = deserializePage;
exports.deserializePages = deserializePages;
