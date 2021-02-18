//Purpose: Handle logging
// Error ID: B05
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
import { initializeConfiguration, getConfig, saveConfig } from './config.js'
import { refreshModlists, createModlist, deleteModlistFromDisk, launchGame } from './modlists.js'
import { sendError } from './errorHandler'

const homeDirectory = path.join(os.homedir(), 'Azura\'s Star')

function getCurrentTime() {
    let date = new Date
    let time = [date.getHours(), date.getMinutes(), date.getSeconds()]
    time.forEach((entry, index) => {
        if (entry < 10) { time[index] = '0' + entry.toString() } else { time[index] = entry.toString() }
    })
    return (time[0] + ':' + time[1] + ':' + time[2])
}

function getCurrentDate() {
    let date = new Date
    let time = getCurrentTime()
    let currentDate = [date.getFullYear(), date.getMonth() + 1, date.getDate(), time.replace(/:/g, '-')]
    currentDate.forEach((entry, index) => {
        if (entry < 10) { currentDate[index] = '0' + entry.toString() } else { currentDate[index] = entry.toString() }
    })
    return (currentDate[0] + '-' + currentDate[1] + '-' + currentDate[2] + '-' + currentDate[3])
}

export const currentLogPath = path.join(homeDirectory, '/logs/', (getCurrentDate() + '.txt'))

export function toLog(log, tabbed) {
    const logged = '\n' + getCurrentTime() + '  -  ' + '  '.repeat(tabbed) + log
    fs.appendFile(currentLogPath, logged, err => {
        if (err) sendError('B05-01-00', 'Error while writing to log! Logging has been disabled.', err, tabbed)
    })
}

export function openLog() {
    shell.openPath(currentLogPath)
}