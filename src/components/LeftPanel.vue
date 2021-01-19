<template>
  <b-container fluid>
    <b-button v-b-toggle.menu style="position:fixed;">Menu ≡</b-button>
    <b-sidebar id="menu" bg-variant="dark" text-variant="light" :backdrop-variant="'dark'" backdrop shadow no-header>
      <h2 v-b-popover.hover.bottom="'Version 2.1.0'" class="text-center">Azura's Star</h2>
      <!--<b-button v-if="this.advancedOptions" class=navbutton :pressed="this.currentMenu === 'dev'" @click="changeMenu('dev')">Modlist Development</b-button><br/>-->
      <b-button style="border-radius:0;" class=navbutton :pressed="this.currentMenu === 'modlists'" @click="changeMenu('modlists')">Modlists</b-button><br/>
      <b-button style="border-radius:0;" class=navbutton :pressed="this.currentMenu === 'options'" @click="changeMenu('options')">Options</b-button><br/>
      <b-button style="border-radius:0;" class=navbutton v-b-toggle.linksNav>Links</b-button>
      <b-collapse id=linksNav>
        <b-card>
          <b-link class='links' v-b-toggle.linksNav v-for="link in links" :key="link.name" @click="followLink(link.href)">
            <b-img :src="link.img" height="15"/>
            {{ link.name }}<br>
          </b-link>
        </b-card>
      </b-collapse>
    </b-sidebar>
  </b-container>
</template>

<script>
export default {
  name: 'LeftPanel',
  data () {
    return {
      currentMenu: '',
      advancedOptions: false,
      links: [
        { name: 'Patreon', href: 'https://www.patreon.com/ringcomics', img: require('../assets/patreon-icon.png') },
        { name: 'Discord', href: 'https://discord.gg/6wusMF6', img: require('../assets/discord-icon.png') },
        { name: 'YouTube', href: 'https://www.youtube.com/channel/UCif_YWnOGA1HLlkH_4rvIwA', img: require('../assets/youtube-icon.png') },
        { name: 'Twitch', href: 'https://www.twitch.tv/ringcomics', img: require('../assets/twitch-icon.png') },
        { name: 'GitHub', href: 'https://ringcomics.github.io/azuras-star/', img: require('../assets/github.png') }
      ]
    }
  },
  methods: {
    changeMenu (value) {
      if (this.$route.path.endsWith(value)) {
        this.$router.push('/')
        this.currentMenu = ''
      } else {
        this.$router.push(value)
        this.currentMenu = value
      }
    },
    followLink (value) {
      window.ipcRenderer.send('follow-link', value)
    },
    getGameDirectory () {
      window.ipcRenderer.invoke('get-directory').then((result) => {
        if (result !== undefined) { this.GameDirectory = result[0] }
      })
    },
    getModDirectory () {
      window.ipcRenderer.invoke('get-directory').then((result) => {
        if (result !== undefined) { this.ModDirectory = result[0] }
      })
    }
  },
  mounted () {
    window.ipcRenderer.invoke('get-config').then(result => {
      this.advancedOptions = result.Options.advancedOptions
    })
  }
}
</script>

<style lang="scss">
  .navbutton {
    width: 100%;
    border-radius: 0;
  }
  .links {
    color: red;
  }
</style>
