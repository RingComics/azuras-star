<template>
  <div>
    <h2>Launcher Settings</h2>
    <b-form @submit="saveConfig()">
      <b-card-header header-tag="header" class="p-1" role="tab">
        <b-button block v-b-toggle.directories>Game directories</b-button>
      </b-card-header>
      <b-collapse id="directories">
        <div v-for="(gameDirectory, index) in gameDirectories" :key="index">
          <b-input-group>
            <b-input-group-prepend is-text>{{ gameDirectory.game }} Directory</b-input-group-prepend>
            <b-form-input v-model="gameDirectory.path" disabled></b-form-input>
            <b-input-group-append>
              <b-button v-b-popover.hover.top="'Change '+gameDirectory.game+' Directory'" class="float-right" @click="getDirectory(gameDirectory.game)">Browse</b-button>
            </b-input-group-append>
          </b-input-group>
        </div>
      </b-collapse><br />

      <b-input-group>
        <b-input-group-prepend is-text>Wabbajack Directory</b-input-group-prepend>
        <b-form-input v-model="WabbajackDirectory" disabled></b-form-input>
        <b-input-group-append>
          <b-button v-b-popover.hover.top="'Change Wabbajack Directory'" class="float-right" @click="getDirectory('WabbajackDirectory')">Browse</b-button>
        </b-input-group-append>
      </b-input-group>

      <b-checkbox v-model="advancedOptions"><span v-b-popover.hover.top="'Enables extra options for modlists'">Advanced Modlist Options</span></b-checkbox><br />

      <!--<b-button @click="debug()">Debug</b-button><br />-->

      <b-button type="submit" variant="primary">Apply</b-button>
    </b-form>
    <b-modal ref="debugModal">
      <p>{{ this.debugResult }}</p>
    </b-modal>
  </div>
</template>

<script>

export default {
  name: 'Options',
  data () {
    return {
      gameDirectories: [],
      WabbajackDirectory: '',
      advancedOptions: '',
      currentConfig: '',
      debugResult: '',
      downloading: false
    }
  },
  methods: {
    loadConfig () {
      window.ipcRenderer.invoke('get-config').then((result) => {
        console.log(result)
        this.gameDirectories = result.Options.gameDirectories
        this.WabbajackDirectory = result.Options.WabbajackDirectory
        this.advancedOptions = result.Options.advancedOptions
        this.currentConfig = result
      })
    },
    saveConfig () {
      this.currentConfig.Options.gameDirectories = this.gameDirectories
      this.currentConfig.Options.WabbajackDirectory = this.WabbajackDirectory
      this.currentConfig.Options.advancedOptions = this.advancedOptions
      window.ipcRenderer.invoke('update-config', this.currentConfig)
    },
    getDirectory (game) {
      window.ipcRenderer.invoke('get-directory').then((result) => {
        if (result !== undefined) {
          if (game === 'WabbajackDirectory') {
            this.WabbajackDirectory = result[0]
            return
          }
          this.gameDirectories.find(x => x.game === game).path = result[0]
          this.saveConfig()
        }
      })
    },
    downloadWabbajack () {
      window.ipcRenderer.invoke('download-wabbajack')
    },
    debug () {
      window.ipcRenderer.invoke('debug').then(result => {
        this.debugResult = result
        this.$refs.debugModal.show()
      })
    }
  },
  beforeMount () {
    this.loadConfig()
  }
}
</script>
