<!--
  Error Identifier: F01
-->
<template>
  <b-container fluid>
    <b-button class="d-sm-block" v-b-toggle.menu style="position: fixed">
      ≡
    </b-button>
    <b-button class="d-none d-md-block" v-b-toggle.menu style="position: fixed">
      Menu ≡
    </b-button>
    <b-sidebar
      id="menu"
      ref="menu"
      bg-variant="dark"
      text-variant="light"
      :backdrop-variant="'dark'"
      backdrop
      shadow
      no-header
    >
      <h2
        v-b-popover.hover.bottom="'Version ' + this.version"
        class="text-center"
        @click="changeMenu('changelog')"
        style="cursor: pointer"
      >
        Azura's Star
      </h2>
      <b-button
        style="border-radius: 0"
        class="navbutton"
        :pressed="this.currentMenu === '/'"
        @click="changeMenu('/')"
      >
        Modlists
      </b-button>
      <br />
      <!--<b-button
        v-if="this.advancedOptions"
        class=navbutton
        :pressed="this.currentMenu === 'dev'"
        @click="changeMenu('dev')"
      >
        Modlist Development
      </b-button>
      <br/>-->
      <b-button
        style="border-radius: 0"
        class="navbutton"
        :pressed="this.currentMenu === 'options'"
        @click="changeMenu('options')"
      >
        Settings
      </b-button>
      <br />
      <b-button style="border-radius: 0" class="navbutton" v-b-toggle.linksNav>
        Links
      </b-button>
      <b-collapse id="linksNav">
        <b-card>
          <b-link
            class="links"
            v-b-toggle.linksNav
            v-for="link in links"
            :key="link.name"
            @click="followLink(link.href)"
          >
            <b-img :src="link.img" height="15" />
            {{ link.name }}
            <br />
          </b-link>
        </b-card>
      </b-collapse>
      <div v-if="this.dev">
        <h3>Dev Options</h3>
        <b-button
          @click="
            sendError(
              'DummyError',
              'Tasked failed successfully!',
              '404: Error not found',
              0
            )
          "
          >Send Error</b-button
        >
      </div>
    </b-sidebar>

    <b-modal ref="error-modal" ok-only title="An error occured!">
      <p>{{ this.error.message }}</p>
      <p>Error code: {{ this.error.code }}</p>
      <p>{{ this.error.err }}</p>
    </b-modal>
  </b-container>
</template>

<script>
export default {
  name: 'LeftPanel',
  data() {
    return {
      currentMenu: '',
      advancedOptions: false,
      currentList: '',
      version: '',
      dev: false,
      error: {
        message: '',
        err: '',
        code: '',
      },
      links: [
        {
          name: 'Patreon',
          href: 'https://www.patreon.com/ringcomics',
          img: require('../assets/img/patreon-icon.png'),
        },
        {
          name: 'Discord',
          href: 'https://discord.gg/6wusMF6',
          img: require('../assets/img/discord-icon.png'),
        },
        {
          name: 'YouTube',
          href: 'https://www.youtube.com/channel/UCif_YWnOGA1HLlkH_4rvIwA',
          img: require('../assets/img/youtube-icon.png'),
        },
        {
          name: 'Twitch',
          href: 'https://www.twitch.tv/ringcomics',
          img: require('../assets/img/twitch-icon.png'),
        },
        {
          name: 'GitHub',
          href: 'https://ringcomics.github.io/azuras-star/',
          img: require('../assets/img/github.png'),
        },
        {
          name: 'NexusMods',
          href: 'https://www.nexusmods.com/skyrimspecialedition/mods/42528',
          img: require('../assets/img/nexus-logo.png'),
        },
      ],
    }
  },
  methods: {
    changeMenu(value) {
      // Error identifier: 03
      try {
        if (!this.$route.path.endsWith(value)) {
          this.$router.push(value)
          this.currentMenu = value
        }
      } catch (err) {
        this.sendError('F01-03-01', 'Error while changing menus!', err, 0)
      }
    },
    followLink(value) {
      // Error Identifier: 04
      try {
        window.ipcRenderer.send('follow-link', { link: value })
      } catch (err) {
        this.sendError(
          'F01-04-01',
          'Error while opening web link!\nLink: ' + value,
          err,
          0
        )
      }
    },
    sendError(code, message, err, tabbed) {
      // Error identifier: God help us
      window.ipcRenderer.send('error', {
        code: code,
        message: message,
        err: err,
        tabbed: tabbed,
      })
    },
  },
  beforeMount() {
    // Error identifier 01
  },
  mounted() {
    // Error identifier 02
    try {
      window.ipcRenderer.invoke('get-config').then((result) => {
        if (result === 'ERROR') return
        this.advancedOptions = result.Options.advancedOptions
        this.version = result.version
        this.dev = result.isDevelopment
      })
      window.ipcRenderer.send('initialized')
      window.ipcRenderer.on('error', (_event, { code, message, err }) => {
        this.error.code = code
        this.error.message = message
        this.error.err = err
        this.$refs['error-modal'].show()
      })
    } catch (err) {
      this.sendError('F01-02-00', 'Error in LeftPanel.vue mounted()!', err, 0)
    }
  },
}
</script>

<style lang="scss">
.navbutton {
  width: 100%;
  border-radius: 0;
}
</style>
