# VisionCamera + react-native-fast-tflite Integration

This reference covers the full pattern for running TFLite models on live camera frames
using react-native-vision-camera and react-native-fast-tflite together.

## Table of Contents

1. [Required Dependencies](#required-dependencies)
2. [Basic Frame Processor Pattern](#basic-frame-processor-pattern)
3. [Resize Plugin Configuration](#resize-plugin-configuration)
4. [Throttling with runAtTargetFps](#throttling-with-runattargetfps)
5. [Bridging Results to JS Thread](#bridging-results-to-js-thread)
6. [Full Object Detection Example](#full-object-detection-example)
7. [Full Classification Example](#full-classification-example)
8. [Tips and Pitfalls](#tips-and-pitfalls)

---

## Required Dependencies

```bash
yarn add react-native-fast-tflite react-native-vision-camera vision-camera-resize-plugin react-native-worklets-core
```

- **react-native-vision-camera**: Camera access and frame processor API
- **vision-camera-resize-plugin**: Resizes camera frames to model input dimensions
  (e.g., 224×224, 192×192). Without this, frames are full-resolution (4K) and won't
  match the model's expected input shape.
- **react-native-worklets-core**: Worklet runtime. Peer dependency of both
  vision-camera and fast-tflite. Required for `useFrameProcessor` and `runSync`.

## Basic Frame Processor Pattern

```tsx
import { useTensorflowModel } from 'react-native-fast-tflite';
import { useResizePlugin } from 'vision-camera-resize-plugin';
import {
  Camera,
  useCameraDevice,
  useFrameProcessor,
} from 'react-native-vision-camera';

function MLCamera() {
  const device = useCameraDevice('back');
  const tfPlugin = useTensorflowModel(require('./model.tflite'));
  const model = tfPlugin.state === 'loaded' ? tfPlugin.model : undefined;
  const { resize } = useResizePlugin();

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet';
    if (model == null) return;

    const resized = resize(frame, {
      scale: { width: 224, height: 224 },
      pixelFormat: 'rgb',
      dataType: 'uint8',
    });

    const outputs = model.runSync([resized]);
    // interpret outputs...
  }, [model]);

  if (device == null) return <Text>No camera</Text>;

  return (
    <Camera
      device={device}
      isActive={true}
      frameProcessor={frameProcessor}
      style={{ flex: 1 }}
    />
  );
}
```

## Resize Plugin Configuration

The resize plugin converts camera frames to match model input requirements.

```ts
const resized = resize(frame, {
  scale: {
    width: 192,   // model's expected width
    height: 192,  // model's expected height
  },
  pixelFormat: 'rgb',    // 'rgb' = 3 channels, 'rgba' = 4 channels
  dataType: 'uint8',     // 'uint8' or 'float32' depending on model
});
```

Common model input sizes:
- MobileNet: 224 × 224 × 3
- SSD MobileNet object detection: 300 × 300 × 3
- EfficientDet: 320 × 320 × 3 or 512 × 512 × 3
- Custom models: check in Netron (https://netron.app)

The `pixelFormat` and `dataType` must match the model's input tensor specification.
Most models use `rgb` with `uint8`, but some use `float32` (often with normalization
to [0, 1] or [-1, 1]).

## Throttling with runAtTargetFps

Running inference on every frame (30–60 fps) is usually unnecessary and wastes battery.
Use `runAtTargetFps` to throttle:

```tsx
import { runAtTargetFps } from 'react-native-vision-camera';

const frameProcessor = useFrameProcessor((frame) => {
  'worklet';
  if (model == null) return;

  runAtTargetFps(5, () => {
    // This block runs at ~5 fps instead of every frame
    const resized = resize(frame, { /* ... */ });
    const outputs = model.runSync([resized]);
    // ...
  });
}, [model]);
```

Recommended fps ranges by use case:
- Object detection overlays: 5–10 fps
- Classification / labeling: 3–5 fps
- Real-time tracking: 15–30 fps

## Bridging Results to JS Thread

Frame processors run in a worklet (native thread). To update React state from a worklet,
use `useRunOnJS` from `react-native-worklets-core`:

```tsx
import { useRunOnJS } from 'react-native-worklets-core';

function MLCamera() {
  const [result, setResult] = useState<string | null>(null);

  const handleResult = useCallback((label: string) => {
    setResult(label);
  }, []);

  const runOnJs = useRunOnJS(handleResult, [handleResult]);

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet';
    if (model == null) return;

    const resized = resize(frame, { /* ... */ });
    const outputs = model.runSync([resized]);

    // Bridge result back to JS thread
    const topClass = outputs[0].indexOf(Math.max(...outputs[0]));
    runOnJs(`Class ${topClass}`);
  }, [model, runOnJs]);

  return (
    <>
      <Camera frameProcessor={frameProcessor} /* ... */ />
      {result && <Text>{result}</Text>}
    </>
  );
}
```

## Full Object Detection Example

```tsx
import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import {
  Camera,
  useCameraDevice,
  useCameraPermission,
  useFrameProcessor,
  runAtTargetFps,
} from 'react-native-vision-camera';
import { useTensorflowModel } from 'react-native-fast-tflite';
import { useResizePlugin } from 'vision-camera-resize-plugin';
import { useRunOnJS } from 'react-native-worklets-core';

interface Detection {
  x: number;
  y: number;
  width: number;
  height: number;
  classIndex: number;
  confidence: number;
}

export function ObjectDetectionScreen() {
  const device = useCameraDevice('back');
  const { hasPermission, requestPermission } = useCameraPermission();
  const [detections, setDetections] = useState<Detection[]>([]);

  const tfPlugin = useTensorflowModel(require('./ssd_mobilenet.tflite'));
  const model = tfPlugin.state === 'loaded' ? tfPlugin.model : undefined;
  const { resize } = useResizePlugin();

  const onDetections = useCallback((dets: Detection[]) => {
    setDetections(dets);
  }, []);

  const bridgeDetections = useRunOnJS(onDetections, [onDetections]);

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet';
    if (model == null) return;

    runAtTargetFps(5, () => {
      const resized = resize(frame, {
        scale: { width: 300, height: 300 },
        pixelFormat: 'rgb',
        dataType: 'uint8',
      });

      const outputs = model.runSync([resized]);
      const boxes = outputs[0];
      const classes = outputs[1];
      const scores = outputs[2];
      const count = outputs[3];

      const results: Detection[] = [];
      for (let i = 0; i < count[0]; i++) {
        if (scores[i] > 0.5) {
          results.push({
            y: boxes[i * 4],
            x: boxes[i * 4 + 1],
            height: boxes[i * 4 + 2] - boxes[i * 4],
            width: boxes[i * 4 + 3] - boxes[i * 4 + 1],
            classIndex: classes[i],
            confidence: scores[i],
          });
        }
      }

      bridgeDetections(results);
    });
  }, [model, resize, bridgeDetections]);

  if (!hasPermission) {
    requestPermission();
    return <Text>Requesting camera permission...</Text>;
  }
  if (device == null) return <Text>No camera device</Text>;
  if (tfPlugin.state === 'loading') return <Text>Loading model...</Text>;
  if (tfPlugin.state === 'error') return <Text>Model error: {tfPlugin.error.message}</Text>;

  return (
    <View style={{ flex: 1 }}>
      <Camera
        device={device}
        isActive={true}
        frameProcessor={frameProcessor}
        style={StyleSheet.absoluteFill}
      />
      {detections.map((det, i) => (
        <View
          key={i}
          style={{
            position: 'absolute',
            borderWidth: 2,
            borderColor: 'red',
            left: `${det.x * 100}%`,
            top: `${det.y * 100}%`,
            width: `${det.width * 100}%`,
            height: `${det.height * 100}%`,
          }}
        />
      ))}
    </View>
  );
}
```

## Full Classification Example

```tsx
import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import {
  Camera,
  useCameraDevice,
  useFrameProcessor,
  runAtTargetFps,
} from 'react-native-vision-camera';
import { useTensorflowModel } from 'react-native-fast-tflite';
import { useResizePlugin } from 'vision-camera-resize-plugin';
import { useRunOnJS } from 'react-native-worklets-core';

const LABELS = ['cat', 'dog', 'bird', /* ... your labels ... */];

export function ClassificationScreen() {
  const device = useCameraDevice('back');
  const [prediction, setPrediction] = useState<string>('');

  const tfPlugin = useTensorflowModel(require('./mobilenet.tflite'));
  const model = tfPlugin.state === 'loaded' ? tfPlugin.model : undefined;
  const { resize } = useResizePlugin();

  const onPrediction = useCallback((label: string) => {
    setPrediction(label);
  }, []);

  const bridgePrediction = useRunOnJS(onPrediction, [onPrediction]);

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet';
    if (model == null) return;

    runAtTargetFps(3, () => {
      const resized = resize(frame, {
        scale: { width: 224, height: 224 },
        pixelFormat: 'rgb',
        dataType: 'uint8',
      });

      const outputs = model.runSync([resized]);
      const probs = outputs[0];

      let maxIdx = 0;
      let maxVal = probs[0];
      for (let i = 1; i < probs.length; i++) {
        if (probs[i] > maxVal) {
          maxVal = probs[i];
          maxIdx = i;
        }
      }

      bridgePrediction(`${LABELS[maxIdx] ?? maxIdx} (${(maxVal * 100).toFixed(1)}%)`);
    });
  }, [model, resize, bridgePrediction]);

  if (device == null) return <Text>No camera</Text>;
  if (tfPlugin.state === 'loading') return <ActivityIndicator size="large" />;

  return (
    <View style={{ flex: 1 }}>
      <Camera
        device={device}
        isActive={true}
        frameProcessor={frameProcessor}
        style={StyleSheet.absoluteFill}
      />
      <View style={styles.labelContainer}>
        <Text style={styles.label}>{prediction}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  labelContainer: {
    position: 'absolute',
    bottom: 80,
    alignSelf: 'center',
    backgroundColor: 'rgba(0,0,0,0.7)',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 10,
  },
  label: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
});
```

## Tips and Pitfalls

1. **Always check model is loaded before using it.** The `useTensorflowModel` hook
   starts in `'loading'` state. Guard all `model.runSync()` calls with a null check.

2. **Use `runSync` inside frame processors, not `run`.** Frame processors are worklets
   running on a native thread — only synchronous calls work here.

3. **Match input tensor dimensions exactly.** If your model expects 224×224×3 uint8,
   the resize plugin must output exactly that shape and type. Mismatched dimensions
   cause crashes or garbage output.

4. **Don't update React state on every frame.** Use `runAtTargetFps` to throttle
   inference, and batch state updates. Updating state at 30+ fps will cause lag.

5. **Worklets can't access closures freely.** Dependencies used inside a frame
   processor must be in the dependency array of `useFrameProcessor`.

6. **Large models may freeze the UI briefly during load.** Show a loading indicator.
   Consider loading the model in a parent component or on app startup to avoid
   freezes during navigation.

7. **GPU delegates may not support all operations.** If a model uses ops not supported
   by CoreML or the Android GPU delegate, it will either crash or silently fall back
   to CPU. Always test with `'default'` first.

8. **Inspect your model with Netron.** Before writing any inference code, open your
   `.tflite` model at https://netron.app to see exact input/output tensor shapes,
   types, and names.
