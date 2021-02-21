/**
 * Handles modlist interactions.
 * @author RingComics <thomasblasquez@gmail.com>
 * @version 1.0.0
 * @module
 */

import path from 'path'
import fs from 'fs'
import childProcess from 'child_process'
import ncp from 'ncp'
import ini from 'ini'
import { getConfig, saveConfig } from './config.js'
import { toLog } from './log.js'
import { sendError } from './errorHandler.js'
import { getWebContents, getWindow } from './ipcHandler'

/**
 * Refreshes modlists information from config.
 * @author RingComics <thomasblasquez@gmail.com>
 * @version 1.0.0
 * @throws B06-01-00
 * 
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
            // Time
            if (config.Modlists[list].created === undefined) config.Modlists[modlistInfo.name].created = Date.now()
            if (config.Modlists[list].modified === undefined) config.Modlists[modlistInfo.name].modified = Date.now()
        })

        // Update config
        saveConfig(config, 1)
        toLog('Done!\n' + '='.repeat(80) + '\n', 1)
    } catch (err) {
        sendError('B06-01-00', 'Error while refreshing modlists!', err)
    }
}

/**
 * Creates a new modlist profile
 * @author RingComics <thomasblasquez@gmail.com>
 * @version 1.0.0
 * @param {JSON} modlistInfo 
 * @returns {Object} New Profile info
 * @throws B06-02-00
 * @throws B06-07-01
 * @throws B06-07-02
 * @throws B06-07-03
 * 
 * @todo Check to see if returning the modlistInfo is required.
 */
export function createModlist(modlistInfo) {
    try {
        // Check if selected folder contains required files
        toLog('Creating new Modlist, ' + modlistInfo.name + '\n' + '='.repeat(80), 0)
        toLog('Modlist path: ' + modlistInfo.path, 1)
        toLog('Checking for MO2 files', 1)
        if (!fs.existsSync(path.join(modlistInfo.path, 'ModOrganizer.exe'))) {
            sendError(
                'B06-07-01',
                'ModOrganizer.exe does not exist at this path. Cannot create new modlist profile.',
                new Error('ModOrganizer.exe not found!'),
                1
            )
            return 'Error'
        }
        if (!fs.existsSync(path.join(modlistInfo.path, 'ModOrganizer.ini'))) {
            sendError(
                'B06-07-02',
                'ModOrganizer.ini does not exist at this path. Cannot create new modlist profile.',
                new Error('ModOrganizer.ini not found!'),
                1
            )
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
            default:
                sendError(
                    'B06-07-03',
                    modlistInfo.game + ' is not supported! If you would like to see support added, please comment on the Supported Games pinned issue on GitHub',
                    new Error('Game not supported by Azura\'s Star!'),
                    3
                )
                return 'ERROR'
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
        if (options === 'ERROR') return 'ERROR'
        options.Modlists[modlistInfo.name] = modlistInfo
        options.Modlists[modlistInfo.name].created = Date.now()
        options.Modlists[modlistInfo.name].modified = Date.now()
        saveConfig(options, 1)
        toLog('Done!\n' + '='.repeat(80) + '\n')

        // Return with new modlist info
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

/**
 * Launches modlist
 * @author RingComics <thomasblasquez@gmail.com>
 * @version 1.0.0
 * @param {String} list
 * @emits game-closed
 */
export function launchGame(list) {
    try {
        toLog('Launching: ' + list + '\n' + '='.repeat(80), 0)
        const currentConfig = getConfig(1)
        if (currentConfig === 'ERROR') return getWebContents().send('game-closed')
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
                    getWebContents().send('game-closed')
                    sendError('B06-03-01', 'Error while moving Game Folder Files', err, 2)
                    return
                }
            })
        } else {
            toLog('Azura\'s Star does not handle Morrowind GFF!', 1)
        }
        toLog('Starting MO2', 1)
        const execCMD = '"' + modlistPath + '\\ModOrganizer.exe" -p "' + profile + '" "moshortcut://:' + exe + '"'
        childProcess.exec(execCMD, (error) => {
            if (error) {
                getWebContents().send('game-closed')
                sendError('B06-03-02', 'Error while executing ModOrganizer!', err, 2)
                return
            }
        })
        /**
         * Checks if queried program is still running
         * @param {String} query 
         * @param {Function} cb 
         */
        const isRunning = (query, cb) => {
            childProcess.exec('tasklist', (err, stdout, stderr) => {
                cb(stdout.toLowerCase().indexOf(query.toLowerCase()) > -1);
            });
        }
        let isGameRunning = setInterval(checkProcess, 1000)
        /**
         * Wrapper for checking if game is still running
         * @author RingComics <thomasblasquez@gmail.com>
         * @version 1.0.0
         */
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
                            getWindow().show()
                            getWebContents().send('game-closed')
                            toLog('Done!\n' + '='.repeat(80) + '\n')
                        })
                    } else {
                        getWindow().show()
                        getWebContents().send('game-closed')
                        toLog('Done!\n' + '='.repeat(80) + '\n', 1)
                    }
                }
            })
        }
    } catch (err) {
        getWebContents().send('game-closed')
        sendError('B06-03-00', 'Error while launching modlist: ' + list, err)
    }
}
