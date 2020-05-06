<<<<<<< Updated upstream:src/index.js
import { app, BrowserWindow } from "electron";
=======
/* eslint-disable prefer-template */
/* eslint-disable no-path-concat */
import { app, ipcMain, dialog, BrowserWindow } from 'electron';
>>>>>>> Stashed changes:src/main.js

// Handle creating/removing shortcuts on Windows when installing/uninstalling.
if (require("electron-squirrel-startup")) {
  // eslint-disable-line global-require
  app.quit();
}

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;

const createWindow = () => {
  // Create the browser window.
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    icon: __dirname + "/img/azura.ico",
    webPreferences: {
      nodeIntegration: true,
    },
  });

  // and load the index.html of the app.
  mainWindow.loadURL(`file://${__dirname}/index.html`);

  // Open the DevTools.
  mainWindow.webContents.openDevTools();

  // Emitted when the window is closed.
  mainWindow.on("closed", () => {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null;
  });
};

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
<<<<<<< Updated upstream:src/index.js
app.on("ready", createWindow);
=======
app.on('ready',createWindow);
>>>>>>> Stashed changes:src/main.js

// Quit when all windows are closed.
app.on("window-all-closed", () => {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== "darwin") {
    app.quit();
  }
});

app.on("activate", () => {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow();
  }
});

// In this file you can include the rest of your app's specific main process
<<<<<<< Updated upstream:src/index.js
// code. You can also put them in separate files and import them here.
const fs = require("fs");
=======
// code. You can also put them in separate files and import them here.
>>>>>>> Stashed changes:src/main.js
