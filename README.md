# QRious

A modern, feature-rich QR code scanner and generator with built-in security features.

![App Banner](assets/screenshots/banner.png)

## ✨ Features

- **Scan QR codes** with your camera
- **Generate QR codes** for URLs, text, phone numbers, and Wi-Fi
- **Security checks** for potentially harmful URLs
- **Save & organize** your scan history
- **Customize** QR code appearance
- **Dark mode** support

## 📱 Screenshots

### Light Mode
<p align="center">
  <img src="assets/screenshots/lm_scan.png" width="24%" />
  <img src="assets/screenshots/lm_creator.png" width="24%" />
  <img src="assets/screenshots/lm_history_lists.png" width="24%" />
  <img src="assets/screenshots/lm_history_favorites.png" width="24%" />
</p>

### Dark Mode
<p align="center">
  <img src="assets/screenshots/dm_scan.png" width="24%" />
  <img src="assets/screenshots/dm_creator.png" width="24%" />
  <img src="assets/screenshots/dm_history_lists.png" width="24%" />
  <img src="assets/screenshots/dm_history_favorites.png" width="24%" />
</p>

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (^3.7.2)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator / Physical Device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/QRious.git
   cd QRious
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🔒 Privacy & Security

- All processing is done **locally** on your device
- **No data is sent** to any external servers
- Built-in security checks warn about potentially unsafe URLs
- Camera access only when actively scanning

## 🔧 Troubleshooting

### iOS Build Issues

If you encounter pod install issues, try:
```bash
flutter clean
cd ios && pod install && cd ..
```

### Android Permissions

If camera doesn't work, check that you've granted camera permission in your device settings.

## 💡 Contributing

Contributions are welcome! For more details about the app's architecture and implementation, check [appcore.md](appcore.md).

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📩 Contact

Project Link: [https://github.com/NaimiNafis/QRious](https://github.com/NaimiNafis/QRious)