# Panduan Persiapan Upload Google Play Store

## 1. Cek Project
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## 2. Build APK untuk Testing
```bash
flutter build apk --release
```

## 3. Build AAB untuk Upload Play Store
```bash
flutter build appbundle --release
```

## 4. File yang Diunggah
Gunakan file berikut untuk Play Store:
```text
build/app/outputs/bundle/release/app-release.aab
```

## 5. Yang Masih Harus Disiapkan Manual
- Akun Google Play Console
- App icon final
- Screenshot aplikasi
- Deskripsi aplikasi
- Privacy Policy
- Signing key dan package name final
