const assert=require('node:assert/strict');
const {evaluate,lambertW}=require('../maquettes/calculator-engine.js');
let count=0;
function close(expression,expected,options={},tolerance=1e-12){const actual=evaluate(expression,options);assert.ok(Math.abs(actual-expected)<=tolerance*Math.max(1,Math.abs(expected)),`${expression}: ${actual} != ${expected}`);count++;}
for(const [s,v] of [['W(1)',0.5671432904097839],['W(e)',1],['w(0)',0],['W(-1/e)',-1],['wm1(-1/e)',-1],['wm1(-0.1)',-3.577152063957297],['W(-0.1)',-0.11183255915896297],['gamma(0.5)',Math.sqrt(Math.PI)],['gamma(5)',24],['gamma(-0.5)',-2*Math.sqrt(Math.PI)],['5!',120],['0!',1],['ncr(52,5)',2598960],['npr(10,3)',720],['cbrt(-8)',-2],['log2(256)',8],['expm1(1e-8)',Math.expm1(1e-8)],['log1p(1e-8)',Math.log1p(1e-8)],['hypot(3,4)',5],['min(5,2,3)',2],['max(-1,5,2)',5],['mod(17,5)',2],['2^3^2',512],['(-2)^2',4],['3!^2',36]])close(s,v);
close('sin(30)',0.5,{angle:'deg'});close('asin(0.5)',30,{angle:'deg'});close('atan2(1,1)',45,{angle:'deg'});close('sin(pi/2)',1);
close('x^2+ans',151,{variables:{x:12},ans:7});
for(const s of ['W(-0.4)','wm1(0)','wm1(1)','gamma(0)','gamma(-2)','171!','(-1)!','2.5!','sqrt(-1)','log(-1)','asin(2)','tan(90)','ncr(3,4)','ncr(3.5,1)','mod(2,0)','sin(1,2)','x','__proto__','2(3)','sin(1)+']){assert.throws(()=>evaluate(s,{angle:'deg'}),undefined,s);count++;}
for(const x of [-0.36,-0.2,-0.01,-1e-8,-1e-100])for(const branch of [0,-1]){const w=lambertW(x,branch);assert.ok(Math.abs(w*Math.exp(w)/x-1)<2e-12,`${x} ${branch}`);assert.ok(branch===0?w>=-1:w<=-1);count++;}
for(const x of [1e-100,1e-8,1,100,1e100,1e300]){const w=lambertW(x);assert.ok(Math.abs((w+Math.log(w))-Math.log(x))<2e-12*Math.max(1,Math.abs(Math.log(x))));count++;}
console.log(`Scientifique : ${count} tests passent`);
for(const s of ['gamma(172)','gamma(-200.5)'])assert.throws(()=>evaluate(s));
for(const x of [NaN,Infinity,-Infinity])assert.throws(()=>lambertW(x));
console.log('5 limites supplémentaires vérifiées');
for(const [s,v] of [['gcd(48,18)',6],['gcd(-12,0)',12],['lcm(12,18)',36],['lcm(0,0)',0],['trunc(-1.8)',-1],['rad(180)',Math.PI],['deg(pi)',180]])close(s,v);
for(const s of ['gcd(1.2,3)','lcm(9007199254740991,2)'])assert.throws(()=>evaluate(s));
console.log('9 tests entiers / conversions supplémentaires passent');
