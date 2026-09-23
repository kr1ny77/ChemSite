import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  build: {
    target: 'es2022',
    sourcemap: true,
    chunkSizeWarningLimit: 2500,
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'zustand'],
          'three-core': ['three'],
          'physics-core': ['@dimforge/rapier3d-compat'],
          'r3f-vendor': [
            '@react-three/fiber',
            '@react-three/drei',
            '@react-three/rapier',
            '@react-three/postprocessing',
            'postprocessing',
          ],
        },
      },
    },
  },
})
