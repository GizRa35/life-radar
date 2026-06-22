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
      if (p === '/api/rates') return await rates();
      if (p === '/api/weather') return await weather(url);
      if (p === '/api/tts') return await tts(request, env);
      if (p === '/api/register-token') return await registerToken(request, env);
      if (p === '/api/send-push') return await sendPush(request, env);
      if (p === '/api/health') return json({ ok: true, service: 'Life Radar API' });
      // AdMob doğrulaması: yetkili satıcı beyanı (app-ads.txt).
      if (p === '/app-ads.txt') {
        return new Response(
          'google.com, pub-5548072655592841, DIRECT, f08c47fec0942fa0\n',
          { headers: { 'Content-Type': 'text/plain; charset=utf-8', ...CORS } },
        );
      }
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
  const res = await fetch(aUrl, {
    headers: { 'User-Agent': UA, 'Accept-Language': 'tr,en;q=0.8' },
  });
  const html = await res.text();

  // 1) Görseller — ÖNEMLİ: <figure> silinmeden ÖNCE, ham HTML'den topla.
  const images = [];
  const og = (html.match(/<meta[^>]+property=["']og:image["'][^>]+content=["']([^"']+)["']/i) || [])[1];
  if (og) images.push(og);
  const tw = (html.match(/<meta[^>]+name=["']twitter:image["'][^>]+content=["']([^"']+)["']/i) || [])[1];
  if (tw && !images.includes(tw)) images.push(tw);
  const junkImg = /(logo|icon|sprite|avatar|pixel|1x1|blank|placeholder|spacer|emoji|favicon|ad[-_]|gravatar)/i;
  for (const m of html.matchAll(/<img[^>]+(?:src|data-src)=["']([^"']+)["']/gi)) {
    const src = m[1];
    if (/^https?:\/\//.test(src) && !junkImg.test(src) && !images.includes(src)) {
      images.push(src);
    }
    if (images.length >= 6) break;
  }

  // 2) Metin — gürültüyü temizle, en uzun <article> (>400) yoksa tüm gövde.
  let clean = html
    .replace(/<script[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style[\s\S]*?<\/style>/gi, ' ')
    .replace(/<(nav|header|footer|aside|form|figure|figcaption|noscript|svg)[\s\S]*?<\/\1>/gi, ' ');
  let content = clean;
  const arts = [...clean.matchAll(/<article[^>]*>([\s\S]*?)<\/article>/gi)].map((m) => m[1]);
  if (arts.length) {
    const best = arts.sort((a, b) => b.length - a.length)[0];
    if (best.length > 400) content = best;
  }
  const bl = /(çerez|cookie|abone|reklam|tüm hakları|telif|©|paylaş|ilgili haber|whatsapp|giriş yap|üye ol|bülten|advertisement|subscribe|newsletter|son dakika|canlı izle|copyright|kaynak:|fotoğraf:)/i;
  const paras = [...content.matchAll(/<p[^>]*>([\s\S]*?)<\/p>/gi)]
    .map((m) => stripTags(m[1]))
    .filter((t) => t.length >= 35 && !bl.test(t));
  let text = paras.join('\n\n');
  if (text.length > 8000) text = text.slice(0, 8000);
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

// ---- /api/rates ---- (TRY cinsinden USD, EUR ve gram altın)
async function rates() {
  let usd = null, eur = null, gold = null;
  // USD/EUR — güvenilir, anahtarsız (base USD).
  try {
    const r = await fetch('https://open.er-api.com/v6/latest/USD');
    if (r.ok) {
      const j = await r.json();
      const tryRate = j?.rates?.TRY;
      const eurRate = j?.rates?.EUR;
      if (tryRate) usd = tryRate;
      if (tryRate && eurRate) eur = tryRate / eurRate; // 1 EUR kaç TRY
    }
  } catch (_) {}
  // Gram altın — best-effort (XAU/USD * USD/TRY / 31.1035).
  try {
    const r = await fetch('https://api.gold-api.com/price/XAU');
    if (r.ok) {
      const j = await r.json();
      const xauUsd = j?.price; // 1 ons altın USD
      if (xauUsd && usd) gold = (xauUsd * usd) / 31.1034768;
    }
  } catch (_) {}
  const round2 = (n) => (n == null ? null : Math.round(n * 100) / 100);
  return json({
    usd: round2(usd),
    eur: round2(eur),
    gold: round2(gold),
    currency: 'TRY',
  });
}

// ---- /api/register-token ---- (FCM cihaz token'ını KV'ye kaydet)
// POST { token, platform } → KV'de "tok:<token>" anahtarıyla saklanır.
// Kritik gelişmede bu token'lara push gönderilir (gönderim: sendPush, Aşama 2).
async function registerToken(request, env) {
  if (!env.TOKENS) return json({ error: 'kv not configured' }, 503);
  const body = await request.json().catch(() => ({}));
  const token = String(body.token || '').trim();
  if (!token) return json({ error: 'no token' }, 400);
  const platform = String(body.platform || 'unknown');
  await env.TOKENS.put(
    `tok:${token}`,
    JSON.stringify({ platform, ts: Date.now() }),
  );
  return json({ ok: true });
}

// ---- Push gönderimi (FCM HTTP v1) ----
// Service account JSON'dan (FCM_SERVICE_ACCOUNT secret) OAuth access token üretir
// (JWT'yi RS256 ile imzalar), sonra tüm kayıtlı token'lara bildirim gönderir.
function _b64url(input) {
  const s = typeof input === 'string'
    ? btoa(input)
    : btoa(String.fromCharCode(...new Uint8Array(input)));
  return s.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}
function _pemToArrayBuffer(pem) {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s+/g, '');
  const bin = atob(b64);
  const buf = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) buf[i] = bin.charCodeAt(i);
  return buf.buffer;
}
async function _fcmAccessToken(sa) {
  const now = Math.floor(Date.now() / 1000);
  const aud = sa.token_uri || 'https://oauth2.googleapis.com/token';
  const header = _b64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const claim = _b64url(JSON.stringify({
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud,
    iat: now,
    exp: now + 3600,
  }));
  const unsigned = `${header}.${claim}`;
  const key = await crypto.subtle.importKey(
    'pkcs8',
    _pemToArrayBuffer(sa.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const sig = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5', key, new TextEncoder().encode(unsigned));
  const jwt = `${unsigned}.${_b64url(sig)}`;
  const r = await fetch(aud, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });
  const j = await r.json();
  if (!j.access_token) throw new Error('oauth: ' + JSON.stringify(j));
  return j.access_token;
}

// Tüm kayıtlı token'lara bildirim gönderir; geçersiz token'ları KV'den siler.
async function _broadcast(env, title, text) {
  const sa = JSON.parse(env.FCM_SERVICE_ACCOUNT);
  const accessToken = await _fcmAccessToken(sa);
  const projectId = sa.project_id;
  let cursor;
  let total = 0, sent = 0, removed = 0;
  const errors = [];
  do {
    const list = await env.TOKENS.list({ prefix: 'tok:', cursor });
    cursor = list.list_complete ? null : list.cursor;
    for (const k of list.keys) {
      total++;
      const token = k.name.slice(4);
      const r = await fetch(
        `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
        {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            message: { token, notification: { title, body: text } },
          }),
        });
      if (r.ok) {
        sent++;
      } else {
        const e = await r.json().catch(() => ({}));
        const code = e?.error?.status;
        // Hata teşhisi için ilk birkaç hatayı topla.
        if (errors.length < 3) {
          errors.push({ status: code, message: e?.error?.message || r.status });
        }
        if (code === 'NOT_FOUND' || code === 'UNREGISTERED' ||
            code === 'INVALID_ARGUMENT') {
          await env.TOKENS.delete(k.name);
          removed++;
        }
      }
    }
  } while (cursor);
  return { total, sent, removed, errors };
}

// ---- /api/send-push ---- (korumalı: admin secret ile tüm cihazlara bildirim)
// POST { title, body }  +  header "x-admin-secret" veya ?secret=...
async function sendPush(request, env) {
  const url = new URL(request.url);
  const secret =
    request.headers.get('x-admin-secret') || url.searchParams.get('secret');
  if (!env.PUSH_ADMIN_SECRET || secret !== env.PUSH_ADMIN_SECRET) {
    return json({ error: 'unauthorized' }, 401);
  }
  if (!env.FCM_SERVICE_ACCOUNT || !env.TOKENS) {
    return json({ error: 'not configured' }, 503);
  }
  const body = await request.json().catch(() => ({}));
  const title = String(body.title || 'Life Radar').slice(0, 120);
  const text = String(body.body || '').trim().slice(0, 400);
  if (!text) return json({ error: 'no body' }, 400);
  try {
    const res = await _broadcast(env, title, text);
    return json({ ok: true, ...res });
  } catch (e) {
    return json({ error: String(e) }, 502);
  }
}

// ---- /api/tts ---- (Google Cloud Text-to-Speech; anahtar Worker secret'ında)
// POST { text, voice? } → audio/mpeg (MP3). Doğal Wavenet Türkçe ses.
async function tts(request, env) {
  if (!env.GOOGLE_TTS_KEY) return json({ error: 'tts not configured' }, 503);
  const body = await request.json().catch(() => ({}));
  let text = String(body.text || '').trim();
  if (!text) return json({ error: 'no text' }, 400);
  // Google TTS tek istekte en fazla ~5000 bayt kabul eder.
  if (text.length > 4800) text = text.slice(0, 4800);
  const voice = String(body.voice || 'tr-TR-Wavenet-C');
  const r = await fetch(
    `https://texttospeech.googleapis.com/v1/text:synthesize?key=${env.GOOGLE_TTS_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        input: { text },
        voice: { languageCode: 'tr-TR', name: voice },
        audioConfig: { audioEncoding: 'MP3', speakingRate: 1.0, pitch: 0.0 },
      }),
    });
  const j = await r.json().catch(() => ({}));
  if (!r.ok || !j.audioContent) {
    return json({ error: 'tts failed', detail: j?.error?.message || r.status }, 502);
  }
  // base64 → ikili MP3
  const bin = atob(j.audioContent);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return new Response(bytes, {
    status: 200,
    headers: {
      'Content-Type': 'audio/mpeg',
      'Cache-Control': 'public, max-age=86400',
      ...CORS,
    },
  });
}

// ---- /api/weather ---- (Open-Meteo: anlık hava + hava kalitesi)
async function weather(url) {
  const lat = url.searchParams.get('lat');
  const lon = url.searchParams.get('lon');
  if (!lat || !lon) return json({ error: 'lat/lon gerekli' }, 400);
  const out = {};
  try {
    const wr = await fetch(
      `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}` +
      `&current=temperature_2m,weather_code,wind_speed_10m,relative_humidity_2m&timezone=auto`);
    if (wr.ok) {
      const j = await wr.json();
      const c = j?.current || {};
      out.temp = c.temperature_2m ?? null;
      out.code = c.weather_code ?? null;
      out.wind = c.wind_speed_10m ?? null;
      out.humidity = c.relative_humidity_2m ?? null;
    }
  } catch (_) {}
  try {
    const ar = await fetch(
      `https://air-quality-api.open-meteo.com/v1/air-quality?latitude=${lat}&longitude=${lon}` +
      `&current=european_aqi,pm2_5&timezone=auto`);
    if (ar.ok) {
      const j = await ar.json();
      const c = j?.current || {};
      out.aqi = c.european_aqi ?? null;
      out.pm25 = c.pm2_5 ?? null;
    }
  } catch (_) {}
  return json(out);
}
