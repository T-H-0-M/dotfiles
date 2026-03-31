# Photo Capture, Video Recording & Camera Formats

## Table of contents
1. [Camera ref setup](#camera-ref-setup)
2. [Taking photos](#taking-photos)
3. [Taking snapshots](#taking-snapshots)
4. [Recording video](#recording-video)
5. [Camera formats](#camera-formats)
6. [FPS configuration](#fps-configuration)
7. [HDR](#hdr)
8. [Zoom](#zoom)
9. [Torch / flash](#torch--flash)
10. [Focus](#focus)
11. [Orientation](#orientation)

---

## Camera ref setup

Photo and video actions are imperative — you call methods on the Camera ref:

```tsx
import { useRef } from 'react'
import { Camera } from 'react-native-vision-camera'

function CameraScreen() {
  const cameraRef = useRef<Camera>(null)

  return (
    <Camera
      ref={cameraRef}
      device={device}
      isActive={true}
      photo={true}       // Enable photo capture
      video={true}       // Enable video recording
      audio={true}       // Enable audio for video
    />
  )
}
```

You must explicitly enable `photo`, `video`, and/or `audio` props — they're `false` by default. Enabling only what you need is better for performance because VisionCamera configures the native session accordingly.

---

## Taking photos

```tsx
const takePhoto = async () => {
  if (cameraRef.current == null) return

  const photo = await cameraRef.current.takePhoto({
    flash: 'auto',                    // 'auto' | 'on' | 'off'
    qualityPrioritization: 'quality', // 'quality' | 'balanced' | 'speed'
    enableShutterSound: true,
    enableAutoRedEyeReduction: true,
  })

  // photo.path is a file URI (e.g. file:///tmp/photo_123.jpg)
  // photo.width, photo.height — dimensions in pixels
  // photo.orientation — EXIF orientation
  console.log('Photo saved to:', photo.path)
}
```

### Saving to camera roll

VisionCamera writes photos to a temp path. To save permanently, use `@react-native-camera-roll/camera-roll`:

```tsx
import { CameraRoll } from '@react-native-camera-roll/camera-roll'

const photo = await cameraRef.current.takePhoto()
await CameraRoll.saveAsset(`file://${photo.path}`, { type: 'photo' })
```

---

## Taking snapshots

`takeSnapshot()` is much faster than `takePhoto()` (~16ms) because it captures the current preview frame rather than triggering the full camera pipeline. Trade-off: lower quality, no flash, no HDR.

```tsx
const snapshot = await cameraRef.current.takeSnapshot({
  quality: 85, // 0–100, JPEG quality
})

console.log(snapshot.path)
```

Use snapshots for things like thumbnail previews or quick captures where speed matters more than quality.

---

## Recording video

```tsx
const startRecording = () => {
  cameraRef.current?.startRecording({
    flash: 'off',
    onRecordingFinished: (video) => {
      console.log('Video saved to:', video.path)
      console.log('Duration:', video.duration, 'seconds')
    },
    onRecordingError: (error) => {
      console.error('Recording failed:', error)
    },
  })
}

const stopRecording = async () => {
  await cameraRef.current?.stopRecording()
  // This triggers onRecordingFinished
}

const pauseRecording = async () => {
  await cameraRef.current?.pauseRecording()
}

const resumeRecording = async () => {
  await cameraRef.current?.resumeRecording()
}
```

### Video codec and bitrate

In VisionCamera v4, codec and bitrate are set on the `<Camera>` component, not in `startRecording()`:

```tsx
<Camera
  video={true}
  audio={true}
  videoCodec="h265"         // 'h264' | 'h265'
  videoBitRate="normal"     // 'low' | 'normal' | 'high' | number (kbps)
  device={device}
  isActive={true}
/>
```

---

## Camera formats

A "format" defines the camera's capture capabilities — resolution, FPS ranges, HDR support, etc. Each device supports multiple formats.

### Automatic format selection with `useCameraFormat`

```tsx
import { useCameraFormat } from 'react-native-vision-camera'

const format = useCameraFormat(device, {
  videoResolution: { width: 1920, height: 1080 },
  photoResolution: 'max',
  fps: 60,
  videoHdr: true,
})

// Pass to Camera
<Camera format={format} device={device} isActive={true} />
```

`useCameraFormat` finds the closest match to your requirements. If no format matches all criteria, it picks the best compromise.

### Format properties

A `CameraDeviceFormat` object includes:

```tsx
format.videoWidth        // number
format.videoHeight       // number
format.photoWidth        // number
format.photoHeight       // number
format.maxFps            // number
format.minFps            // number
format.supportsVideoHdr  // boolean
format.supportsPhotoHdr  // boolean
format.supportsDepthCapture // boolean
format.pixelFormats      // ('native' | 'yuv' | 'rgb')[]
```

### Manual format selection

If you need precise control, iterate over `device.formats`:

```tsx
const format = device?.formats
  .filter(f => f.videoWidth >= 1920 && f.maxFps >= 60)
  .sort((a, b) => a.videoWidth - b.videoWidth)[0]
```

---

## FPS configuration

```tsx
// Fixed FPS
<Camera fps={30} format={format} />

// Dynamic range (camera adjusts FPS based on lighting)
<Camera fps={60} format={format} />
```

Always ensure your chosen format supports the FPS you set — check `format.maxFps`. Setting an unsupported FPS will throw.

---

## HDR

```tsx
// Photo HDR (computational multi-exposure)
<Camera photoHdr={true} />

// Video HDR (10-bit capture, requires compatible format)
<Camera videoHdr={true} />
```

Check support before enabling:

```tsx
if (format?.supportsVideoHdr) {
  // Safe to enable videoHdr
}
```

Photo HDR and video HDR can conflict on some devices — if you need both, test on real hardware.

---

## Zoom

```tsx
// Static zoom
<Camera zoom={2.0} />

// Pinch-to-zoom gesture (built-in)
<Camera enableZoomGesture={true} />
```

### Animated zoom with Reanimated

```tsx
import Animated, { useSharedValue, useAnimatedProps } from 'react-native-reanimated'

const ReanimatedCamera = Animated.createAnimatedComponent(Camera)

function CameraWithAnimatedZoom() {
  const zoom = useSharedValue(1)
  const animatedProps = useAnimatedProps(() => ({ zoom: zoom.value }))

  return (
    <ReanimatedCamera
      animatedProps={animatedProps}
      device={device}
      isActive={true}
    />
  )
}
```

### Zoom range

```tsx
device.minZoom  // Usually 1.0
device.maxZoom  // Depends on device (e.g. 8.0, 16.0)
device.neutralZoom // The "1x" zoom level (useful for multi-lens devices)
```

---

## Torch / flash

```tsx
// Continuous torch (flashlight)
<Camera torch="on" />  // 'on' | 'off'

// Flash for photo capture only
const photo = await cameraRef.current.takePhoto({
  flash: 'auto', // 'auto' | 'on' | 'off'
})
```

Torch and flash are different: torch stays on continuously, flash fires only during capture. Not all devices support both.

---

## Focus

```tsx
// Tap-to-focus
const handleTap = async (event) => {
  const { x, y } = event.nativeEvent
  await cameraRef.current?.focus({ x, y })
}

// Wrap Camera in a Pressable/TouchableWithoutFeedback
<TouchableWithoutFeedback onPress={handleTap}>
  <Camera ... />
</TouchableWithoutFeedback>
```

The coordinates are in the Camera view's coordinate system (points, not pixels). Check `device.supportsFocus` before calling.

---

## Orientation

```tsx
<Camera
  outputOrientation="device"  // 'device' | 'preview'
/>
```

- `"device"` — Output matches the physical device orientation (photos/videos rotate with the device). This is usually what you want.
- `"preview"` — Output matches whatever the preview shows, regardless of device rotation.
