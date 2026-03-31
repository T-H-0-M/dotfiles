# Frame Processors

Frame processors let you run JavaScript (or native) code on every camera frame in real time. They're the foundation for features like object detection, face tracking, text recognition, color analysis, and anything that needs to analyze or transform live camera data.

## Table of contents
1. [How they work](#how-they-work)
2. [Basic usage](#basic-usage)
3. [The worklet directive](#the-worklet-directive)
4. [Accessing frame data](#accessing-frame-data)
5. [Running async work](#running-async-work)
6. [Communicating with React](#communicating-with-react)
7. [Using frame processor plugins](#using-frame-processor-plugins)
8. [Building a native plugin](#building-a-native-plugin)
9. [Performance guide](#performance-guide)
10. [Community plugins](#community-plugins)

---

## How they work

Frame processors run on a separate thread using React Native Worklets. When you pass a `frameProcessor` to `<Camera>`, VisionCamera calls your function with each frame as it arrives from the camera hardware. The function runs synchronously on the camera thread — so it must be fast, or you drop frames.

The key constraint: frame processor functions run in a "worklet" context, not the normal JS thread. This means you can't access regular React state or call arbitrary JS functions directly. You use `runOnJS()` to communicate back.

### Dependencies

Frame processors require `react-native-worklets-core`:

```bash
npm install react-native-worklets-core
```

Add the babel plugin to `babel.config.js`:

```js
module.exports = {
  plugins: [
    ['react-native-worklets-core/plugin'],
    // ... other plugins
  ],
}
```

---

## Basic usage

```tsx
import { useFrameProcessor, Camera } from 'react-native-vision-camera'

function CameraWithProcessing() {
  const frameProcessor = useFrameProcessor((frame) => {
    'worklet'
    console.log(`Frame: ${frame.width}x${frame.height} (${frame.pixelFormat})`)
  }, [])

  return (
    <Camera
      frameProcessor={frameProcessor}
      device={device}
      isActive={true}
      pixelFormat="yuv" // or 'rgb' — see Performance section
    />
  )
}
```

---

## The worklet directive

Every frame processor function **must** start with the `'worklet'` string directive:

```tsx
const frameProcessor = useFrameProcessor((frame) => {
  'worklet'  // ← Required. Without this, the function runs on the wrong thread.
  // ... your processing code
}, [])
```

This tells the babel plugin to compile the function for the worklet runtime. If you forget it, you'll get a runtime error about the function not being a worklet.

---

## Accessing frame data

The `frame` parameter gives you access to the raw camera data:

```tsx
const frameProcessor = useFrameProcessor((frame) => {
  'worklet'

  frame.width          // number — pixel width
  frame.height         // number — pixel height
  frame.bytesPerRow    // number
  frame.pixelFormat    // 'yuv' | 'rgb' | 'native'
  frame.orientation    // 'portrait' | 'landscape-left' | etc.
  frame.isMirrored     // boolean (true for front camera)
  frame.timestamp      // number (nanoseconds)
}, [])
```

### Reading pixel data

```tsx
const frameProcessor = useFrameProcessor((frame) => {
  'worklet'

  const buffer = frame.toArrayBuffer()
  const data = new Uint8Array(buffer)

  // For RGB format: every 3 bytes = one pixel (R, G, B)
  const r = data[0]
  const g = data[1]
  const b = data[2]
}, [])
```

Reading raw pixels is expensive — prefer using native plugins for heavy image processing.

---

## Running async work

If your processing takes too long for the synchronous frame callback, use `runAsync` to offload it:

```tsx
import { useFrameProcessor } from 'react-native-vision-camera'
import { runAsync } from 'react-native-worklets-core'

const frameProcessor = useFrameProcessor((frame) => {
  'worklet'

  runAsync(frame, () => {
    'worklet'
    // This runs on a separate thread
    // The frame is kept alive until this completes
    const result = someExpensiveOperation(frame)
  })
}, [])
```

`runAsync` lets the camera pipeline continue delivering frames while your heavy processing happens in the background. The frame passed to the async callback is "held" — it won't be recycled until the callback finishes.

---

## Communicating with React

Use `runOnJS` from worklets-core to call back into the React JS thread:

```tsx
import { useFrameProcessor } from 'react-native-vision-camera'
import { Worklets } from 'react-native-worklets-core'

function CameraWithDetection() {
  const [detected, setDetected] = useState(false)

  const handleDetection = Worklets.createRunOnJS((value: boolean) => {
    setDetected(value)
  })

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet'

    const hasObject = detectSomething(frame)
    handleDetection(hasObject)
  }, [handleDetection])

  return <Camera frameProcessor={frameProcessor} ... />
}
```

The `Worklets.createRunOnJS()` wrapper is needed because you can't call `setDetected` directly from a worklet — it runs on a different thread.

---

## Using frame processor plugins

Plugins are native functions (written in Swift/Kotlin/C++) that you can call from within frame processors. They do the heavy lifting (ML inference, image processing) at native speed.

```tsx
// Example: using a TFLite plugin
import { useTensorflowModel } from 'react-native-fast-tflite'

function CameraWithML() {
  const model = useTensorflowModel(require('./model.tflite'))

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet'

    if (model.state === 'loaded') {
      const result = model.model.runForMultipleInputsOutputs(frame)
      // process result...
    }
  }, [model])

  return <Camera frameProcessor={frameProcessor} ... />
}
```

### Installing plugins

Most plugins are regular npm packages:

```bash
npm install react-native-fast-tflite
npm install vision-camera-resize-plugin
```

They register themselves via VisionCamera's plugin system — after installation, their functions are available inside frame processors.

---

## Building a native plugin

If you need custom native processing (e.g. wrapping a proprietary SDK), you can write your own frame processor plugin.

### iOS (Swift)

```swift
import VisionCamera

@objc(MyFrameProcessorPlugin)
public class MyFrameProcessorPlugin: FrameProcessorPlugin {
  public override init(proxy: VisionCameraProxyHolder, options: [AnyHashable: Any]! = [:]) {
    super.init(proxy: proxy, options: options)
  }

  public override func callback(_ frame: Frame, withArguments arguments: [AnyHashable: Any]?) -> Any? {
    let buffer = frame.buffer
    let width = CVPixelBufferGetWidth(buffer)
    let height = CVPixelBufferGetHeight(buffer)

    // Your processing logic here...

    return [
      "width": width,
      "height": height,
      "result": "processed"
    ]
  }
}
```

Register it in an Objective-C file:

```objc
// MyFrameProcessorPlugin.m
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>

@interface VISION_EXPORT_SWIFT_FRAME_PROCESSOR(MyFrameProcessorPlugin, myPlugin)
@end
```

### Android (Kotlin)

```kotlin
import com.mrousavy.camera.frameprocessors.Frame
import com.mrousavy.camera.frameprocessors.FrameProcessorPlugin
import com.mrousavy.camera.frameprocessors.VisionCameraProxy

class MyFrameProcessorPlugin(proxy: VisionCameraProxy, options: Map<String, Any>?) :
  FrameProcessorPlugin() {

  override fun callback(frame: Frame, arguments: Map<String, Any>?): Any? {
    val image = frame.image
    val width = image.width
    val height = image.height

    // Your processing logic here...

    return mapOf(
      "width" to width,
      "height" to height,
      "result" to "processed"
    )
  }
}
```

Register it in your package:

```kotlin
// MyFrameProcessorPluginPackage.kt
import com.mrousavy.camera.frameprocessors.FrameProcessorPluginRegistry

class MyFrameProcessorPluginPackage : ReactPackage {
  companion object {
    init {
      FrameProcessorPluginRegistry.add(MyFrameProcessorPlugin::class.java)
    }
  }
  // ... standard ReactPackage methods
}
```

### Using your plugin in JS

```tsx
import { VisionCameraProxy } from 'react-native-vision-camera'

const plugin = VisionCameraProxy.initFrameProcessorPlugin('myPlugin', {})

const frameProcessor = useFrameProcessor((frame) => {
  'worklet'
  const result = plugin?.call(frame)
  console.log(result) // { width: 1920, height: 1080, result: 'processed' }
}, [plugin])
```

---

## Performance guide

Frame processors run on the camera pipeline — every millisecond counts. Here's how to keep them fast:

1. **Use YUV pixel format.** YUV is the native camera format on both platforms and avoids a color-space conversion. RGB is easier to work with but costs ~1-2ms per frame in conversion overhead.
   ```tsx
   <Camera pixelFormat="yuv" />
   ```

2. **Offload heavy work with `runAsync`.** If your processing takes >8ms, it'll drop frames at 120fps. Use `runAsync` to process on a background thread.

3. **Prefer native plugins for ML inference.** Running TFLite, CoreML, or MLKit through a native plugin is 10-100x faster than doing it in JS.

4. **Don't allocate in the hot path.** Creating new arrays, objects, or strings on every frame creates GC pressure. Pre-allocate buffers where possible.

5. **Reduce resolution.** Use `vision-camera-resize-plugin` to downscale frames before processing — most ML models don't need full-resolution input.
   ```tsx
   import { resize } from 'vision-camera-resize-plugin'

   const frameProcessor = useFrameProcessor((frame) => {
     'worklet'
     const resized = resize(frame, {
       scale: { width: 320, height: 240 },
       pixelFormat: 'rgb',
     })
     // Process the smaller frame
   }, [])
   ```

6. **Profile on real devices.** Simulators don't give meaningful frame processor performance numbers. Always test on physical hardware.

---

## Community plugins

Popular frame processor plugins from the ecosystem:

| Plugin | Purpose |
|---|---|
| `react-native-fast-tflite` | TensorFlow Lite inference with GPU delegate |
| `vision-camera-resize-plugin` | Fast frame resizing and pixel format conversion |
| `react-native-vision-camera-face-detector` | MLKit face detection |
| `vision-camera-ocr` | On-device text recognition |
| `react-native-vision-camera-barcodes-scanner` | MLKit barcode scanning as a frame processor |
| `vision-camera-image-labeler` | MLKit image labeling |

Find more at [the VisionCamera docs](https://react-native-vision-camera.com/docs/guides/frame-processor-plugins-community).
