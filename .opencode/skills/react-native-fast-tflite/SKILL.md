---
name: react-native-fast-tflite
description: >
  Guide for integrating and using the react-native-fast-tflite library — a high-performance
  TensorFlow Lite library for React Native with GPU acceleration (CoreML, Metal, OpenGL).
  Use this skill whenever the user is working with TensorFlow Lite models in React Native,
  including: loading .tflite models, running inference, configuring GPU delegates (CoreML on iOS,
  GPU/NNAPI on Android), integrating with VisionCamera frame processors, handling tensor
  input/output, setting up metro config for .tflite assets, or troubleshooting TFLite-related
  build and runtime issues. Also trigger when the user mentions react-native-fast-tflite,
  tflite in a React Native context, on-device ML/AI in React Native, object detection or
  image classification in React Native, or useTensorflowModel / loadTensorflowModel.
  Even if the user just asks about running ML models on-device in React Native, this skill
  is likely relevant.
---

# react-native-fast-tflite

A high-performance TensorFlow Lite library for React Native, powered by JSI with zero-copy
ArrayBuffers and GPU-accelerated delegate support. Created by mrousavy (Margelo).

GitHub: https://github.com/mrousavy/react-native-fast-tflite

## Key Features

- JSI-powered for near-native performance
- Zero-copy ArrayBuffers — no serialization overhead
- Direct C/C++ TensorFlow Lite core API access
- Hot-swap models at runtime (no rebuild needed)
- GPU delegates: CoreML/Metal (iOS), GPU/NNAPI (Android)
- First-class VisionCamera frame processor integration
- Both async (`run`) and synchronous (`runSync`) inference

## Installation

### Step 1: Install the package

```bash
yarn add react-native-fast-tflite
# or
npm install react-native-fast-tflite
```

### Step 2: Configure Metro to bundle .tflite files

This is the most commonly missed step. In `metro.config.js`, register `tflite` as an asset extension:

**Bare React Native:**
```js
// metro.config.js
const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

const defaultConfig = getDefaultConfig(__dirname);

const config = {
  resolver: {
    assetExts: [...defaultConfig.resolver.assetExts, 'tflite'],
  },
};

module.exports = mergeConfig(defaultConfig, config);
```

**Expo:**
```js
// metro.config.js
const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);
config.resolver.assetExts.push('tflite');

module.exports = config;
```

Without this, `require('assets/model.tflite')` will fail at build time.

### Step 3: Install native dependencies

```bash
# iOS
cd ios && pod install && cd ..

# Then run
yarn ios
# or
yarn android
```

### Step 4 (Optional): Enable GPU Delegates

See the "GPU Delegates" section below.

## Core API

### Loading a Model

Two approaches — a standalone async function and a React hook:

```tsx
import { loadTensorflowModel, useTensorflowModel } from 'react-native-fast-tflite';

// ── Option A: Async function (use anywhere) ──
const model = await loadTensorflowModel(require('./assets/my-model.tflite'));

// ── Option B: React hook (use in components) ──
function MyComponent() {
  const plugin = useTensorflowModel(require('./assets/my-model.tflite'));

  if (plugin.state === 'loading') return <ActivityIndicator />;
  if (plugin.state === 'error')   return <Text>Error: {plugin.error.message}</Text>;

  // plugin.state === 'loaded'
  const model = plugin.model;
  // ...
}
```

### Model Sources

Models can be loaded from three source types:

```ts
// 1. Bundled asset (via require — needs metro config)
loadTensorflowModel(require('./assets/model.tflite'));

// 2. Local filesystem
loadTensorflowModel({ url: 'file:///var/mobile/.../model.tflite' });

// 3. Remote URL (downloaded at runtime)
loadTensorflowModel({ url: 'https://example.com/model.tflite' });
```

### Running Inference

```ts
// Async (off the JS thread)
const outputs = await model.run([inputBuffer]);

// Synchronous (use in worklets / frame processors)
const outputs = model.runSync([inputBuffer]);
```

- Input: an array of `ArrayBuffer | TypedArray` matching the model's input tensors.
- Output: an array of `TypedArray` matching the model's output tensors.

### Inspecting Tensor Shapes

To understand what input/output shapes your model expects, open the `.tflite` file in
[Netron](https://netron.app). It shows each tensor's name, shape, and data type.

The model object exposes `inputs` and `outputs` metadata arrays you can inspect at runtime:

```ts
console.log('Inputs:', model.inputs);
console.log('Outputs:', model.outputs);
```

### The `useTensorflowModel` Hook Return Type

```ts
type TensorflowPlugin =
  | { state: 'loading'; model: undefined }
  | { state: 'loaded';  model: TensorflowModel }
  | { state: 'error';   model: undefined; error: Error };
```

Always check `state` before accessing `model`. A common pattern:

```ts
const tfPlugin = useTensorflowModel(require('./model.tflite'));
const model = tfPlugin.state === 'loaded' ? tfPlugin.model : undefined;
```

## GPU Delegates

GPU delegates provide hardware-accelerated inference. Pass the delegate name as the second
argument to `loadTensorflowModel` or `useTensorflowModel`.

### Delegate Options

| Delegate       | Platform | Value          | Notes                                    |
|----------------|----------|----------------|------------------------------------------|
| Default (CPU)  | Both     | `'default'`    | No extra setup needed                    |
| CoreML         | iOS      | `'core-ml'`    | Requires extra build config              |
| Metal          | iOS      | `'metal'`      | Requires extra build config              |
| Android GPU    | Android  | `'android-gpu'`| May need native library declarations     |
| NNAPI          | Android  | `'nnapi'`      | Deprecated on Android 15+                |

### CoreML Setup (iOS)

**Expo:**
```json
{
  "plugins": [
    ["react-native-fast-tflite", { "enableCoreMLDelegate": true }]
  ]
}
```

**Bare React Native:**
1. Add `$EnableCoreMLDelegate = true` at the top of your `Podfile`.
2. In Xcode, add the `CoreML` framework under General → Frameworks, Libraries and Embedded Content.
3. Reinstall pods: `cd ios && pod install && cd ..`

**Usage:**
```ts
const model = await loadTensorflowModel(require('./model.tflite'), 'core-ml');
```

Not all TFLite ops are supported by CoreML — verify your model is compatible.

### Android GPU / NNAPI Setup

**Expo:**
```json
{
  "plugins": [
    ["react-native-fast-tflite", { "enableAndroidGpuLibraries": true }]
  ]
}
```

You can also specify exact libraries:
```json
{ "enableAndroidGpuLibraries": ["libOpenCL-pixel.so", "libGLES_mali.so"] }
```

**Bare React Native:**
Add `<uses-native-library>` entries in `AndroidManifest.xml` under the `<application>` tag:
```xml
<uses-native-library android:name="libOpenCL.so" android:required="false" />
<uses-native-library android:name="libOpenCL-pixel.so" android:required="false" />
<uses-native-library android:name="libGLES_mali.so" android:required="false" />
<uses-native-library android:name="libPVROCL.so" android:required="false" />
```

**Usage:**
```ts
const model = await loadTensorflowModel(require('./model.tflite'), 'android-gpu');
// or
const model = await loadTensorflowModel(require('./model.tflite'), 'nnapi');
```

NNAPI is deprecated starting Android 15. Prefer `'android-gpu'` for new projects — it has
similar performance but better initial load times.

## VisionCamera Integration

For detailed VisionCamera + frame processor patterns, read the reference file:
`references/vision-camera-integration.md`

The high-level pattern:

```tsx
import { useTensorflowModel } from 'react-native-fast-tflite';
import { useResizePlugin } from 'vision-camera-resize-plugin';
import { useFrameProcessor, Camera } from 'react-native-vision-camera';

function DetectionCamera() {
  const tfPlugin = useTensorflowModel(require('./object_detection.tflite'));
  const model = tfPlugin.state === 'loaded' ? tfPlugin.model : undefined;
  const { resize } = useResizePlugin();

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet';
    if (model == null) return;

    // Resize camera frame to match model input (e.g. 192×192 RGB)
    const resized = resize(frame, {
      scale: { width: 192, height: 192 },
      pixelFormat: 'rgb',
      dataType: 'uint8',
    });

    // Run synchronous inference inside the worklet
    const outputs = model.runSync([resized]);

    // Interpret outputs based on your model's spec
    const boxes = outputs[0];
    const classes = outputs[1];
    const scores = outputs[2];
    const count = outputs[3];
  }, [model]);

  return <Camera frameProcessor={frameProcessor} /* ...props */ />;
}
```

Key dependencies for VisionCamera integration:
- `react-native-vision-camera` — camera + frame processors
- `vision-camera-resize-plugin` — resize frames to model input dimensions
- `react-native-worklets-core` — worklet runtime (peer dependency)

## Troubleshooting

### "Unable to resolve module" / .tflite file not found
You forgot to add `'tflite'` to `assetExts` in `metro.config.js`. See the Installation
section above. After changing metro config, clear the cache: `npx react-native start --reset-cache`.

### App crashes on `useTensorflowModel`
- Verify the `.tflite` file is valid and not corrupted.
- Check that `react-native-worklets-core` is installed (it's a peer dependency).
- On iOS, ensure pods are reinstalled after adding the package.
- Check the native logs (Xcode console / Logcat) for the actual crash reason.

### App freezes while model loads
`useTensorflowModel` loads asynchronously, but very large models can still cause a brief
freeze. Show a loading indicator while `state === 'loading'`. The model object itself is
ready to use immediately once state becomes `'loaded'`.

### CoreML delegate fails
Not all TFLite operations are supported by CoreML. If the model uses unsupported ops, it
will fall back to CPU or crash. Test with `'default'` first, then try `'core-ml'`.

### Android GPU delegate issues
- Make sure `uses-native-library` entries are in `AndroidManifest.xml`.
- OpenCL is not officially supported by Android but most GPU vendors provide it.
- If GPU delegate fails, fall back to `'default'` (CPU).

### Build failures with New Architecture
If using React Native 0.77+ with the new architecture, ensure you're on the latest version
of react-native-fast-tflite (v2.0.0+). Older versions may have codegen compatibility issues.

## Common Patterns

### Object Detection

```ts
const outputs = model.runSync([imageBuffer]);
const boxes = outputs[0];   // [y1, x1, y2, x2, y1, x1, y2, x2, ...]
const classes = outputs[1];  // class indices
const scores = outputs[2];   // confidence scores
const count = outputs[3];    // number of detections

for (let i = 0; i < count[0]; i++) {
  if (scores[i] > 0.7) {
    const [y1, x1, y2, x2] = [
      boxes[i * 4], boxes[i * 4 + 1],
      boxes[i * 4 + 2], boxes[i * 4 + 3],
    ];
    console.log(`Detection ${i}: class=${classes[i]}, score=${scores[i]}`);
  }
}
```

### Image Classification

```ts
const outputs = model.runSync([imageBuffer]);
const probabilities = outputs[0]; // array of class probabilities
const topClassIndex = probabilities.indexOf(Math.max(...probabilities));
console.log(`Predicted class: ${topClassIndex}, confidence: ${probabilities[topClassIndex]}`);
```

### Swapping Models at Runtime

Because `.tflite` files are bundled as assets, you can load different models without
rebuilding:

```ts
const [modelPath, setModelPath] = useState(require('./model-v1.tflite'));
const plugin = useTensorflowModel(modelPath);

// Later, swap to a different model:
setModelPath(require('./model-v2.tflite'));
```

Or load from a URL to enable over-the-air model updates:

```ts
const model = await loadTensorflowModel({
  url: 'https://your-cdn.com/models/latest.tflite',
});
```

## Reference Files

- `references/vision-camera-integration.md` — Full VisionCamera + frame processor patterns,
  including resize plugin setup, `runAtTargetFps`, and `useRunOnJS` for bridging worklet
  results back to the JS thread.
