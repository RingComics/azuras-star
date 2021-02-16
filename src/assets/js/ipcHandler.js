import { app, protocol, dialog, BrowserWindow, ipcMain, shell } from 'electron'
import { createProtocol } from 'vue-cli-plugin-electron-builder/lib'
import installExtension, { VUEJS_DEVTOOLS } from 'electron-devtools-installer'
import path from 'path'
import fs from 'fs'
import childProcess from 'child_process'
import ncp from 'ncp'
import os from 'os'
import ini from 'ini'
import http from 'https'
import { ModalPlugin } from 'bootstrap-vue'
import { initializeConfiguration, getConfig, saveConfig, resetConfig } from './config.js'
import { currentLogPath, toLog, openLog, getLog } from './log.js'
import { refreshModlists, createModlist, launchGame } from './modlists.js'

const homeDirectory = path.join(os.homedir(), 'Azura\'s Star')

// IPC On: No return
// IPC Handle: Returns object
ipcMain.on('follow-link', (_event, args) => {     // Open hyperlinks in the default browser
    toLog('Opening link: ' + args, 0)
    shell.openExternal(args)
}).on('open-modlist-profile', (_event, args) => { // Open path to modlist folder
    toLog('Opening explorer path: ' + args, 0)
    shell.openPath(args)
}).on('open-log', (_event, args) => {             // Open current log
    openLog()
}).on('open-logs-directory', (_event, args) => {  // Open logs folder
    shell.showItemInFolder(currentLogPath)
}).on('update-config', (_event, args) => {        // Update configuration file
    toLog('Recieved new configuration from front-end', 0)
    saveConfig(args, 1)
}).on('launch-mo2', (_event, args) => {           // Launch MO2
    toLog('Launching MO2 instance for ' + args, 0)
    const currentConfig = getConfig(1)
    const moPath = path.join(currentConfig.Modlists[args].path, '\\ModOrganizer.exe')
    childProcess.exec('"' + moPath + '"')
}).on('open-dev-tools', (_event, args) => {       // Open Developer Console
    toLog('Opening developer tools', 0)
    _event.sender.openDevTools()
}).on('open-config', (_event, args) => {
    shell.openPath(path.join(homeDirectory, 'options.json'))
})

ipcMain.handle('create-modlist-profile', async (_event, modlistInfo) => {  // Add a new modlist profile
    return createModlist(modlistInfo)
})

ipcMain.handle('refresh-modlists', async (_event, args) => {               // Refresh modlist cache
    return refreshModlists()
})

ipcMain.handle('get-config', async (_event, args) => {                     // Get configuration
    toLog('Front-end requesting config', 0)
    return getConfig(1)
})

ipcMain.handle('get-directory', async (_event, args) => {                  // Get Directory
    toLog('Getting directory', 0)
    return dialog.showOpenDialogSync({
        buttonLabel: 'Choose Folder',
        properties: ['openDirectory']
    })
})

ipcMain.handle('launch-game', async (_event, args) => {                    // Launch modlist
    launchGame(args)
})

ipcMain.handle('reset-config', async (_event, args) => {                   // Reset config to default
    toLog('Reseting configurations.', 0)
    return resetConfig()
})