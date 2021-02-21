<template>
  <div id="app">
    <b-container fluid class="mb-4" />
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      error: '',
      currentList: '',
    }
  },
  methods: {},
}
</script>

<style lang="scss">
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
}

#logo {
  -webkit-user-drag: none;
  -webkit-user-select: none;
}

#logo-container {
  -webkit-app-region: drag;
}
</style>
