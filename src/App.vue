<template>
  <div id="app">
    <b-container fluid class="mb-4">
    </b-container>
    <router-view/>
  </div>
</template>

<script>
export default {
  name: 'App',
  methods: {
    close () {
      window.ipcRenderer.send('close')
    },
    minimize () {
      window.ipcRenderer.send('minimize')
    }
  }
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
