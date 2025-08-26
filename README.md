# Panther Kiosk – UI Only (v2)

This is a **UI-only** Flutter project for quick demos:
- Check-In → Payment Method → Cash/Card → e‑Signature → Confirmation (+ Admin stub)
- Camera photo capture (not persisted)
- Signature pad (not persisted)
- No local DB, no backend → just UI + navigation

## Run

```bash
flutter pub get
flutter create .      # generates android/ios folders if missing
flutter run
```

## Android permissions
Add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
```
