<template>
  <div id="app">
    <b-container fluid class="mb-4">
    </b-container>
    <router-view/>
    <b-modal ref="error-message" title="An error occured" ok-only>
      <p> {{ this.error }} </p>
    </b-modal>
    <b-modal ref="game-running" :title="'Currently running ' + this.currentList" hide-footer hide-header-close no-close-on-backdrop no-close-on-esc >
      <h2>Application locked while game is running</h2>
      <p>DO NOT EXIT AZURA'S STAR WHILE THE GAME IS RUNNING.</p>
      <b-button @click="forceQuit()">Force quit {{ this.currentList }}</b-button>
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
    forceQuit () {
      window.ipcRenderer.invoke('force-quit')
    }
  },
  mounted () {
    window.ipcRenderer.on('cmd-launch', (event, args) => {
      window.ipcRenderer.once('game-closed', (event, args) => {
        this.$refs['game-running'].hide()
      })
      this.currentList = args
    })
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
