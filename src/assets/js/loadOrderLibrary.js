/**
 * Handles interactions with the Load Order Library API
 * @author RingComics <thomasblasquez@gmail.com>
 * @version 1.0.0
 * @throws B04-00
 * @throws B04-01-00
 * @throws B04-02-00
 *  @throws B04-02-01
 *  @throws B04-02-02
 */
import { app, protocol, dialog, BrowserWindow, ipcMain, shell } from 'electron'
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
import { initializeConfiguration, getConfig, saveConfig, isDevelopment } from './config.js'
import { toLog, openLog } from './log.js'
import { refreshModlists, createModlist, deleteModlistFromDisk, launchGame } from './modlists.js'
import { getWebContents } from './ipcHandler.js'
import {
    sendError,
    fatalError
} from './errorHandler.js'
import { send } from 'process'

export const URI = (isDevelopment) ? 'https://testing.loadorderlibrary.com/' : 'https://www.loadorderlibrary.com/'

/**
 * Gets URL for specified list ID
 * @author RingComics <thomasblasquez@gmail.com>
 * @version 1.0.0
 * @param {String} id 
 * @returns {String} URL or ERROR
 * @throws B04-01-00
 */
export function getURL (id) {
    try {
        return URI + 'lists/' + id
    } catch (err) {
        sendError('B04-01-00', 'Error while creating URL for ' + id, err)
        return 'ERROR'
    }
}
/**
 * Checks availibility of Load Order Library.
 * Can define a sepecific list ID to check, if not general site availability is reported.
 * @author RingComics <thomasblasquez@gmail.com>
 * @version 1.0.0
 * @param {String} listID 
 * @returns {Boolean|String} Availibility Status or ERROR
 * @throws B04-02-00
 * @throws B04-02-01
 * @throws B04-02-02
 */
export async function checkAvailability (listID) {
    try {
        let options = {
            method: 'HEAD',
            uri: URI
        }
        if (!listID === null) {
            options.uri = getURL(listID)
            if (options.uri === 'ERROR') return 'ERROR'
        }
        request(options, (err, res, body) => {
            if (err) {
                sendError('B04-02-01', 'Error while sending Load Order Library request', err)
                return 'ERROR'
            }
            switch (res.statusCode) {
                case 200:
                    return true
                case 404:
                    sendError('B04-02-02', 'LoadOrderLibrary not available!', new Error(res.statusMessage))
                    return false
                case 500:
                    sendError('B04-02-03', 'LoadOrderLibrary server error', new Error(body.error))
                    return 'ERROR'
            }
        })
    } catch (err) {
        sendError('B04-02-00', 'Error while checking Load Order Library availability', err)
        return 'ERROR'
    }
}
export const api = {
    URI: URI + 'api/',
    /**
     * Upload list to LoadOrderLibrary
     * @author RingComics <thomasblasquez@gmail.com>
     * @version 1.0.0
     * @param {JSON} list 
     * @throws 
     */
    upload: async function (list) {
        try {
            if (!checkAvailability()) return 'ERROR'
            switch (list.game) {
                case 'Morrowind':
                    gameIndex = 1
                    break;
                case 'Oblivion':
                    gameIndex = 2
                    break;
                case 'Skyrim':
                    gameIndex = 3
                    break;
                case 'Skyrim Special Edition':
                    gameIndex = 4
                    break;
                case 'Skyrim VR':
                    gameIndex = 5
                    break;
                case 'Fallout 3':
                    gameIndex = 6
                    break;
                case 'New Vegas':
                    gameIndex = 7
                    break;
                case 'Fallout 4':
                    gameIndex = 8
                    break;
                case 'Fallout 4 VR':
                    gameIndex = 9
                    break;
            }
            let form = {
                name: "Your " + list.name + " (Azura's Star)",
                description: "Uploaded from Azura's Star.",
                game: gameIndex,
                private: 'true',
                'files[]': []
            }

            fs.readdir(list.path, (err, files) => {
                if (err) {
                    sendError('B04-02-01:01', 'Error while reading profile directory', err)
                    return 'ERROR'
                }
                files.forEach(file => {
                    let filePath = path.join(list.path, file)
                    if((path.extname(path.join(list.path, file)) == 'txt' || path.extname(path.join(list.name, file)) == 'ini') && fs.statSync(path.join(list.name, file)).size <= 128000) {
                        form['files[]'].push(fs.createReadStream(path.join(list.name, file)))
                    }
                })
            })
            const options = { url: this.URI + 'upload', headers: { 'content-type': 'multipart/form-data' }, formData: form }
            request.post(options, (err, res, body) => {
                if (res.statusMessage === 200) {
                    return body
                } else {
                    sendError('B04-03-01:01')
                }
            })
        } catch (err) {
            sendError('B04-02-01:00')
        }
    },
    compare: function (masterList, replicaList) {
        shell.openExternal(URI + 'compare/' + replicaList + '/' + masterList)
    }
}