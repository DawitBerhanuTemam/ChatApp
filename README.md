# TechiBot ChatBot

A Flutter chatbot application with Stripe payment integration.

## Features

- 💬 Interactive chat interface
- 💳 Stripe payment integration (works on web, mobile, and desktop)
- 🌐 Cross-platform support (Web, iOS, Android, macOS, Windows, Linux)

## Quick Start

### 1. Install Dependencies

```bash
flutter pub get
cd backend
npm install
```

### 2. Configure Environment Variables

Create a `.env` file in the `backend` folder:

```bash
cd backend
cp .env.example .env
```

Then edit `.env` and add your Stripe secret key:
```
STRIPE_SECRET_KEY=sk_test_your_actual_stripe_secret_key_here
PORT=3000
```

### 3. Start Backend Server

```bash
cd backend
npm start
```

Server runs on `http://localhost:3000`

### 4. Run the App

**Web (Chrome):**
```bash
flutter run -d chrome
```

**macOS:**
```bash
flutter run -d macos
```

**iOS/Android:**
```bash
flutter run
```

## Payment Testing

Use Stripe test card:
- **Card**: 4242 4242 4242 4242
- **Expiry**: Any future date (e.g., 12/25)
- **CVC**: Any 3 digits (e.g., 123)

## Project Structure

```
lib/
├── screens/          # UI screens
├── services/         # Business logic & API calls
└── config/           # Configuration files

backend/
└── server.js         # Node.js Express server for Stripe
```
