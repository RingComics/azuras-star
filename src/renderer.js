//Modules
const { ipcRenderer, shell } = require('electron');
const { dialog } = require('electron').remote;
const nodePS = require('node-powershell');
const fs = require('fs');
const http = require('http');

//init powershell console
const ps = new nodePS({
    executionPolicy: "Bypass",
    noProfile: true,
  });

//Global Variables
const modpackListJsonLocation = __dirname + '\\user\\modpacks.json';
const userInfo = require('./user/settings.json')
const modpackInfo = require("./user/modpacks.json");