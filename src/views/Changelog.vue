<!--
    Error identifier: 02
-->
<template>
  <b-container>
    <h1>Changelog</h1>
    <b-card>
      <h2>
        <b-link
          @click="
            followLink(
              'https://github.com/RingComics/azuras-star/releases/tag/v2.2.1'
            )
          "
          >2.2.1</b-link
        >
      </h2>
      <h6>Released on Feb 9, 2021</h6>
      <h4>Changes</h4>
      <p>None</p>
      <h4>Bug Fixes</h4>
      <ul>
        <li>Modlists no longer sync up with MO2's last executable</li>
        <li>
          Modlists use script extenders as default executable on Modlist
          creation
        </li>
        <li>
          Selected profile no longer updates to the first profile alphabetically
        </li>
      </ul>
      <h4>Known Issues</h4>
      <p>
        Modlists have a tendency to break if the selected executable is deleted
        from MO2. This can easily be fixed by changing it in the advanced
        Modlist options.
      </p>
    </b-card>

    <b-card>
      <h2>
        <b-link
          @click="
            followLink(
              'https://github.com/RingComics/azuras-star/releases/tag/v2.2.0'
            )
          "
          >2.2.0</b-link
        >
      </h2>
      <h6>Released on Feb 3, 2021</h6>
      <h4>Changes</h4>
      <ul>
        <li>Added Nexus Mods to links</li>
        <li>Improved code formatting</li>
        <li>
          Added a button to open the console (only visible when Advanced Options
          is ticked)
        </li>
        <li>App no longer minimizes on game launch</li>
        <li>Rearranged package structure</li>
        <li>
          Modlists refresh values when the modlist page loads or when the new
          Refresh button is pressed
        </li>
        <li>
          Executables now change on a dropdown similar to profiles. These values
          are derived from MO2's configuration file
        </li>
        <li>
          Game names in options.json config file and the settings menu now
          exactly match MO2's naming scheme
        </li>
        <li>Property "version" added to default configuration file</li>
        <li>
          Initialization script now recognizes the old config format and updates
          it accordingly
        </li>
        <li>Links are now blue</li>
        <li>
          Changelog page added, accessed by clicking "Azura's Star" in the
          sidebar (Hey that's this thing!)
        </li>
        <li>
          Launcher settings now update the config automatically when changed
        </li>
        <li>WJ directory setting removed</li>
        <li>App module dependencies updated</li>
      </ul>
      <h4>Bug Fixes</h4>
      <p>None</p>
      <h4>Known Issues</h4>
      <ul>
        <li>
          The default executable used by Azura's Star on modlist creation is the
          same as MO2's selected executable. MO2 sometimes fails to change the
          value, resulting in a random executable being chosen instead.
        </li>
        <li>
          Modlists have a tendency to break if the selected executable is
          deleted from MO2. This can easily be fixed by changing it in the
          advanced Modlist options.
        </li>
      </ul>
    </b-card>

    <b-card>
      <h2>
        <b-link
          @click="
            followLink(
              'https://github.com/RingComics/azuras-star/releases/tag/v2.1.0'
            )
          "
          >2.1.0</b-link
        >
      </h2>
      <h6>Released on Jan 18, 2021</h6>
      <h4>Changes</h4>
      <ul>
        <li>Updated package dependencies</li>
        <li>Removed Morrowind Game Folder Files support</li>
        <li>Properly licensed the tool</li>
        <li>
          Made a number of styling changes, including implementing a new dark
          theme instead of the eye blinding light.
        </li>
      </ul>
      <p></p>
    </b-card>

    <b-card>
      <h2>
        <b-link
          @click="
            followLink(
              'https://github.com/RingComics/azuras-star/releases/tag/v2.0.1'
            )
          "
          >2.0.1</b-link
        >
      </h2>
      <h6>Released on Nov 18, 2020</h6>
      <p>
        Small bug fix causing certain lists to fail when launching their script
        extender.
      </p>
    </b-card>

    <b-card>
      <h2>
        <b-link
          @click="
            followLink(
              'https://github.com/RingComics/azuras-star/releases/tag/v2.0.0'
            )
          "
          >2.0.0</b-link
        >
      </h2>
      <h6>Released on Nov 17, 2020</h6>
      <p>Finally got around to finishing moving over to Electron</p>
      <p>
        Will add more documentation in the coming weeks. Download and run.
        Currently only recommend using with WJ lists until I get some
        documentation written.
      </p>
      <p>
        <b-link
          @click="followLink('https://www.youtube.com/watch?v=j78rCYnsO0M')"
          >Introduction video</b-link
        >
      </p>
      <p>
        More info, support, and dev updates in my
        <b-link @click="followLink('https://www.discord.gg/6wusMF6')"
          >Discord</b-link
        >
      </p>
    </b-card>

    <b-card>
      <h2>
        <b-link
          @click="
            followLink(
              'https://github.com/RingComics/azuras-star/releases/tag/v1.2.3'
            )
          "
          >1.2.3</b-link
        >
      </h2>
      <h6>Released on May 29, 2020</h6>
      <p>haha remember when I said that would be the last powershell release</p>
      <p>I lied</p>
      <p>This new version should actually install UltSky without borking.</p>
      <p>Unzip and run AzurasStar.exe</p>
      <p>
        If you get errors during the DLC cleaning, run the Finalize step again.
      </p>
      <p>Thanks for all the support.</p>
    </b-card>

    <b-card>
      <h2>
        <b-link
          @click="
            followLink(
              'https://github.com/RingComics/azuras-star/releases/tag/v1.2.2'
            )
          "
          >1.2.2</b-link
        >
      </h2>
      <h6>Released on Mar 27, 2020</h6>
      <h4>Changes</h4>
      <ul>
        <li>Updated to reflect the most version of Ultimate Skyrim.</li>
        <li>
          Fixed a bug with the installer not recognizing the modpack
          installation folder.
        </li>
      </ul>
      <h4>Known Issues</h4>
      <ul>
        <li>
          Sometimes the ENB files are unpacked into the root of Skyrim's root
          folder. This doesn't cause any issues but is very ugly.
        </li>
      </ul>
    </b-card>

    <b-card>
      <h2>
        <b-link
          @click="
            followLink(
              'https://github.com/RingComics/azuras-star/releases/tag/v1.2.0'
            )
          "
          >1.2.0</b-link
        >
      </h2>
      <h6>Released on Mar 9, 2020</h6>
      <p>
        Note: You will need to download the most recent .auto files from
        <b-link
          @click="
            followLink(
              'https://www.ultimateskyrim.com/express-installation-free'
            )
          "
        >
          Ultimate Skyrim's website</b-link
        >
      </p>
    </b-card>

    <b-card>
      <h2>
        <b-link
          @click="
            followLink(
              'https://github.com/RingComics/azuras-star/releases/tag/1.1.0-rc1'
            )
          "
          >1.1.0</b-link
        >
      </h2>
      <h6>Released on Feb 3, 2020</h6>
      <h4>Features:</h4>
      <ul>
        <li>Added cleaning DLC as a separate button</li>
        <li>Added ability to detect multiple Skyrim installs</li>
        <li>
          If the lookup for the Skyrim install path fails, gives the option to
          manually input the path
        </li>
      </ul>
      <h4>Bug fixes</h4>
      <ul>
        <li>Fixed DLC not correctly cleaning</li>
      </ul>
    </b-card>

    <b-card>
      <h2>
        <b-link
          @click="
            followLink(
              'https://github.com/RingComics/azuras-star/releases/tag/v1.0.0'
            )
          "
          >1.0</b-link
        >
      </h2>
      <h6>Released on Jan 19, 2020</h6>
      <p>Installer now installs UltSky completely!</p>
      <p>A few things to note:</p>
      <ul>
        <li>Template save only works with keyboard users.</li>
        <li>
          If you have black bars when you load in, you need to change the ENB
          settings by hitting SHIFT+ENTER and changing the letterbox setting
          under EFFECT.TXT in the right-hand pane. This should be fixed in the
          latest commit but it still happens to some users.
        </li>
        <li>
          You still need to change your Ultimate Skyrim MCM settings to your
          liking before hitting "Begin Your Adventure"
        </li>
        <li>
          Post-Start MCM still needs to be configured as seen
          <b-link
            @click="
              followLink(
                'https://docs.google.com/document/d/1VlPjBuCTIkRHe5Mx1M3Yw4uYb5xGfoZetCKdfMqMo0A/edit#heading=h.qc6slo7zww5t'
              )
            "
            >here.</b-link
          >
        </li>
      </ul>
      <h4>Changes</h4>
      <ul>
        <li>
          Bug Fixes
          <ul>
            <li>
              SKSE and ENB now install correctly (and in the right order), which
              was before causing a CTD upon loading into a save
            </li>
            <li>
              Installer now waits for TES5Edit to finish cleaning DLCs before
              prompting to continue.
            </li>
            <li>Fixed memory leak</li>
          </ul>
        </li>
        <li>Template Save reintegrated, Keyboard only!</li>
      </ul>
    </b-card>
  </b-container>
</template>
<script>
export default {
  name: 'changelog',
  methods: {
    followLink(value) {
      try {
        window.ipcRenderer.send('follow-link', { link: value })
      } catch (err) {
        this.sendError(
          'F02-01-01',
          'Error while opening web link!\nLink: ' + value,
          err,
          0
        )
      }
    },
  },
}
</script>

<style lang="scss">
h6 {
  color: gray;
}
h4 {
  text-decoration: underline;
}
</style>
