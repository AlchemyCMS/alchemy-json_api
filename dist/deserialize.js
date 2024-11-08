'use strict';

var structuredClone = require('@ungap/structured-clone');

function deserialize(originalResponse) {
  const response = structuredClone(originalResponse);
  const included = response.included || [];
  if (Array.isArray(response.data)) {
    return response.data.map(data => {
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
  const attributes = data.attributes || {};
  const resource = attributes;
  resource.id = data.id;
  included.cached[data.type][data.id] = resource;
  if (data.relationships) {
    for (const relationName of Object.keys(data.relationships)) {
      const relationRef = data.relationships[relationName];
      if (Array.isArray(relationRef.data)) {
        const items = [];
        relationRef.data.forEach(relationData => {
          const item = findJsonApiIncluded(included, relationData.type, relationData.id);
          items.push(item);
        });
        resource[relationName] = items;
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
  let found = null;
  included.forEach(item => {
    if (item.type === type && item.id === id) {
      found = parseJsonApiSimpleResourceData(item, included, true);
    }
  });
  if (!found) {
    found = {
      id
    };
  }
  return found;
}

exports.deserialize = deserialize;
