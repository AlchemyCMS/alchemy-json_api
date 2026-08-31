import { defineConfig } from "vite"
import { resolve } from "path"

export default defineConfig({
  build: {
    lib: {
      entry: {
        "alchemy-json_api": resolve(__dirname, "src/main.ts"),
        deserialize: resolve(__dirname, "src/deserialize.ts")
      },
      formats: ["es"],
      fileName: (_format, entryName) => `${entryName}.js`
    }
  }
})
