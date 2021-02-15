<template>
  <div>
    <h2>Launcher Settings</h2>
    <b-form
      @submit="saveConfig()"
    >
      <b-card-header
        header-tag="header"
        class="p-1"
        role="tab"
      >
        <b-button
          block
          v-b-toggle.directories
        >
          Game directories
        </b-button>
      </b-card-header>
      <b-collapse
        id="directories"
      >
      <b-form-group>
        <br />
        <div
          v-for="(gameDirectory, index) in gameDirectories"
          :key="index"
        >
              <span>
                    {{ gameDirectory.game }} Directory
              </span><br />
              <b-input-group>
                <b-form-input
                  v-model="gameDirectory.path"
                  disabled
                  @change="saveConfig()"
                />
                <b-input-group-append>
                  <b-button
                    v-b-popover.hover.top="'Change ' + gameDirectory.game + ' Directory'"
                    @click="getDirectory(gameDirectory.game)"
                  >
                    Browse
                  </b-button>
                </b-input-group-append>
              </b-input-group>
              <br />
        </div>
      </b-form-group>
      </b-collapse>
      <br/>
      <b-checkbox
        v-model="advancedOptions"
        @change="saveConfig()"
      >
        <span
          v-b-popover.hover.top="'Enables extra options for modlists'"
        >
          Advanced Modlist Options
        </span>
      </b-checkbox>
      <b-button
        v-if="this.advancedOptions == true"
        @click="openConsole()"
      >
        Open Developer Console
      </b-button>
      <b-button
        v-if="this.advancedOptions == true"
        @click="openLog()"
      >
        Open Current Log File
      </b-button>
      <b-button
        v-if="this.advancedOptions == true"
        @click="openLogsFolder()"
      >
        All Logs
      </b-button>
    </b-form>
  </div>
</template>

<script>

export default {
  name: 'Options',
  data () {
    return {
      gameDirectories: [],
      advancedOptions: '',
      currentConfig: ''
    }
  },
  methods: {
    loadConfig () {
      window.ipcRenderer.invoke('get-config').then((result) => {
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
    openConsole () {
      window.ipcRenderer.send('open-dev-tools')
    },
    openLog () {
      window.ipcRenderer.send('open-log')
    },
    openLogsFolder () {
      window.ipcRenderer.send('open-logs-directory')
    }
  },
  beforeMount () {
    this.loadConfig()
  }
}
</script>
