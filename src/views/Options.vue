<template>
  <div>
    <h2>Launcher Settings</h2>
    <b-form @submit="saveConfig">
      <b-card-header header-tag="header" class="p-1" role="tab">
        <b-button block v-b-toggle.directories>Game directories</b-button>
      </b-card-header>
      <b-collapse id="directories">
        <span>Morrowind directory: {{ this.MorrowindDirectory }}</span>
        <b-button class="float-right" @click="getDirectory('MorrowindDirectory')">Browse</b-button><br/><br />

        <span>Skyrim LE directory: {{ this.SkyrimLEDirectory }}</span>
        <b-button class="float-right" @click="getDirectory('SkyrimLEDirectory')">Browse</b-button><br/><br />

        <span>Skyrim SE directory: {{ this.SkyrimSEDirectory }}</span>
        <b-button class="float-right" @click="getDirectory('SkyrimSEDirectory')">Browse</b-button><br /><br />

        <span>Skyrim VR directory: {{ this.SkyrimVRDirectory }}</span>
        <b-button class="float-right" @click="getDirectory('SkyrimVRDirectory')">Browse</b-button><br /><br />

        <span>Fallout 3 directory: {{ this.Fallout3Directory }}</span>
        <b-button class="float-right" @click="getDirectory('Fallout3Directory')">Browse</b-button><br /><br />

        <span>Fallout NV directory: {{ this.FalloutNVDirectory }}</span>
        <b-button class="float-right" @click="getDirectory('FalloutNVDirectory')">Browse</b-button><br /><br />

        <span>Fallout 4 directory: {{ this.Fallout4Directory }}</span>
        <b-button class="float-right" @click="getDirectory('Fallout4Directory')">Browse</b-button><br /><br />

        <span>Fallout 4 VR directory: {{ this.FalloutVRDirectory }}</span>
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
      SkyrimLEDirectory: '',
      SkyrimSEDirectory: '',
      currentConfig: ''
    }
  },
  methods: {
    loadConfig () {
      window.ipcRenderer.invoke('get-config').then((result) => {
        this.SkyrimLEDirectory = result.Options.SkyrimLEDirectory
        this.SkyrimSEDirectory = result.Options.SkyrimSEDirectory
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
        if (result !== undefined) { this[game] = result[0] }
      })
    }
  },
  beforeMount () {
    this.loadConfig()
  }
}
</script>
