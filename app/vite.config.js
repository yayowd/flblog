/**
 * type {import('vite').UserConfig}
 */
export default (mode) => {
    let build = {
        outDir: '../home',
        rollupInputOptions: {
            external: ['vue'],
        },
        rollupOutputOptions: {
            plugins: [ {
                name: 'replace-importer',
                renderChunk(code) {
                    // add esm cdn link
                    code = code.replace(/from\s+(["']vue["'])/g, 'from "https://cdn.jsdelivr.net/npm/vue@3.0.5/dist/vue.esm-browser.prod.js"')
                    return { code, map: null }
                }
            }]
        }
    }
    if (mode === 'development') {
        build = {
            ...build,
            descripe: 'development config'
        }
    } else if (mode === 'production') {
        build = {
            ...build,
            descripe: 'production config'
        }
    } else if (mode === 'demo') {
        build = {
            ...build,
            descripe: 'demo config'
        }
    } else {
        throw 'unknown build mode'
    }
    return build
}
