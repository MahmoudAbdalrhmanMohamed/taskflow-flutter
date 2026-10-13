# TaskFlow – Flutter Mobile & Tablet Application

> Production-grade cross-platform client for **TaskFlow – Smart Team & Project Management** built with Flutter, Riverpod, GoRouter, and Material 3 design system.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-38B2AC)](https://riverpod.dev/)
[![Material 3](https://img.shields.io/badge/Material_3-Enabled-6750A4)](https://m3.material.io/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 🌟 Application Features

- **Executive Analytics Dashboard**: Real-time project counts, completed tasks counter, overdue task alerts, completion percentage progress bar, upcoming deadlines, and team activity timeline.
- **Interactive Kanban Board**: 3-column drag-and-drop board (`To Do` → `In Progress` → `Done`) with column badges and optimistic status syncing to the backend.
- **Comprehensive Project Management**: Create, edit, and delete projects with custom color accents and icons, tracking task completion progress per project.
- **Complete Task CRUD**: Filter by project, status (`TODO`, `IN_PROGRESS`, `DONE`), priority (`LOW`, `MEDIUM`, `HIGH`), and instant search query.
- **Authentication & Secure Storage**: Stateless JWT authentication stored in encrypted platform storage (`flutter_secure_storage`) with auto-relogin and 401 interceptors.
- **Adaptive Layout**: Responsive interface utilizing `NavigationBar` on phones and `NavigationRail` on tablets/desktops.
- **Light & Dark Theme**: Elegant indigo (`#6366F1`) and violet (`#8B5CF6`) palette adhering to Material 3 tokens.
- **Dynamic Server Switcher**: Seamlessly switch between Localhost (`http://localhost:3000/api`), Android Emulator (`http://10.0.2.2:3000/api`), and Render Cloud API (`https://taskflow-nestjs-api.onrender.com/api`) in the Profile screen with 1 tap.

---

## 🏛️ Clean Architecture Structure

```
lib/
├── main.dart                  # ProviderScope entrypoint
├── core/
│   ├── config/                # Environment configuration and API base URLs
│   ├── constants/             # AppColors, typography, and styling tokens
│   ├── network/               # Centralized Dio ApiClient and error interceptors
│   ├── routing/               # GoRouter with authentication guards and redirects
│   ├── theme/                 # Material 3 Light & Dark ThemeData
│   └── widgets/               # Reusable buttons, text fields, chips, and stat cards
├── features/
│   ├── auth/                  # Login, Register, UserModel, and AuthNotifier
│   ├── dashboard/             # Executive analytics, progress gauges, and timelines
│   ├── projects/              # Project grid, details, form dialogs, and repository
│   ├── tasks/                 # Task list, Kanban drag-and-drop board, and CRUD dialogs
│   └── profile/               # User profile, environment switcher, and theme settings
└── shared/
    └── widgets/               # AppScaffold with responsive NavigationBar/NavigationRail
```

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK 3.24+ (Dart 3.5+)
- Android Studio / Xcode / Chrome for execution

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Static Analysis & Tests
```bash
flutter analyze
flutter test
```

### 4. Launch Application
```bash
# Run on connected mobile device or emulator
flutter run

# Run on Chrome
flutter run -d chrome

# Run with custom API URL
flutter run --dart-define=API_URL=http://localhost:3000/api
```

---

## ⚡ Demo Account

Use the built-in **Quick Demo Autofill** button on the Login screen:
- **Email:** `demo@taskflow.dev`
- **Password:** `DemoPassword123!`
