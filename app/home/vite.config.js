import vue from '@vitejs/plugin-vue'
import {resolve} from 'path'

/**
 * @type {import('vite').UserConfig}
 */
export default {
    plugins: [vue()],
    build: {
        outDir: '../../home',
        lib: {
            entry: resolve(__dirname, 'src/main.js'),
            name: 'HomeLib',
        },
        rollupOptions: {
            external: ['vue'],
            output: {
                globals: {
                    vue: 'Vue',
                },
                paths: {
                    vue: 'https://cdn.jsdelivr.net/npm/vue@3.0.5/dist/vue.esm-browser.prod.js',
                },
            },
        },
    },
}
