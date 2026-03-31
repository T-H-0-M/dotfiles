# Troubleshooting

Common issues, their causes, and how to fix them.

## Table of contents
1. [Build errors](#build-errors)
2. [Runtime errors](#runtime-errors)
3. [Camera behavior issues](#camera-behavior-issues)
4. [Performance issues](#performance-issues)
5. [Platform-specific quirks](#platform-specific-quirks)

---

## Build errors

### iOS: "Module 'VisionCamera' not found"

**Cause:** Pods out of sync.

```bash
cd ios
rm -rf Pods Podfile.lock build
pod install --repo-update
cd ..
npx react-native run-ios
```

### iOS: Swift version errors

**Cause:** VisionCamera requires Swift 5.2+. If your project has an older Swift version configured:

Check `ios/<YourApp>.xcodeproj/project.pbxproj` and ensure `SWIFT_VERSION = 5.0` or higher. Or set it in Xcode under Build Settings → Swift Language Version.

### Android: "VisionCamera: Frame Processor Plugin not found"

**Cause:** Plugin not registered, or autolinking failed.

```bash
cd android && ./gradlew clean && cd ..
npx react-native run-android
```

If it persists, check the plugin's docs for manual linking instructions.

### Android: MLKit / Code Scanner crash

**Cause:** Code scanner feature not enabled in build config. Add to `android/app/build.gradle`:

```groovy
VisionCamera {
  enableCodeScanner true
}
```

Then rebuild.

---

## Runtime errors

### "Camera session failed to configure"

**Cause:** Incompatible format/FPS/feature combination. For example, requesting 240fps with HDR on a device that doesn't support that combination.

**Fix:** Use `useCameraFormat` to let VisionCamera find a compatible format automatically, rather than setting format properties manually. Check `format.maxFps`, `format.supportsVideoHdr`, etc. before enabling features.

### "Camera permission denied" even after granting

**Cause:** On iOS, missing `NSCameraUsageDescription` in Info.plist causes the OS to silently deny access. On Android, the permission might be in the manifest but the runtime request wasn't made.

**Fix:**
- iOS: Ensure `NSCameraUsageDescription` is in Info.plist (not just as a comment or in the wrong `<dict>`).
- Android: Ensure the `useCameraPermission()` hook is calling `requestPermission()`.

### "Frame Processor threw an error" / worklet crash

**Cause:** Usually one of:
- Missing `'worklet'` directive at the top of the frame processor function
- Calling a non-worklet function from within the worklet
- Accessing React state directly (instead of using `runOnJS`)

**Fix:** Ensure the function has `'worklet'` as its first statement, and use `Worklets.createRunOnJS()` for any communication back to React.

### `useCameraDevice` returns `null`

**Cause:** Normal on simulators (no camera hardware). On real devices, it can mean the device is in use by another app or the position string is wrong.

**Fix:** Always handle the `null` case with a fallback UI. On real devices, try `'back'` instead of `'front'` to test. Use `useCameraDevices()` to see what's actually available.

---

## Camera behavior issues

### Black screen

**Possible causes:**

1. **`isActive` is `false`.** This is the most common cause. Make sure `isActive` is `true` when the screen is focused and the app is active.
   ```tsx
   const isFocused = useIsFocused() // from @react-navigation
   const appState = useAppState()   // or AppState.currentState
   <Camera isActive={isFocused && appState === 'active'} />
   ```

2. **Camera device is `null`.** Render a loading state until `useCameraDevice` returns a device.

3. **Style issue.** The Camera component has zero size. Ensure it has `StyleSheet.absoluteFill` or explicit dimensions.

4. **Hot reload corruption.** Metro's hot reload can sometimes corrupt the camera session. Fully reload the app (shake → "Reload" or `R` in terminal).

### Camera freezes when navigating between screens

**Cause:** The camera session stays active in the background. Without `isActive` management, it can conflict when coming back.

**Fix:** Tie `isActive` to screen focus:

```tsx
import { useIsFocused } from '@react-navigation/native'

function CameraScreen() {
  const isFocused = useIsFocused()
  return <Camera isActive={isFocused} ... />
}
```

### Camera flickers or reinitializes constantly

**Cause:** Props changing every render, causing the camera session to rebuild. The most common culprit is an un-memoized `codeScanner` or `frameProcessor`.

**Fix:** Use the hooks (`useCodeScanner`, `useFrameProcessor`) — they handle memoization. If building config objects manually, wrap them in `useMemo`.

### Photo/video output is rotated

**Cause:** `outputOrientation` not set, or set to `'preview'` when the device is rotated.

**Fix:** Use `outputOrientation="device"` to have output match the physical device orientation:

```tsx
<Camera outputOrientation="device" />
```

---

## Performance issues

### Frame processor drops frames

**Symptoms:** Choppy preview, frame processor logs show irregular timing, videos stutter.

**Fixes:**
1. Reduce processing — use `runAsync` for heavy work
2. Switch to `pixelFormat="yuv"` (avoids RGB conversion cost)
3. Lower the camera resolution/FPS
4. Use `vision-camera-resize-plugin` to downscale before processing
5. Move processing to a native plugin

### High memory usage

**Cause:** Holding references to frames outside the processor callback, or large buffers from `toArrayBuffer()`.

**Fix:** Never store frames. Process them and discard. If you need to keep results, extract just the data you need (e.g. coordinates, not the full pixel buffer).

### Slow photo capture

**Fix:** Use `qualityPrioritization: 'speed'` or `'balanced'` instead of `'quality'`. Or use `takeSnapshot()` for near-instant captures at lower quality.

---

## Platform-specific quirks

### iOS: Camera pauses when opening Control Center

**Explanation:** iOS deactivates the camera session when certain system overlays appear. This is OS-level behavior — `isActive` will re-activate when the overlay dismisses.

### iOS: No audio in video on simulator

**Explanation:** The iOS simulator doesn't have a real microphone. Audio recording only works on physical devices.

### Android: Camera preview stretched or cropped

**Cause:** Aspect ratio mismatch between the Camera view and the selected format.

**Fix:** Use `resizeMode` prop:

```tsx
<Camera
  resizeMode="cover"  // 'cover' | 'contain'
  ...
/>
```

Or select a format whose aspect ratio matches your view's dimensions.

### Android: First launch is slow

**Explanation:** MLKit downloads and initializes models on first use. Subsequent launches are faster. For code scanning, the model is ~2.2 MB and may need a network connection on first use (though it's usually bundled).

### React Native 0.78+ compatibility

Some versions of VisionCamera (particularly v4.7.1 and earlier) have known issues with React Native 0.78+ related to event handling. If you experience crashes or freezes during navigation:

**Fix:** Update to the latest VisionCamera version. Check the [GitHub releases](https://github.com/mrousavy/react-native-vision-camera/releases) for patch notes.
