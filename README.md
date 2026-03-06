# Oversized Recyclable Items Ecosystem (UTP)

A cross-platform Flutter application designed to facilitate the buying, selling, and recycling of second-hand oversized items (like furniture, electronics, and appliances) within a university campus setting (Universiti Teknologi PETRONAS).

The app promotes a circular economy by making it easy for students to pass on their bulky items, reducing waste and carbon emissions.

## Core Features

* **Smart Marketplace:** Browse active listings using a visually appealing Grid View or a location-based Map View.

* **AI-Powered Item Listing:** * **Magic Write:** Automatically generates catchy item descriptions.

  * **AI Auto-Pricing:** Integrates with the Gemini Vision API to analyze uploaded images, identify brands, and suggest a fair second-hand selling price based on the item's condition.

* **Eco-Gamification:** Users earn "Eco-Points" for listing items, allowing them to level up (from *Seedling* to *Forest Guardian*) and track their estimated CO2 savings.

* **Direct Communication:** Seamless integration to contact sellers directly via WhatsApp, Telegram, or Email.

* **Admin Dashboard:** A dedicated interface for campus administrators to track expired listings on a map and schedule them for official recycling/trash pickup.

* **Responsive Design:** Fully adaptive UI with dedicated layouts for both mobile devices (Small Screen) and web/desktop (Large Screen).

## Tech Stack

* **Frontend:** Flutter & Dart

* **Backend:** Firebase (Authentication, Firestore, Cloud Storage)

* **Maps:** `flutter_map` (OpenStreetMap integration)

* **AI Integration:** Google Gemini Pro Vision API (for image analysis and pricing)

* **State Management:** Provider (`AppState`, `UserState`)

## Getting Started

1. Ensure you have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.

2. Clone this repository.

3. Run `flutter pub get` to install dependencies.

4. Add your Google Maps/Firebase configuration details (handled via `firebase_options.dart`).

5. Run the app using `flutter run` (supports Web, Android, and iOS).
