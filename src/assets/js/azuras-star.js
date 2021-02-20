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
import {
    sendError,
    fatalError
} from './errorHandler.js'
import { getWebContents } from './ipcHandler.js'