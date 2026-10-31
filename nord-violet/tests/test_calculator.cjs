const assert = require('node:assert/strict');
const {calculate} = require('../maquettes/calculator-engine.js');
for (const [expression, expected] of [['2+3*4',14],['(2+3)*4',20],['-2^2',-4],['2^-2',0.25],['2^3^2',512],['20%',0.2],['129.9*0.8',103.92],['sqrt(256)*1.5',24],['sin(pi/2)',1],['log(100)',2],['1e-3+2',2.001],['3×4−2',10]]) assert.equal(calculate(expression),expected,expression);
for (const expression of ['1/0','sqrt(-1)','2+','(2+3','2abc','globalThis.process','2**3','']) assert.throws(()=>calculate(expression),undefined,expression);
assert.throws(()=>calculate('1'.repeat(501)));
console.log('Calculatrice : 21 tests passent');
