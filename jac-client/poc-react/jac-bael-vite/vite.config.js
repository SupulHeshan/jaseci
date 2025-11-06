import { defineConfig } from "vite";

export default defineConfig({
  root: ".",          // base folder
  build: {
    rollupOptions: {
      input: "index.html",
    },
    outDir: "dist",   // final bundled output
  },
});
