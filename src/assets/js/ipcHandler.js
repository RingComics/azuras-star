// Purpose: Handle IPC communication
// Error ID: B03

// Import Modules
import { 
    app,
    protocol,
    dialog,
    BrowserWindow,
    ipcMain,
    shell
} from 'electron'
import { createProtocol } from 'vue-cli-plugin-electron-builder/lib'
import installExtension, { VUEJS_DEVTOOLS } from 'electron-devtools-installer'
import path from 'path'
import fs from 'fs'
import childProcess from 'child_process'
import ncp from 'ncp'
import os from 'os'
import ini from 'ini'
import request from 'request'
import FormData from 'form-data'
import { ModalPlugin } from 'bootstrap-vue'
import {
    initializeConfiguration,
    getConfig,
    saveConfig
} from './config.js'
import {
    toLog,
    openLog
} from './log.js'
import {
    refreshModlists,
    createModlist,
    deleteModlistFromDisk,
    launchGame
} from './modlists.js'
import {
    sendError,
    fatalError
} from './errorHandler.js'

// Declare global variables
const homeDirectory = path.join(os.homedir(), 'Azura\'s Star')
let webContents

//Functions
    // Returns webContents object to modules without access to the win object. Error ID: B03-01
    export function getWebContents() {
        try {
            return webContents
        } catch (err) {
            sendError('B02-02-00', 'Error while returning WebContents', err, 0)
        }
    }

// IPC handling
    // Open hyperlinks in the default browser. Error ID: B03-02
    ipcMain.on('follow-link', (_event, { link }) => {
        // link = String
        try {
            toLog('Opening link: ' + link, 0)
            shell.openExternal(link)
        } catch (err) {
            sendError(
                'B03-02-00',
                'Error while opening web link! Link:' + link, 
                err
            )
        }
    })
    // Open path to folder. Error ID: B03-03
    ipcMain.on('open-modlist-profile', (_event, { path }) => {
        // path = String
        try {
            toLog('Opening explorer path: ' + path, 0)
            shell.openPath(path)
        } catch (err) {
            sendError(
                'B03-03-00',
                'Error while opening file path! Path:' + path, 
                err
            )
        }
    })
    // Open logs folder. Error ID: B03-04
    ipcMain.on('open-logs-directory', () => {
        try {
            shell.showItemInFolder(currentLogPath)
        } catch (err) {
            sendError('B03-04-00', 'Error while opening logs folder!', err)
        }
    })
    // Launch MO2. Error ID: B03-05
    ipcMain.on('launch-mo2', (_event, { listName }) => {
        // listName = String
        try {
            toLog('Launching MO2 instance for ' + listName, 0)
            const currentConfig = getConfig(1)
            if (currentConfig === 'ERROR') return
            const moPath = path.join(currentConfig.Modlists[listName].path, '\\ModOrganizer.exe')
            childProcess.exec('"' + moPath + '"')
        } catch (err) {
            sendError('B03-05-00', 'Error while opening MO2 for ' + listName + '!', err)
        }
    })
    // Open Developer Console. Error ID: B03-06
    ipcMain.on('open-dev-tools', _event => {
        try {
            toLog('Opening developer tools', 0)
            _event.sender.openDevTools()
        } catch (err) {
            sendError('B03-06-00', 'Error while opening developer tools!', err)
        }
    })
    // Open config file. Error ID: B03-07
    ipcMain.on('open-config', () => {
        try {
            shell.openPath(path.join(homeDirectory, 'options.json'))
        } catch (err) {
            sendError('B03-07-00', 'Error while opening config file!', err)
        }
    })
    // Stores webContents on app initialization. Error ID: B03-08
    ipcMain.once('initialized', _event => {
        try {
            webContents = _event.sender
        } catch (err) {
            sendError('B03-08-00', 'Error while recieving front-end initialization confirmation', err, 0)
        }
    })
    // Get Directory. Error ID: B03-09
    ipcMain.handle('get-directory', async () => {
        try {
            toLog('Getting directory', 0)
            return dialog.showOpenDialogSync({
                buttonLabel: 'Choose Folder',
                properties: ['openDirectory']
            })
        } catch (err) {
            sendError('B03-09-00', 'Error while getting directory path!', err, 0)
        }
    })
    // Forwards errors sent from front-end to errorHandler.js. No Error ID
    ipcMain.on('error', (_event, { code, message, err, tabbed }) => {
        // code = String
        // message = String
        // err = ErrorConstructor
        // tabbed = Number
        sendError(code, message, err, tabbed)
    })
    // Add a new modlist profile. No Error ID
    ipcMain.handle('create-modlist-profile', async (_event, { modlistInfo }) => {
        // modlistInfo = JSON object
        return createModlist(modlistInfo)
    })
    // Refresh modlist cache. No Error ID
    ipcMain.handle('refresh-modlists', async () => {
        return refreshModlists()
    })
    // Get configuration. No Error ID
    ipcMain.handle('get-config', async () => {
        toLog('Front-end requesting config', 0)
        return getConfig(1)
    })
    // Launch modlist. No Error ID
    ipcMain.handle('launch-game', async (_event, { listName }) => {
        // listName = String
        launchGame(listName)
    })
    // Reset config to default. No Error ID
    ipcMain.handle('reset-config', async () => {
        toLog('Reseting configurations.', 0)
        return resetConfig()
    })
    // Open current log. No Error ID
    ipcMain.on('open-log', () => {
        openLog()
    })
    // Update configuration file. No Error ID.
    ipcMain.on('update-config', (_event, { newConfig }) => {
        // newConfig = JSON object
        toLog('Recieved new configuration from front-end', 0)
        saveConfig(newConfig, 1)
    })