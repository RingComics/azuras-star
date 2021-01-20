<template>
  <div id="app">
    <b-container
      fluid
      class="mb-4"
    />
    <router-view/>
    <b-modal
      ref="error-message"
      title="An error occured"
      ok-only
    >
      <p> {{ this.error }} </p>
    </b-modal>
  </div>
</template>

<script>
export default {
  name: 'App',
  data () {
    return {
      error: '',
      currentList: ''
    }
  },
  methods: {

  },
  mounted () {
    window.ipcRenderer.on('error', (event, args) => {
      switch (args[0]) {
        case '001':
          this.error = args[1]
          break
        default:
          this.error = 'An error occured, but we aren\'t sure what (Error 000). Please report this to the developer. Error message:\n' + args[1]
          break
      }
      this.$refs['error-message'].show()
    })
  }
}
</script>

<style lang="scss">
@import 'scss/custom.scss';
@import '../node_modules/bootstrap/scss/bootstrap.scss';
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
