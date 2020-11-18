<template>
  <b-container fluid class="text-center" key="profiles">
    <b-overlay :show="loading">
      <h2>Modlists</h2>
      <label class="float-left" for="gameFilter"><b-button @click="showModal('add-modlist-modal')">Add new Modlist</b-button></label>
      <b-form-select id='gameFilter' v-model="selectedGame" :options="gamesList"/>
      <b-form-input placeholder="Search for a list..." v-model="search" />
      <br />
      <div class="accordian" role="tablist">
        <ModlistProfile
          v-for="(profile, index) in profiles"
          :key="profile.id"
          :name="profile.name"
          :path="profile.path"
          :exe="profile.exe"
          :game="profile.game"
          :profiles="profile.profiles[0]"
          :selectedProfile="profile.selectedProfile"
          :selectedGame="selectedGame"
          :search="search"
          :index="index"
          :advancedOptions="currentConfig.Options.advancedOptions"
          @change-modlist="editModlist($event)"
          @change-profile="this.profiles[$event[0]].selectedProfile = $event[1]"
          @configure="openModlistProfile($event)"
          @delete="confirmDeleteModlistProfile($event)"
          @play="launchGame($event)"
          @shortcut="createShortcut($event)"
          @launch-mo2="launchMO2($event)"
        />
      </div>
    </b-overlay>

    <b-modal ref="add-modlist-modal" title="Name Your Profile" hide-footer>
      <b-form @submit="createModlistProfile">
        <p>Find your Modlist's folder (where Mod Organizer.exe is) and Azura's Star will fill in the modlist info.</p>
        <b-form-input required placeholder="Enter Modlist name" v-model="addModal.name" />
        <b-input-group>
          <b-form-input required placeholder="Enter Modlist folder" v-model="addModal.path" />
          <b-input-group-append>
            <b-button @click="addModlistPath">Browse</b-button>
          </b-input-group-append>
        </b-input-group><br />
        <b-button class="float-right" type="submit" variant="primary">Add Modlist</b-button>
      </b-form>
    </b-modal>

    <b-modal ref="delete-modlist-modal" title="Delete Your Profile" hide-footer>
      <b-form @submit="deleteModlistProfile">
        <p class="text-center">
          Are you sure you want to delete {{ this.deleteModal.name }}?
        </p>
        <b-button type="submit" variant="danger">Delete</b-button>
      </b-form>
    </b-modal>

    <b-modal ref="edit-modlist-modal" :title="'Edit Profile ' + this.editModal.property" hide-footer>
      <b-form @submit="changeModlist">
        <b-form-input v-if="editModal.property != 'game' & editModal.property != 'selectedProfile'" v-model="editModal.value" :value="editModal.value" />
        <b-form-select v-if="editModal.property == 'game'" v-model="editModal.value" :options="gamesList"/>
        <b-select v-if="editModal.property == 'selectedProfile'" v-model="editModal.value" :options="editModal.profiles" />
        <b-button @click="getPath('this.editModal.value')" v-if="editModal.property == 'path'">Browse</b-button>
        <b-button type="submit">Change {{ this.editModal.property }}</b-button>
      </b-form>
    </b-modal>

    <b-modal ref="game-running" :title="'Currently running ' + this.currentList" hide-footer hide-header-close no-close-on-backdrop no-close-on-esc >
      <h2>Application locked while game is running</h2>
      <p>DO NOT EXIT AZURA'S STAR WHILE THE GAME IS RUNNING.</p>
      <b-button @click="forceQuit()">Force quit {{ this.currentList }}</b-button>
    </b-modal>

    <b-modal ref="error-message" title="An error occured" ok-only>
      <p> {{ this.error }} </p>
    </b-modal>
  </b-container>
</template>

<script>
import ModlistProfile from '../components/ModlistProfile.vue'

export default {
  name: 'Modlists',
  components: {
    ModlistProfile
  },
  data () {
    return {
      loading: false,
      selectedGame: null,
      currentList: null,
      currentConfig: '',
      search: '',
      error: 'Something went wrong, but we aren\'t sure what',
      gamesList: [
        { value: null, text: 'Filter by game' },
        { value: 'SkyrimLE', text: 'The Elder Scrolls V: Skyrim Legendary Edition' },
        { value: 'SkyrimSE', text: 'The Elder Scrolls V: Skyrim Special Edition' },
        { value: 'SkyrimVR', text: 'The Elder Scrolls V: Skyrim VR' },
        { value: 'Oblivion', text: 'The Elder Scrolls IV: Oblivion' },
        { value: 'Morrowind', text: 'The Elder Scrolls III: Morrowind' },
        // { value: 'Enderal', text: 'Enderal' },
        { value: 'Fallout4VR', text: 'Fallout 4 VR' },
        { value: 'Fallout4', text: 'Fallout 4' },
        { value: 'FalloutNV', text: 'Fallout: New Vegas' },
        { value: 'Fallout3', text: 'Fallout 3' }
      ],
      // We should get this from the settings on-load
      profiles: [],
      addModal: {
        path: '',
        name: ''
      },
      deleteModal: {
        name: ''
      },
      editModal: {
        list: '',
        property: '',
        value: '',
        profiles: []
      }
    }
  },
  methods: {
    showModal (name) {
      this.$refs[name].show()
    },
    createModlistProfile () {
      this.loading = true
      this.$refs['add-modlist-modal'].hide()

      const modlistInfo = { name: this.addModal.name, path: this.addModal.path }

      window.ipcRenderer.once('unknown-game', (event, args) => {
        this.error = args + ' is not supported by Azura\'s Star (Error code 202)'
        this.$refs['error-message'].show()
        this.loading = false
      })

      window.ipcRenderer.invoke('create-modlist-profile', modlistInfo).then((result) => {
        if (result === 'ERROR 202') return
        this.profiles.push(result)
        this.loading = false
        location.reload()
      })
    },
    openModlistProfile (name) {
      const profile = this.profiles.find(x => x.name === name)

      window.ipcRenderer.send('open-modlist-profile', profile.path)
    },
    confirmDeleteModlistProfile (name) {
      this.deleteModal.name = name
      this.showModal('delete-modlist-modal')
    },
    deleteModlistProfile () {
      this.loading = true
      this.$refs['delete-modlist-modal'].hide()
      window.ipcRenderer.invoke('get-config').then(result => {
        delete result.Modlists[this.deleteModal.name]
        window.ipcRenderer.invoke('update-config', result)
      })
      this.loading = false
      location.reload()
    },
    editModlist (args) {
      this.editModal.list = args[0]
      this.editModal.property = args[1]
      if (args[1] === 'selectedProfile') {
        this.profiles.find(x => x.name === args[0]).profiles[0].forEach(x => this.editModal.profiles.push(x))
      }
      this.showModal('edit-modlist-modal')
    },
    changeModlist () {
      this.loading = true
      window.ipcRenderer.invoke('get-config').then(result => {
        const listIndex = this.profiles.findIndex(obj => obj.name === result.Modlists[this.editModal.list].name)
        result.Modlists[this.editModal.list][this.editModal.property] = this.editModal.value
        const newProfile = result.Modlists[this.editModal.list]
        this.profiles[listIndex] = newProfile
        delete result.Modlists[this.editModal.list]
        result.Modlists[newProfile.name] = newProfile
        window.ipcRenderer.invoke('update-config', result)
        location.reload()
      })

      this.$refs['edit-modlist-modal'].hide()
    },
    getPath () {
      window.ipcRenderer.invoke('get-directory').then(result => {
        if (result !== undefined) { this.editModal.value = result[0] }
      })
    },
    addModlistPath () {
      window.ipcRenderer.invoke('get-directory').then(result => {
        if (result !== undefined) { this.addModal.path = result[0] }
      })
    },
    launchGame (list) {
      this.currentList = list
      const game = this.profiles[this.profiles.findIndex(x => x.name === list)].game
      if (this.currentConfig.Options.gameDirectories.find(x => x.game === game).path === '') {
        this.error = 'Your game directory for ' + game + ' could not be found. Please make sure it is set in the options menu and try again (Error code 201)'
        this.showModal('error-message')
        return
      }
      this.showModal('game-running')
      window.ipcRenderer.invoke('launch-game', list)
      window.ipcRenderer.once('game-closed', (event, args) => {
        this.$refs['game-running'].hide()
      })
    },
    forceQuit () {
      window.ipcRenderer.invoke('force-quit')
    },
    createShortcut (name) {
      window.ipcRenderer.invoke('create-shortcut', name)
    },
    launchMO2 (list) {
      window.ipcRenderer.invoke('launch-mo2', list)
    }
  },
  beforeMount () {

  },
  mounted () {
    window.ipcRenderer.invoke('get-config').then((result) => {
      this.currentConfig = result
      Object.entries(this.currentConfig.Modlists).forEach(key => {
        this.profiles.push({ name: key[1].name, path: key[1].path, exe: key[1].exe, game: key[1].game, profiles: [], selectedProfile: key[1].selectedProfile })
        this.profiles[Object.keys(this.currentConfig.Modlists).indexOf(key[1].name)].profiles.push([...this.currentConfig.Modlists[key[1].name].profiles])
      })
    })
    window.ipcRenderer.on('error', (event, args) => {
      switch (args[0]) {
        case '204':
          this.error = 'There was an issue launching the game (Error 204): ' + args[1]
          break
        case '002':
          this.error = 'There was an issue moving Game Folder Files over (Error 002): ' + args[1]
          break
        default:
          this.error = 'An error occured, but we aren\'t sure what (Error 000). Please report this to the developer. Error message:\n' + args[1]
          break
      }
      this.showModal('error-message')
    })
  }
}
</script>

<style lang="scss">

</style>
