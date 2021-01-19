# Azura's Star

A modding tool for managing modlists

[Nexus](https://www.nexusmods.com/skyrimspecialedition/mods/42528)

[Discord](https://www.discord.gg/6wusMF6)

[Youtube](https://www.youtube.com/channel/UCif_YWnOGA1HLlkH_4rvIwA)

[Patreon](https://www.patreon.com/ringcomics)

## Installation

Azura's Star doesn't require any dependencies, just install using the setup executable or extract the portable download to a folder. [Wabbajack](https://www.wabbajack.org) is a very useful tool, however, and Azura's Star was designed with it in mind.

## Usage

### With Wabbajack modlists
After installing your modlist using Wabbajack, make sure you follow all of the steps in that modlists read me, EXCEPT for moving the Game Folder Files into your game installation (Azura's Star does this before you launch the modlist). If a step requires you to move a file into your game installation for patching, you still need to do this, but ENB files and script extenders will be moved over when you launch the modlist.

### With non-Wabbajack modlists
Azura's Star still works with non-Wabbajack installed modlists, just make sure to create a folder called "Game Folder Files" inside your MO2 folder. You can put all of your script extenders, ENB files, and any other files that need to be inside of the game install folder while the modlist runs. You can enable Advanced Options in the Options menu if you need to change the name of the executable that launches the game.

You can then add your modlist in the Modlist Menu with the Add a Modlist button. Azura's Star will detect what it needs from the Mod Organizer install, and add it to the list.

You can check the [wiki](https://github.com/RingComics/azuras-star/wiki) for more help as it's updated.

## Contributing
If you want to help with development, great! You need to have Node.js installed. Clone the repo and run `npm install` in the repo folder. Please avoid adding extra modules without communicating with me first. I'll review any pull requests submitted.

Specifically, we do need someone to make the application look a little less ugly, feel free to PM me on Discord if you are interested.
