# TaskFlow Testing Guide

Welcome to the TaskFlow multi-platform testing package. Both the Android APK and Windows desktop application connect to the live cloud backend ([taskflow-nestjs-api.vercel.app](https://taskflow-nestjs-api.vercel.app/api)) backed by a serverless Neon PostgreSQL database.

---

## 📦 Distribution Files

| Platform | File | Size | Description |
| :--- | :--- | :--- | :--- |
| **Android** | `TaskFlow-v1.0.0.apk` | ~53 MB | Standalone Release APK for Android 5.0+ devices & emulators |
| **Windows** | `TaskFlow-Windows-v1.0.0.zip` | ~12 MB | Complete self-contained desktop bundle with `TaskFlow.exe` |

---

## 🔑 Login Credentials

You can use the pre-configured demo account or register a fresh account:

- **Email:** `demo@taskflow.dev`
- **Password:** `DemoPassword123!`
- **One-Click Autofill:** You can also click the **"Quick Demo Autofill"** button on the login screen.
- **New Account Registration:** Click **"Create an account"** to sign up with your own email and password.

---

## 📱 Android Installation Instructions

1. Transfer `TaskFlow-v1.0.0.apk` to your Android device (via USB, Google Drive, Telegram, WhatsApp, or browser download).
2. Tap the APK file to install.
3. **Security Note:** Since this is a direct release build not yet published on Google Play:
   - If prompted **"Install unknown apps"**, toggle **"Allow from this source"**.
   - If prompted **"Google Play Protect: Unrecognized app"**, tap **"More details"** $\rightarrow$ **"Install anyway"**.
4. Launch TaskFlow and sign in!

---

## 💻 Windows Desktop Instructions

> ⚠️ **Important:** Do NOT extract or send `TaskFlow.exe` alone! Flutter desktop apps require the companion files (`flutter_windows.dll` and `data/` folder) included in the `.zip`.

1. Send or download `TaskFlow-Windows-v1.0.0.zip`.
2. Right-click the `.zip` file $\rightarrow$ **"Extract All..."**.
3. Open the extracted folder and double-click **`TaskFlow.exe`** (or `new_app.exe`).
4. **SmartScreen Note:** If Windows Defender SmartScreen shows a blue banner *"Windows protected your PC"*, click **"More info"** $\rightarrow$ **"Run anyway"**.
5. The application will launch full-screen with the TaskFlow branding.

---

## 🧪 Core Features to Test

1. **Branded Launch & Splash Screen:** Notice the radiant gradient logo and startup loader (`"Loading workspace..."`).
2. **Smooth Authentication Guard:** Unauthenticated users land directly on `/login` without any flashing or layout jumps.
3. **Workspace Projects:** Go to the Projects tab and click **`+`** to create a custom project with customized color and icon.
4. **Task Management:** Create tasks assigned to projects with priority badges (`HIGH`, `MEDIUM`, `LOW`) and deadlines.
5. **Interactive Kanban Board:** Switch to Kanban view to drag/move tasks across `TODO`, `IN PROGRESS`, and `DONE` columns.
6. **Live Dashboard Metrics:** Verify that sprint completion rates, overdue counts, and priority charts update in real-time.
7. **Theme Toggle:** Visit the Profile tab to test seamless switching between Dark Mode and Light Mode.
