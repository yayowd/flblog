/**
 * app.js
 * home
 *
 * 应用实例
 * 适配用户个性设置
 *
 * @author yayowd
 * @since 2021/06/12 20:14
 **/
import { saveData, loadData } from './util/store'

// 主题配置参数名称
const THEME_TONE = 'tone' // 色调
const THEME_SPACE = 'space' // 空间
const THEME_LAYOUT = 'layout' // 布局

export const CfgApp = {
    get tone() {
        return loadData(THEME_TONE, 'light')
    },
    set tone(val) {
        saveData(THEME_TONE, val)
    },
    get space() {
        return loadData(THEME_SPACE, 'loose')
    },
    set space(val) {
        saveData(THEME_SPACE, val)
    },
    get layout() {
        return loadData(THEME_LAYOUT, 'Simple')
    },
    set layout(val) {
        saveData(THEME_LAYOUT, val)
    },
    get app() {
        import(`./css/${this.tone}.css`)
        import(`./css/${this.space}.css`)
        return import(`./layout/${this.layout}.vue`)
    },
}
