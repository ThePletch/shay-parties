import type { UserConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby';
import path from 'path';

export default {
  plugins: [
    RubyPlugin(),
  ],
  // config for local dev server
  server: {
    // Vite 7+ returns 403 when Host is not localhost / *.localhost / an IP.
    // vite_rails’ Rack proxy forwards with Host set to ViteRuby’s `host`
    // (e.g. the Docker Compose service name `vite`), which must be allowed.
    allowedHosts: true,
  },
  css: {
    preprocessorOptions: {
      scss: {
        // bootstrap 5 uses deprecated syntax, these silences allow it to compile until we can get off of bootstrap.
        silenceDeprecations: ['if-function', 'color-functions', 'global-builtin', 'import']
      },
    }
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./app/frontend/src"),
    },
  },
} satisfies UserConfig;
