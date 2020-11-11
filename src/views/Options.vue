<template>
  <div>
    <h2>Launcher Settings</h2>
    <b-form @submit="saveConfig">
      <b-card-header header-tag="header" class="p-1" role="tab">
        <b-button block v-b-toggle.directories>Game directories</b-button>
      </b-card-header>
      <b-collapse id="directories">
        <span>Morrowind directory: {{ this.MorrowindDirectory }}<span v-if="this.MorrowindDirectory === ''">Not Set</span></span>
        <b-button class="float-right" @click="getDirectory('MorrowindDirectory')">Browse</b-button><br/><br />

        <span>Oblivion directory: {{ this.OblivionDirectory }}<span v-if="this.OblivionDirectory === ''">Not Set</span></span>
        <b-button class="float-right" @click="getDirectory('OblivionDirectory')">Browse</b-button><br/><br />

        <span>Skyrim LE directory: {{ this.SkyrimLEDirectory }}<span v-if="this.SkyrimLEDirectory === ''">Not Set</span></span>
        <b-button class="float-right" @click="getDirectory('SkyrimLEDirectory')">Browse</b-button><br/><br />

        <span>Skyrim SE directory: {{ this.SkyrimSEDirectory }}<span v-if="this.SkyrimSEDirectory === ''">Not Set</span></span>
        <b-button class="float-right" @click="getDirectory('SkyrimSEDirectory')">Browse</b-button><br /><br />

        <span>Skyrim VR directory: {{ this.SkyrimVRDirectory }}<span v-if="this.SkyrimVRDirectory === ''">Not Set</span></span>
        <b-button class="float-right" @click="getDirectory('SkyrimVRDirectory')">Browse</b-button><br /><br />

        <span>Fallout 3 directory: {{ this.Fallout3Directory }}<span v-if="this.Fallout3Directory === ''">Not Set</span></span>
        <b-button class="float-right" @click="getDirectory('Fallout3Directory')">Browse</b-button><br /><br />

        <span>Fallout NV directory: {{ this.FalloutNVDirectory }}<span v-if="this.FalloutNVDirectory === ''">Not Set</span></span>
        <b-button class="float-right" @click="getDirectory('FalloutNVDirectory')">Browse</b-button><br /><br />

        <span>Fallout 4 directory: {{ this.Fallout4Directory }}<span v-if="this.Fallout4Directory === ''">Not Set</span></span>
        <b-button class="float-right" @click="getDirectory('Fallout4Directory')">Browse</b-button><br /><br />

        <span>Fallout 4 VR directory: {{ this.FalloutVRDirectory }}<span v-if="this.FalloutVRDirectory === ''">Not Set</span></span>
        <b-button class="float-right" @click="getDirectory('FalloutVRDirectory')">Browse</b-button><br /><br />
      </b-collapse>

      <b-button type="submit" variant="primary">Apply</b-button>
    </b-form>
  </div>
</template>

<script>

export default {
  name: 'Options',
  data () {
    return {
      MorrowindDirectory: '',
      OblivionDirectory: '',
      SkyrimLEDirectory: '',
      SkyrimSEDirectory: '',
      SkyrimVRDirectory: '',
      Fallout3Directory: '',
      FalloutNVDirectory: '',
      Fallout4Directory: '',
      FalloutVRDirectory: '',
      currentConfig: ''
    }
  },
  methods: {
    loadConfig () {
      window.ipcRenderer.invoke('get-config').then((result) => {
        this.MorrowindDirectory = result.Options.MorrowindDirectory
        this.OblivionDirectory = result.Options.OblivionDirectory
        this.SkyrimLEDirectory = result.Options.SkyrimLEDirectory
        this.SkyrimSEDirectory = result.Options.SkyrimSEDirectory
        this.SkyrimVRDirectory = result.Options.SkyrimVRDirectory
        this.Fallout3Directory = result.Options.Fallout3Directory
        this.FalloutNVDirectory = result.Options.FalloutNVDirectory
        this.Fallout4Directory = result.Options.Fallout4Directory
        this.FalloutVRDirectory = result.Options.FalloutVRDirectory
        this.currentConfig = result
      })
    },
    saveConfig () {
      this.currentConfig.Options.SkyrimLEDirectory = this.SkyrimLEDirectory
      this.currentConfig.Options.SkyrimSEDirectory = this.SkyrimSEDirectory
      window.ipcRenderer.invoke('update-config', this.currentConfig)
    },
    getDirectory (game) {
      window.ipcRenderer.invoke('get-directory').then((result) => {
        if (result !== undefined) {
          this[game] = result[0]
          this.saveConfig()
        }
      })
    }
  },
  beforeMount () {
    this.loadConfig()
  }
}
</script>
