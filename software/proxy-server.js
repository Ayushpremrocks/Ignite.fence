// Simple CORS proxy for the Smart Fence dashboard
// Usage:
// 1) npm install express axios cors
// 2) node proxy-server.js
// 3) In js/dashboard.js set PROXY_BASE = 'http://localhost:3001/'

const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3001;

// External API endpoint
const EXTERNAL_API = 'https://ecomlancers.com/Sih_Api/fetch_data';

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/', (req, res) => res.json({ ok: true, proxy: true }));

// Proxy endpoint that mirrors the external API
app.all('/fetch_data', async (req, res) => {
  try {
    const method = req.method.toUpperCase();

    // Build request to external API
    let response;
    if (method === 'GET') {
      response = await axios.get(EXTERNAL_API, {
        params: req.query,
        headers: { Accept: 'application/json' },
        timeout: 8000,
      });
    } else if (method === 'POST') {
      // Accept both JSON and form-urlencoded from the browser
      const contentType = req.headers['content-type'] || '';
      if (contentType.includes('application/x-www-form-urlencoded')) {
        const params = new URLSearchParams(req.body).toString();
        response = await axios.post(EXTERNAL_API, params, {
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          timeout: 8000,
        });
      } else {
        response = await axios.post(EXTERNAL_API, req.body, {
          headers: { 'Content-Type': 'application/json' },
          timeout: 8000,
        });
      }
    } else {
      return res.status(405).json({ error: 'Method Not Allowed' });
    }

    // Forward external response as-is
    res.status(response.status).send(response.data);
  } catch (err) {
    const status = err.response?.status || 502;
    const data = err.response?.data || { error: 'Bad Gateway', message: String(err) };
    res.status(status).send(data);
  }
});

app.listen(PORT, () => {
  console.log(`CORS proxy running at http://localhost:${PORT}`);
});
