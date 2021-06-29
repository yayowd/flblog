<!--
 ! Logo.vue
 ! home
 !
 ! 显示应用标志
 !
 ! @author yayowd
 ! @since 2021/06/12 17:14
-->
<template>
    <p v-if='maker'><a class='maker' :href='makerUrl'>{{ maker }}</a></p>
    <p v-if='title' class='title'>{{ title }}</p>
    <p v-if='memo' class='memo'>{{ memo }}</p>
</template>

<script setup>
import { defineProps } from 'vue'

defineProps({
    maker: String,
    makerUrl: String,
    title: String,
    memo: String,
})
</script>

<style scoped>
.maker {
    text-decoration: none;
    color: #333;
    font-size: x-small;
}
.title {
    text-align: center;
}
.memo {
    text-align: center;
    font-size: small;
}
</style>
