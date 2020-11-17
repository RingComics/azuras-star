<template>
  <b-container fluid class="text-center">
    <h2>Azura's Star Modlist Manager</h2>
    <p class="text-left">Azura's Star is a modlist manager. You can import modlists by clicking the "Add new Modlist" button in the modlist menu. All of your modlists are kept in that menu as well, which you can filter by game and/or name.</p>
    <p class="text-left">Make sure to set your game directories in the options menu. You can also enable advanced modlist options there, which allow you to directly launch Mod Organizer and change the game and executable used by that list.</p>
    <p class="text-left">Under the links tab you can find socials for the developer (RingComics), the Patreon if you wish to support us, the AS GitHub page if you want to help with development or report a bug, as well as the Discord server where you can get support or follow development.</p>
    <iframe width="50%" :height="this.videoHeight" src="https://www.youtube.com/embed/j78rCYnsO0M" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"></iframe>
  </b-container>
</template>

<script>
export default {
  name: 'Welcome',
  data () {
    return {
      videoHeight: 280.5
    }
  },
  methods: {
    resizeVideo () {
      this.videoHeight = window.innerHeight * 0.50
    }
  },
  mounted () {
    window.addEventListener('resize', this.resizeVideo)
    this.resizeVideo()
  }
}
</script>

<style lang="scss">

</style>
