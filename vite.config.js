import { defineConfig, loadEnv } from "vite";

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");

  return {
    server: {
      proxy: {
        "/api": {
          target: `http://127.0.0.1:${env.BACKEND_PORT || 8000}`,
          changeOrigin: true,
        },
      },
    },
  };
});
