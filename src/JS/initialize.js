function initializeAS() {
    if(userInfo.username == "" || userInfo.username == undefined) {
        dialog.showErrorBox("Azura's Star","You are not authenticated with the Nexus. Please open the settings and authenticate.")
        return
    }
    dialog.showMessageBox('Test','test')
}