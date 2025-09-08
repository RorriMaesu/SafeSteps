# SafeSteps Mobile (Expo)

This is a minimal Expo React Native app scaffold per the SafeSteps plan. It includes parent dashboard, fence editor, and child map with TTS demo.

## Requirements
- Windows 11
- Node.js 18 LTS
- Android Studio (SDK + emulator) or a physical Android device with USB debugging enabled

## Setup
1. Install dependencies
```
pnpm i || npm i || yarn
```
2. Start the dev server
```
npx expo start -c
```
3. Run on Android (emulator or device)
```
npx expo run:android
```

If build tools are missing, open Android Studio, install SDK Platform and Build Tools for Android 14 (API 34), then retry.

## Notes
- Location/TTS require allowing permissions when prompted.
- Map uses react-native-maps; you may need Google Play Services on the emulator.

## Android: Google Maps API key

Provide a Google Maps API key so MapView can initialize:

- Enable “Maps SDK for Android” in Google Cloud Console.
- Set the key before building using one of:
	- Environment variable `GOOGLE_MAPS_API_KEY`
	- Or add to `android/keystore.properties`:

```
GOOGLE_MAPS_API_KEY=YOUR_ANDROID_MAPS_KEY
```

Rebuild the app; Gradle injects it into the manifest via `${GOOGLE_MAPS_API_KEY}`.
If you previously ran a native build, clean and rebuild the Android project to pick up the change.

## Firebase setup (google-services.json)

Firebase powers Google Sign-In and notifications.

1) Create/Select Firebase project: https://console.firebase.google.com/
2) Add Android app:
	- Package name: `com.safesteps.app`
	- SHA-1: use the script `../infrastructure/scripts/print-android-signing.ps1` from the repo root to print the Debug SHA-1.
3) Download the generated `google-services.json` and place it at:
	- `mobile/android/app/google-services.json`
	(This file is intentionally gitignored.)
4) Enable Google provider in Firebase Authentication (Sign-in method) and copy the "Web client ID" into repo `.env`:

```
GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID
```

5) Rebuild Android after adding the file/env var.
