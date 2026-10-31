// nmcli lists access points, not unique network names.
function networks(rows) {
    var result = [];
    rows.forEach(function(row) {
        if (!row.ssid) return;
        var index = result.findIndex(function(other) {
            return other.ssid === row.ssid && other.security === row.security;
        });
        if (index < 0) result.push(row);
        else if ((row.active && !result[index].active) ||
                 (row.active === result[index].active && row.signal > result[index].signal))
            result[index] = row;
    });
    return result.sort(function(a, b) {
        return Number(b.active) - Number(a.active) || b.signal - a.signal;
    });
}
if (typeof module !== "undefined") module.exports = { networks: networks };
