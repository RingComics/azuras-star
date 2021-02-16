// Import modules
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
import { initializeConfiguration, getConfig, saveConfig } from './assets/js/config.js'
import { toLog, openLog } from './assets/js/log.js'
import { refreshModlists, createModlist, deleteModlistFromDisk, launchGame } from './assets/js/modlists.js'
import './assets/js/ipcHandler.js'

const homeDirectory = path.join(os.homedir(), 'Azura\'s Star')

// Scheme must be registered before the app is ready
protocol.registerSchemesAsPrivileged([
  { scheme: 'app', privileges: { secure: true, standard: true } }
])

//Functions
function createWindow () { // Create the browser window.
  win = new BrowserWindow({
    width: 1200,
    height: 600,
    title: "Azura's Star",
    icon: path.join(__static, 'azura.png'),
    webPreferences: {
      // Use pluginOptions.nodeIntegration, leave this alone
      // See nklayman.github.io/vue-cli-plugin-electron-builder/guide/security.html#node-integration for more info
      webviewTag: true,
      nodeIntegration: process.env.ELECTRON_NODE_INTEGRATION,
      preload: path.join(__dirname, 'preload.js')
    }
  })

  if (process.env.WEBPACK_DEV_SERVER_URL) {
    // Load the url of the dev server if in development mode
    win.loadURL(process.env.WEBPACK_DEV_SERVER_URL)
    if (!process.env.IS_TEST) win.webContents.openDevTools()
  } else {
    createProtocol('app')
    // Load the index.html when not in development
    win.loadURL(path.join(__dirname, 'index.html'))
  }

  // Remove context menu
  win.removeMenu()

  win.on('closed', () => {
    win = null
  })
}

// Global Variables
const isDevelopment = process.env.NODE_ENV !== 'production'
let win

// App listeners
app.on('activate', () => {
  // On macOS it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (win === null) {
    createWindow()
  }
})

app.on('ready', async () => {
  // This method will be called when Electron has finished
  // initialization and is ready to create browser windows.
  // Some APIs can only be used after this event occurs.
  if (isDevelopment && !process.env.IS_TEST) {
    // Install Vue Devtools
    try {
      await installExtension(VUEJS_DEVTOOLS)
    } catch (e) {
      console.error('Vue Devtools failed to install:', e.toString())
    }
  }
  initializeConfiguration()
  toLog('Creating window.', 1)
  createWindow()

  toLog('App started!\n' + '='.repeat(80) + '\n', 1)
})

app.on('quit', () => {
  toLog('EXITING AZURA\'S STAR', 0)
})

// Exit cleanly on request from parent process in development mode.
if (isDevelopment) {
  if (process.platform === 'win32') {
    process.on('message', (data) => {
      if (data === 'graceful-exit') {
        app.quit()
      }
    })
  } else {
    process.on('SIGTERM', () => {
      app.quit()
    })
  }
}