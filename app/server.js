const http = require('http');
const os = require('os');

const PORT = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end(`
    <html>
      <body style="font-family:sans-serif;padding:2rem;background:#f0f4f8">
        <h1>🚀 GKE Demo App</h1>
        <p><b>Pod:</b> ${os.hostname()}</p>
        <p><b>Time:</b> ${new Date().toISOString()}</p>
        <p><b>Version:</b> ${process.env.APP_VERSION || 'local'}</p>
      </body>
    </html>
  `);
});

server.listen(PORT, () => console.log(`Server running on port ${PORT}`));