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

const isDevelopment = process.env.NODE_ENV !== 'production'

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let win

// Scheme must be registered before the app is ready
protocol.registerSchemesAsPrivileged([
  { scheme: 'app', privileges: { secure: true, standard: true } }
])

function createWindow () {
  // Create the browser window.
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

app.on('activate', () => {
  // On macOS it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (win === null) {
    createWindow()
  }
})

// Define default configuration settings and configuration directory
const homedir = path.join(os.homedir(),'Azura\'s Star')
if(!fs.existsSync(homedir, err => {throw err})) {
  toLog('Home Directory does not exist! Creating directory at ' + homedir)
  fs.mkdir(homedir, err => { throw err })
  fs.mkdir(path.join(homedir, 'logs'), err => {throw err})
}
if(!fs.existsSync(path.join(homedir, 'logs'), err => {throw err})) {
  fs.mkdir(path.join(homedir, 'logs'), err => {throw err})
}
const appPath = process.argv[0]

let defaultConfig = require('./assets/json/defaultConfig.json')
defaultConfig.Options.ASPath = appPath

// Create new log file
function getCurrentTime () {
  let date = new Date
  let time = date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds()
  return time.toString()
}

function getCurrentDate () {
  let date = new Date
  let time = getCurrentTime()
  let output = date.getFullYear() + '-' + date.getMonth() + '-' + date.getDate() + '-' + time.replace(/:/g,'-')
  return output
}

let logName = getCurrentDate() + '.txt'
const currentLogPath = path.join(homedir, '/logs/', logName)
fs.writeFileSync(currentLogPath, "LOG BEGIN")

function toLog (log) {
  fs.appendFileSync(currentLogPath, '\n' + getCurrentTime() + '  -  ' + log)
}

toLog('Azura\'s Star version ' + defaultConfig.version)
toLog('Home Directory path: ' + homedir)

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', async () => {
  if (isDevelopment && !process.env.IS_TEST) {
    // Install Vue Devtools
    try {
      await installExtension(VUEJS_DEVTOOLS)
    } catch (e) {
      console.error('Vue Devtools failed to install:', e.toString())
    }
  }
  toLog('Creating window.')
  createWindow()

  // Check if configuration file exists, if not, create a default one
  toLog('Checking for configuration file')
  let oldConfig = {}
  if (!fs.existsSync(path.join(homedir, '/options.json'))) {
    toLog('  File not found! Creating configuration file at ' + path.join(homedir, 'options.json'))
    fs.writeFileSync(path.join(homedir, 'options.json'), JSON.stringify(defaultConfig, null, 2))
    oldConfig = defaultConfig
  } else { // Store current configuration
    toLog('  Configuration file found at ' + path.join(homedir, 'options.json'))
    oldConfig = JSON.parse(fs.readFileSync(path.join(homedir, '/options.json'), 'utf-8'))
  }
  // If current config is using < 2.2.0 format, change it to current
  if (oldConfig.version == undefined) {
    toLog('  Configuration file is < v2.1.0, applying configuration changes.')
    oldConfig.Options.gameDirectories.forEach((entry, index) => {
      oldConfig.Options.gameDirectories[index].game = defaultConfig.Options.gameDirectories[index].game
    })
    oldConfig.version = defaultConfig.version
    fs.writeFileSync(path.join(homedir, 'options.json'), JSON.stringify(oldConfig, null, 2))
    toLog('  Configuration:\n' + JSON.stringify(oldConfig, null, 2))
  } else if (oldConfig.version != defaultConfig.version) {
    toLog('Updating config version from ' + oldConfig.version + ' to ' + defaultConfig.version)
    oldConfig.version = defaultConfig.version
    fs.writeFileSync(path.join(homedir, 'options.json'), JSON.stringify(oldConfig, null, 2))
    toLog('  Configuration:\n' + JSON.stringify(oldConfig, null, 2))
  }
  // If deprecated Modlists folder exists, delete it
  if (fs.existsSync(path.join(homedir, 'Modlists'))) {
    toLog('Deprecated "Modlists" folder detected, deleting...')
    fs.rmdirSync(path.join(homedir, 'Modlists'))
  }
})

app.on('quit', () => {
  toLog('EXITING AZURA\'S STAR')
})

const isRunning = (query, cb) => {
  let platform = process.platform;
  let cmd = '';
  switch (platform) {
      case 'win32' : cmd = `tasklist`; break;
      case 'darwin' : cmd = `ps -ax | grep ${query}`; break;
      case 'linux' : cmd = `ps -A`; break;
      default: break;
  }
  childProcess.exec(cmd, (err, stdout, stderr) => {
      cb(stdout.toLowerCase().indexOf(query.toLowerCase()) > -1);
  });
}

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

// Functions
function getConfig () {
  toLog('  Reading config')
  return JSON.parse(fs.readFileSync(path.join(homedir, 'options.json')))
}

function saveConfig (newConfig) {
  // newConfig is a JSON object with the new configuration in it
  toLog('  Saving config')
  toLog('  New Configuration:\n' + JSON.stringify(newConfig, null, 2))
  fs.writeFileSync(path.join(homedir, '/options.json'), JSON.stringify(newConfig, null, 2))
}

function launchGame (list) {
  // list is a string with the modlist name as it appears in the config (config.Modlists[modlistName].name)
  toLog('Launching game')
  toLog('==========================================')
  toLog('  Launching: ' + list)
  const currentConfig = getConfig()
  const modlistPath = currentConfig.Modlists[list].path
  toLog('    Path: ' + modlistPath)
  const exe = currentConfig.Modlists[list].exe
  toLog('    Executable: ' + exe)
  const profile = currentConfig.Modlists[list].selectedProfile
  toLog('    MO2 Profile: ' + profile)
  const game = currentConfig.Modlists[list].game
  toLog('    Game: ' + game)
  const gamePath = currentConfig.Options.gameDirectories.find(x => x.game === game).path
  toLog('    Game Path: ' + gamePath)

  if (game != 'Morrowind') {
    toLog('  Moving Game Folder Files')
    ncp.ncp(path.join(modlistPath, 'Game Folder Files'), gamePath, err => {
      if (err) {
        toLog('ERROR WHILE MOVING GAME FOLDER FILES:')
        toLog(err)
        toLog('==========================================')
        win.webContents.send('game-closed')
        return win.webContents.send('error', ['002', err])
      }
    })
  }
  toLog('  Starting MO2')
  const execCMD = '"' + modlistPath + '\\ModOrganizer.exe" -p "' + profile + '" "moshortcut://:' + exe + '"'
  childProcess.exec(execCMD, (error) => {
    if (error) {
      toLog('ERROR WHILE EXECUTING MOD ORGANIZER:')
      toLog(error)
      toLog('==========================================')
      win.webContents.send('game-closed')
      return win.webContents.send(['204', error])
    }
  })

  let isGameRunning = setInterval(checkProcess, 1000)
  function checkProcess () {
    isRunning('ModOrganizer.exe', (status) => {
      if (!status) {
        toLog('  GAME CLOSED')
        clearInterval(isGameRunning)
        if (game != 'Morrowind') {
          toLog('    Removing Game Folder Files')
          fs.readdir(path.join(modlistPath, 'Game Folder Files'), (err,files) => {
            files.forEach(file => {
              toLog('      Removing ' + file)
              fs.unlink(path.join(gamePath, file), (err) => {})
              fs.rmdir(path.join(gamePath, file), { recursive: true }, (err) => {})
            })
            win.show()
            win.webContents.send('game-closed')
            toLog('==========================================')
          })
        } else {
          win.show()
          win.webContents.send('game-closed')
          toLog('==========================================')
        }
      }
    })
  }
}

function refreshModlists () {
  toLog('Refreshing modlists')
  toLog('==========================================')
  // Get current configuration
  let config = getConfig()

  // Update each list in configuration
  Object.keys(config.Modlists).forEach(list =>{
    // Get current MO2 configuration
    toLog('  Getting Modlist MO2 info for ' + list)
    const MO2ini = ini.parse(fs.readFileSync(path.join(config.Modlists[list].path, 'ModOrganizer.ini'), 'utf-8'))
    let modlistInfo = {
      name: list,
      path: config.Modlists[list].path,
      game: MO2ini.General.gameName,
      executables: [],
      exe: config.Modlists[list].exe,
      profiles: [],
      selectedProfile: config.Modlists[list].selectedProfile
    }

    // Update executables array
    toLog('    Updating executable array')
    Object.keys(MO2ini.customExecutables).forEach(entry => {
      if (entry.includes('title') && MO2ini.customExecutables[entry] != undefined) {
        toLog('      Found ' + MO2ini.customExecutables[entry])
        modlistInfo.executables.push(MO2ini.customExecutables[entry])
      }
    })

    // Update profiles array
    toLog('    Updating profiles array')
    const files = fs.readdirSync(path.join(modlistInfo.path, 'profiles'))
    files.forEach(file => {
      toLog('      Found ' + file)
      modlistInfo.profiles.push(file)
    })

    // Push changes to saved config
    config.Modlists[list] = modlistInfo
  })

  // Update config
  saveConfig(config)
  toLog('==========================================')
  return true
}

function createModlist (modlistInfo) {
  // modlist info is an Object with the modlist information taken from the config (config.Modlists[modlistName])
  // Check if selected folder contains required files
  toLog('Creating new Modlist, ' + modlistInfo.name)
  toLog('==========================================')
  toLog('  Modlist path: ' + modlistInfo.path)
  toLog('  Checking for MO2 files')
  if (!fs.existsSync(path.join(modlistInfo.path, 'ModOrganizer.exe'))) { //Check if path contains Mod Organizer
    toLog('  ERROR: FOLDER DOES NOT CONTAIN MODORGANIZER.EXE')
    toLog('==========================================')
    win.webContents.send(['203', modlistInfo.path + ' does not contain ModOrganizer.exe. Please double check the path and try again'])
    return 'Error'
  }
  if (!fs.existsSync(path.join(modlistInfo.path, 'ModOrganizer.ini'))) {
    toLog('  ERROR: FOLDER DOES NOT CONTAIN MODORGANIZER.INI')
    toLog('==========================================')
    win.webContents.send(['203', modlistInfo.path + ' does not contain ModOrganizer.ini. Please double check the path and try again'])
    return 'Error'
  }

  // Read MO2 configuration file
  toLog('  Reading ModOrganizer.ini')
  const MO2ini = ini.parse(fs.readFileSync(path.join(modlistInfo.path, 'ModOrganizer.ini'), 'utf-8'))

  // Get game name and set default executable
  modlistInfo.game = MO2ini.General.gameName
  toLog('    Game name: ' + modlistInfo.game)
  switch (modlistInfo.game) {
    case 'Skyrim':
      modlistInfo.exe = 'SKSE'
      break;
    case 'Skyrim Special Edition':
      modlistInfo.exe = 'SKSE'
      break;
    case 'Morrowind':
      modlistInfo.exe = 'Morrowind'
      break;
    case 'Oblivion':
      modlistInfo.exe = 'OBSE'
      break;
    case 'Skyrim VR':
      modlistInfo.exe = 'SKSE'
      break;
    case 'Fallout 3':
      modlistInfo.exe = 'FOSE'
      break;
    case 'New Vegas':
      modlistInfo.exe = 'NVSE'
      break;
    case 'Fallout 4':
      modlistInfo.exe = 'F4SE'
      break;
    case 'Fallout 4 VR':
      modlistInfo.exe = 'F4SE'
      break;
  }
  toLog('    Setting default executable to ' + modlistInfo.exe)

  // Get list of MO2 executables
  modlistInfo.executables = []
  toLog('    Reading executables:')
  Object.keys(MO2ini.customExecutables).forEach(entry => {
    if (entry.includes('title') && MO2ini.customExecutables[entry] != undefined) {
      toLog('      ' + MO2ini.customExecutables[entry])
      modlistInfo.executables.push(MO2ini.customExecutables[entry])
    }
  })

  // Get list of MO2 profiles
  toLog('    Reading profiles:')
  const files = fs.readdirSync(path.join(modlistInfo.path, 'profiles'))
  modlistInfo.profiles = []
  files.forEach(file => {
    toLog('      ' + file)
    modlistInfo.profiles.push(file)
  })
  modlistInfo.selectedProfile = modlistInfo.profiles[0]
  toLog('    Setting default profile: ' + modlistInfo.selectedProfile)

  // Save to config
  let options = getConfig()
  options.Modlists[modlistInfo.name] = modlistInfo
  saveConfig(options)
  toLog('==========================================')

  // Return with new modlist info
  // TODO: Check to see if this is required.
  return {
    name: modlistInfo.name,
    path: modlistInfo.path,
    game: modlistInfo.game,
    executables: modlistInfo.executables,
    exe: modlistInfo.exe,
    selectedProfile: modlistInfo.selectedProfile,
    profiles: modlistInfo.profiles
  }
}

// IpcRenderer handling
ipcMain.on('follow-link', (_event, args) => { // Open hyperlinks in the default browser
  toLog('Opening link: ' + args)
  shell.openExternal(args)
}).on('open-modlist-profile', (_event, args) => { // Open path to modlist folder
  toLog('Opening explorer path: ' + args)
  shell.openPath(args)
})

// Add a new modlist profile
ipcMain.handle('create-modlist-profile', async (_event, modlistInfo) => {
  return createModlist(modlistInfo)
})

// Refresh modlist cache
ipcMain.handle('refresh-modlists', async (_event, args) => {
  return refreshModlists()
})

// Update configuration file
ipcMain.handle('update-config', async (_event, args) => {
  saveConfig(args)
})

// Get configuration
ipcMain.handle('get-config', async (_event, args) => {
  return getConfig()
})

// Get Directory
ipcMain.handle('get-directory', async (_event, args) => {
  toLog('Getting directory')
  return dialog.showOpenDialogSync({
    buttonLabel: 'Choose Folder',
    properties: ['openDirectory']
  })
})

// Launch modlist
ipcMain.handle('launch-game', async (_event, args) => {
 launchGame(args)
})

// Launch MO2
ipcMain.handle('launch-mo2', async (_event, args) => {
  toLog('Launching MO2')
  const currentConfig = JSON.parse(fs.readFileSync(path.join(homedir, 'options.json')))
  const moPath = path.join(currentConfig.Modlists[args].path, '\\ModOrganizer.exe')
  childProcess.exec('"'+moPath+'"')
})

// Open console
ipcMain.on('open-dev-tools', (_event, args) => {
  toLog('Opening developer tools')
  win.webContents.openDevTools()
})