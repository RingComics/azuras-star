<!--
  Options.vue
  Error identifier: F07
-->
<template>
  <div>
    <b-overlay
      :show="loading"
    >
      <h2>Settings</h2>
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
        <b-button
          @click="showModal('confirm-config-reset')"
          variant="danger"
        >
          Reset configurations
        </b-button>
        <br />
        <b-checkbox
          v-model="advancedOptions"
          @change="saveConfig()"
        >
          <span
            v-b-popover.hover.top="'Enables extra settings, modlist options, and the developer page (coming soon)'"
          >
            Advanced Options
          </span>
        </b-checkbox>
        <h3 v-if="advancedOptions">Advanced</h3>
        <b-row no-gutters style="margin: 1%">
          <b-col>
            <b-button
              style="width: 100%"
              v-if="advancedOptions"
              @click="openConsole()"
            >
              Open Developer Console
            </b-button>
          </b-col>
          <b-col>
            <b-button
              style="width: 100%"
              v-if="advancedOptions"
              @click="openLog()"
            >
              Open Current Log File
            </b-button>
          </b-col>
          <b-col>
            <b-button
              style="width: 100%"
              v-if="advancedOptions"
              @click="openLogsFolder()"
            >
              All Logs
            </b-button>
          </b-col>
        </b-row>
        <b-card-header
          header-tag="header"
          class="p-1"
          role="tab"
        >
          <b-button
            block
            v-b-toggle.config
            v-if="advancedOptions"
          >
            Current Configuration
          </b-button>
        </b-card-header>
        <b-collapse
          id="config"
        >
          <b-button style="width:20%;margin-left: 40%;margin-right: 40%;" @click="openConfig()">Open config file</b-button>
          <ul>
            <li><strong><u>Version:</u></strong> {{ currentConfig.version}}</li>
            <li><strong><u>App Path:</u></strong> {{ currentConfig.ASPath }}</li>
            <li><strong><u>Development:</u></strong> {{ currentConfig.isDevelopment }}</li>
            <li><strong><u>Options:</u></strong></li>
            <ul>
              <li><strong><u>Advanced Options:</u></strong> {{ currentConfig.Options.advancedOptions }}</li>
              <li><strong><u>Game Directories</u></strong></li>
                <ul>
                  <div
                    v-for="(entry, index) in currentConfig.Options.gameDirectories"
                    :key="index"
                  >
                    <li><strong><u>{{ entry.game }}:</u></strong> {{ entry.path }}</li>
                  </div>
                </ul>
            </ul>
            <li><strong><u>Modlists:</u></strong></li>
              <ul>
                <div
                  v-for="(list, index1) in Object.keys(currentConfig.Modlists)"
                  :key="index1"
                >
                  <li><strong><u>{{ list }}:</u></strong></li>
                    <ul>
                      <div
                        v-for="(entry, index2) in Object.keys(currentConfig.Modlists[list])"
                        :key="index2"
                      >
                        <li
                          v-if="typeof currentConfig.Modlists[list][entry] == 'string'"
                        >
                          <strong><u>{{ entry }}:</u></strong> {{ currentConfig.Modlists[list][entry] }}
                        </li>
                        <div
                          v-if="Array.isArray(currentConfig.Modlists[list][entry])"
                        >
                          <li><strong><u>{{ entry }}:</u></strong></li>
                          <ul>
                            <li
                              v-for="(value, index3) in currentConfig.Modlists[list][entry]"
                              :key="index3"
                            >
                              {{ value }}
                            </li>
                          </ul>
                        </div>
                        <li
                          v-if="typeof currentConfig.Modlists[list][entry] == 'number'"
                        >
                          <strong><u>{{ entry }}:</u></strong> {{ Date(currentConfig.Modlists[list][entry]) }}
                        </li>
                      </div>
                    </ul>
                </div>
              </ul>
          </ul>

        </b-collapse>
      </b-form>
    </b-overlay>

    <!--Modals-->
  <b-modal ref='confirm-config-reset'
    title="Reset settings?"
    hide-footer
  >
    <p>This will clear all of your modlists and settings (Your modlists will not be deleted from your computer)</p>
    <b-button
      variant="danger"
      @click="resetSettings()"
    >
      Yes
    </b-button>
    <b-button
      @click="hideModal('confirm-config-reset')"
    >
      No
    </b-button>
  </b-modal>
  </div>
</template>

<script>

export default {
  name: 'Options',
  data () {
    return {
      gameDirectories: [],
      advancedOptions: '',
      currentConfig: '',
      loading: false
    }
  },
  methods: {
    showModal (name) {
      this.$refs[name].show()
    },
    hideModal (name) {
      this.$refs[name].hide()
    },
    loadConfig () {
      // Error ID: F07-03
      try {
        window.ipcRenderer.invoke('get-config').then((result) => {
          if (result === 'ERROR') return
          this.gameDirectories = result.Options.gameDirectories
          this.WabbajackDirectory = result.Options.WabbajackDirectory
          this.advancedOptions = result.Options.advancedOptions
          this.currentConfig = result
        })
      } catch (err) {
        this.sendError('F07-03-00', 'Error while requesting config!', err, 0)
      }
    },
    saveConfig () {
      // Error ID: F07-04
      try {
        this.currentConfig.Options.gameDirectories = this.gameDirectories
        this.currentConfig.Options.WabbajackDirectory = this.WabbajackDirectory
        this.currentConfig.Options.advancedOptions = this.advancedOptions
        window.ipcRenderer.send('update-config', { newConfig: this.currentConfig })
      } catch (err) {
        this.sendError('F07-04-00', 'Error while sending config!', err, 0)
      }
    },
    openConfig () {
      window.ipcRenderer.send('open-config')
    },
    getDirectory (game) {
      window.ipcRenderer.invoke('get-directory').then((result) => {
        if (result !== undefined) {
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
    },
    resetSettings () {
      this.loading = true
      window.ipcRenderer.invoke('reset-config').then(result => {
        if (result) {
          location.reload()
        } else {
          this.loading = false
          this.hideModal('confirm-config-reset')
        }
      })
    },
    sendError (code, message, err, tabbed) {
      // Error identifier: God help us
      window.ipcRenderer.send('error', { code, message, err, tabbed })
    }
  },
  beforeMount () {
    this.loadConfig()
  },
  mounted () {
    // Error Identifier: F07-02
    try {
    } catch (err) {

    }
  }
}
</script>
