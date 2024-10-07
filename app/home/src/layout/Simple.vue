<!--
 ! Simple.vue
 ! home
 !
 ! 简单页面布局
 !
 ! @author yayowd
 ! @since 2021/06/12 21:38
-->
<template>
    <div class='left'>
        <Header />
    </div>
    <div>Simple</div>
</template>

<script setup>
import Header from '../components/Header.vue'
</script>

<style scoped>
.left {
    width: 250px;
    height: 100%;
    margin: 0;
}
</style>>