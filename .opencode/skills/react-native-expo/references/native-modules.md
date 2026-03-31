# Native Modules & Config Plugins Reference

This reference covers creating custom native code in Expo projects using the Expo Modules API and config plugins.

## Table of Contents

1. [When You Need Native Code](#when-you-need-native-code)
2. [Expo Modules API](#expo-modules-api)
3. [Creating a Native Module](#creating-a-native-module)
4. [Native Views](#native-views)
5. [Config Plugins](#config-plugins)
6. [Common Config Plugin Patterns](#common-config-plugin-patterns)

---

## When You Need Native Code

Most Expo projects never need custom native code — the Expo SDK covers cameras, notifications, sensors, file systems, and more. You need native modules when:

- Wrapping a third-party native SDK (analytics, payments, etc.)
- Accessing platform APIs not covered by Expo SDK
- Performance-critical code that must run natively (image processing, ML inference)
- Custom native UI components (maps overlays, video players with custom controls)

If you're just using a community library that requires native code, you don't need to write a module — you need a **development build** with `expo-dev-client`.

---

## Expo Modules API

The Expo Modules API lets you write native modules in **Swift** (iOS) and **Kotlin** (Android), taking advantage of modern language features. It's designed to minimize boilerplate compared to the old React Native bridge.

### Creating a module project

```bash
npx create-expo-module my-module
```

This scaffolds:

```
my-module/
├── src/
│   └── MyModuleModule.ts        # TypeScript interface
├── ios/
│   └── MyModuleModule.swift     # Swift implementation
├── android/
│   └── src/main/java/.../
│       └── MyModuleModule.kt    # Kotlin implementation
├── expo-module.config.json
└── example/                     # Example app for testing
```

### For a local module within an existing app

```bash
npx create-expo-module --local my-module
```

This creates the module inside your project's `modules/` directory so you can develop it alongside your app.

---

## Creating a Native Module

### TypeScript interface (the JS-facing API)

```tsx
// src/MyModule.ts
import { NativeModule, requireNativeModule } from 'expo-modules-core';

declare class MyModuleNativeModule extends NativeModule {
  greet(name: string): string;
  fetchDataAsync(url: string): Promise<string>;
}

export default requireNativeModule<MyModuleNativeModule>('MyModule');
```

### Swift implementation (iOS)

```swift
// ios/MyModuleModule.swift
import ExpoModulesCore

public class MyModuleModule: Module {
  public func definition() -> ModuleDefinition {
    Name("MyModule")

    // Synchronous function — runs on JS thread
    Function("greet") { (name: String) -> String in
      return "Hello, \(name)!"
    }

    // Async function — runs on a background thread
    AsyncFunction("fetchDataAsync") { (url: String) -> String in
      let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
      return String(data: data, encoding: .utf8) ?? ""
    }
  }
}
```

### Kotlin implementation (Android)

```kotlin
// android/src/main/java/expo/modules/mymodule/MyModuleModule.kt
package expo.modules.mymodule

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import java.net.URL

class MyModuleModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("MyModule")

    Function("greet") { name: String ->
      "Hello, $name!"
    }

    AsyncFunction("fetchDataAsync") { url: String ->
      URL(url).readText()
    }
  }
}
```

### Module definition building blocks

| Block | Purpose |
|---|---|
| `Name("ModuleName")` | Required. Identifies the module in JS. |
| `Function("name") { }` | Synchronous function, runs on JS thread |
| `AsyncFunction("name") { }` | Async function, returns a Promise |
| `Property("name")` | Readable/writable property |
| `Events("onData", "onError")` | Declares events the module can emit |
| `View(MyNativeView.self) { }` | Defines a native view component |
| `OnCreate { }` | Called when the module is initialized |
| `OnDestroy { }` | Cleanup when the module is torn down |

### Emitting events

```swift
// Swift
Events("onProgress")

AsyncFunction("startDownload") { (url: String) in
  // ... downloading ...
  self.sendEvent("onProgress", ["percent": 0.5])
}
```

```tsx
// TypeScript — listening to events
import { useEvent } from 'expo';
import MyModule from './MyModule';

function DownloadProgress() {
  const event = useEvent(MyModule, 'onProgress');
  return <Text>Progress: {(event?.percent ?? 0) * 100}%</Text>;
}
```

---

## Native Views

For custom native UI components:

```swift
// ios/MyMapView.swift
import ExpoModulesCore
import MapKit

class MyMapView: ExpoView {
  let mapView = MKMapView()

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    addSubview(mapView)
  }

  override func layoutSubviews() {
    mapView.frame = bounds
  }
}

// In module definition:
View(MyMapView.self) {
  Prop("region") { (view: MyMapView, region: [String: Double]) in
    // Update the map region
  }

  Events("onRegionChange")
}
```

```tsx
// TypeScript — using the view
import { requireNativeView } from 'expo';

const MyMapView = requireNativeView('MyMapView');

<MyMapView
  region={{ latitude: 37.78, longitude: -122.43 }}
  onRegionChange={(e) => console.log(e.nativeEvent)}
  style={{ width: '100%', height: 300 }}
/>
```

---

## Config Plugins

Config plugins modify the native project files generated by `npx expo prebuild`. They're essential for Continuous Native Generation (CNG), where native projects are generated from `app.json` / `app.config.ts` rather than being manually maintained.

### When to use config plugins

- Setting native build properties (min SDK version, permissions, entitlements)
- Adding API keys to `AndroidManifest.xml` or `Info.plist`
- Modifying `build.gradle` or `Podfile`
- Adding app extensions (widgets, share extensions)
- Configuring deep linking schemes

### Writing a config plugin

Config plugins are functions that take an `ExpoConfig` and return a modified one. They use "mods" to intercept and modify specific native files.

```ts
// plugins/with-google-maps.ts
import { ConfigPlugin, withInfoPlist, withAndroidManifest } from 'expo/config-plugins';

const withGoogleMaps: ConfigPlugin<{ apiKey: string }> = (config, { apiKey }) => {
  // iOS: Add API key to Info.plist
  config = withInfoPlist(config, (config) => {
    config.modResults.GMSApiKey = apiKey;
    return config;
  });

  // Android: Add API key to AndroidManifest.xml
  config = withAndroidManifest(config, (config) => {
    const mainApp = config.modResults.manifest.application?.[0];
    if (mainApp) {
      mainApp['meta-data'] = mainApp['meta-data'] || [];
      mainApp['meta-data'].push({
        $: {
          'android:name': 'com.google.android.geo.API_KEY',
          'android:value': apiKey,
        },
      });
    }
    return config;
  });

  return config;
};

export default withGoogleMaps;
```

### Using the plugin in app.config.ts

```ts
// app.config.ts
import { ExpoConfig, ConfigContext } from 'expo/config';

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'My App',
  plugins: [
    ['./plugins/with-google-maps', { apiKey: process.env.GOOGLE_MAPS_API_KEY }],
    'expo-router',
    'expo-font',
  ],
});
```

### Available mods

| Mod | What it modifies |
|---|---|
| `withInfoPlist` | iOS `Info.plist` |
| `withEntitlementsPlist` | iOS entitlements |
| `withXcodeProject` | iOS `.xcodeproj` settings |
| `withAndroidManifest` | Android `AndroidManifest.xml` |
| `withMainApplication` | Android `MainApplication.kt` |
| `withMainActivity` | Android `MainActivity.kt` |
| `withAppBuildGradle` | Android `app/build.gradle` |
| `withProjectBuildGradle` | Android `build.gradle` (project-level) |
| `withAppDelegate` | iOS `AppDelegate.swift` |
| `withPodfile` | iOS `Podfile` |
| `withStringsXml` | Android `strings.xml` |

### Plugin naming convention

Prefix plugin functions with `with`: `withMyPlugin`, `withGoogleMaps`, `withSentry`.

---

## Common Config Plugin Patterns

### Adding permissions

```ts
import { ConfigPlugin, withInfoPlist, AndroidConfig } from 'expo/config-plugins';

const withCameraPermission: ConfigPlugin = (config) => {
  // iOS
  config = withInfoPlist(config, (config) => {
    config.modResults.NSCameraUsageDescription =
      'This app uses the camera to scan barcodes';
    return config;
  });

  // Android — permissions are usually handled via app.json's "permissions" field,
  // but for fine-grained control:
  config = AndroidConfig.Permissions.withPermissions(config, [
    'android.permission.CAMERA',
  ]);

  return config;
};
```

### Adding a build dependency (Android)

```ts
import { ConfigPlugin, withAppBuildGradle } from 'expo/config-plugins';

const withFirebase: ConfigPlugin = (config) => {
  return withAppBuildGradle(config, (config) => {
    if (!config.modResults.contents.includes('com.google.firebase')) {
      config.modResults.contents = config.modResults.contents.replace(
        'dependencies {',
        `dependencies {\n    implementation 'com.google.firebase:firebase-analytics:21.5.0'`
      );
    }
    return config;
  });
};
```

### Adding a CocoaPod (iOS)

```ts
import { ConfigPlugin, withPodfile } from 'expo/config-plugins';

const withMyPod: ConfigPlugin = (config) => {
  return withPodfile(config, (config) => {
    if (!config.modResults.contents.includes("pod 'MyLibrary'")) {
      config.modResults.contents = config.modResults.contents.replace(
        "use_expo_modules!",
        "use_expo_modules!\n  pod 'MyLibrary', '~> 2.0'"
      );
    }
    return config;
  });
};
```

### Testing your plugin

After writing a config plugin:

1. Run `npx expo prebuild --clean` to regenerate native projects
2. Inspect the generated files (`ios/` and `android/`) to verify your changes
3. Build and run: `npx expo run:ios` or `npx expo run:android`

The `--clean` flag ensures a fresh prebuild, so you're testing from a clean slate rather than layering changes.
