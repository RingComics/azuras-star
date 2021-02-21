<template>
  <b-container fluid>
    <b-row no-gutters>
      <b-col cols="1.5" style="width: 10%">
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
    CenterPanel,
  },
}
</script>

<style lang="scss"></style>
