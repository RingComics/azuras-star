<template>
  <b-container fluid>
    <b-overlay
      :show="loading"
    >
      <b-row>
        <b-col>
        <h2
          style="float:left;"
        >
          Modlists
        </h2>
        </b-col>
      </b-row>
      <b-row align-h="between" align-v="end" class="mb-2">
        <b-col class="pb-0">
            <b-form-select v-model="sort" id="sortBy" @change="sortBy(sort)">
              <b-form-select-option value="modified">Modified ↓</b-form-select-option>
              <b-form-select-option value="modified-reverse">Modified ↑</b-form-select-option>
              <b-form-select-option value="alpha">Alphabetical ↓</b-form-select-option>
              <b-form-select-option value="alpha-reverse">Alphabetical ↑</b-form-select-option>
              <b-form-select-option value="created">Created ↓</b-form-select-option>
              <b-form-select-option value="created-reverse">Created ↑</b-form-select-option>
            </b-form-select>
        </b-col>
        <b-col class="pb-0">
            <b-form-select
              id='gameFilter'
              v-model="selectedGame"
              :options="gamesList"
            />
        </b-col>
        <b-col align-h="end" class="pb-0">
            <b-button-group>
              <b-button
              variant="success"
              @click="showModal('add-modlist-modal')"
              >
                Add new Modlist
              </b-button>
              <b-button
                variant="info"
                @click="refreshModlists()"
              >
                Refresh
              </b-button>
            </b-button-group>
        </b-col>
      </b-row>
      <b-row class="mb-3">
        <b-col>
          <b-form-input
          placeholder="Search for a list..."
          v-model="search"
          />
        </b-col>
      </b-row>
      <div
        class="accordian text-center"
        role="tablist"
      >
        <ModlistProfile
          v-for="(profile, index) in profiles"
          :key="profile.id"
          :name="profile.name"
          :path="profile.path"
          :executables="profile.executables"
          :exe="profile.exe"
          :game="profile.game"
          :profiles="profile.profiles[0]"
          :modified="profile.modified"
          :created="profile.created"
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

    <b-modal ref="add-modlist-modal"
      title="Name Your Profile"
      hide-footer
    >
      <b-form
        @submit="createModlistProfile"
      >
        <p>
          Find your Modlist's folder (where Mod Organizer.exe is) and Azura's
          Star will fill in the modlist info.
        </p>
        <b-form-input
          required placeholder="Enter Modlist name"
          v-model="addModal.name"
        />
        <b-input-group>
          <b-form-input
            required placeholder="Enter Modlist folder"
            v-model="addModal.path"
          />
          <b-input-group-append>
            <b-button
              @click="addModlistPath"
            >
              Browse
            </b-button>
          </b-input-group-append>
        </b-input-group>
        <br/>
        <b-button
          class="float-right"
          type="submit"
          variant="primary"
        >
          Add Modlist
        </b-button>
      </b-form>
    </b-modal>

    <b-modal ref="morrowind-warning"
      title="WARNING"
      ok-only
      @ok="reload()"
    >
      <p>
        Your Morrowind modlist has been added, however, Azura's Star cannot
        manage the game folder files for Morrowind modlists. You will still need
        to manually move and configure the game folder files according to the
        modlists readme if you installed via Wabbajack, or make the
        configurations yourself if this is a custom modlist.
      </p>
    </b-modal>

    <b-modal ref="delete-modlist-modal"
      title="Delete Your Profile"
      hide-footer
    >
      <b-form
        @submit="deleteModlistProfile"
      >
        <p
          class="text-center"
        >
          Are you sure you want to delete {{ this.deleteModal.name }}?
        </p>
        <b-button
          class="float-right"
          type="submit"
          variant="danger"
        >
          Delete from AS
        </b-button>
      </b-form>
    </b-modal>

    <b-modal ref="edit-modlist-modal"
      :title="'Edit Profile ' + this.editModal.property"
      hide-footer
    >
      <b-form
        @submit="changeModlist"
      >
        <b-form-input
          v-if="editModal.property != 'game' & editModal.property != 'selectedProfile' & editModal.property != 'exe'"
          v-model="editModal.value" :value="editModal.value"
        />
        <b-form-select
          v-if="editModal.property == 'game'"
          v-model="editModal.value"
          :options="gamesList"
        />
        <b-select
          v-if="editModal.property == 'selectedProfile'"
          v-model="editModal.value"
          :options="editModal.profiles"
        />
        <b-select
          v-if="editModal.property == 'exe'"
          v-model="editModal.value"
          :options="editModal.executables"
        />
        <b-button
          @click="getPath('this.editModal.value')"
          v-if="editModal.property == 'path'"
        >
          Browse
        </b-button>
        <b-button
          type="submit"
        >
          Change {{ this.editModal.property }}
        </b-button>
      </b-form>
    </b-modal>

    <b-modal ref="game-running"
      :title="'Currently running ' + this.currentList"
      hide-footer
      hide-header-close
      no-close-on-backdrop
      no-close-on-esc
    >
      <h2>Application locked while game is running</h2>
      <p>DO NOT EXIT AZURA'S STAR WHILE THE GAME IS RUNNING.</p>
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
      gamesList: [
        { value: null, text: 'All Games' },
        { value: 'Skyrim', text: 'The Elder Scrolls V: Skyrim Legendary Edition' },
        { value: 'Skyrim Special Edition', text: 'The Elder Scrolls V: Skyrim Special Edition' },
        { value: 'Skyrim VR', text: 'The Elder Scrolls V: Skyrim VR' },
        { value: 'Oblivion', text: 'The Elder Scrolls IV: Oblivion' },
        { value: 'Morrowind', text: 'The Elder Scrolls III: Morrowind' },
        // { value: 'Enderal', text: 'Enderal' },
        { value: 'Fallout 4 VR', text: 'Fallout 4 VR' },
        { value: 'Fallout 4', text: 'Fallout 4' },
        { value: 'New Vegas', text: 'Fallout: New Vegas' },
        { value: 'Fallout 3', text: 'Fallout 3' }
      ],
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
        profiles: [],
        executables: []
      },
      sort: 'modified'
    }
  },
  methods: {
    showModal (name) {
      this.$refs[name].show()
    },
    hideModal (name) {
      this.$refs[name].hide()
    },
    async getConfig () {
      return await window.ipcRenderer.invoke('get-config')
    },
    reload () {
      this.loading = true
      location.reload()
    },
    saveConfig (newConfig) {
      window.ipcRenderer.send('update-config', { newConfig: newConfig })
    },
    createModlistProfile () {
      // Error identifier : 03
      try {
        this.loading = true
        this.hideModal('add-modlist-modal')

        const modlistInfo = {
          name: this.addModal.name,
          path: this.addModal.path
        }

        window.ipcRenderer.invoke('create-modlist-profile', { modlistInfo }).then((result) => {
          if (result === 'ERROR') {
            this.loading = false
            return
          }
          if (result.game === 'Morrowind') {
            this.loading = false
            this.showModal('morrowind-warning')
          } else {
            location.reload()
          }
        })
      } catch (err) {
        this.sendError('F04-03-00', 'Error while requesting modlist creation!', err, 0)
      }
    },
    openModlistProfile (name) {
      // Error identifier: 04
      try {
        const profile = this.profiles.find(x => x.name === name)
        window.ipcRenderer.send('open-modlist-profile', profile.path)
      } catch (err) {
        this.sendError('F04-04-00', 'Error while opening modlist profile folder!', err, 0)
      }
    },
    confirmDeleteModlistProfile (name) {
      this.deleteModal.name = name
      this.showModal('delete-modlist-modal')
    },
    deleteModlistProfile () {
      // Error identifier: 05
      try {
        this.loading = true
        this.hideModal('delete-modlist-modal')
        this.getConfig().then(result => {
          if (result === 'ERROR') return
          delete result.Modlists[this.deleteModal.name]
          this.saveConfig(result)
          location.reload()
        })
      } catch (err) {
        this.sendError('F04-05-00', 'Error while requesting modlist deletion!', err, 0)
      }
    },
    editModlist (args) {
      // Error Identifier: 06
      try {
        this.editModal.list = args[0]
        this.editModal.property = args[1]
        if (args[1] === 'selectedProfile') {
          this.profiles.find(
            x => x.name === args[0]
          ).profiles[0].forEach(
            x => this.editModal.profiles.push(x)
          )
        }
        if (args[1] === 'exe') {
          this.profiles.find(
            x => x.name === args[0]
          ).executables.forEach(
            x => this.editModal.executables.push(x)
          )
        }
        this.showModal('edit-modlist-modal')
      } catch (err) {
        this.sendError('F04-06-00', 'Error while collecting modlist edit info!', err, 0)
      }
    },
    changeModlist () {
      // Error Identifier: 07
      try {
        this.loading = true
        this.getConfig().then(result => {
          if (result === 'ERROR') return
          const listIndex = this.profiles.findIndex(
            obj => obj.name === result.Modlists[this.editModal.list].name
          )
          result.Modlists[this.editModal.list][this.editModal.property] = this.editModal.value
          const newProfile = result.Modlists[this.editModal.list]
          this.profiles[listIndex] = newProfile
          delete result.Modlists[this.editModal.list]
          result.Modlists[newProfile.name] = newProfile
          result.Modlists[newProfile.name].modified = Date.now()
          this.saveConfig(result)
          location.reload()
        })
        this.hideModal('edit-modlist-modal')
      } catch (err) {
        this.sendError('F04-07-00', 'Error while requesting modlist edit!', err, 0)
      }
    },
    getPath () {
      window.ipcRenderer.invoke('get-directory').then(result => {
        if (result !== undefined) {
          this.editModal.value = result[0]
        }
      })
    },
    addModlistPath () {
      window.ipcRenderer.invoke('get-directory').then(result => {
        if (result !== undefined) {
          this.addModal.path = result[0]
        }
      })
    },
    launchGame (list) {
      // Error ID: 08
      try {
        this.currentList = list
        const game = this.profiles[this.profiles.findIndex(x => x.name === list)].game
        if (this.currentConfig.Options.gameDirectories.find(x => x.game === game).path === '') {
          window.ipcRenderer.send('error', {
            code: 'F04-08-01',
            message: 'Your game directory for ' + game + ' could not be found. Please make sure it is set in the options menu and try again',
            err: new Error('Directory not found!')
          })
          return
        }
        this.showModal('game-running')
        window.ipcRenderer.invoke('launch-game', { listName: list })
        window.ipcRenderer.once('game-closed', (event, args) => {
          this.hideModal('game-running')
        })
      } catch (err) {
        this.sendError('F04-08-00', 'Error while initiating game launch!', err, 0)
      }
    },
    launchMO2 (list) {
      window.ipcRenderer.invoke('launch-mo2', list)
    },
    refreshModlists () {
      this.loading = true
      window.ipcRenderer.invoke('refresh-modlists').then(result => {
        location.reload()
      })
    },
    sendError (code, message, err, tabbed) {
      // Error identifier: God help us
      window.ipcRenderer.send('error', { code, message, err, tabbed })
    },
    sortBy (sorting) {
      this.profiles.sort(function (a, b) {
        switch (sorting) {
          case 'alpha':
            return (a.name > b.name) ? 1 : -1
          case 'alpha-reverse':
            return (a.name < b.name) ? 1 : -1
          case 'modified':
            return a.modified - b.modified
          case 'modified-reverse':
            return b.modified - a.modified
          case 'created':
            return a.created - b.created
          case 'created-reverse':
            return b.created - a.created
        }
      })
    }
  },
  beforeMount () {
    // Error identifier 01
  },
  mounted () {
    // Error identifier 02
    try {
      window.ipcRenderer.invoke('refresh-modlists').then(result => {
        this.getConfig().then((result) => {
          if (result === 'ERROR') return
          this.currentConfig = result
          Object.entries(this.currentConfig.Modlists).forEach(key => {
            this.profiles.push({
              name: key[1].name,
              path: key[1].path,
              executables: key[1].executables,
              exe: key[1].exe,
              game: key[1].game,
              profiles: [],
              selectedProfile: key[1].selectedProfile,
              modified: key[1].modified,
              created: key[1].created
            })
            this.profiles[Object.keys(this.currentConfig.Modlists).indexOf(
              key[1].name
            )].profiles.push(
              [...this.currentConfig.Modlists[key[1].name].profiles]
            )
          })
          this.profiles.reverse()
        })
      })
    } catch (err) {
      this.sendError('F04-02-00', 'Error in Modlists.vue mounted()!', err, 0)
    }
  }
}
</script>

<style lang="scss">

</style>
