let validateJSON;
function updatePath(elementID) {
    let folder = pickFolder();
    if(folder != undefined)
    {
        document.getElementById(elementID).value = folder;
    }
}

async function validateUserAPIKey() {
    let url = `https://api.nexusmods.com/v1/users/validate.json`;
    let myKey = document.getElementById('fAPIKey').value
    let response = await fetch(url, {
        headers: {
            apiKey: myKey
        }
    })
    validateJSON = await response.json()
    document.getElementById('username').innerText = validateJSON.name;
    document.getElementById('isPremium').innerText = validateJSON.is_premium;
    document.getElementById('userAPIKey').innerText = validateJSON.key;
}

function showAPIKey()
{
    document.getElementById('userAPIKey').style = 'display: block;';
    document.getElementById('apiToggle').innerText = 'Hide';
    document.getElementById('apiToggle').setAttribute('onclick', 'hideAPIKey()');
}

function hideAPIKey()
{
    document.getElementById('userAPIKey').style = 'display: none;';
    document.getElementById('apiToggle').innerText = 'Show';
    document.getElementById('apiToggle').setAttribute('onclick', 'showAPIKey()');
}

function confirmSettings() {
    settingsJSON.firstRun = false;
    settingsJSON.downloadPath = document.getElementById('fDownloadPath').value;
    settingsJSON.defaultInstallPath = document.getElementById('fInstallPath').value;
    settingsJSON.nexusAPIKey = validateJSON.key;
    settingsJSON.nexusPremium = validateJSON.is_premium;
    settingsJSON.username = validateJSON.name;
    fs.writeFile(__dirname + '\\settings.json', JSON.stringify(settingsJSON, null, 2), function writeJSON(err) {
        if (err) return console.log(err);
    });
    window.location.href = '../index.html'
}