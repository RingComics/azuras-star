/**
 * Handles errors
 * @author RingComics <thomasblasquez@gmail.com>
 * @module
 */

//Import modules
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
import { getWebContents } from './ipcHandler.js'

// Functions
    /**
     * Sends errors to front-end error modal and log. Error ID: B02-01
     * @fires webContents#error
     * @param {string} code
     * @param {string} message
     * @param {Error} err
     * @param {Number} tabbed
     * @throws B02-01-00
     */
    export function sendError(code, message, err, tabbed) {
        toLog(message + '\n' + 'Error code: ' + code + '\n\n' + err + '\n\n', tabbed)
        try {
            /**
             * Sends error to front-end
             * @event webContents#error
             */
            getWebContents().send('error', { code: code, message: message, err: err })
        } catch (e) { toLog('Error not sent to front end. WebContents is most likely not defined.\nError code: B02-01-00\n\n' + e + '\n\n', tabbed) }
    }

    // Shows error dialog and quits app on fatal error. No Error ID.
    /**
     * @param {string} code
     * @param {string} message
     * @param {Error} err
     * @param {Number} tabbed
     */
    export function fatalError(code, message, err) {
        dialog.showMessageBoxSync({ type: 'error', title: 'A fatal error occured!' }, () => {
            toLog('\n\n' + '='.repeat(10) + 'A FATAL ERROR OCCURED' + '='.repeat(10) + message + '\n\n' + err + '\n\nEXITING AZURA\'S STAR.')
            app.quit()
        })
    }