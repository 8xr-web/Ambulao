# 🚑 AMBULAO

**Emergency Ambulance Booking, Reimagined.**

AMBULAO is a full-stack emergency ambulance dispatch platform connecting patients in need with certified ambulance drivers in real time. Built for speed, reliability, and trust — because in an emergency, every second counts.

---

## 📱 What is AMBULAO?

AMBULAO is a two-sided platform consisting of:

- **Patient App** — Book an ambulance instantly, track it live, and pay digitally or by cash
- **Driver App** — Accept trip requests, navigate to patients, manage earnings, and stay online with a single tap
- **Web Platform** — Landing page with app download links and upcoming web booking support

---

## 🧩 Platform Overview

| Component | Tech Stack | Status |
|---|---|---|
| Driver App | React Native / Antigravity | ✅ In Development |
| Patient App | React Native | 🔜 Coming Soon |
| Website | HTML / CSS / JS | ✅ Live |
| Backend API | Node.js / Express | 🔜 Coming Soon |
| Maps Integration | Google Maps SDK | ✅ In Development |

---

## ✨ Key Features

### For Patients
- 🆘 One-tap emergency ambulance booking
- 📍 Real-time GPS tracking of the ambulance
- 💬 In-app chat and call with the driver
- 💳 Cash, UPI, and card payment support
- 🏥 Schedule hospital transfer rides in advance

### For Drivers
- 🔔 Instant trip request notifications with 10s accept window
- 🗺 Turn-by-turn navigation to patient and hospital
- 💰 Real-time earnings dashboard with weekly/monthly breakdown
- 📄 In-app document upload and management
- 🏦 Bank and UPI payout management
- ⭐ Ratings, acceptance rate, and performance tracking

---

## 🎨 Design System

AMBULAO uses a custom **iOS 26-inspired design system**:

- **Primary Blue** `#007AFF` — main brand color
- **Deep Blue** `#0040A0` — headers and active states  
- **Sky Blue** `#E8F2FF` — backgrounds and card fills
- **Typography** — Nunito (display) + Nunito Sans (body)
- **Style** — Liquid glass morphism, pill buttons (50px radius), frosted blur panels

---

## 🗂 Repository Structure
```
ambulao/
├── driver-app/          # React Native driver-facing app
│   ├── screens/         # All 19 app screens
│   ├── components/      # Reusable UI components
│   ├── navigation/      # Stack and tab navigation
│   ├── assets/          # Icons, fonts, images
│   └── services/        # API calls, location, maps
├── patient-app/         # React Native patient-facing app (coming soon)
├── website/             # Static HTML/CSS/JS landing page
│   └── index.html
├── backend/             # Node.js API server (coming soon)
│   ├── routes/
│   ├── models/
│   └── controllers/
└── docs/                # Design specs, API docs, Figma links
```

---

## 🚀 Getting Started

### Driver App
```bash
# Clone the repository
git clone https://github.com/your-org/ambulao.git

# Navigate to driver app
cd ambulao/driver-app

# Install dependencies
npm install

# Start the development server
npm start

# Run on Android
npm run android

# Run on iOS
npm run ios
```

### Website
```bash
# Navigate to website folder
cd ambulao/website

# Open in browser
open index.html
```

---

## 📸 Screenshots

> Driver App — 19 Screens including Splash, Login, OTP, Home, Trip Request, Navigation, Earnings, Wallet, Profile, and Settings.

*(Add screenshots here)*

---

## 🗺 Roadmap

- [x] Driver App UI — 19 screens
- [x] AMBULAO Website — Landing page
- [ ] Driver App — Backend API integration
- [ ] Patient App — UI and booking flow
- [ ] Web Booking — Live ambulance booking from browser
- [ ] Admin Dashboard — Fleet and dispatch management
- [ ] Push Notifications — Firebase Cloud Messaging
- [ ] Payment Gateway — Razorpay integration

---

## 🤝 Contributing

Contributions are welcome. Please open an issue first to discuss what you'd like to change. Make sure to follow the existing design system and code conventions.

---

## 📄 License

MIT License — © 2026 AMBULAO Technologies Pvt. Ltd., Hyderabad, India

---

## 📬 Contact

- Website: [ambulao.in](https://ambulao.in)
- Email: support@ambulao.in
- Helpline: 1800-AMBULAO (1800-262-5226)
```

---

## One-liner for npm / package.json description
```
Emergency ambulance booking platform — driver app, patient app, and web presence for real-time dispatch in Hyderabad.
```

---

## App Store / Play Store Short Description (80 chars max)
```
Book a certified ambulance instantly. Real-time tracking. 24/7.
```

---

## App Store / Play Store Long Description
```
AMBULAO is Hyderabad's emergency ambulance booking app — 
connecting patients with the nearest certified ambulance 
driver in seconds.

🚑 INSTANT BOOKING — Tap once, ambulance dispatched
📍 LIVE TRACKING — Watch your ambulance arrive in real time  
💬 IN-APP COMMUNICATION — Chat and call your driver directly
💳 FLEXIBLE PAYMENTS — Cash, UPI, or card
🏥 HOSPITAL TRANSFERS — Schedule non-emergency rides
⭐ VERIFIED DRIVERS — Background-checked and certified

Every second counts. AMBULAO makes sure help is always 
on the way.# Ambulao
Full project
