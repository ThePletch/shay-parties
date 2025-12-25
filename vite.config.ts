import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  css: {
    preprocessorOptions: {
      scss: {
        // bootstrap 5 uses deprecated syntax, these silences allow it to compile until we can get off of bootstrap.
        silenceDeprecations: ['if-function', 'color-functions', 'global-builtin', 'import']
      },
    }
  },
});
