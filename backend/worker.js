/**
 * Life Radar — Production backend (Cloudflare Worker).
 *
 * serve.ps1 içindeki tüm proxy uçlarının bulut karşılığı. CORS'u açar,
 * API anahtarlarını (Groq, Pexels) Worker secret'larında tutar (client'ta GÖMÜLMEZ).
 *
 * Uçlar:  /api/rss · /api/article · /api/translate · /api/groq ·
 *         /api/img · /api/geo · /api/revgeo · /api/pexels · /api/gdelt
 *
 * ── KURULUM ──────────────────────────────────────────────────────────────
 *  1) Node kuruluysa:        npm i -g wrangler
 *  2) Giriş:                 wrangler login
 *  3) Anahtarları gizli ekle (client'a girmez):
 *        wrangler secret put GROQ_KEY
 *        wrangler secret put PEXELS_KEY
 *  4) Yayınla:               wrangler deploy
 *  5) Çıkan adresi Flutter'a ver:
 *        flutter build web --dart-define=API_BASE=https://life-radar.<hesabın>.workers.dev
 * ─────────────────────────────────────────────────────────────────────────
 */

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

const UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)';

function json(obj, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { 'Content-Type': 'application/json; charset=utf-8', ...CORS },
  });
}

function decodeHtml(s) {
  if (!s) return '';
  return s
    .replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&#x27;/g, "'")
    .replace(/&nbsp;/g, ' ').replace(/&rsquo;/g, '’').replace(/&ldquo;/g, '“')
    .replace(/&rdquo;/g, '”');
}
const stripTags = (s) => decodeHtml((s || '').replace(/<[^>]+>/g, ' ')).replace(/\s+/g, ' ').trim();

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') return new Response(null, { headers: CORS });
    const url = new URL(request.url);
    const p = url.pathname;
    try {
      if (p === '/api/rss') return await rss(url);
      if (p === '/api/article') return await article(url);
      if (p === '/api/translate') return await translate(request);
      if (p === '/api/groq') return await groq(request, env);
      if (p === '/api/pexels') return await pexels(url, env);
      if (p === '/api/img') return await img(url);
      if (p === '/api/geo') return await geo();
      if (p === '/api/revgeo') return await revgeo(url);
      if (p === '/api/gdelt') return await gdelt(url);
      if (p === '/api/health') return json({ ok: true, service: 'Life Radar API' });
      // /api dışındaki her şey → Flutter web uygulaması (statik dosyalar + SPA fallback)
      if (env.ASSETS) return env.ASSETS.fetch(request);
      return json({ error: 'not found' }, 404);
    } catch (e) {
      return json({ error: String(e) }, 502);
    }
  },
};

// ---- /api/rss ----
async function rss(url) {
  const feed = url.searchParams.get('url');
  if (!feed) return json({ items: [] });
  const res = await fetch(feed, { headers: { 'User-Agent': UA } });
  const xml = await res.text();
  let blocks = [...xml.matchAll(/<entry[^>]*>([\s\S]*?)<\/entry>/gi)];
  if (blocks.length === 0) blocks = [...xml.matchAll(/<item[^>]*>([\s\S]*?)<\/item>/gi)];
  const items = [];
  for (const m of blocks) {
    const blk = m[1];
    const title = stripTags((blk.match(/<title[^>]*>([\s\S]*?)<\/title>/i) || [])[1]);
    let link = (blk.match(/<link[^>]*href=["']([^"']+)["']/i) || [])[1] || '';
    if (!link) link = ((blk.match(/<link[^>]*>([\s\S]*?)<\/link>/i) || [])[1] || '').trim();
    if (!link) link = ((blk.match(/<guid[^>]*>([\s\S]*?)<\/guid>/i) || [])[1] || '').trim();
    let cRaw = (blk.match(/<content[^>]*>([\s\S]*?)<\/content>/i) || [])[1]
      || (blk.match(/<summary[^>]*>([\s\S]*?)<\/summary>/i) || [])[1]
      || (blk.match(/<description[^>]*>([\s\S]*?)<\/description>/i) || [])[1] || '';
    const cHtml = decodeHtml(cRaw);
    let summary = stripTags(cHtml);
    if (summary.length > 240) summary = summary.slice(0, 240);
    let image = (blk.match(/<enclosure[^>]+url=["']([^"']+)["']/i) || [])[1]
      || (blk.match(/<media:content[^>]+url=["']([^"']+)["']/i) || [])[1]
      || (cHtml.match(/<img[^>]+src=["']([^"']+)["']/i) || [])[1] || '';
    if (title && link) items.push({ title, link, summary, image, date: '' });
    if (items.length >= 15) break;
  }
  return json({ items });
}

// ---- /api/article ----
async function article(url) {
  const aUrl = url.searchParams.get('url');
  if (!aUrl || aUrl.includes('news.google.')) return json({ text: '', images: [] });
  const res = await fetch(aUrl, { headers: { 'User-Agent': UA } });
  let html = await res.text();
  const images = [];
  const og = (html.match(/<meta[^>]+property=["']og:image["'][^>]+content=["']([^"']+)["']/i) || [])[1];
  if (og) images.push(og);
  html = html
    .replace(/<script[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style[\s\S]*?<\/style>/gi, ' ')
    .replace(/<(nav|header|footer|aside|form|figure|figcaption|noscript|svg)[\s\S]*?<\/\1>/gi, ' ');
  const articleBlocks = [...html.matchAll(/<article[^>]*>([\s\S]*?)<\/article>/gi)].map((m) => m[1]);
  const scope = articleBlocks.sort((a, b) => b.length - a.length)[0] || html;
  for (const m of scope.matchAll(/<img[^>]+src=["']([^"']+)["']/gi)) {
    if (m[1].startsWith('http') && !images.includes(m[1])) images.push(m[1]);
    if (images.length >= 5) break;
  }
  const junk = /(çerez|cookie|abone|reklam|tüm hakları|telif|giriş yap|kayıt ol|yorum yap|paylaş)/i;
  const paras = [...scope.matchAll(/<p[^>]*>([\s\S]*?)<\/p>/gi)]
    .map((m) => stripTags(m[1]))
    .filter((t) => t.length >= 40 && !junk.test(t));
  const text = paras.join('\n\n');
  return json({ text, images });
}

// ---- /api/translate ---- (Google ücretsiz gtx endpoint)
async function translate(request) {
  const body = await request.json().catch(() => ({}));
  const to = body.to || 'tr';
  const out = [];
  for (let s of body.items || []) {
    s = String(s || '');
    if (!s.trim()) { out.push(s); continue; }
    if (s.length > 4500) s = s.slice(0, 4500);
    try {
      const u = `https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=${to}&dt=t&q=${encodeURIComponent(s)}`;
      const r = await fetch(u, { headers: { 'User-Agent': 'Mozilla/5.0' } });
      const j = await r.json();
      out.push((j[0] || []).map((seg) => seg[0] || '').join('') || s);
    } catch { out.push(s); }
  }
  return json({ items: out });
}

// ---- /api/groq ---- (anahtar Worker secret'ında)
async function groq(request, env) {
  const reqBody = await request.text();
  const r = await fetch('https://api.groq.com/openai/v1/chat/completions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${env.GROQ_KEY}` },
    body: reqBody,
  });
  const out = await r.text();
  return new Response(out, {
    status: r.status,
    headers: { 'Content-Type': 'application/json; charset=utf-8', ...CORS },
  });
}

// ---- /api/pexels ---- (anahtar Worker secret'ında, görsel olarak döner)
async function pexels(url, env) {
  const q = url.searchParams.get('q') || 'news';
  const r = await fetch(`https://api.pexels.com/v1/search?query=${encodeURIComponent(q)}&per_page=1&orientation=landscape`,
    { headers: { Authorization: env.PEXELS_KEY } });
  const j = await r.json().catch(() => ({}));
  const src = j?.photos?.[0]?.src?.landscape;
  if (!src) return json({ error: 'no image' }, 404);
  const imgRes = await fetch(src);
  return new Response(imgRes.body, {
    status: 200,
    headers: { 'Content-Type': 'image/jpeg', 'Cache-Control': 'public, max-age=86400', ...CORS },
  });
}

// ---- /api/img ---- (haber görselini CORS olmadan geçir)
async function img(url) {
  const src = url.searchParams.get('url');
  if (!src) return json({ error: 'no url' }, 400);
  const r = await fetch(src, { headers: { 'User-Agent': UA } });
  return new Response(r.body, {
    status: r.status,
    headers: {
      'Content-Type': r.headers.get('Content-Type') || 'image/jpeg',
      'Cache-Control': 'public, max-age=86400', ...CORS,
    },
  });
}

// ---- /api/geo ---- (IP tabanlı konum, ip-api normalize)
async function geo() {
  const r = await fetch('http://ip-api.com/json/?lang=tr&fields=status,country,regionName,city,lat,lon');
  const j = await r.json();
  return json({
    city: j.city, region: j.regionName, country_name: j.country,
    latitude: j.lat, longitude: j.lon,
  });
}

// ---- /api/revgeo ---- (koordinattan şehir, BigDataCloud)
async function revgeo(url) {
  const lat = url.searchParams.get('lat');
  const lon = url.searchParams.get('lon');
  const r = await fetch(`https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${lat}&longitude=${lon}&localityLanguage=tr`);
  return new Response(await r.text(), {
    status: r.status, headers: { 'Content-Type': 'application/json; charset=utf-8', ...CORS },
  });
}

// ---- /api/gdelt ----
async function gdelt(url) {
  const query = url.searchParams.get('query') || '';
  const u = `https://api.gdeltproject.org/api/v2/doc/doc?query=${encodeURIComponent(query)}&mode=artlist&format=json&maxrecords=12&sort=datedesc`;
  const r = await fetch(u, { headers: { 'User-Agent': UA } });
  return new Response(await r.text(), {
    status: r.status, headers: { 'Content-Type': 'application/json; charset=utf-8', ...CORS },
  });
}
