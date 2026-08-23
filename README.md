# SmartHarvest

SmartHarvest is a full-stack agricultural platform built to support farmers, buyers, and agriculture officers across Sri Lanka. It provides a digital marketplace where farmers can list their crops, buyers can connect directly with producers, and agriculture officers can share guidance and updates.

The app is built with **Flutter** (mobile/web) and a **Flask** backend, using **Firebase** for authentication, real-time data, file storage, and push notifications. The goal is to simplify agricultural trade and improve communication between everyone involved in the farming supply chain.

## Key Features

- **User Authentication** — Firebase Authentication with email/password, email OTP verification, and Google Sign-In
- **Crop Management** — farmers can list, update, and manage their crops
- **Marketplace** — buyers can browse crop listings and connect with farmers
- **Market Prices** — live crop price data with ML-based price forecasting
- **Weather Information** — current weather updates via OpenWeatherMap to support farming decisions
- **Notifications** — push notifications through Firebase Cloud Messaging
- **Chat / Messaging** — direct messaging between users
- **Analytics** — usage and marketplace analytics
- **News** — agricultural news updates
- **Surplus Management** — managing and listing surplus crops
- **Government Dashboard** — dedicated tools for agriculture officers
- **Multi-language Support** — available in English, Sinhala, and Tamil

## Technologies Used

**Frontend**
- Flutter / Dart
- flutter_bloc (state management)
- Firebase Authentication, Cloud Firestore, Firebase Storage, Firebase Cloud Messaging
- Google Sign-In
- Dio / HTTP for networking

**Backend**
- Python / Flask (REST API)
- Firebase Admin SDK (Auth, Firestore, Cloud Messaging)
- scikit-learn, pandas, NumPy (crop price forecasting)
- PyJWT, Passlib (security)
- OpenWeatherMap API (weather data)
- SMTP (email OTP verification)
- Gunicorn (production server)

## Project Structure

```text
SDGP_SmartHarvest-main/
├── frontend/   # Flutter app (mobile & web)
├── backend/    # Flask REST API
└── README.md
```

- **frontend/** — Flutter application containing UI, state management, and Firebase client integration, organized by feature (authentication, crop management, marketplace, weather, messaging, etc.)
- **backend/** — Flask API containing routes, services, models, and the price forecasting logic, using Firebase Admin SDK for auth verification and Firestore access

## How to Run the Project

The project may be downloaded or cloned to different locations, so replace `/path/to/SDGP_SmartHarvest-main` below with your actual project folder path.

### Frontend

```bash
cd /path/to/SDGP_SmartHarvest-main
cd frontend
flutter pub get
flutter run
```

If Flutter asks which device to use, select Chrome, macOS, or another configured device.

If you run into build or dependency issues, clean the project first:

```bash
flutter clean
flutter pub get
flutter run
```

### Backend

```bash
cd /path/to/SDGP_SmartHarvest-main/backend
```

Create and activate a Python virtual environment:

```bash
python3 -m venv venv
source venv/bin/activate
```

Install the dependencies:

```bash
pip install -r requirements.txt
```

Copy the example environment file and fill in your own values:

```bash
cp .env.example .env
```

Make sure `serviceAccountKey.json` (your Firebase service account key) is placed inside the `backend` folder.

Then start the backend:

```bash
python3 app.py
```

The API will run on `http://localhost:5000`.

## Firebase Configuration

This project requires your own Firebase project and credentials to run:

- A Firebase service account key file, saved as `backend/serviceAccountKey.json`
- A `.env` file in `backend/` created from `.env.example`

**Never commit `serviceAccountKey.json` or `.env` to GitHub.** Both files contain private credentials and are excluded via `.gitignore`.

## Environment Variables

The backend uses a `.env` file (created from `backend/.env.example`) with values such as:

- `SECRET_KEY` — Flask secret key
- `FLASK_DEBUG` — enable/disable debug mode
- `FIREBASE_CREDENTIALS` — path to the Firebase service account key
- `FIREBASE_PROJECT_ID` — your Firebase project ID
- `OPENWEATHER_API_KEY` — API key from OpenWeatherMap
- `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `SMTP_FROM` — used to send OTP verification emails

Fill these in with your own values — do not use real credentials in a public repository.

## Development Notes

- Run `flutter pub get` after downloading the project to install frontend dependencies.
- Set up and activate the Python virtual environment before installing backend dependencies or running the Flask server.
- Firebase credentials and a valid `.env` file are required for the backend to start.
- The project path differs depending on where the project is downloaded or cloned, so always update commands to match your local path.

## GitHub / Security

Before pushing to a public repository, make sure the following are **not** committed:

- `.env` files
- `serviceAccountKey.json`
- Python virtual environment folders (`venv/`)
- Flutter build output (`build/`, `.dart_tool/`)

These are already excluded via `.gitignore`, but always double-check before pushing.

## Future Improvements

- Improve market price forecasting accuracy
- Add AI-based crop recommendations
- Expand notification features
- Add more detailed farmer analytics
- Add online payment integration
- Add order tracking and delivery management
- Add farmer ratings and reviews