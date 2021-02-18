/**
 * Handles modlist interactions. Error ID: B06
 * @author RingComics <thomasblasquez@gmail.com>
 * @module
 */
// Import modules
import path from 'path'
import fs from 'fs'
import childProcess from 'child_process'
import ncp from 'ncp'
import ini from 'ini'
import { getConfig, saveConfig } from './config.js'
import { toLog } from './log.js'
import { sendError } from './errorHandler.js'

/**
 * Refreshes modlists information from config.
 * @throws B06-01-00
 */
export function refreshModlists() {
    try {
        toLog('Refreshing modlists\n' + '='.repeat(80), 0)
        // Get current configuration
        let config = getConfig(1)
        if (config === 'ERROR') return

        // Update each list in configuration
        Object.keys(config.Modlists).forEach(list => {
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
    } catch (err) {
        sendError('B06-01-00', 'Error while refreshing modlists!', err)
    }
}

export function createModlist(modlistInfo) {
    // modlist info is an Object with the modlist information taken from the config (config.Modlists[modlistName])
    try {
        // Check if selected folder contains required files
        toLog('Creating new Modlist, ' + modlistInfo.name + '\n' + '='.repeat(80), 0)
        toLog('Modlist path: ' + modlistInfo.path, 1)
        toLog('Checking for MO2 files', 1)
        if (!fs.existsSync(path.join(modlistInfo.path, 'ModOrganizer.exe'))) { //Check if path contains Mod Organizer
            toLog('ERROR: FOLDER DOES NOT CONTAIN MODORGANIZER.EXE\n' + '='.repeat(80), 2)
            return 'Error'
        }
        if (!fs.existsSync(path.join(modlistInfo.path, 'ModOrganizer.ini'))) {
            toLog('ERROR: FOLDER DOES NOT CONTAIN MODORGANIZER.INI\n' + '='.repeat(80), 2)
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
        if (options === 'ERROR') return
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
    } catch (err) {
        sendError('B06-02-00', 'Error while creating modlist!', err)
    }
}

export function deleteModlistFromDisk(list) {
    try {
        let config = getConfig()
        if (config === 'ERROR') return
        let listPath = config.Modlists[list].path
        toLog('Removing ' + list + ' from disk at ' + listPath, 0)
        fs.rmdirSync(listPath, { recursive: true })
        delete config.Modlists[list]
        saveConfig(config)
    } catch (err) {
        sendError('B06-03-00', 'Error while deleting modlist: ' + list, err)
    }
}

export function launchGame(list) {
    try {
        // list is a string with the modlist name as it appears in the config (config.Modlists[modlistName].name)
        toLog('Launching: ' + list + '\n' + '='.repeat(80), 0)
        const currentConfig = getConfig(1)
        if (currentConfig === 'ERROR') return
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
                    toLog('ERROR WHILE MOVING GAME FOLDER FILES (background.js):\n' + err + '\n' + '='.repeat(80) + '\n', 2)
                    win.webContents.send('game-closed')
                    return win.webContents.send('error', ['002', err])
                }
            })
        } else {
            toLog('Azura\'s Star does not handle Morrowind GFF!', 1)
        }
        toLog('Starting MO2', 1)
        const execCMD = '"' + modlistPath + '\\ModOrganizer.exe" -p "' + profile + '" "moshortcut://:' + exe + '"'
        childProcess.exec(execCMD, (error) => {
            if (error) {
                toLog('ERROR WHILE EXECUTING MOD ORGANIZER (background.js):\n' + error + '\n' + '='.repeat(80) + '\n', 2)

                win.webContents.send('game-closed')
                return win.webContents.send(['204', error])
            }
        })

        const isRunning = (query, cb) => { // Check if queried program is running (This is a function, I promise)
            let platform = process.platform;
            let cmd = '';
            switch (platform) {
                case 'win32': cmd = `tasklist`; break;
                case 'darwin': cmd = `ps -ax | grep ${query}`; break;
                case 'linux': cmd = `ps -A`; break;
                default: break;
            }
            childProcess.exec(cmd, (err, stdout, stderr) => {
                cb(stdout.toLowerCase().indexOf(query.toLowerCase()) > -1);
            });
        }

        let isGameRunning = setInterval(checkProcess, 1000)
        function checkProcess() {
            isRunning('ModOrganizer.exe', (status) => {
                if (!status) {
                    toLog('GAME CLOSED', 1)
                    clearInterval(isGameRunning)
                    if (game != 'Morrowind') {
                        toLog('Removing Game Folder Files', 2)
                        fs.readdir(path.join(modlistPath, 'Game Folder Files'), (err, files) => {
                            files.forEach(file => {
                                toLog('Removing ' + file, 3)
                                fs.unlink(path.join(gamePath, file), (err) => { })
                                fs.rmdir(path.join(gamePath, file), { recursive: true }, (err) => { })
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
    } catch (err) {
        sendError('B06-04-00', 'Error while launching modlist: ' + list, err)
    }
}