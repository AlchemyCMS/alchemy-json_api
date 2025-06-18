import typescript from "@rollup/plugin-typescript"

const external = ["@ungap/structured-clone"]

export default [
  {
    input: "src/main.ts",
    output: [
      {
        file: "dist/alchemy-json_api.js",
        format: "esm"
      }
    ],
    external,
    plugins: [typescript()]
  },
  {
    input: "src/deserialize.ts",
    output: [
      {
        file: "dist/deserialize.js",
        format: "esm"
      }
    ],
    external
  }
]
