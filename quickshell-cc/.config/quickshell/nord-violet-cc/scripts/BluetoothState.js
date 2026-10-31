// Fonctions sans dépendance : utilisables par QML et les tests Node.
function parseDevices(text) {
    var devices = [];
    var seen = {};
    for (var line of text.split("\n")) {
        var match = line.trim().match(/^Device ((?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}) (.+)$/);
        if (!match) continue;
        var address = match[1].toUpperCase();
        if (seen[address]) continue;
        seen[address] = true;
        devices.push({ address: address, name: match[2] });
    }
    return devices;
}

function connectedAddresses(text) {
    return parseDevices(text).map(function(device) { return device.address; });
}
