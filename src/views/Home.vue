<template>
  <b-container fluid>
    <b-row no-gutters>
      <b-col cols="3">
        <LeftPanel />
      </b-col>
      <b-col>
        <CenterPanel />
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import LeftPanel from '../components/LeftPanel.vue'
import CenterPanel from '../components/CenterPanel.vue'

export default {
  name: 'Home',
  components: {
    LeftPanel,
    CenterPanel
  }
}
</script>

<style lang="scss">
  * {
    color: #0c1c24;
    background-color: transparent;
  }
  template {
    background-color: #8aa491;
  }
</style>
