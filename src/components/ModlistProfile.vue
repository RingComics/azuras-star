<template>
  <b-card
    no-body class="mb-1"
    v-if="
      (
        this.$props.selectedGame == this.$props.game
        ||
        this.$props.selectedGame == null
      )
      &
      (
        this.$props.name.toLowerCase().includes(this.$props.search.toLowerCase())
        ||
        this.$props.search == ''
      )
    "
  >
    <b-card-header
      :disabled="this.$props.gameRunning"
      header-tag="header"
      class="p-1"
      role="tab"
    >
      <b-button
        block
        v-b-toggle="'accordion-'+this.$props.index"
      >
        {{ this.$props.name }}
      </b-button>
    </b-card-header>
    <b-collapse
      :id="'accordion-'+this.$props.index"
      role="tabpanel"
      accordion="modlist"
    >
      <b-tabs>
        <b-tab
          title="Play"
          active
        >
          <b-button
            v-b-popover.hover.top="'Change the Mod Organizer profile used when launching the game'"
            variant="primary"
            v-if="$props.profiles.length > 1"
            @click="$emit('change-modlist', [ name, 'selectedProfile', $props.profiles])"
          >
            Change Profile
          </b-button>
          <br/>
          <p
            v-if="$props.profiles.length > 1"
          >
            Profile: {{ $props.selectedProfile }}
          </p>
          <b-button
            variant="success"
            block
            @click="$emit('play', name)"
          >
            Play
          </b-button>
          <br/>
        </b-tab>
        <b-tab
          title="Options"
        >
          <p
            class="text-left"
          >
            Name: {{ this.$props.name }}
            <b-button
              v-b-popover.hover.top="'Change modlist name'"
              variant="primary"
              @click="$emit('change-modlist', [ name, 'name'])"
              class="float-right"
            >
              Change
            </b-button>
          </p>
          <p
            class="text-left"
          >
            Path: {{ this.$props.path }}
            <b-button
              v-b-popover.hover.top="'Change modlist path'"
              variant="primary"
              @click="$emit('change-modlist', [ name, 'path'])"
              class="float-right"
            >
              Change
            </b-button>
          </p>
          <p
            v-if="this.$props.advancedOptions"
            class="text-left"
          >
            Game: {{ this.$props.game }}
            <b-button
              v-b-popover.hover.top="'Change game the modlist is for'"
              v-if="this.$props.advancedOptions"
              variant="primary"
              @click="$emit('change-modlist', [ name, 'game'])"
              class="float-right"
            >
              Change
            </b-button>
          </p>
          <p
            v-if="this.$props.advancedOptions"
            class="text-left"
          >
            Executable: {{ this.$props.exe }}
            <b-button
              v-b-popover.hover.top="'Change which Mod Organizer executable is used when launching the game'"
              v-if="this.$props.advancedOptions"
              variant="primary"
              @click="$emit('change-modlist', [ name, 'exe'])"
              class="float-right"
            >
              Change
            </b-button>
          </p>
          <b-button
            v-b-popover.hover.top="'Delete this modlist'"
            class="float-right"
            variant="danger"
            @click="$emit('delete', name)"
          >
            Delete
          </b-button>
          <br/>
          <br/>
          <b-button
            v-b-popover.hover.top="'Open the Mod Organizer instance for this modlist'"
            v-if="this.$props.advancedOptions"
            variant="primary"
            @click="$emit('launch-mo2', name)"
          >
            Launch Mod Organizer
          </b-button>
          <b-button
            v-b-popover.hover.top="'Open modlist folder'"
            v-if="this.$props.advancedOptions"
            variant="primary"
            @click="$emit('configure', name)"
          >
            Open Folder
          </b-button>
        </b-tab>
      </b-tabs>
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
    search: String,
    selectedProfile: String,
    selectedGame: String,
    advancedOptions: Boolean
  }
}
</script>
