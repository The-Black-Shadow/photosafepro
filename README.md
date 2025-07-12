# PhotoSafe-Pro

A secure, on-device photo vault application built with Flutter that provides military-grade encryption for your private photos.

## 🔐 Project Overview

PhotoSafe-Pro is a secure, on-device photo vault application built with Flutter. It allows users to import photos from their device's public gallery into a private, encrypted storage area within the app. Access to the vault is protected by a mandatory PIN and optional biometric (fingerprint) authentication.

This project focuses on robust security, a clean user experience, and modern Android compatibility.

**Current Status:** The core functionality of the application is complete and stable. Users can securely import, view, and manage photos within the vault.

## ✨ Core Features Implemented

### 🔑 Secure PIN Authentication

- Users must set a 4-digit PIN on their first use
- The PIN is never stored directly - it is salted and hashed using SHA-256
- Only the hash is saved to the device's hardware-backed Keystore/Keychain via `flutter_secure_storage`

### 👆 Biometric Unlock

- Seamlessly integrated fingerprint unlock for quick and secure access on supported devices
- The app automatically prompts for biometric authentication upon launch if available

### 📱 Robust Permission Handling

- Utilizes the `permission_handler` package to correctly request media permissions
- Supports `READ_MEDIA_IMAGES` (Android 13+) or `READ_EXTERNAL_STORAGE` (older versions) depending on the Android SDK version
- The permission dialog is only shown when necessary and does not re-prompt the user if permission has already been granted

### 🔒 AES-256 Encryption

- All imported photos and their thumbnails are encrypted using the industry-standard AES-256 algorithm
- A unique Initialization Vector (IV) is generated for each file
- Encrypted data is stored in format: `iv_base64:data_base64`, ensuring each encryption is unique and secure

### ⚡ Optimized Vault Gallery

- When a photo is imported, a small 200x200 pixel thumbnail is generated and separately encrypted
- The main gallery grid loads only these lightweight thumbnails, ensuring fast, smooth, and memory-efficient performance
- `ValueKey` is used for each thumbnail widget to prevent UI glitches during deletion

### 🗑️ Automatic & Silent Deletion of Originals

- Complies with modern Android Scoped Storage policies (API 29+)
- Uses the recommended `deleteWithIds` method from `photo_manager`
- After a photo is successfully secured in the vault, the original file is automatically removed from the gallery
- Provides a seamless user experience while remaining compliant with Google Play policies

## 🛠️ Technology Stack

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** flutter_bloc
- **Database:** sqflite for local metadata storage
- **Security & Encryption:** flutter_secure_storage, encrypt, crypto
- **Media & Permissions:** permission_handler, photo_manager, wechat_assets_picker
- **Authentication:** local_auth

## 🏗️ Architectural Decisions & Challenges Solved

This project successfully navigated several common but complex challenges in modern mobile development:

### The Android Permission Maze

**Challenge:** Initial implementation suffered from repeated permission dialogs and incorrect status checks.

**Solution:** Migrated to `permission_handler` and implemented robust logic flow: Check Status → Request if Denied → Proceed.

### The Encryption IV Bug

**Challenge:** Critical bug where photos would not decrypt was traced back to the Initialization Vector (IV) not being saved.

**Solution:** Redesigned architecture to store the IV and encrypted data together as a single string, solving decryption failures.

### Scoped Storage & Silent Deletion

**Challenge:** Goal of silent, permanent delete without violating Google Play policies.

**Solution:** Pivoted to the modern `deleteWithIds` API, achieving desired user experience (silent removal from gallery) in a compliant and safe manner.

### Gallery Performance

**Challenge:** Initial approach of decrypting full-resolution images for grid view was inefficient.

**Solution:** Implementation of encrypted thumbnails drastically improved performance and reduced memory usage.

## 🚀 How to Run This Project

### Prerequisites

- Flutter SDK (3.8.0 or higher)
- Android Studio or VS Code
- Android device/emulator (API 21+)

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/The-Black-Shadow/photosafepro.git
   cd photosafepro
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── blocs/          # BLoC state management
├── models/         # Data models
├── repositories/   # Data layer
├── screens/        # UI screens
├── utils/          # Utility functions
├── widgets/        # Reusable widgets
└── main.dart       # App entry point
```

## 🔐 Security Features

- **AES-256 Encryption:** Industry-standard encryption for all stored photos
- **Hardware-backed Storage:** PIN hashes stored in secure hardware keystore
- **Biometric Authentication:** Fingerprint unlock support
- **No Cloud Dependencies:** All data stays on device
- **Secure Deletion:** Original photos automatically removed from gallery

## 📋 Requirements

- **Minimum Android Version:** API 21 (Android 5.0)
- **Target Android Version:** API 34 (Android 14)
- **Permissions Required:**
  - `READ_MEDIA_IMAGES` (Android 13+)
  - `READ_EXTERNAL_STORAGE` (Android 12 and below)
  - `MANAGE_EXTERNAL_STORAGE` (for deletion)
  - `USE_BIOMETRIC` / `USE_FINGERPRINT`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact

For any questions or support, please contact [The-Black-Shadow](https://github.com/The-Black-Shadow).

---

**⚠️ Security Notice:** This app stores all data locally on your device. Make sure to backup your PIN and ensure you don't lose access to your device, as there is no way to recover encrypted photos without the PIN.
