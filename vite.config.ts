import { defineConfig } from "vite"
import { resolve } from "path"

const external = ["@ungap/structured-clone"]

export default defineConfig({
  build: {
    lib: {
      entry: {
        "alchemy-json_api": resolve(__dirname, "src/main.js"),
        deserialize: resolve(__dirname, "src/deserialize.js")
      },
      formats: ["es"],
      fileName: (_format, entryName) => `${entryName}.js`
    },
    rollupOptions: {
      external
    }
  }
})
