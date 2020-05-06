function updateModpackListJson(mp,key,value) {
  let modpackListJson = require(modpackListJsonLocation);
  modpackListJson[mp][key] = value;
  fs.writeFile(modpackListJsonLocation, JSON.stringify(modpackListJson), function writeJSON(err) {
    if (err) return console.log(err);
    console.log(JSON.stringify(modpackListJson, null, 2));
  });
}

function pickFolder() {
  let foldername = dialog.showOpenDialogSync({
    properties: ['openDirectory']
  })
  if (foldername == undefined)
  {
    return "cancelled"
  } else {
    return foldername[0]
  }
};

function changeLEPath() {
  let path = (pickFolder() + '\\TESV.exe')
  fs.stat(path, function (err) {
    if(err == null) {
      updateModpackListJson('Vanilla (Legendary Edition)','path',path)
      document.getElementById("check-le").innerHTML =
        "Skyrim LE installed at: " +
        modpackInfo['Vanilla (Legendary Edition)'].path +
        " <button onclick='changeLEPath()'>Change</button>";
    } else if(err.code === 'ENOENT') {
      dialog.showErrorBox('Azura\'s Star', "Path could not be set. Either user cancelled action or path does not contain TESV.exe")
    } else {
      console.log('Some other error: ', err.code);
    }
  });
}

function changeSEPath() {
  let path = (pickFolder() + '\\SkyrimSE.exe')
  fs.stat(path, function (err) {
    if(err == null) {
      updateModpackListJson('Vanilla (Special Edition)','path',path)
      document.getElementById("check-se").innerHTML =
        "Skyrim SE installed at: " +
        modpackInfo['Vanilla (Special Edition)'].path +
        " <button onclick='changeSEPath()'>Change</button>";
    } else if(err.code === 'ENOENT') {
      dialog.showErrorBox('Azura\'s Star', "Path could not be set. Either user cancelled action or path does not contain SkyrimSE.exe")
    } else {
      console.log('Some other error: ', err.code);
    }
  });
}