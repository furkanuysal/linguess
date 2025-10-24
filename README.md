# Linguess

Linguess is a Flutter-based multilingual word puzzle application.  
Players guess words in a **target language** based on their equivalents in another language.  
The app includes daily challenges, category-based games, hints, progress tracking, and a gold-based in-app economy.  
User authentication and data persistence are managed via Firebase.

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.litusware.linguess">
    <img alt="Get it on Google Play" height="60" src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"/>
  </a>
  <br/>
  <a href="https://furkanuysal.github.io/linguess">
    <img alt="Play on Web" height="60" src="https://img.shields.io/badge/Play%20on-Web-blue?style=for-the-badge" />
  </a>
</p>

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.litusware.linguess">
    <img alt="Available on Google Play" src="https://img.shields.io/badge/Available%20on-Google%20Play-brightgreen?logo=googleplay" />
  </a>
  <a href="https://furkanuysal.github.io/linguess">
    <img alt="Available on Web" src="https://img.shields.io/badge/Available%20on-Web-blue" />
  </a>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter&logoColor=white" />
  <img alt="Dart" src="https://img.shields.io/badge/Dart-^3-lightblue?logo=dart&logoColor=white" />
  <img alt="Firebase" src="https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Core-orange?logo=firebase&logoColor=white" />
  <img alt="State" src="https://img.shields.io/badge/State-Riverpod-6aa84f" />
  <img alt="Router" src="https://img.shields.io/badge/Router-go__router-8e7cc3" />
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green" />
</p>

---

## Features

* **Word Guessing Gameplay**
* **Word Review System (Practice & Repetition)**
* **Gold-Based Economy**
* **Profile & Progress Tracking**
* **Firebase Authentication**
* **Multi-language Localization**

---

## Tech Stack

* **Framework:** Flutter (Dart)
* **State Management:** Riverpod
* **Routing:** go\_router
* **Backend (BaaS):** Firebase (Auth, Firestore, Core)
* **Ads:** Google Mobile Ads (rewarded ads)
* **UI Enhancements:** Google Fonts, animated text
* **Storage:** shared\_preferences

---

## Installation

### Prerequisites

* Flutter SDK (>=3.32.1)
* Dart SDK (included with Flutter)
* Android Studio / Xcode / VS Code (depending on platform & IDE preference)

### Setup

#### Clone the repository

```bash
git clone https://github.com/furkanuysal/linguess.git
cd linguess
```

#### Install dependencies:

```bash
flutter pub get
```

#### Firebase Setup (required):
This project uses Firebase Authentication and Firestore.
You must connect your own Firebase project before running locally.

#### Running the App:

```bash
flutter run -d android   # or ios / web / macos / windows
```

#### Build for release:

```bash
flutter build apk   # or appbundle / ipa / web
```

---
## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contributing

Contributions, issues and feature requests are welcome!  
Feel free to open an [issue](../../issues) or submit a pull request.

---

## Privacy

Linguess uses Firebase Authentication and Google Mobile Ads.  
Ads are **non-personalized** (not based on personal interests).  

📄 Read the full Privacy Policy here:  
[Privacy Policy](https://sites.google.com/view/linguess/en-privacy)

<p align="center">
  <img src="https://img.shields.io/github/last-commit/furkanuysal/linguess?color=blue" />
  <img src="https://img.shields.io/github/stars/furkanuysal/linguess?style=social" />
</p>
