const assert = require('node:assert/strict');
const {networks} = require('../../quickshell-cc/.config/quickshell/nord-violet-cc/scripts/WifiState.js');
const row = (ssid, signal, active=false, security='WPA2') => ({ssid,signal,active,security});
assert.deepEqual(networks([row('Box',69),row('Box',79)]), [row('Box',79)]);
assert.deepEqual(networks([row('Box',69,true),row('Box',79)]), [row('Box',69,true)]);
assert.equal(networks([row('Box',69),row('Box',79,false,'--')]).length,2);
assert.deepEqual(networks([row('',90),row('Other',90),row('Box',40,true)]).map(r=>r.ssid),['Box','Other']);
assert.deepEqual(networks([]),[]);
console.log('Wi-Fi : 5 tests passent');
