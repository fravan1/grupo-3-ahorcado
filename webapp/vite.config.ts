import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { nodePolyfills } from 'vite-plugin-node-polyfills';

// https://vite.dev/config/
export default defineConfig({
  optimizeDeps: {
    esbuildOptions: { target: 'esnext' },
    exclude: ['@noir-lang/noirc_abi', '@noir-lang/acvm_js'],
  },
  plugins: [
    react(),
    nodePolyfills({
          // You can specify which polyfills to include or exclude.
          // For Buffer, you would ensure it's not excluded or explicitly include it.
          globals: {
            Buffer: true, // Polyfill Buffer global
            // You can also polyfill other globals like process, global, etc.
          },
          // include: ['buffer'], // Explicitly include buffer if needed
        }),
  ],

})
