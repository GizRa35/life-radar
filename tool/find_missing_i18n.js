const fs = require('fs');
const path = require('path');
const libDir = 'lib';
const i18nPath = 'lib/core/i18n.dart';

function walk(dir, acc) {
  for (const f of fs.readdirSync(dir)) {
    const p = path.join(dir, f);
    const st = fs.statSync(p);
    if (st.isDirectory()) walk(p, acc);
    else if (p.endsWith('.dart')) acc.push(p);
  }
  return acc;
}

const used = new Set();
const reS = /\bt\(\s*'((?:\\.|[^'\\])*)'/g;
const reD = /\bt\(\s*"((?:\\.|[^"\\])*)"/g;
for (const file of walk(libDir, [])) {
  if (file.replace(/\\/g, '/').endsWith('core/i18n.dart')) continue;
  const src = fs.readFileSync(file, 'utf8');
  let m;
  while ((m = reS.exec(src))) used.add(m[1].replace(/\\'/g, "'"));
  while ((m = reD.exec(src))) used.add(m[1].replace(/\\"/g, '"'));
}

const i18n = fs.readFileSync(i18nPath, 'utf8');
const defined = new Set();
// Hem tek hem çift tırnaklı anahtarları say.
const reKey = /^\s*(?:'((?:\\.|[^'\\])*)'|"((?:\\.|[^"\\])*)")\s*:/gm;
let k;
while ((k = reKey.exec(i18n))) {
  const raw = k[1] !== undefined ? k[1] : k[2];
  defined.add(raw.replace(/\\'/g, "'").replace(/\\"/g, '"'));
}

const missing = [...used]
  .filter((x) => !defined.has(x))
  .filter((x) => x.trim().length > 0);
console.log('USED:' + used.size + ' DEFINED:' + defined.size + ' MISSING:' + missing.length);
console.log('---MISSING---');
for (const x of missing.sort()) console.log(JSON.stringify(x));
