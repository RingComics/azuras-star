//Load installed modpacks
let modpackInfo = require("./user/modpacks.json");
const modpackList = document.getElementById("select-modpack");
for (let modpack in modpackInfo) {
    let opt = document.createElement("option");
    opt.value = modpack;
    opt.innerHTML = modpack;
    modpackList.appendChild(opt);
}

const userInfo = require('./user/settings.json')
if(userInfo.firstRun) {window.location.href = './user/settings.html'} else {
    document.getElementById('welcomeUsername').innerText = "Welcome, " + userInfo.username;
}

//Check if Java / 7-Zip is installed
Promise.resolve(getProgramDetailsFromPS("Java")).then((value) => {
    if (value.DisplayName) {
        if (value.DisplayName.indexOf("64-bit") != -1) {
            document.getElementById("check-java").innerText =
                "Java Version: " + value.DisplayVersion;
        } else {
            document.getElementById("check-java").innerHTML =
                'Java 64-Bit is required. <a href="" onclick="shell.openExternal(\'https://www.java.com/en/download/windows-64bit.jsp\')">Install Here.</a>';
        }
    } else {
        document.getElementById("check-java").innerHTML =
            'Java 64-Bit is required. <a href="" onclick="shell.openExternal(\'https://www.java.com/en/download/windows-64bit.jsp\')">Install Here.</a>';
    }
    Promise.resolve(getProgramDetailsFromPS("7-Zip")).then((value) => {
        if (value.DisplayName) {
            document.getElementById("check-7Zip").innerText =
                "7-Zip Version: " + value.DisplayVersion;
        } else {
            document.getElementById("check-7Zip").innerHTML =
                '7-Zip is required. <a href="" onclick="shell.openExternal(\'https://www.7-zip.org\')">Install Here.</a>';
        }
        //Check for Skyrim LE
        if (modpackInfo['Vanilla (Legendary Edition)'].path == "") {
            Promise.resolve(
                getProgramDetailsFromPS("The Elder Scrolls V: Skyrim")
            ).then((value) => {
                if (value.DisplayName) {
                    document.getElementById("check-le").innerHTML =
                        "Skyrim LE installed at: " +
                        value.InstallLocation +
                        " <button onclick='changeLEPath()'>Change</button>";
                    updateModpackListJson("Vanilla (Legendary Edition)", 'path', value.InstallLocation + "TESV.exe")
                } else {
                    document.getElementById("check-le").innerHTML =
                        "Skyrim LE not found. <button onclick=\"shell.openExternal('steam://install/72850')\">Install through Steam.</button><button onclick='changeLEPath()'>Enter Path</button>";
                }
                //Check for Skyrim SE
                if(modpackInfo['Vanilla (Special Edition)'].path == "") {
                    Promise.resolve(
                        getProgramDetailsFromPS("The Elder Scrolls V: Skyrim Special Edition")
                    ).then((value) => {
                        if (value.DisplayName) {
                            document.getElementById("check-se").innerHTML =
                                "Skyrim SE installed at: " +
                                value.InstallLocation +
                                " <button onclick='changeSEPath()'>Change</button>";
                        } else {
                            document.getElementById("check-se").innerHTML =
                                "Skyrim SE not found. <button onclick=\"shell.openExternal('steam://install/489830')\">Install through Steam.</button><button onclick='changeSEPath()'>Enter Path</button>";
                        }
                        document.getElementById("install-info").style = "display:block;";
                        document.getElementById("load-install-info").style =
                            "display:none;";
                    });
                } else {
                    document.getElementById("check-se").innerHTML =
                        "Skyrim SE installed at: " +
                        modpackInfo['Vanilla (Special Edition)'].path +
                        " <button onclick='changeSEPath()'>Change</button>";
                    document.getElementById("install-info").style = "display:block;";
                    document.getElementById("load-install-info").style = "display:none;";
                }
            });
        } else {
            document.getElementById("check-le").innerHTML =
                "Skyrim LE installed at: " +
                modpackInfo['Vanilla (Legendary Edition)'].path +
                " <button onclick='changeLEPath()'>Change</button>";
            if(modpackInfo['Vanilla (Special Edition)'].path == "") {
                Promise.resolve(
                    getProgramDetailsFromPS("The Elder Scrolls V: Skyrim Special Edition")
                ).then((value) => {
                    if (value.DisplayName) {
                        document.getElementById("check-se").innerHTML =
                            "Skyrim SE installed at: " +
                            value.InstallLocation +
                            " <button onclick='changeSEPath()'>Change</button>";
                    } else {
                        document.getElementById("check-se").innerHTML =
                            "Skyrim SE not found. <button onclick=\"shell.openExternal('steam://install/489830')\">Install through Steam.</button><button onclick=changeSEPath()>Enter Path</button>";
                    }
                    document.getElementById("install-info").style = "display:block;";
                    document.getElementById("load-install-info").style =
                        "display:none;";
                });
            } else {
                document.getElementById("check-se").innerHTML =
                    "Skyrim SE installed at: " +
                    modpackInfo['Vanilla (Special Edition)'].path +
                    " <button onclick='changeSEPath()'>Change</button>";
                document.getElementById("install-info").style = "display:block;";
                document.getElementById("load-install-info").style = "display:none;";
            }
        }
    });
});
