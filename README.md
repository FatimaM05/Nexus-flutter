# Nexus – Personal Productivity & Life Management App

Nexus is a cross-platform mobile application built with **Flutter** that helps users manage daily tasks, personal journals, and life highlights in a single unified platform. The app combines productivity tools with reflective journaling to support both organization and personal well-being.

## 📱 Features

### 🔐 Authentication
- Email & Password registration and login
- Google Sign-In (OAuth 2.0)
- Secure session management
- Persistent login using SharedPreferences

### ✅ To-Do Management
- Create multiple to-do lists
- Add, update, and delete tasks
- Mark tasks as completed
- Real-time task search and filtering

### 📔 Journal Management
- Create and edit personal journal entries
- Tag-based organization
- Chronological journal history
- Full-text search across entries

### 🏠 Dashboard & Highlights
- Personalized dashboard after login
- Daily greeting
- Daily highlights with image uploads
- Overview of tasks and activities

---

## 🧱 System Architecture

Nexus follows a **client–server architecture**:

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Authentication, Firestore, Storage)
- **Database:** Cloud Firestore (NoSQL)
- **Storage:** Firebase Storage for image uploads

The app is designed using a modular architecture with clear separation between UI, business logic, and data services.

---

## 🛠️ Technology Stack

### Frontend
- **Flutter** (3.9.2+)
- **Dart**
- Material Design 3
- SharedPreferences
- Image Picker
- Intl (Date & Time formatting)

### Backend
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Storage**
- **Google Sign-In**

### Tools
- Android Studio / VS Code
- Flutter SDK
- Firebase CLI & FlutterFire CLI
- Git & GitHub

---

## 🗂️ Data Model (Firestore Collections)

- `todo_lists` – stores user-created to-do lists
- `todo_tasks` – stores tasks linked to lists
- `journal_entries` – stores journal content, dates, and tags
- `highlights` – stores daily highlight images and metadata
- `user_profiles` – stores user profile information

---

