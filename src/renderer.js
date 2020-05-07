//Modules
const { ipcRenderer, shell } = require("electron");
const { dialog } = require("electron").remote;
const nodePS = require("node-powershell");
const fs = require("fs");
const http = require("http");
const convert = require("xml-js");

//init powershell console
const ps = new nodePS({
  executionPolicy: "Bypass",
  noProfile: true,
});

//Global Variables
const modpackListJsonLocation = __dirname + "\\user\\modpacks.json";
let userInfo = require("./user/settings.json");
let modpackInfo = require("./user/modpacks.json");
let enbInfo = require("./user/enb.json");
