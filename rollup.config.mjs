const external = ["@ungap/structured-clone"]

export default [
  {
    input: "src/main.js",
    output: [
      {
        file: "dist/alchemy-json_api.js",
        format: "esm"
      }
    ],
    external
  },
  {
    input: "src/deserialize.js",
    output: [
      {
        file: "dist/deserialize.js",
        format: "esm"
      }
    ],
    external
  }
]
