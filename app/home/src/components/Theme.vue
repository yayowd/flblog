<!--
 ! Theme.vue
 ! home
 !
 ! 样式配置组件
 !
 ! @author yayowd
 ! @since 2021/06/13 19:26
-->
<template>
    <p class='theme'>
        <span>布局：
            <span :class='layout === "Simple" ? "used" : ""'>简单</span>
        </span>
        <span>样式：
            <span :class='tone === "light" ? "used" : ""'> 亮 </span>
            <span :class='tone === "dark" ? "used" : ""'> 暗 </span>
            <span :class='space === "loose" ? "used" : ""'> 松 </span>
            <span :class='space === "compact" ? "used" : ""'> 紧 </span>
        </span>
    </p>
</template>

<script setup>
import {CfgApp} from '../app'

const tone = CfgApp.tone
const space = CfgApp.space
const layout = CfgApp.layout
</script>

<style scoped>
.theme {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    font-size: small;
}
span span {
    cursor: pointer;
}
.used {
    text-decoration: underline dotted;
}
</style>