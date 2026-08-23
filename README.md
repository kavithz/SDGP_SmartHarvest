# Smart Harvest

Smart Harvest is a full-stack agricultural platform designed to connect farmers, buyers and agriculture officers across Sri Lanka. The platform provides a digital marketplace, crop information, weather updates, secure communication and agricultural services in one application.

## Features

- Crop marketplace for farmers and buyers
- Crop listings with price, quantity and availability
- Buyer and farmer communication
- Real-time weather information
- Secure user authentication
- Real-time messaging
- Push notifications
- Agricultural news and announcements
- Crop price information
- Government and agriculture officer support
- Analytics and dashboard features

## Tech Stack

### Frontend

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging

### Backend

- Python
- Flask
- REST API

### External Services

- OpenWeather API
- Firebase Services

## Project Structure

```text
SmartHarvest/
│
├── frontend/
│   ├── lib/
│   │   ├── core/
│   │   ├── config/
│   │   ├── features/
│   │   └── services/
│   ├── assets/
│   │   ├── images/
│   │   ├── icons/
│   │   └── translations/
│   ├── android/
│   ├── ios/
│   ├── macos/
│   ├── linux/
│   ├── windows/
│   ├── web/
│   ├── test/
│   ├── pubspec.yaml
│   └── main.dart
│
├── backend/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── utils/
│   ├── price_service/
│   ├── app.py
│   ├── config.py
│   ├── database.py
│   └── requirements.txt
│
├── .github/
├── .gitignore
└── README.md
