# Code Scanning (QR & Barcode)

VisionCamera has a built-in code scanner powered by Apple's AVFoundation (iOS) and Google's MLKit (Android). No extra dependencies needed — just configure and go.

## Table of contents
1. [Basic setup](#basic-setup)
2. [Supported code types](#supported-code-types)
3. [Android-specific setup](#android-specific-setup)
4. [Handling scanned codes](#handling-scanned-codes)
5. [Scan region / area](#scan-region--area)
6. [Performance tips](#performance-tips)
7. [Common patterns](#common-patterns)

---

## Basic setup

```tsx
import { useCodeScanner, Camera, useCameraDevice } from 'react-native-vision-camera'

function ScannerScreen() {
  const device = useCameraDevice('back')

  const codeScanner = useCodeScanner({
    codeTypes: ['qr', 'ean-13'],
    onCodeScanned: (codes) => {
      for (const code of codes) {
        console.log(`Scanned: ${code.value} (type: ${code.type})`)
      }
    },
  })

  return (
    <Camera
      device={device}
      isActive={true}
      codeScanner={codeScanner}
      style={{ flex: 1 }}
    />
  )
}
```

The `codeScanner` prop and the `useCodeScanner` hook work together — the hook creates a memoized configuration object that the Camera uses to set up its scanning pipeline.

---

## Supported code types

Pass these strings in the `codeTypes` array:

| Code type | String value |
|---|---|
| QR Code | `'qr'` |
| EAN-13 | `'ean-13'` |
| EAN-8 | `'ean-8'` |
| UPC-E | `'upc-e'` |
| Code 128 | `'code-128'` |
| Code 39 | `'code-39'` |
| Code 93 | `'code-93'` |
| Codabar | `'codabar'` |
| ITF | `'itf'` |
| Aztec | `'aztec'` |
| Data Matrix | `'data-matrix'` |
| PDF 417 | `'pdf-417'` |

Specify only the types you care about — fewer types = faster scanning because the scanner doesn't have to check for all formats in each frame.

---

## Android-specific setup

On Android, the code scanner uses Google MLKit, which requires an explicit opt-in because it bundles a model (~2.2 MB).

### React Native CLI projects

In `android/app/build.gradle`:

```groovy
VisionCamera {
  enableCodeScanner true
}
```

### Expo projects

In `app.json`:

```json
{
  "expo": {
    "plugins": [
      [
        "react-native-vision-camera",
        {
          "enableCodeScanner": true
        }
      ]
    ]
  }
}
```

Without this, the app will crash on Android when you try to use the code scanner.

---

## Handling scanned codes

The `onCodeScanned` callback receives an array of `Code` objects:

```tsx
interface Code {
  type: string       // e.g. 'qr', 'ean-13'
  value: string      // The decoded content
  frame?: {          // Bounding box in the preview (optional)
    x: number
    y: number
    width: number
    height: number
  }
  corners?: Point[]  // Corner points of the code (optional)
}
```

### Debouncing scans

The scanner fires continuously — the same code will trigger `onCodeScanned` many times per second. Use a ref or state to debounce:

```tsx
import { useCallback, useRef } from 'react'

function ScannerScreen() {
  const lastScannedRef = useRef<string | null>(null)

  const codeScanner = useCodeScanner({
    codeTypes: ['qr'],
    onCodeScanned: useCallback((codes) => {
      const value = codes[0]?.value
      if (value && value !== lastScannedRef.current) {
        lastScannedRef.current = value
        handleScannedCode(value)
      }
    }, []),
  })

  // ...
}
```

### "Scan once" pattern

If you only need one scan (e.g. a QR login flow), deactivate the camera after the first result:

```tsx
const [scanned, setScanned] = useState(false)

const codeScanner = useCodeScanner({
  codeTypes: ['qr'],
  onCodeScanned: (codes) => {
    if (!scanned && codes.length > 0) {
      setScanned(true)
      processCode(codes[0].value)
    }
  },
})

return <Camera isActive={!scanned} codeScanner={codeScanner} ... />
```

---

## Scan region / area

You can restrict the scanning area to a specific region of the camera frame using `regionOfInterest`:

```tsx
const codeScanner = useCodeScanner({
  codeTypes: ['qr'],
  regionOfInterest: {
    x: 0.25,      // Normalized coordinates (0–1)
    y: 0.25,
    width: 0.5,
    height: 0.5,
  },
  onCodeScanned: (codes) => { ... },
})
```

This is useful for "scan the code inside the box" UIs — it makes scanning faster and prevents accidental reads of codes outside the target area.

---

## Performance tips

1. **Minimize code types.** Only include the types you actually need. Scanning for all types simultaneously is slower.
2. **Use `regionOfInterest`** when you have a scanning viewfinder UI — it reduces the search area.
3. **Memoize the scanner config.** `useCodeScanner` handles this, but if you build the config manually, wrap it in `useMemo`.
4. **Consider resolution.** A lower-resolution format scans faster (less data per frame). For scanning-only apps, you don't need 4K.

---

## Common patterns

### QR code scanner with overlay

```tsx
import { useState, useCallback } from 'react'
import { View, StyleSheet, Text } from 'react-native'
import {
  Camera,
  useCameraDevice,
  useCameraPermission,
  useCodeScanner,
} from 'react-native-vision-camera'

export function QRScannerScreen() {
  const { hasPermission } = useCameraPermission()
  const device = useCameraDevice('back')
  const [lastCode, setLastCode] = useState<string | null>(null)

  const codeScanner = useCodeScanner({
    codeTypes: ['qr'],
    onCodeScanned: useCallback((codes) => {
      if (codes[0]?.value) {
        setLastCode(codes[0].value)
      }
    }, []),
  })

  if (!hasPermission || !device) return null

  return (
    <View style={StyleSheet.absoluteFill}>
      <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={true}
        codeScanner={codeScanner}
      />

      {/* Scanning viewfinder overlay */}
      <View style={styles.overlay}>
        <View style={styles.scanBox} />
      </View>

      {lastCode && (
        <View style={styles.result}>
          <Text>Scanned: {lastCode}</Text>
        </View>
      )}
    </View>
  )
}

const styles = StyleSheet.create({
  overlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'center',
    alignItems: 'center',
  },
  scanBox: {
    width: 250,
    height: 250,
    borderWidth: 2,
    borderColor: 'white',
    borderRadius: 12,
  },
  result: {
    position: 'absolute',
    bottom: 80,
    alignSelf: 'center',
    backgroundColor: 'white',
    padding: 16,
    borderRadius: 8,
  },
})
```

### Multi-format product scanner

```tsx
const codeScanner = useCodeScanner({
  codeTypes: ['ean-13', 'ean-8', 'upc-e', 'code-128'],
  onCodeScanned: (codes) => {
    const barcode = codes[0]
    if (barcode) {
      lookupProduct(barcode.value, barcode.type)
    }
  },
})
```
