const admin = require('firebase-admin');

/**
 * Send a single FCM notification to one device token.
 * @param {string} token  - FCM registration token
 * @param {string} title  - Notification title
 * @param {string} body   - Notification body
 * @param {Object} data   - Extra key/value data payload
 * @returns {Promise<boolean>}
 */
const sendNotification = async (token, title, body, data = {}) => {
  try {
    await admin.messaging().send({
      token,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          priority: 'high',
          channelId: 'ambulao_trips',
        },
      },
    });
    return true;
  } catch (error) {
    console.error('FCM send error:', error.message);
    return false;
  }
};

/**
 * Fan-out: Send a new-trip notification to every online driver
 * whose ambulance_type matches and who has a saved fcm_token.
 * @param {string} tripId
 * @param {string} ambulanceType
 * @param {string} pickupAddress
 */
const notifyOnlineDrivers = async (tripId, ambulanceType, pickupAddress) => {
  const db = admin.firestore();

  const driversSnapshot = await db
    .collection('drivers')
    .where('is_online', '==', true)
    .where('ambulance_type', '==', ambulanceType)
    .get();

  const notifications = driversSnapshot.docs
    .filter((doc) => doc.data().fcm_token)
    .map((doc) =>
      sendNotification(
        doc.data().fcm_token,
        '🚨 New Emergency Request',
        `Pickup: ${pickupAddress}`,
        {
          type: 'new_trip',
          trip_id: tripId,
          ambulance_type: ambulanceType,
          pickup_address: pickupAddress,
        }
      )
    );

  await Promise.all(notifications);
  console.log(`[FCM] Notified ${notifications.length} driver(s) for trip ${tripId}`);
};

module.exports = { sendNotification, notifyOnlineDrivers };
