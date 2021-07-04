import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [vue()],
    build: {
        outDir: '../../dist',
        lib: {
            entry: resolve(__dirname, 'src/main.js'),
            name: 'HomeLib',
        },
        cssCodeSplit: false,
        rollupOptions: {
            external: ['vue'],
            output: {
                globals: {
                    vue: 'Vue',
                },
                paths: {
                    vue: 'https://cdn.jsdelivr.net/npm/vue@3.0.5/dist/vue.esm-browser.prod.js',
                },
                assetFileNames: '19blog-home[extname]',
            },
        },
    },
})
