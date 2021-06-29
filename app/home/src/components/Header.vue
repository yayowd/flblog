<!--
 ! Header.vue
 ! home
 !
 !
 !
 ! @author yayowd
 ! @since 2021/06/13 12:43
-->
<template>
    <div class='logo'>
        <Logo maker='19blog'
              maker-url='https://github.com/yayowd/19blog'
              :title='title'
              :memo='memo'
        />
        <Theme />
    </div>
</template>

<script setup>
import Logo from './Logo.vue'
import Theme from './Theme.vue'

import {getMeta} from '../util/data'
const title = getMeta('title')
const memo = getMeta('memo')
</script>

<style scoped>
.logo {
    /* clear margin collapse */
    padding: 0.01px 5px;
    border-bottom: 1px solid #d9e9d9;
}
</style>