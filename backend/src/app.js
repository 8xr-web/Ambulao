const express = require('express');
const admin = require('firebase-admin');

// ── Firebase Admin init ────────────────────────────────────────────────────────
// Set GOOGLE_APPLICATION_CREDENTIALS env variable on Railway to the path of
// your service account JSON, or use admin.credential.cert(require(...)) directly.
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}

// ── Express setup ──────────────────────────────────────────────────────────────
const app = express();
app.use(express.json());

// ── Routes ─────────────────────────────────────────────────────────────────────
const notificationRoutes = require('./routes/notifications');
app.use('/notifications', notificationRoutes);

// Health check
app.get('/health', (req, res) => res.json({ status: 'ok' }));

// ── Start ──────────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Ambulao backend listening on port ${PORT}`));

module.exports = app;
