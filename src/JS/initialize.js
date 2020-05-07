async function initializeAS() {
  if (userInfo.username == "" || userInfo.username == undefined) {
    dialog.showErrorBox(
      "Azura's Star",
      "You are not authenticated with the Nexus. Please open the settings and authenticate."
    );
    return;
  }
  const result = await dialog.showMessageBoxSync({
    type: "question",
    buttons: ["Yes", "No"],
    deafaultId: 1,
    title: "Azura's Star",
    message:
      "The initialization process involves installing SKSE and ENBoost to your vanilla Skyrim install, as well as cleaning your DLC masters with xEdit. This process is required for Azura's Star, as well as most mod installs. Is this okay?",
  });
  console.log(result);
  if (result === 1) {
    return;
  }
  outputConsole("Getting hardware info...");
  await ps.addCommand('dxdiag /x "C:\\temp\\hwinfo.xml" | Wait-Process');
  ps.invoke().then(async (output) => {
    let dxdiag = await fs.readFileSync("C:\\temp\\hwinfo.xml");
    let hwinfo = JSON.parse(
      convert.xml2json(dxdiag, { compact: true, spaces: 4 })
    );
    enbInfo.hardware.ram = parseInt(
      hwinfo.DxDiag.SystemInformation.Memory._text
    );
    enbInfo.hardware.vram = parseInt(
      hwinfo.DxDiag.DisplayDevices.DisplayDevice[0].DedicatedMemory._text
    );
    enbInfo.hardware.videomemory =
      enbInfo.hardware.ram + enbInfo.hardware.vram - 2048;
    outputConsole(
      "Hardware info:\n    RAM :" +
        enbInfo.hardware.ram +
        "\n    VRAM: " +
        enbInfo.hardware.vram +
        "\n    VideoMemory: " +
        enbInfo.hardware.videomemory
    );
    fs.unlink("C:\\temp\\hwinfo.xml", (err) => {
      if (err) throw err;
    });
    fs.writeFile(
      "./src/user/enb.json",
      JSON.stringify(enbInfo, null, 2),
      function writeJSON(err) {
        if (err) return console.log(err);
      }
    );
    let enblocal = await fs.readFileSync(
      "./src/bin/enb/enblocal.ini",
      "utf8",
      (data) => {}
    );
    enblocal = enblocal.replace(
      "{insertVideoMemHere}",
      enbInfo.hardware.videomemory
    );
    console.log(enblocal);
    fs.writeFile("./src/bin/enb/enblocal.ini", enblocal, function (err) {
      if (err) return console.log(err);
    });
  });
  outputConsole("Downloading TES5Edit");
}
