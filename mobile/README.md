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
