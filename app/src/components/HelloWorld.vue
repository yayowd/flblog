<template>
  <h1>{{ msg }}</h1>
  <button @click="count++">count is: {{ count }} aaa fff gg  kkk yy</button>
  <p>Edit <code>components/HelloWorld.vue</code> to test hot module replacement.</p>
</template>

<script>
export default {
  name: 'HelloWorld',
  props: {
    msg: String
  },
  data() {
    return {
      count: 1
    }
  }
}
</script>
