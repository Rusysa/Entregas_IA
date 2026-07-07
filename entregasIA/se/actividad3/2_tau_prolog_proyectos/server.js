const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = process.env.PORT ? Number(process.env.PORT) : 8000;
const BASE_DIR = __dirname;

const MIME_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".pl": "text/plain; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".txt": "text/plain; charset=utf-8",
};

function send404(res) {
  res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
  res.end("404 - Archivo no encontrado");
}

function send500(res) {
  res.writeHead(500, { "Content-Type": "text/plain; charset=utf-8" });
  res.end("500 - Error interno del servidor");
}

const server = http.createServer((req, res) => {
  try {
    const urlPath = decodeURIComponent(req.url.split("?")[0]);
    const requestedPath = urlPath === "/" ? "/index.html" : urlPath;

    const normalizedPath = path
      .normalize(requestedPath)
      .replace(/^([.][.][/\\])+/, "");

    const filePath = path.join(BASE_DIR, normalizedPath);

    if (!filePath.startsWith(BASE_DIR)) {
      return send404(res);
    }

    fs.readFile(filePath, (err, data) => {
      if (err) {
        if (err.code === "ENOENT") return send404(res);
        return send500(res);
      }

      const ext = path.extname(filePath).toLowerCase();
      const contentType = MIME_TYPES[ext] || "application/octet-stream";
      res.writeHead(200, { "Content-Type": contentType });
      res.end(data);
    });
  } catch {
    send500(res);
  }
});

server.listen(PORT, () => {
  console.log(`Servidor listo en http://localhost:${PORT}`);
});
