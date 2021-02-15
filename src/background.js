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

function getCurrentTime () {
  let date = new Date
  let time = [date.getHours(), date.getMinutes(), date.getSeconds()]
  time.forEach((entry,index) => {
    if (entry < 10) { time[index] = '0' + entry.toString() } else { time[index] = entry.toString()}
  })
  return (time[0] + ':' + time[1] + ':' + time[2])
}

function getCurrentDate () {
  let date = new Date
  let time = getCurrentTime()
  let currentDate = [date.getFullYear(), date.getMonth() + 1, date.getDate(), time.replace(/:/g,'-')]
  currentDate.forEach((entry,index) => {
    if (entry < 10) { currentDate[index] = '0' + entry.toString() } else { currentDate[index] = entry.toString()}
  })
  return (currentDate[0] + '-' + currentDate[1] + '-' + currentDate[2] + '-' + currentDate[3])
}

function toLog (log, tabbed) {
  fs.appendFileSync(currentLogPath, '\n' + getCurrentTime() + '  -  ' + '  '.repeat(tabbed) + log)
}

function openLog () {
  shell.openPath(currentLogPath)
}

function initializeConfiguration () { // Define default configuration settings and configuration directory
  if(!fs.existsSync(homedir, err => {throw err})) {
    fs.mkdir(homedir, err => { throw err })
    fs.mkdir(path.join(homedir, 'logs'), err => {throw err})
  }

  if(!fs.existsSync(path.join(homedir, 'logs'), err => {throw err})) {
    fs.mkdir(path.join(homedir, 'logs'), err => {throw err})
  }

  fs.writeFileSync(currentLogPath, "LOG BEGIN")
  toLog('Azura\'s Star version ' + defaultConfig.version, 0)
  toLog('Home Directory path: ' + homedir, 0)
  toLog('Starting...\n' + '='.repeat(80),0)
  toLog('Checking for configuration file', 1)

  let oldConfig = {}
  if (!fs.existsSync(path.join(homedir, '/options.json'))) {
    toLog('File not found! Creating configuration file at ' + path.join(homedir, 'options.json'), 2)
    fs.writeFileSync(path.join(homedir, 'options.json'), JSON.stringify(defaultConfig, null, 2))
    oldConfig = defaultConfig
  } else { // Store current configuration
    toLog('Configuration file found at ' + path.join(homedir, 'options.json'), 2)
    oldConfig = JSON.parse(fs.readFileSync(path.join(homedir, '/options.json'), 'utf-8'))
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
  toLog('Configuration:\n' + JSON.stringify(oldConfig, null, 2), 2)
  fs.writeFileSync(path.join(homedir, 'options.json'), JSON.stringify(oldConfig, null, 2))
  // If deprecated Modlists folder exists, delete it
  if (fs.existsSync(path.join(homedir, 'Modlists'))) {
    toLog('Deprecated "Modlists" folder detected, deleting...', 0)
    fs.rmdirSync(path.join(homedir, 'Modlists'))
  }
}

const isRunning = (query, cb) => { // Check if queried program is running (This is a function, I promise)
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

function getConfig (tabbed) {
  toLog('Reading config', tabbed)
  return JSON.parse(fs.readFileSync(path.join(homedir, 'options.json')))
}

function saveConfig (newConfig, tabbed) {
  // newConfig is a JSON object with the new configuration in it
  toLog('Saving config', tabbed)
  toLog('New Configuration:\n' + JSON.stringify(newConfig, null, 2), tabbed)
  fs.writeFileSync(path.join(homedir, '/options.json'), JSON.stringify(newConfig, null, 2))
}

function launchGame (list) {
  // list is a string with the modlist name as it appears in the config (config.Modlists[modlistName].name)
  toLog('Launching game\n' + '='.repeat(80), 0)

  toLog('Launching: ' + list, 1)
  const currentConfig = getConfig(1)
  const modlistPath = currentConfig.Modlists[list].path
  toLog('Path: ' + modlistPath, 2)
  const exe = currentConfig.Modlists[list].exe
  toLog('Executable: ' + exe, 2)
  const profile = currentConfig.Modlists[list].selectedProfile
  toLog('MO2 Profile: ' + profile, 2)
  const game = currentConfig.Modlists[list].game
  toLog('Game: ' + game, 2)
  const gamePath = currentConfig.Options.gameDirectories.find(x => x.game === game).path
  toLog('Game Path: ' + gamePath, 2)

  if (game != 'Morrowind') {
    toLog('Moving Game Folder Files', 1)
    toLog('GFF:', 2)
    let gffArray = fs.readdirSync(path.join(modlistPath, 'Game Folder Files'))
    gffArray.forEach(file => {
      toLog(file, 3)
    })
    ncp.ncp(path.join(modlistPath, 'Game Folder Files'), gamePath, err => {
      if (err) {
        toLog('ERROR WHILE MOVING GAME FOLDER FILES:\n' + err + '\n' + '='.repeat(80) + '\n', 2)
        win.webContents.send('game-closed')
        return win.webContents.send('error', ['002', err])
      }
    })
  } else {
    toLog('ERROR: Azura\'s Star does not handle Morrowind GFF!', 1)
  }
  toLog('Starting MO2', 1)
  const execCMD = '"' + modlistPath + '\\ModOrganizer.exe" -p "' + profile + '" "moshortcut://:' + exe + '"'
  childProcess.exec(execCMD, (error) => {
    if (error) {
      toLog('ERROR WHILE EXECUTING MOD ORGANIZER:\n' + error + '\n' + '='.repeat(80) + '\n', 2)

      win.webContents.send('game-closed')
      return win.webContents.send(['204', error])
    }
  })

  let isGameRunning = setInterval(checkProcess, 1000)
  function checkProcess () {
    isRunning('ModOrganizer.exe', (status) => {
      if (!status) {
        toLog('GAME CLOSED', 1)
        clearInterval(isGameRunning)
        if (game != 'Morrowind') {
          toLog('Removing Game Folder Files', 2)
          fs.readdir(path.join(modlistPath, 'Game Folder Files'), (err,files) => {
            files.forEach(file => {
              toLog('Removing ' + file, 3)
              fs.unlink(path.join(gamePath, file), (err) => {})
              fs.rmdir(path.join(gamePath, file), { recursive: true }, (err) => {})
            })
            win.show()
            win.webContents.send('game-closed')
            toLog('Done!\n' + '='.repeat(80) + '\n')
          })
        } else {
          win.show()
          win.webContents.send('game-closed')
          toLog('Done!\n' + '='.repeat(80) + '\n', 1)
        }
      }
    })
  }
}

function refreshModlists () {
  toLog('Refreshing modlists\n' + '='.repeat(80), 0)
  // Get current configuration
  let config = getConfig(1)

  // Update each list in configuration
  Object.keys(config.Modlists).forEach(list =>{
    // Get current MO2 configuration
    toLog('Getting Modlist MO2 info for ' + list, 1)
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
    toLog('Updating executable array', 2)
    Object.keys(MO2ini.customExecutables).forEach(entry => {
      if (entry.includes('title') && MO2ini.customExecutables[entry] != undefined) {
        toLog('Found ' + MO2ini.customExecutables[entry], 3)
        modlistInfo.executables.push(MO2ini.customExecutables[entry])
      }
    })

    // Update profiles array
    toLog('Updating profiles array', 2)
    const files = fs.readdirSync(path.join(modlistInfo.path, 'profiles'))
    files.forEach(file => {
      toLog('Found ' + file, 3)
      modlistInfo.profiles.push(file)
    })

    // Push changes to saved config
    config.Modlists[list] = modlistInfo
  })

  // Update config
  saveConfig(config, 1)
  toLog('Done!\n' + '='.repeat(80) + '\n', 1)
  return true
}

function createModlist (modlistInfo) {
  // modlist info is an Object with the modlist information taken from the config (config.Modlists[modlistName])
  // Check if selected folder contains required files
  toLog('Creating new Modlist, ' + modlistInfo.name + '\n' + '='.repeat(80),0)
  toLog('Modlist path: ' + modlistInfo.path, 1)
  toLog('Checking for MO2 files', 1)
  if (!fs.existsSync(path.join(modlistInfo.path, 'ModOrganizer.exe'))) { //Check if path contains Mod Organizer
    toLog('ERROR: FOLDER DOES NOT CONTAIN MODORGANIZER.EXE\n' + '='.repeat(80),2)
    win.webContents.send(['203', modlistInfo.path + ' does not contain ModOrganizer.exe. Please double check the path and try again'])
    return 'Error'
  }
  if (!fs.existsSync(path.join(modlistInfo.path, 'ModOrganizer.ini'))) {
    toLog('ERROR: FOLDER DOES NOT CONTAIN MODORGANIZER.INI\n' + '='.repeat(80),2)
    win.webContents.send(['203', modlistInfo.path + ' does not contain ModOrganizer.ini. Please double check the path and try again'])
    return 'Error'
  }

  // Read MO2 configuration file
  toLog('Reading ModOrganizer.ini', 1)
  const MO2ini = ini.parse(fs.readFileSync(path.join(modlistInfo.path, 'ModOrganizer.ini'), 'utf-8'))

  // Get game name and set default executable
  modlistInfo.game = MO2ini.General.gameName
  toLog('Game name: ' + modlistInfo.game, 2)
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
  toLog('Setting default executable to ' + modlistInfo.exe, 2)

  // Get list of MO2 executables
  modlistInfo.executables = []
  toLog('Reading executables:', 2)
  Object.keys(MO2ini.customExecutables).forEach(entry => {
    if (entry.includes('title') && MO2ini.customExecutables[entry] != undefined) {
      toLog(MO2ini.customExecutables[entry], 3)
      modlistInfo.executables.push(MO2ini.customExecutables[entry])
    }
  })

  // Get list of MO2 profiles
  toLog('Reading profiles:', 2)
  const files = fs.readdirSync(path.join(modlistInfo.path, 'profiles'))
  modlistInfo.profiles = []
  files.forEach(file => {
    toLog(file, 3)
    modlistInfo.profiles.push(file)
  })
  modlistInfo.selectedProfile = modlistInfo.profiles[0]
  toLog('Setting default profile: ' + modlistInfo.selectedProfile, 2)

  // Save to config
  let options = getConfig(1)
  options.Modlists[modlistInfo.name] = modlistInfo
  saveConfig(options, 1)
  toLog('Done!\n' + '='.repeat(80) + '\n')

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

function deleteModlistFromDisk (list) {
  let config = getConfig()
  let listPath = config.Modlists[list].path
  toLog('Removing ' + args + ' from disk at ' + listPath, 0)
  fs.rmdirSync(listPath)
  delete config.Modlists[list]
  saveConfig(config)
}

// Global Variables
const isDevelopment = process.env.NODE_ENV !== 'production'
const homedir = path.join(os.homedir(),'Azura\'s Star')
const appPath = process.argv[0]
const defaultConfig = require('./assets/json/defaultConfig.json')
const currentLogPath = path.join(homedir, '/logs/', (getCurrentDate() + '.txt'))
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

// IpcRenderer handling
ipcMain.on('follow-link', (_event, args) => {                         // Open hyperlinks in the default browser
  toLog('Opening link: ' + args, 0)
  shell.openExternal(args)
}).on('open-modlist-profile', (_event, args) => {                     // Open path to modlist folder
  toLog('Opening explorer path: ' + args, 0)
  shell.openPath(args)
}).on('open-log', (_event, args) => {                                 // Open current log
  openLog()
}).on('open-logs-directory', (_event, args) => {                      // Open logs folder
  shell.showItemInFolder(currentLogPath)
}).on('update-config', async (_event, args) => {                      // Update configuration file
  toLog('Recieved new configuration from front-end', 0)
  saveConfig(args, 1)
}).on('launch-mo2', async (_event, args) => {                         // Launch MO2
  toLog('Launching MO2 instance for ' + args, 0)
  const currentConfig = JSON.parse(fs.readFileSync(path.join(homedir, 'options.json')))
  const moPath = path.join(currentConfig.Modlists[args].path, '\\ModOrganizer.exe')
  childProcess.exec('"'+moPath+'"')
}).on('open-dev-tools', (_event, args) => {                           // Open Developer Console
  toLog('Opening developer tools', 0)
  win.webContents.openDevTools()
})

ipcMain.handle('delete-list-from-disk', (_event, args) => {                // Delete Modlist from disk
  deleteModlistFromDisk(args)
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