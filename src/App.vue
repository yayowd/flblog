<template>
  <img alt="Vue logo" src="./assets/logo.png" />
  <HelloWorld msg="Hello Vue 3.0 + Vite...gogogo...yy..mm" />
  <p class="pa" v-for="a in as">{{a}}</p>
</template>

<script>
import * as R from 'ramda'
import HelloWorld from './components/HelloWorld.vue'

export default {
  name: 'App',
  components: {
    HelloWorld
  },
  data() {
    return {
      as: [],
    }
  },
  mounted() {
    const as = document.getElementById("19as")
    this.as = R.map(n=>n.innerText,as.children)
  }
}
</script>

<style scoped>
.pa {
  border: bisque dotted 1px;
  background-color: aqua;
  margin: 9px;
  padding: 5px;
}
</style>