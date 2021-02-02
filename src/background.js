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
  fs.mkdir(homedir, err => {throw err})
}
const appPath = process.argv[0].replace(/\\/gi,'\\\\')
console.log(appPath)

let defaultConfig = require('./assets/json/defaultConfig.json')
defaultConfig.Options.ASPath = appPath

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
  createWindow()

  // Check if configuration file exists, if not, create a default one
  if (!fs.existsSync(path.join(homedir, '/options.json'))) {
    fs.writeFileSync(path.join(homedir, 'options.json'), JSON.stringify(defaultConfig, null, 2))
  }
  if (!fs.existsSync(path.join(homedir, 'Modlists'))) {
    fs.mkdirSync(path.join(homedir, 'Modlists'))
  }
})

console.log(process.env.PORTABLE_EXECUTABLE_DIR)

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

// Handle commandline arguments


// IpcRenderer handling
ipcMain.on('follow-link', (_event, args) => { // Open hyperlinks in the default browser
  shell.openExternal(args)
}).on('open-modlist-profile', (_event, args) => { // Open path to modlist folder
  shell.openPath(args)
})

ipcMain.handle('create-modlist-profile', async (_event, modlistInfo) => { // Add a new modlist profile
  if (!fs.existsSync(path.join(modlistInfo.path, 'ModOrganizer.exe'))) { //Check if path contains Mod Organizer
    win.webContents.send(['203', modlistInfo.path + ' does not contain ModOrganizer.exe'])
    return 'Error'
  }
  const MO2ini = ini.parse(fs.readFileSync(path.join(modlistInfo.path, 'ModOrganizer.ini'), 'utf-8'))
  modlistInfo.game = MO2ini.General.gameName
  modlistInfo.executables = []
  Object.keys(MO2ini.customExecutables).forEach(entry => {
    if (entry.includes('title') && MO2ini.customExecutables[entry] != undefined) {
      modlistInfo.executables.push(MO2ini.customExecutables[entry])
    }
    if (entry.toString().includes(MO2ini.General.selected_executable.toString()) && entry.toString().includes('title')) {
      modlistInfo.exe = MO2ini.customExecutables[entry]
    }
  })
  const files = fs.readdirSync(path.join(modlistInfo.path, 'profiles'))
  modlistInfo.profiles = []
  files.forEach(file => {
    modlistInfo.profiles.push(file)
  })
  modlistInfo.selectedProfile = modlistInfo.profiles[0]

  let options = JSON.parse(fs.readFileSync(path.join(homedir, 'options.json')))
  options.Modlists[modlistInfo.name] = modlistInfo
  fs.writeFileSync(path.join(homedir, '/options.json'), JSON.stringify(options, null, 2))
  return {
    name: modlistInfo.name,
    path: modlistInfo.path,
    game: modlistInfo.game,
    executables: modlistInfo.executables,
    exe: modlistInfo.exe,
    selectedProfile: modlistInfo.selectedProfile,
    profiles: modlistInfo.profiles
  }
})

ipcMain.handle('refresh-modlists', async (_event, args) => {
  let config = JSON.parse(fs.readFileSync(path.join(homedir, 'options.json'), { encoding:'utf8' }))
  Object.keys(config.Modlists).forEach(list =>{
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
    Object.keys(MO2ini.customExecutables).forEach(entry => {
      if (entry.includes('title') && MO2ini.customExecutables[entry] != undefined) {
        modlistInfo.executables.push(MO2ini.customExecutables[entry])
      }
      if (MO2ini.customExecutables[entry] != modlistInfo.exe && entry.toString().includes(MO2ini.General.selected_executable.toString()) && entry.toString().includes('title')) {
        modlistInfo.exe = MO2ini.customExecutables[entry]
      }
    })
    const files = fs.readdirSync(path.join(modlistInfo.path, 'profiles'))
    files.forEach(file => {
      modlistInfo.profiles.push(file)
    })
    modlistInfo.selectedProfile = modlistInfo.profiles[0]
    console.log(modlistInfo)
    config.Modlists[list] = modlistInfo
  })
  fs.writeFileSync(path.join(homedir, '/options.json'), JSON.stringify(config, null, 2))
  return true
})

// Update configuration file
ipcMain.handle('update-config', async (_event, args) => {
  const newConfig = JSON.stringify(args, null, 2)
  fs.writeFileSync(path.join(homedir, '/options.json'), newConfig)
})

// Get configuration
ipcMain.handle('get-config', async (_event, args) => {
  let options = fs.readFileSync(path.join(homedir, 'options.json'), { encoding:'utf8' })
  let result = JSON.parse(options)
  return result
})


ipcMain.handle('get-profiles', async (_event, args) => {
  let options = fs.readFileSync(path.join(homedir, 'options.json'), { encoding:'utf8' })
  return JSON.parse(options).Modlists[args].profiles
})

// Get Directory
ipcMain.handle('get-directory', async (_event, args) => {
  return dialog.showOpenDialogSync({
    buttonLabel: 'Choose Folder',
    properties: ['openDirectory']
  })
})

ipcMain.handle('launch-game', async (_event, args) => {
  const currentConfig = JSON.parse(fs.readFileSync(path.join(homedir, 'options.json')))
  const modlistPath = currentConfig.Modlists[args].path
  const exe = currentConfig.Modlists[args].exe
  const profile = currentConfig.Modlists[args].selectedProfile
  const game = currentConfig.Modlists[args].game
  const gamePath = currentConfig.Options.gameDirectories.find(x => x.game === game).path

  if (game != 'Morrowind') {
    ncp.ncp(path.join(modlistPath, 'Game Folder Files'), gamePath, err => {
      if (err) {
        win.webContents.send('game-closed')
        return win.webContents.send('error', ['002', err])
      }
    })
  }
  const execCMD = '"' + modlistPath + '\\ModOrganizer.exe" -p "' + profile + '" "moshortcut://:' + exe + '"'
  childProcess.exec(execCMD, (error) => {
    console.log(error)
    if (error) {
      win.webContents.send('game-closed')
      return win.webContents.send(['204', error])
    }
  })

  let isGameRunning = setInterval(checkProcess, 1000)
  function checkProcess () {
    isRunning('ModOrganizer.exe', (status) => {
      if (!status) {
        clearInterval(isGameRunning)
        if (game != 'Morrowind') {
          fs.readdir(path.join(modlistPath, 'Game Folder Files'), (err,files) => {
            files.forEach(file => {
              fs.unlink(path.join(gamePath, file), (err) => {})
              fs.rmdir(path.join(gamePath, file), { recursive: true }, (err) => {})
            })
            win.show()
            win.webContents.send('game-closed')
          })
        } else {
          win.show()
          win.webContents.send('game-closed')
        }
      }
    })
  }
})

ipcMain.handle('force-quit', async (_event, args) => {
  childProcess.exec('kill ModOrganizer.exe')
})

ipcMain.handle('launch-mo2', async (_event, args) => {
  const currentConfig = JSON.parse(fs.readFileSync(path.join(homedir, 'options.json')))
  const moPath = path.join(currentConfig.Modlists[args].path, '\\ModOrganizer.exe')
  childProcess.exec('"'+moPath+'"')
})

ipcMain.on('open-dev-tools', (_event, args) => {
  win.webContents.openDevTools()
})