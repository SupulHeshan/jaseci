
import { defineConfig } from "vite";

export default defineConfig({
  root: ".",          // base folder
  build: {
    rollupOptions: {
      input: "build/main.js", // your compiled entry file
      output: {
        entryFileNames: "client.[hash].js", // name of the final js file
        assetFileNames: "[name].[ext]",
      },
    },
    outDir: "dist",   // final bundled output
    emptyOutDir: true,
  },
  publicDir: false,
});
