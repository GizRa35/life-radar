const fs = require('fs');
const s = fs.readFileSync('lib/core/i18n.dart', 'utf8');
// Hem tek hem çift tırnaklı anahtarları yakala: satır başı '...' : veya "..." :
const re = /^\s*('(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*")\s*:/gm;
function unescape(lit) {
  const q = lit[0];
  let body = lit.slice(1, -1);
  // basit kaçış çözümü
  body = body.replace(/\\(['"\\nt])/g, (m, c) =>
    c === 'n' ? '\n' : c === 't' ? '\t' : c);
  return body;
}
const seen = new Map();
let m;
while ((m = re.exec(s))) {
  const raw = m[1];
  const val = unescape(raw);
  if (!seen.has(val)) seen.set(val, []);
  seen.get(val).push(raw);
}
const dups = [];
for (const [val, raws] of seen) {
  if (raws.length > 1) dups.push(JSON.stringify(val) + '  ->  ' + raws.join('  ||  '));
}
console.log('Benzersiz anahtar: ' + seen.size);
console.log(dups.length ? 'YINELENEN (runtime ayni):\n' + dups.join('\n') : 'Yinelenen yok');
