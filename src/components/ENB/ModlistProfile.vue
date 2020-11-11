<template>
  <b-card no-body class="mb-1" v-if="this.$props.selectedGame == this.$props.game || this.$props.selectedGame == null">
    <b-card-header header-tag="header" class="p-1" role="tab">
      <b-button block v-b-toggle="'accordion-'+this.$props.index">{{ this.$props.name }}</b-button>
    </b-card-header>
    <b-collapse :id="'accordion-'+this.$props.index" role="tabpanel" accordion="modlist">
        <p class="text-left">Name: {{ this.$props.name }} <b-button variant="primary" @click="$emit('change-modlist', [ name, 'name'])" class="float-right">Change</b-button></p>
        <p class="text-left">Path: {{ this.$props.path }} <b-button variant="primary" @click="$emit('change-modlist', [ name, 'path'])" class="float-right">Change</b-button></p>
        <p class="text-left">Game: {{ this.$props.game }} <b-button variant="primary" @click="$emit('change-modlist', [ name, 'game'])" class="float-right">Change</b-button></p>
        <p class="text-left">Executable: {{ this.$props.exe }} <b-button variant="primary" @click="$emit('change-modlist', [ name, 'exe'])" class="float-right">Change</b-button></p>
        <b-button variant="primary" @click="$emit('configure', name)">Open Folder</b-button>
        <b-button variant="primary" v-if="$props.profiles.length > 1" @click="$emit('change-modlist', [ name, 'selectedProfile', $props.profiles])">Change Profile</b-button>
        <b-button variant="primary" @click="$emit('delete', name)">Delete</b-button><br/>
        <p v-if="$props.profiles.length > 1">Profile: {{ $props.selectedProfile }}</p>
        <br />
        <b-button variant="success" block @click="$emit('play', name)">Play</b-button><br/>
    </b-collapse>
  </b-card>
</template>

<script>
export default {
  name: 'ModlistProfile',
  props: {
    name: String,
    path: String,
    exe: String,
    game: String,
    index: Number,
    profiles: Array,
    selectedProfile: String,
    selectedGame: String
  }
}
</script>
