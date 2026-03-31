# Setup & Installation

## Table of contents
1. [Installation](#installation)
2. [iOS configuration](#ios-configuration)
3. [Android configuration](#android-configuration)
4. [Permission handling patterns](#permission-handling-patterns)
5. [Expo projects](#expo-projects)

---

## Installation

```bash
npm install react-native-vision-camera
# or
yarn add react-native-vision-camera
```

Then install iOS pods:

```bash
cd ios && pod install && cd ..
```

### Requirements
- React Native 0.71+
- iOS 12.4+ (Swift 5.2+)
- Android SDK 21+
- For frame processors: `react-native-worklets-core` 1.0.0+

---

## iOS configuration

### Info.plist permissions

Add these to `ios/<YourApp>/Info.plist` inside the top-level `<dict>`:

```xml
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) needs access to your camera</string>

<!-- Only needed if recording video with audio -->
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) needs access to your microphone</string>
```

The string values are what the user sees in the permission dialog — make them descriptive and relevant to your app's use case.

### Podfile

No special Podfile changes are needed for basic usage. If you run into build issues:

```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

---

## Android configuration

### AndroidManifest.xml permissions

Add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.CAMERA" />

<!-- Only needed if recording video with audio -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### Minimum SDK version

Ensure `android/build.gradle` (or `android/app/build.gradle`) has:

```groovy
minSdkVersion 21
```

### Code scanning (MLKit)

If you plan to use the code scanner (QR/barcode), you need to enable the MLKit dependency. In your `android/app/build.gradle`, add:

```groovy
android {
  defaultConfig {
    // ...existing config...
  }
}

// Add VisionCamera config
VisionCamera {
  enableCodeScanner true
}
```

This downloads the MLKit barcode scanning model (~2.2 MB). Without it, code scanning will crash on Android.

---

## Permission handling patterns

VisionCamera provides hooks that handle the full permission lifecycle. Always check permissions before rendering `<Camera>`.

### Basic pattern

```tsx
import { useEffect } from 'react'
import { Linking, Text, TouchableOpacity } from 'react-native'
import { useCameraPermission } from 'react-native-vision-camera'

function CameraPermissionGate({ children }: { children: React.ReactNode }) {
  const { hasPermission, requestPermission } = useCameraPermission()

  useEffect(() => {
    if (!hasPermission) {
      requestPermission()
    }
  }, [hasPermission])

  if (!hasPermission) {
    return (
      <TouchableOpacity onPress={() => Linking.openSettings()}>
        <Text>Camera permission is required. Tap to open Settings.</Text>
      </TouchableOpacity>
    )
  }

  return <>{children}</>
}
```

### With microphone (for video recording)

```tsx
import {
  useCameraPermission,
  useMicrophonePermission,
} from 'react-native-vision-camera'

function usePermissions() {
  const camera = useCameraPermission()
  const mic = useMicrophonePermission()

  const allGranted = camera.hasPermission && mic.hasPermission

  const requestAll = async () => {
    if (!camera.hasPermission) await camera.requestPermission()
    if (!mic.hasPermission) await mic.requestPermission()
  }

  return { allGranted, requestAll }
}
```

### Static permission checks

You can also check permissions imperatively (useful outside components):

```tsx
import { Camera } from 'react-native-vision-camera'

const cameraStatus = Camera.getCameraPermissionStatus()
// Returns: 'granted' | 'not-determined' | 'denied' | 'restricted'

const micStatus = Camera.getMicrophonePermissionStatus()
```

### Handling "denied" state

Once a user denies permission, `requestPermission()` won't show the dialog again on iOS — the OS blocks it. You need to direct them to Settings:

```tsx
import { Linking, Platform } from 'react-native'

function openAppSettings() {
  if (Platform.OS === 'ios') {
    Linking.openURL('app-settings:')
  } else {
    Linking.openSettings()
  }
}
```

---

## Expo projects

For Expo managed workflow, use the config plugin:

```json
// app.json
{
  "expo": {
    "plugins": [
      [
        "react-native-vision-camera",
        {
          "cameraPermissionText": "$(PRODUCT_NAME) needs camera access",
          "enableMicrophonePermission": true,
          "microphonePermissionText": "$(PRODUCT_NAME) needs microphone access",
          "enableCodeScanner": true
        }
      ]
    ]
  }
}
```

Then rebuild with `npx expo prebuild` and `npx expo run:ios` / `npx expo run:android`.
