const fs = require('fs');
const path = require('path');

function walk(dir, acc) {
  for (const f of fs.readdirSync(dir)) {
    const p = path.join(dir, f);
    const st = fs.statSync(p);
    if (st.isDirectory()) walk(p, acc);
    else if (p.endsWith('.dart')) acc.push(p);
  }
  return acc;
}

const trChars = /[ğşıçöüİŞĞÇÖÜ]/;
// string literal with Turkish chars
const strRe = /'((?:\\.|[^'\\])*)'|"((?:\\.|[^"\\])*)"/g;
const dirs = ['lib/screens', 'lib/widgets'];
let count = 0;
for (const d of dirs) {
  if (!fs.existsSync(d)) continue;
  for (const file of walk(d, [])) {
    const lines = fs.readFileSync(file, 'utf8').split('\n');
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const trimmed = line.trim();
      if (trimmed.startsWith('//') || trimmed.startsWith('*') ||
          trimmed.startsWith('import ')) continue;
      let m;
      strRe.lastIndex = 0;
      while ((m = strRe.exec(line))) {
        const s = m[1] !== undefined ? m[1] : m[2];
        if (!s || !trChars.test(s)) continue;
        // skip if this literal is the argument of t( right before it
        const before = line.slice(0, m.index);
        if (/t\(\s*$/.test(before)) continue;
        // skip asset/url-ish
        if (/https?:\/\//.test(s) || s.includes('/')) continue;
        count++;
        console.log(file.replace(/\\/g, '/') + ':' + (i + 1) + '  ' + JSON.stringify(s));
      }
    }
  }
}
console.log('---TOTAL BARE:' + count);
