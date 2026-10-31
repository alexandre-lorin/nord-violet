var NordCalculator;
(function (root) {
  'use strict';
  function lambertW(x, branch = 0) {
    if (!Number.isFinite(x)) throw new Error('Lambert W : argument réel fini attendu');
    const edge = -1 / Math.E;
    if (![0, -1].includes(branch) || x < edge || (branch === -1 && x >= 0)) throw new Error('W₀ : x ≥ −1/e ; W₋₁ : −1/e ≤ x < 0');
    if (x === edge) return -1;
    if (x === 0) return 0;
    if (branch === 0 && Math.abs(x) < 1e-8) return x - x*x + 1.5*x*x*x;
    const q = Math.E * (x - edge);
    if (x < 0 && q < 1e-5) {
      const p = (branch === 0 ? 1 : -1) * Math.sqrt(2*q);
      return -1 + p - p*p/3 + 11*p**3/72 - 43*p**4/540 + 769*p**5/17280;
    }
    let low, high, residual;
    if (x < 0) {
      const logx = Math.log(-x);
      low = branch === 0 ? -1 : 2*logx-2;
      high = branch === 0 ? 0 : -1;
      residual = w => w + Math.log(-w) - logx;
      // Sur la branche principale négative, la fonction est décroissante.
    } else {
      low = 0; high = Math.max(1, Math.log(x)+1);
      residual = w => w + Math.log(w) - Math.log(x);
    }
    for (let i=0; i<200; i++) {
      const mid = low + (high-low)/2, value = residual(mid);
      if ((value > 0) === (x >= 0 || branch === -1)) high = mid;
      else low = mid;
      if (high-low <= 4*Number.EPSILON*Math.max(Math.abs(mid), Number.MIN_VALUE)) return low+(high-low)/2;
    }
    throw new Error('Lambert W : convergence insuffisante');
  }

  function gamma(z) {
    if (z <= 0 && Number.isInteger(z)) throw new Error('Gamma : pôle aux entiers ≤ 0');
    if (z < 0.5) return Math.PI / (Math.sin(Math.PI*z)*gamma(1-z));
    const c = [0.99999999999980993,676.5203681218851,-1259.1392167224028,771.32342877765313,-176.61502916214059,12.507343278686905,-0.13857109526572012,9.9843695780195716e-6,1.5056327351493116e-7];
    z -= 1;
    let a=c[0];
    for (let i=1;i<c.length;i++) a+=c[i]/(z+i);
    const t=z+7.5;
    const result = Math.exp(0.5*Math.log(2*Math.PI)+(z+0.5)*Math.log(t)-t+Math.log(a));
    if (!Number.isFinite(result)) throw new Error('Gamma : limite de double précision dépassée');
    return result;
  }
  function factorial(n) {
    if (!Number.isInteger(n) || n<0 || n>170) throw new Error('Factorielle : entier entre 0 et 170');
    let result=1; for(let i=2;i<=n;i++) result*=i; return result;
  }

  function evaluate(source, options = {}) {
    if (source.length > 500) throw new Error('Expression trop longue');
    const text = source.replace(/×/g, '*').replace(/÷/g, '/').replace(/−/g, '-').replace(/π/g, 'pi');
    const tokens = text.match(/(?:\d+(?:\.\d*)?|\.\d+)(?:e[+-]?\d+)?|[a-z_][a-z_0-9]*|[^\s]/gi) || [];
    const variables = options.variables || {};
    const angle = options.angle === 'deg' ? Math.PI/180 : 1;
    const functions = {
      sin: x=>Math.sin(x*angle), cos:x=>Math.cos(x*angle), tan:x=>{const a=x*angle;if(Math.abs(Math.cos(a))<1e-14)throw new Error('Tangente non définie à cet angle');return Math.tan(a);},
      asin:x=>Math.asin(x)/angle, acos:x=>Math.acos(x)/angle, atan:x=>Math.atan(x)/angle,
      atan2:(y,x)=>Math.atan2(y,x)/angle,
      sinh:Math.sinh,cosh:Math.cosh,tanh:Math.tanh,asinh:Math.asinh,acosh:Math.acosh,atanh:Math.atanh,
      sqrt:Math.sqrt,cbrt:Math.cbrt,ln:Math.log,log:Math.log10,log2:Math.log2,exp:Math.exp,expm1:Math.expm1,log1p:Math.log1p,
      abs:Math.abs,floor:Math.floor,ceil:Math.ceil,round:Math.round,sign:Math.sign,trunc:Math.trunc,
      rad:x=>x*Math.PI/180,deg:x=>x*180/Math.PI,
      gcd:(a,b)=>{if(!Number.isSafeInteger(a)||!Number.isSafeInteger(b))throw new Error('PGCD : entiers exactement représentables attendus');a=Math.abs(a);b=Math.abs(b);while(b){const r=a%b;a=b;b=r;}return a;},
      lcm:(a,b)=>{if(!Number.isSafeInteger(a)||!Number.isSafeInteger(b))throw new Error('PPCM : entiers exactement représentables attendus');if(a===0||b===0)return 0;const value=Math.abs((a/functions.gcd(a,b))*b);if(!Number.isSafeInteger(value))throw new Error('PPCM trop grand pour un entier exact');return value;},
      hypot:Math.hypot,min:Math.min,max:Math.max,pow:Math.pow,
      w:x=>lambertW(x,0),w0:x=>lambertW(x,0),wm1:x=>lambertW(x,-1),gamma,fact:factorial,
      mod:(a,b)=>{if(b===0)throw new Error('Modulo par zéro');return a%b;},
      ncr:(n,k)=>{if(!Number.isInteger(n)||!Number.isInteger(k)||n<0||n>170||k<0||k>n)throw new Error('nCr : 0 ≤ k ≤ n ≤ 170, entiers');let v=1;k=Math.min(k,n-k);for(let i=1;i<=k;i++)v*= (n-k+i)/i;return v;},
      npr:(n,k)=>{if(!Number.isInteger(n)||!Number.isInteger(k)||n<0||n>170||k<0||k>n)throw new Error('nPr : 0 ≤ k ≤ n ≤ 170, entiers');let v=1;for(let i=0;i<k;i++)v*=n-i;return v;}
    };
    const arities={atan2:2,pow:2,mod:2,ncr:2,npr:2,gcd:2,lcm:2};
    let position = 0;
    const peek = () => tokens[position];
    const take = token => peek() === token ? (++position, true) : false;
    function primary() {
      let value;
      if (take('(')) {
        value = sum();
        if (!take(')')) throw new Error('Parenthèse fermante manquante');
      } else if (/^[a-z_]/i.test(peek() || '')) {
        const name = tokens[position++].toLowerCase();
        if (!Object.prototype.hasOwnProperty.call(functions,name)) {
          const constants={pi:Math.PI,e:Math.E,tau:2*Math.PI,phi:(1+Math.sqrt(5))/2,ans:options.ans??0};
          if(Object.prototype.hasOwnProperty.call(constants,name)) value=constants[name];
          else if(Object.prototype.hasOwnProperty.call(variables,name)) value=variables[name];
          else throw new Error('Nom inconnu : '+name);
        } else {
        if (!take('(')) throw new Error('Utilisez des parenthèses après ' + name);
        const args=[sum()];
        while(take(',')) args.push(sum());
        if (!take(')')) throw new Error('Parenthèse fermante manquante');
        if(args.length !== (arities[name]||1) && !['hypot','min','max'].includes(name)) throw new Error(name+' : nombre d’arguments incorrect');
        value = functions[name](...args);
        }
      } else {
        const token = tokens[position++];
        if (!/^(?:\d+(?:\.\d*)?|\.\d+)(?:e[+-]?\d+)?$/i.test(token || '')) throw new Error('Expression incomplète ou caractère inconnu');
        value = Number(token);
      }
      while (peek()==='%' || peek()==='!') {if(take('%')) value/=100;else {take('!');value=factorial(value);}}
      if(!Number.isFinite(value)) throw new Error('Résultat hors du domaine réel ou trop grand');
      return value;
    }
    function power() { const value = primary(); return take('^') ? value ** unary() : value; }
    function unary() { if (take('+')) return unary(); if (take('-')) return -unary(); return power(); }
    function product() {
      let value = unary();
      while (peek() === '*' || peek() === '/') {
        const op = tokens[position++], right = unary();
        if (op === '/' && right === 0) throw new Error('Division par zéro');
        value = op === '*' ? value * right : value / right;
      }
      return value;
    }
    function sum() {
      let value = product();
      while (peek() === '+' || peek() === '-') { const op = tokens[position++], right = product(); value = op === '+' ? value + right : value - right; }
      return value;
    }
    const value = sum();
    if (position !== tokens.length) throw new Error('Opérateur manquant ou caractère inconnu');
    if (!Number.isFinite(value)) throw new Error('Résultat hors domaine');
    return value;
  }
  function calculate(source, options) { return Number(evaluate(source,options).toPrecision(12)); }
  NordCalculator = {calculate,evaluate,lambertW,gamma,factorial};
  root.NordCalculator = NordCalculator;
  if (typeof module !== 'undefined') module.exports = root.NordCalculator;
})(typeof globalThis !== 'undefined' ? globalThis : this);
