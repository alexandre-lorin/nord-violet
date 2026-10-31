const fs = require('node:fs'), os = require('node:os'), path = require('node:path');
const {spawn,execFileSync} = require('node:child_process');
const assert = require('node:assert/strict');
const root='/home/toubi/01 - Dev/00 - Projets à tester/electron--terminal-deck';
const tmp=fs.mkdtempSync('/tmp/dictation-native-'), home=path.join(tmp,'home'), bin=path.join(tmp,'bin');
fs.mkdirSync(home); fs.mkdirSync(bin);
const bytes=path.join(tmp,'bytes');
fs.writeFileSync(path.join(bin,'codex'),`#!/usr/bin/env node
const fs=require('node:fs');
process.stdin.setRawMode(true);
process.stdout.write('\\x1b[?2004h\\x1b]0;Recette dictée\\x07RECETTE\\r\\n');
process.stdin.on('data',b=>fs.appendFileSync(${JSON.stringify(bytes)},b));
`,{mode:0o700});
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
let app, ws;
const old=JSON.parse(execFileSync('hyprctl',['-j','activewindow'],{encoding:'utf8'})).address;
const env={...process.env,HOME:home,TERMINAL_DECK_PROFILE:path.join(tmp,'profile'),PATH:bin+':'+process.env.PATH};
delete env.ELECTRON_RUN_AS_NODE;
async function main(){
 try {
  app=spawn(path.join(root,'node_modules/electron/dist/electron'),[root,'--no-startup-codex','--ozone-platform=wayland','--remote-debugging-port=19329'],{env,stdio:['ignore','ignore','pipe']});
  let diagnostics=''; app.stderr.on('data',b=>diagnostics=(diagnostics+b).slice(-2000));
  let page;
  for(let i=0;i<100;i++){try{page=(await (await fetch('http://127.0.0.1:19329/json/list')).json()).find(p=>p.type==='page'&&p.url.includes('index.html'));if(page)break;}catch{} await sleep(100)}
  if(!page)throw Error('Recette native indisponible : '+diagnostics);
  ws=new WebSocket(page.webSocketDebuggerUrl); await new Promise((r,j)=>{ws.onopen=r;ws.onerror=j});
  let seq=0;const pending=new Map();ws.onmessage=e=>{const m=JSON.parse(e.data); if(m.id){const p=pending.get(m.id);pending.delete(m.id); if(m.error)p.reject(Error(JSON.stringify(m.error))); else p.resolve(m.result)}};
  const call=(method,params)=>new Promise((resolve,reject)=>{const id=++seq;pending.set(id,{resolve,reject});ws.send(JSON.stringify({id,method,params}))});
  const evaluate=async expression=>{const r=await call('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});if(r.exceptionDetails)throw Error(JSON.stringify(r.exceptionDetails));return r.result.value};
  for(let i=0;i<100;i++){if(await evaluate('typeof state!=="undefined" && !!state'))break; await sleep(100)}
  await evaluate('document.querySelector("#new-codex").click()');
  for(let i=0;i<100;i++){if(await evaluate('[...runtimes.values()].some(r=>r.running)'))break;await sleep(100)}
  await sleep(1000);
  await evaluate('activeRuntime().term.focus()');
  const target=JSON.parse(execFileSync('hyprctl',['-j','clients'],{encoding:'utf8'})).find(w=>w.title.includes('Recette dictée'));
  if(!target)throw Error('Fenêtre native de recette absente');
  execFileSync('hyprctl',['dispatch','focuswindow','address:'+target.address]);
  await sleep(250);
  const deliver=(text,send)=>execFileSync('python3',['-c',`import importlib.util; s=importlib.util.spec_from_file_location('d','/home/toubi/.config/hypr/scripts/codex-dictation.py'); d=importlib.util.module_from_spec(s); s.loader.exec_module(d); target=d.active(); d.hypr('dispatch','submap',d.SUBMAP); d.deliver(${JSON.stringify(text)}, ${send?'True':'False'}, target, lambda: None)`],{timeout:10000});
  deliver('Bonjour Toubi, essai français.',false);
  await sleep(500);
  let b=fs.readFileSync(bytes);
  assert.equal(b.toString(),'\x1b[200~Bonjour Toubi, essai français.\x1b[201~');
  console.log('Brouillon : français collé dans le vrai PTY Electron, aucune Entrée.');
  deliver(' Deuxième essai.',true);
  await sleep(500);
  b=fs.readFileSync(bytes);
  assert.equal(b.toString(),'\x1b[200~Bonjour Toubi, essai français.\x1b[201~\x1b[200~ Deuxième essai.\x1b[201~\r');
  console.log('Envoi : texte collé puis exactement une Entrée dans le vrai PTY.');
  execFileSync('hyprctl',['dispatch','submap','reset']);
  const installed='/home/toubi/.config/hypr/scripts/codex-dictation.py';
  const waitMap=async expected=>{for(let i=0;i<70;i++){if(execFileSync('hyprctl',['submap'],{encoding:'utf8'}).trim()===expected)return;await sleep(75)}throw Error('Sous-mode attendu absent : '+expected)};
  let service=spawn('python3',[installed,'serve'],{stdio:'ignore'});
  await waitMap('codex-dictation');
  execFileSync('python3',[installed,'cancel']);
  await waitMap('default');
  await sleep(200);
  assert.equal(fs.readFileSync(bytes).toString(),b.toString());
  console.log('Échap : vraie capture microphone arrêtée, aucun texte envoyé, clavier normal rétabli.');
  service=spawn('python3',[installed,'serve'],{stdio:'ignore'});
  await waitMap('codex-dictation');
  if(old){execFileSync('hyprctl',['dispatch','focuswindow','address:'+old]);await waitMap('default');await sleep(200);assert.equal(fs.readFileSync(bytes).toString(),b.toString());console.log('Changement de fenêtre : capture annulée automatiquement, aucune saisie.');}
  else {execFileSync('python3',[installed,'cancel']);await waitMap('default');}

 } finally {
  execFileSync('hyprctl',['dispatch','submap','reset']);
  ws?.close();app?.kill();
  if(old)execFileSync('hyprctl',['dispatch','focuswindow','address:'+old]);
 }
}
main().catch(e=>{console.error(e.stack);process.exitCode=1});
