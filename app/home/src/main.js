/**
 * main.js
 * home
 *
 *
 *
 * @author yayowd
 * @since 2021/06/13 12:10
 **/
import { createApp } from 'vue'
import './index.css'

import { CfgApp } from './app'
CfgApp.app.then(App => {
    createApp(App.default).mount('#app')
})
