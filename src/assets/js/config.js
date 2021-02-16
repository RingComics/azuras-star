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
import { currentLogPath, toLog, openLog } from './log.js'
import { refreshModlists, createModlist, deleteModlistFromDisk, launchGame } from './modlists.js'

const homeDirectory = path.join(os.homedir(), 'Azura\'s Star')
const defaultConfig = require('../json/defaultConfig.json')
const appPath = process.argv[0]
const isDevelopment = process.env.NODE_ENV !== 'production'

export function initializeConfiguration() {
    if (!fs.existsSync(homeDirectory, err => { throw err })) {
        fs.mkdir(homeDirectory, err => { throw err })
        fs.mkdir(path.join(homeDirectory, 'logs'), err => { throw err })
    }

    if (!fs.existsSync(path.join(homeDirectory, 'logs'), err => { throw err })) {
        fs.mkdir(path.join(homeDirectory, 'logs'), err => { throw err })
    }

    fs.writeFileSync(currentLogPath, "LOG BEGIN")
    toLog('Azura\'s Star version ' + defaultConfig.version, 0)
    toLog('Home Directory path: ' + homeDirectory, 0)
    toLog('Starting...\n' + '='.repeat(80), 0)
    toLog('Checking for configuration file', 1)

    let oldConfig = {}
    if (!fs.existsSync(path.join(homeDirectory, '/options.json'))) {
        toLog('File not found! Creating configuration file at ' + path.join(homeDirectory, 'options.json'), 2)
        fs.writeFileSync(path.join(homeDirectory, 'options.json'), JSON.stringify(defaultConfig, null, 2))
        oldConfig = defaultConfig
    } else { // Store current configuration
        toLog('Configuration file found at ' + path.join(homeDirectory, 'options.json'), 2)
        oldConfig = JSON.parse(fs.readFileSync(path.join(homeDirectory, '/options.json'), 'utf-8'))
    }
    // If current config is using < 2.2.0 format, change it to current
    if (oldConfig.version == undefined) {
        toLog('Configuration file is < v2.1.0, applying configuration changes.', 2)
        oldConfig.Options.gameDirectories.forEach((entry, index) => {
            oldConfig.Options.gameDirectories[index].game = defaultConfig.Options.gameDirectories[index].game
        })
        oldConfig.version = defaultConfig.version
    } else if (oldConfig.version != defaultConfig.version) {
        toLog('Updating config version from ' + oldConfig.version + ' to ' + defaultConfig.version, 2)
        oldConfig.version = defaultConfig.version
    }
    oldConfig.ASPath = appPath
    oldConfig.isDevelopment = isDevelopment
    toLog('Configuration:\n' + JSON.stringify(oldConfig, null, 2), 2)
    fs.writeFileSync(path.join(homeDirectory, 'options.json'), JSON.stringify(oldConfig, null, 2))
    // If deprecated Modlists folder exists, delete it
    if (fs.existsSync(path.join(homeDirectory, 'Modlists'))) {
        toLog('Deprecated "Modlists" folder detected, deleting...', 0)
        fs.rmdirSync(path.join(homeDirectory, 'Modlists'))
    }
}

export function getConfig(tabbed) {
    toLog('Reading config', tabbed)
    return JSON.parse(fs.readFileSync(path.join(homeDirectory, 'options.json')))
}

export function saveConfig(newConfig, tabbed) {
    // newConfig is a JSON object with the new configuration in it
    toLog('Saving config', tabbed)
    toLog('New Configuration:\n' + JSON.stringify(newConfig, null, 2), tabbed)
    fs.writeFileSync(path.join(homeDirectory, '/options.json'), JSON.stringify(newConfig, null, 2))
}

export function resetConfig() {
    saveConfig(defaultConfig, 1)
    let newConfig = getConfig(1)
    newConfig.ASPath = appPath
    newConfig.isDevelopment = isDevelopment
    saveConfig(newConfig, 1)
}