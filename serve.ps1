# Life Radar - basit kalıcı statik web sunucusu (build/web içeriğini yayınlar).
# Kullanım: powershell -ExecutionPolicy Bypass -File serve.ps1
$ErrorActionPreference = 'Stop'
$root = Join-Path $PSScriptRoot 'build\web'
$port = if ($args.Count -ge 1) { [int]$args[0] } else { 5151 }
$prefix = "http://localhost:$port/"

# Geliştirme anahtarları: repoya GİRMEYEN yerel dosyadan yüklenir (serve.secrets.ps1).
# Bu dosya .gitignore'da; içinde: $env:GROQ_KEY ve $env:PEXELS_KEY tanımlanır.
$secretsFile = Join-Path $PSScriptRoot 'serve.secrets.ps1'
if (Test-Path $secretsFile) { . $secretsFile }

$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.htm'  = 'text/html; charset=utf-8'
  '.js'   = 'application/javascript'
  '.mjs'  = 'application/javascript'
  '.json' = 'application/json'
  '.css'  = 'text/css'
  '.wasm' = 'application/wasm'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.gif'  = 'image/gif'
  '.svg'  = 'image/svg+xml'
  '.ico'  = 'image/x-icon'
  '.otf'  = 'font/otf'
  '.ttf'  = 'font/ttf'
  '.woff' = 'font/woff'
  '.woff2'= 'font/woff2'
  '.map'  = 'application/json'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Host "Life Radar yayinda: $prefix"

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $rel = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))

    # --- Mini proxy: GDELT haber API'si (CORS olmadan gercek veri) ---
    if ($rel -eq 'api/gdelt') {
      $q = $ctx.Request.QueryString['query']
      $articles = '{"articles":[]}'
      if ($q) {
        # Iki noktayi (sourcelang:turkish) koru; sadece bosluk/ozel karakterleri kodla
        $enc = [System.Uri]::EscapeDataString($q).Replace('%3A', ':')
        $gurl = "https://api.gdeltproject.org/api/v2/doc/doc?query=$enc&mode=artlist&format=json&maxrecords=12&sort=datedesc"
        try {
          $resp = Invoke-WebRequest -Uri $gurl -TimeoutSec 10 -UseBasicParsing
          $articles = $resp.Content
        } catch {
          $articles = '{"articles":[]}'
        }
      }
      $b = [System.Text.Encoding]::UTF8.GetBytes($articles)
      $ctx.Response.ContentType = 'application/json; charset=utf-8'
      $ctx.Response.Headers.Add('Access-Control-Allow-Origin', '*')
      $ctx.Response.ContentLength64 = $b.Length
      $ctx.Response.OutputStream.Write($b, 0, $b.Length)
      $ctx.Response.OutputStream.Close()
      continue
    }

    # --- Mini proxy: Groq AI (OpenAI uyumlu, CORS olmadan) ---
    if ($rel -eq 'api/groq') {
      $reader = New-Object System.IO.StreamReader($ctx.Request.InputStream)
      $reqBody = $reader.ReadToEnd()
      $auth = $ctx.Request.Headers['Authorization']
      # Istemci artik gercek anahtar gondermiyor (placeholder). Yerel gelistirmede
      # anahtari burada (sunucu tarafinda) ekle. (Bu dosya son kullaniciya gitmez.)
      if (-not $auth -or $auth -like '*managed-by-backend*') {
        $auth = "Bearer $($env:GROQ_KEY)"
      }
      $out = '{"error":{"message":"proxy"}}'
      $status = 502
      try {
        $resp = Invoke-WebRequest -Uri 'https://api.groq.com/openai/v1/chat/completions' `
          -Method Post -ContentType 'application/json' `
          -Headers @{ 'Authorization' = $auth } -Body $reqBody `
          -TimeoutSec 45 -UseBasicParsing
        $out = [System.Text.Encoding]::UTF8.GetString($resp.RawContentStream.ToArray())
        $status = 200
      } catch {
        $r = $_.Exception.Response
        if ($r) {
          $sr = New-Object System.IO.StreamReader($r.GetResponseStream())
          $out = $sr.ReadToEnd(); $status = [int]$r.StatusCode
        }
      }
      $b = [System.Text.Encoding]::UTF8.GetBytes($out)
      $ctx.Response.StatusCode = $status
      $ctx.Response.ContentType = 'application/json; charset=utf-8'
      $ctx.Response.Headers.Add('Access-Control-Allow-Origin', '*')
      $ctx.Response.ContentLength64 = $b.Length
      $ctx.Response.OutputStream.Write($b, 0, $b.Length)
      $ctx.Response.OutputStream.Close()
      continue
    }

    # --- Mini proxy: RSS/Atom haber akisi (GDELT'e alternatif, hiz limiti yok) ---
    if ($rel -eq 'api/rss') {
      $rssUrl = $ctx.Request.QueryString['url']
      $out = '{"items":[]}'
      if ($rssUrl) {
        try {
          $ErrorActionPreference = 'Continue'
          $resp = Invoke-WebRequest -Uri $rssUrl -TimeoutSec 15 -UseBasicParsing -Headers @{ 'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' }
          $content = [System.Text.Encoding]::UTF8.GetString($resp.RawContentStream.ToArray())
          $items = New-Object System.Collections.Generic.List[object]

          # Atom <entry> veya RSS <item> bloklarini regex ile cikar (saglam, eksikte patlamaz)
          $blocks = [regex]::Matches($content, '(?is)<entry[^>]*>(.*?)</entry>')
          if ($blocks.Count -eq 0) { $blocks = [regex]::Matches($content, '(?is)<item[^>]*>(.*?)</item>') }

          foreach ($bm in $blocks) {
            $blk = $bm.Groups[1].Value

            $titleRaw = [regex]::Match($blk, '(?is)<title[^>]*>(.*?)</title>').Groups[1].Value
            $title = [System.Net.WebUtility]::HtmlDecode([regex]::Replace($titleRaw, '<[^>]+>', '')).Trim()

            $link = ''
            $lm = [regex]::Match($blk, '(?is)<link[^>]*href=["'']([^"'']+)["'']')
            if ($lm.Success) { $link = $lm.Groups[1].Value }
            if (-not $link) { $m2 = [regex]::Match($blk, '(?is)<id>(.*?)</id>'); if ($m2.Success) { $link = $m2.Groups[1].Value.Trim() } }
            if (-not $link) { $m3 = [regex]::Match($blk, '(?is)<link[^>]*>(.*?)</link>'); if ($m3.Success) { $link = $m3.Groups[1].Value.Trim() } }
            if (-not $link) { $m4 = [regex]::Match($blk, '(?is)<guid[^>]*>(.*?)</guid>'); if ($m4.Success) { $link = $m4.Groups[1].Value.Trim() } }

            $cRaw = ''
            $cm = [regex]::Match($blk, '(?is)<content[^>]*>(.*?)</content>'); if ($cm.Success) { $cRaw = $cm.Groups[1].Value }
            if (-not $cRaw) { $sm = [regex]::Match($blk, '(?is)<summary[^>]*>(.*?)</summary>'); if ($sm.Success) { $cRaw = $sm.Groups[1].Value } }
            if (-not $cRaw) { $dm = [regex]::Match($blk, '(?is)<description[^>]*>(.*?)</description>'); if ($dm.Success) { $cRaw = $dm.Groups[1].Value } }
            $cHtml = [System.Net.WebUtility]::HtmlDecode($cRaw)
            $summary = [System.Net.WebUtility]::HtmlDecode([regex]::Replace($cHtml, '(?s)<[^>]+>', '')).Trim()
            $summary = [regex]::Replace($summary, '\s+', ' ')
            if ($summary.Length -gt 240) { $summary = $summary.Substring(0, 240) }

            $img = ''
            $em = [regex]::Match($blk, '(?is)<enclosure[^>]+url=["'']([^"'']+)["'']'); if ($em.Success) { $img = $em.Groups[1].Value }
            if (-not $img) { $mm = [regex]::Match($blk, '(?is)<media:content[^>]+url=["'']([^"'']+)["'']'); if ($mm.Success) { $img = $mm.Groups[1].Value } }
            if (-not $img) { $gm = [regex]::Match($cHtml, '(?i)<img[^>]+src=["'']([^"'']+)["'']'); if ($gm.Success) { $img = $gm.Groups[1].Value } }

            if ($title -and $link) {
              $items.Add([pscustomobject]@{ title = $title; link = $link; summary = $summary; image = $img; date = '' })
            }
            if ($items.Count -ge 15) { break }
          }
          $out = ([pscustomobject]@{ items = $items.ToArray() } | ConvertTo-Json -Depth 5 -Compress)
        } catch {
          $out = '{"items":[]}'
        }
      }
      $b = [System.Text.Encoding]::UTF8.GetBytes($out)
      $ctx.Response.ContentType = 'application/json; charset=utf-8'
      $ctx.Response.Headers.Add('Access-Control-Allow-Origin', '*')
      $ctx.Response.ContentLength64 = $b.Length
      $ctx.Response.OutputStream.Write($b, 0, $b.Length)
      $ctx.Response.OutputStream.Close()
      continue
    }

    # --- Mini proxy: haber tam metni + gorseller (kaynaktan cikar) ---
    if ($rel -eq 'api/article') {
      $aUrl = $ctx.Request.QueryString['url']
      $resultJson = '{"text":"","images":[]}'
      if ($aUrl) {
        try {
          $ErrorActionPreference = 'Continue'
          $resp = Invoke-WebRequest -Uri $aUrl -TimeoutSec 25 -UseBasicParsing -Headers @{ 'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' }
          $html = [System.Text.Encoding]::UTF8.GetString($resp.RawContentStream.ToArray())

          # Ana gorsel (og:image) - temizlik oncesi al
          $imgs = New-Object System.Collections.Generic.List[string]
          $og = [regex]::Match($html, '(?is)<meta[^>]+property=["'']og:image["''][^>]+content=["'']([^"'']+)["'']')
          if ($og.Success) { [void]$imgs.Add($og.Groups[1].Value) }

          # Gurultulu bloklari (menu/script/footer) tamamen kaldir
          foreach ($tag in @('script', 'style', 'nav', 'header', 'footer', 'aside', 'form', 'figure', 'figcaption', 'noscript', 'svg')) {
            $html = [regex]::Replace($html, "(?is)<$tag[^>]*>.*?</$tag>", ' ')
          }

          # Ana govde: en uzun <article> blogu; yoksa tum temizlenmis html
          $content = $html
          $artMatches = [regex]::Matches($html, '(?is)<article[^>]*>(.*?)</article>')
          if ($artMatches.Count -gt 0) {
            $best = ''
            foreach ($am in $artMatches) {
              if ($am.Groups[1].Value.Length -gt $best.Length) { $best = $am.Groups[1].Value }
            }
            if ($best.Length -gt 400) { $content = $best }
          }

          # Junk paragraf kara listesi
          $bl = '(?i)çerez|cookie|abone ol|yorum|reklam|tüm hakları|telif|©|paylaş|ilgili haber|whatsapp|giriş yap|üye ol|bülten|advertisement|subscribe|newsletter|son dakika haber|canlı izle|resmi ilan|copyright'

          $pMatches = [regex]::Matches($content, '(?is)<p[^>]*>(.*?)</p>')
          $paras = New-Object System.Collections.Generic.List[string]
          foreach ($m in $pMatches) {
            $t = [regex]::Replace($m.Groups[1].Value, '(?s)<[^>]+>', '')
            $t = [System.Net.WebUtility]::HtmlDecode($t).Trim()
            $t = [regex]::Replace($t, '\s+', ' ')
            if ($t.Length -lt 40) { continue }
            if ($t -match $bl) { continue }
            [void]$paras.Add($t)
          }
          $text = ($paras -join "`n`n")
          if ($text.Length -gt 8000) { $text = $text.Substring(0, 8000) }

          # Govde icindeki gorseller
          $imgMatches = [regex]::Matches($content, '(?is)<img[^>]+src=["'']([^"'']+)["'']')
          foreach ($im in $imgMatches) {
            $src = $im.Groups[1].Value
            if ($src -match '^https?://' -and $src -notmatch '(?i)logo|icon|sprite|avatar|pixel|1x1|blank|placeholder') {
              if (-not $imgs.Contains($src)) { [void]$imgs.Add($src) }
            }
            if ($imgs.Count -ge 4) { break }
          }

          $obj = [ordered]@{ text = $text; images = @($imgs) }
          $resultJson = $obj | ConvertTo-Json -Compress -Depth 4
        } catch {
          $resultJson = '{"text":"","images":[]}'
        }
      }
      $b = [System.Text.Encoding]::UTF8.GetBytes($resultJson)
      $ctx.Response.ContentType = 'application/json; charset=utf-8'
      $ctx.Response.Headers.Add('Access-Control-Allow-Origin', '*')
      $ctx.Response.ContentLength64 = $b.Length
      $ctx.Response.OutputStream.Write($b, 0, $b.Length)
      $ctx.Response.OutputStream.Close()
      continue
    }

    # --- Mini proxy: Pexels konu fotografi (anahtar sunucuda) ---
    if ($rel -eq 'api/pexels') {
      $q = $ctx.Request.QueryString['q']
      $served = $false
      if ($q) {
        try {
          $ErrorActionPreference = 'Continue'
          $pkey = $env:PEXELS_KEY
          $enc = [System.Uri]::EscapeDataString($q)
          $api = "https://api.pexels.com/v1/search?query=$enc&per_page=1&orientation=landscape"
          $j = Invoke-RestMethod -Uri $api -Headers @{ Authorization = $pkey } -TimeoutSec 20
          $imgUrl = ''
          if ($j.photos -and $j.photos.Count -gt 0) { $imgUrl = [string]$j.photos[0].src.large }
          if ($imgUrl) {
            $resp = Invoke-WebRequest -Uri $imgUrl -TimeoutSec 20 -UseBasicParsing
            $bytes = $resp.Content
            $ct = $resp.Headers['Content-Type']; if ($ct -is [array]) { $ct = $ct[0] }; if (-not $ct) { $ct = 'image/jpeg' }
            $ctx.Response.ContentType = $ct
            $ctx.Response.Headers.Add('Access-Control-Allow-Origin', '*')
            $ctx.Response.Headers.Add('Cache-Control', 'public, max-age=86400')
            $ctx.Response.ContentLength64 = $bytes.Length
            $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
            $ctx.Response.OutputStream.Close()
            $served = $true
          }
        } catch { }
      }
      if (-not $served) { $ctx.Response.StatusCode = 404; $ctx.Response.Close() }
      continue
    }

    # --- Mini proxy: haber gorseli (CORS olmadan goster) ---
    if ($rel -eq 'api/img') {
      $imgUrl = $ctx.Request.QueryString['url']
      if ($imgUrl) {
        try {
          $resp = Invoke-WebRequest -Uri $imgUrl -TimeoutSec 20 -UseBasicParsing
          $bytes = $resp.Content
          $ct = $resp.Headers['Content-Type']
          if (-not $ct) { $ct = 'image/jpeg' }
          if ($ct -is [array]) { $ct = $ct[0] }
          $ctx.Response.ContentType = $ct
          $ctx.Response.Headers.Add('Access-Control-Allow-Origin', '*')
          $ctx.Response.ContentLength64 = $bytes.Length
          $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
          $ctx.Response.OutputStream.Close()
        } catch {
          $ctx.Response.StatusCode = 404; $ctx.Response.Close()
        }
      } else {
        $ctx.Response.StatusCode = 400; $ctx.Response.Close()
      }
      continue
    }

    # --- Mini proxy: ters-geocode (GPS koordinati -> sehir) ---
    if ($rel -eq 'api/revgeo') {
      $lat = $ctx.Request.QueryString['lat']
      $lng = $ctx.Request.QueryString['lng']
      $out = '{}'; $status = 502
      try {
        $u = "https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lng&localityLanguage=tr"
        $resp = Invoke-WebRequest -Uri $u -TimeoutSec 20 -UseBasicParsing
        $j = $resp.Content | ConvertFrom-Json
        $cityVal = $j.city; if ([string]::IsNullOrWhiteSpace($cityVal)) { $cityVal = $j.locality }
        $norm = @{
          city         = $cityVal
          region       = $j.principalSubdivision
          country_name = $j.countryName
          latitude     = [double]$lat
          longitude    = [double]$lng
        } | ConvertTo-Json -Compress
        $out = $norm; $status = 200
      } catch {
        $r = $_.Exception.Response
        if ($r) { $sr = New-Object System.IO.StreamReader($r.GetResponseStream()); $out = $sr.ReadToEnd(); $status = [int]$r.StatusCode }
      }
      $b = [System.Text.Encoding]::UTF8.GetBytes($out)
      $ctx.Response.StatusCode = $status
      $ctx.Response.ContentType = 'application/json; charset=utf-8'
      $ctx.Response.Headers.Add('Access-Control-Allow-Origin', '*')
      $ctx.Response.ContentLength64 = $b.Length
      $ctx.Response.OutputStream.Write($b, 0, $b.Length)
      $ctx.Response.OutputStream.Close()
      continue
    }

    # --- Mini proxy: IP tabanli konum (sehir tespiti) ---
    if ($rel -eq 'api/geo') {
      $out = '{}'; $status = 502
      try {
        $resp = Invoke-WebRequest -Uri 'http://ip-api.com/json/?lang=tr&fields=status,country,regionName,city,lat,lon' `
          -TimeoutSec 20 -UseBasicParsing
        $j = $resp.Content | ConvertFrom-Json
        # ipapi.co tarzi alanlara normalize et (LocationService bekliyor)
        $norm = @{
          city         = $j.city
          region       = $j.regionName
          country_name = $j.country
          latitude     = $j.lat
          longitude    = $j.lon
        } | ConvertTo-Json -Compress
        $out = $norm; $status = 200
      } catch {
        $r = $_.Exception.Response
        if ($r) { $sr = New-Object System.IO.StreamReader($r.GetResponseStream()); $out = $sr.ReadToEnd(); $status = [int]$r.StatusCode }
      }
      $b = [System.Text.Encoding]::UTF8.GetBytes($out)
      $ctx.Response.StatusCode = $status
      $ctx.Response.ContentType = 'application/json; charset=utf-8'
      $ctx.Response.Headers.Add('Access-Control-Allow-Origin', '*')
      $ctx.Response.ContentLength64 = $b.Length
      $ctx.Response.OutputStream.Write($b, 0, $b.Length)
      $ctx.Response.OutputStream.Close()
      continue
    }

    # --- Mini proxy: ceviri (Google Translate ucretsiz gtx endpoint, anahtarsiz) ---
    # POST body: { "items": ["metin1","metin2",...], "to": "tr" }
    # Yanit:     { "items": ["ceviri1","ceviri2",...] }
    if ($rel -eq 'api/translate') {
      $reader = New-Object System.IO.StreamReader($ctx.Request.InputStream, [System.Text.Encoding]::UTF8)
      $reqBody = $reader.ReadToEnd()
      $outItems = New-Object System.Collections.Generic.List[string]
      try {
        $ErrorActionPreference = 'Continue'
        $req = $reqBody | ConvertFrom-Json
        $to = if ($req.to) { $req.to } else { 'tr' }
        foreach ($txt in $req.items) {
          $s = [string]$txt
          if ([string]::IsNullOrWhiteSpace($s)) { $outItems.Add($s); continue }
          # Cok uzun metni kirp (URL limiti); makale govdesi icin yeterli parca
          if ($s.Length -gt 4500) { $s = $s.Substring(0, 4500) }
          try {
            $gurl = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$to&dt=t&q=" + [uri]::EscapeDataString($s)
            $tr = Invoke-WebRequest -Uri $gurl -TimeoutSec 15 -UseBasicParsing -Headers @{ 'User-Agent' = 'Mozilla/5.0' }
            $tj = [System.Text.Encoding]::UTF8.GetString($tr.RawContentStream.ToArray()) | ConvertFrom-Json
            $sb = New-Object System.Text.StringBuilder
            foreach ($seg in $tj[0]) { if ($seg[0]) { [void]$sb.Append([string]$seg[0]) } }
            $res = $sb.ToString()
            if ([string]::IsNullOrWhiteSpace($res)) { $res = $txt }
            $outItems.Add($res)
          } catch {
            $outItems.Add([string]$txt)
          }
        }
      } catch {}
      $out = ([pscustomobject]@{ items = $outItems.ToArray() } | ConvertTo-Json -Depth 4 -Compress)
      $b = [System.Text.Encoding]::UTF8.GetBytes($out)
      $ctx.Response.ContentType = 'application/json; charset=utf-8'
      $ctx.Response.Headers.Add('Access-Control-Allow-Origin', '*')
      $ctx.Response.ContentLength64 = $b.Length
      $ctx.Response.OutputStream.Write($b, 0, $b.Length)
      $ctx.Response.OutputStream.Close()
      continue
    }

    if ([string]::IsNullOrWhiteSpace($rel)) { $rel = 'index.html' }
    $path = Join-Path $root $rel
    if (-not (Test-Path $path -PathType Leaf)) {
      # SPA fallback -> index.html
      $path = Join-Path $root 'index.html'
    }
    $ext = [System.IO.Path]::GetExtension($path).ToLower()
    $ct = $mime[$ext]; if (-not $ct) { $ct = 'application/octet-stream' }
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $ctx.Response.ContentType = $ct
    $ctx.Response.ContentLength64 = $bytes.Length
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $ctx.Response.OutputStream.Close()
  } catch {
    try { $ctx.Response.StatusCode = 500; $ctx.Response.Close() } catch {}
  }
}
