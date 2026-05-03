const express = require('express');
const router = express.Router();
const { notifyOnlineDrivers } = require('../services/notificationService');

/**
 * POST /notifications/new-trip
 * Body: { tripId, ambulanceType, pickupAddress }
 * Fan-out FCM push to all matching online drivers.
 */
router.post('/new-trip', async (req, res) => {
  const { tripId, ambulanceType, pickupAddress } = req.body;

  if (!tripId || !ambulanceType) {
    return res.status(400).json({ error: 'Missing required fields: tripId, ambulanceType' });
  }

  try {
    await notifyOnlineDrivers(tripId, ambulanceType, pickupAddress ?? 'Emergency');
    res.json({ success: true });
  } catch (error) {
    console.error('[notifications/new-trip]', error);
    res.status(500).json({ error: 'Failed to send notifications' });
  }
});

module.exports = router;
