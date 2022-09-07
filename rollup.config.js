import babel from "@rollup/plugin-babel"

const plugins = [babel({ babelHelpers: "bundled" })]
const external = ["@ungap/structured-clone"]

export default [
  {
    input: "src/main.js",
    output: [
      {
        file: "dist/alchemy-json_api.js",
        format: "cjs"
      }
    ],
    plugins,
    external
  },
  {
    input: "src/deserialize.js",
    output: {
      file: "dist/deserialize.js",
      format: "cjs"
    },
    plugins,
    external
  }
]
