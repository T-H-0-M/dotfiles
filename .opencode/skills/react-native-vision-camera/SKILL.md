---
name: react-native-vision-camera
description: >
  Use this skill whenever a user is working with react-native-vision-camera (VisionCamera) in a React Native project.
  This includes: setting up VisionCamera for the first time, capturing photos or recording videos, scanning QR codes
  or barcodes, building frame processor plugins, configuring camera formats (resolution, FPS, HDR), handling camera
  permissions, or troubleshooting camera-related issues on iOS or Android. Trigger whenever the user mentions
  "vision camera", "VisionCamera", "react-native-vision-camera", camera capture in React Native, frame processors,
  QR/barcode scanning with a camera, or any React Native camera integration work — even if they just say
  "add a camera to my app" or "scan a barcode". If the user is building anything camera-related in React Native,
  this skill almost certainly applies.
---

# react-native-vision-camera

A comprehensive guide for building camera features in React Native using [VisionCamera](https://github.com/mrousavy/react-native-vision-camera) (v4.x). This skill covers installation, photo/video capture, QR/barcode scanning, frame processors, and platform-specific configuration for iOS and Android.

## When to read reference files

This skill is organized with detailed reference docs in `references/`. Read the relevant one(s) based on the user's task:

| User's task | Read this file |
|---|---|
| Installing VisionCamera, adding permissions, first-time setup | `references/setup.md` |
| Taking photos, recording video, configuring formats/FPS/HDR/zoom | `references/capture-and-formats.md` |
| Scanning QR codes, barcodes, or any code type | `references/code-scanning.md` |
| Writing frame processors, building native plugins, real-time analysis | `references/frame-processors.md` |
| Camera errors, black screens, build failures, performance issues | `references/troubleshooting.md` |

If the task spans multiple areas (e.g. "set up the camera and add barcode scanning"), read all the relevant files. When in doubt, start with `setup.md` — most tasks assume a working installation.

## Quick-start pattern

For users who just want to get a camera on screen fast, here's the minimal working example. The reference files expand on every piece of this.

```tsx
import { useEffect } from 'react'
import { StyleSheet, View, Text } from 'react-native'
import {
  Camera,
  useCameraDevice,
  useCameraPermission,
} from 'react-native-vision-camera'

export default function CameraScreen() {
  const { hasPermission, requestPermission } = useCameraPermission()
  const device = useCameraDevice('back')

  useEffect(() => {
    if (!hasPermission) requestPermission()
  }, [hasPermission])

  if (!hasPermission) return <Text>Camera permission required</Text>
  if (!device) return <Text>No camera device found</Text>

  return (
    <View style={StyleSheet.absoluteFill}>
      <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={true}
      />
    </View>
  )
}
```

## Core hooks and components at a glance

These are the building blocks — see the reference files for detailed usage and options.

- **`<Camera>`** — The camera view component. Requires `device` and `isActive` props at minimum.
- **`useCameraDevice(position)`** — Returns a `CameraDevice` for `'back'`, `'front'`, or `'external'`. Returns `null` if unavailable.
- **`useCameraDevices()`** — Returns all available camera devices (useful for device pickers).
- **`useCameraPermission()`** — Returns `{ hasPermission, requestPermission }` for camera access.
- **`useMicrophonePermission()`** — Same pattern for microphone (needed for video with audio).
- **`useCameraFormat(device, requirements)`** — Finds the best format matching your resolution/FPS/HDR needs.
- **`useCodeScanner({ codeTypes, onCodeScanned })`** — Configures QR/barcode scanning.
- **`useFrameProcessor(callback, deps)`** — Runs a worklet function on every camera frame for real-time analysis.

## Key principles

1. **Always gate on permissions.** Never render `<Camera>` before `hasPermission` is true — it will throw.
2. **Always gate on device.** `useCameraDevice()` can return `null` (e.g. on simulators). Handle this gracefully.
3. **Use `isActive` to manage the camera lifecycle.** Set it to `false` when navigating away or when the app backgrounds. A common pattern: `isActive={isFocused && appState === 'active'}` using `@react-navigation/native`'s `useIsFocused()` and React Native's `AppState`.
4. **Memoize everything.** Frame processors, code scanners, and callbacks should be memoized to avoid rebuilding the camera session on every render.
5. **Use refs for imperative actions.** Photo capture (`takePhoto`) and video recording (`startRecording` / `stopRecording`) are called on the Camera ref, not via props.

## Platform notes

- **iOS**: Requires `NSCameraUsageDescription` (and `NSMicrophoneUsageDescription` for video with audio) in `Info.plist`. Minimum iOS 12.4.
- **Android**: Requires `CAMERA` permission (and `RECORD_AUDIO` for video) in `AndroidManifest.xml`. Minimum SDK 21. Code scanning requires enabling MLKit in your build config.

See `references/setup.md` for full platform configuration steps.
