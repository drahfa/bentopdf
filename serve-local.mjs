import { createServer } from 'http';
import { readFile, stat } from 'fs/promises';
import { join, extname } from 'path';
import { fileURLToPath } from 'url';

const PORT = 8090;
const DIST = join(fileURLToPath(import.meta.url), '..', 'dist');

const MIME_TYPES = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.mjs': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.wasm': 'application/wasm',
  '.xml': 'application/xml',
  '.webmanifest': 'application/manifest+json',
  '.webp': 'image/webp',
  '.pdf': 'application/pdf',
  '.txt': 'text/plain',
  '.map': 'application/json',
  '.ftl': 'text/plain',
  '.data': 'application/octet-stream',
};

async function tryFile(filePath) {
  try {
    const s = await stat(filePath);
    if (s.isFile()) return filePath;
  } catch {}
  return null;
}

async function resolve(urlPath) {
  let p = join(DIST, decodeURIComponent(urlPath));
  let found = await tryFile(p);
  if (found) return found;
  // Try with .html
  found = await tryFile(p + '.html');
  if (found) return found;
  // Try index.html in directory
  found = await tryFile(join(p, 'index.html'));
  if (found) return found;
  return null;
}

const server = createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  let filePath = await resolve(url.pathname);

  // SPA fallback
  if (!filePath) filePath = join(DIST, 'index.html');

  const ext = extname(filePath);
  const mime = MIME_TYPES[ext] || 'application/octet-stream';

  res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
  res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', mime);

  try {
    const data = await readFile(filePath);
    res.writeHead(200);
    res.end(data);
  } catch {
    res.writeHead(404);
    res.end('Not found');
  }
});

server.listen(PORT, () => {
  console.log(`Serving dist/ on http://localhost:${PORT}`);
  console.log('COOP/COEP headers enabled');
});
