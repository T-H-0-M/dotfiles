---
name: react-native-expo
description: |
  Build React Native components, screens, features, and modules using Expo. Use this skill whenever the user wants to create or modify React Native components, screens, navigation flows, hooks, or native modules in an Expo project. Trigger on any mention of React Native, Expo, Expo Router, mobile app development, native modules, config plugins, or references to an Expo project structure (app/, _layout.tsx, expo-router, etc.). Also trigger when the user asks about mobile UI patterns, push notifications, camera, maps, or other mobile-specific features in a JavaScript/TypeScript context — even if they don't say "Expo" explicitly. If the user's project has an app.json or app.config.ts with "expo" in it, this skill applies.
---

# React Native + Expo Skill

Build components, screens, features, and native modules for React Native apps using Expo.

## When to read reference files

This skill has reference files for specialized topics. Read them when the task involves:

- **Expo Router navigation** (tabs, stacks, drawers, deep links, layouts) → read `references/expo-router.md`
- **Native modules or config plugins** (bridging Swift/Kotlin, custom native code) → read `references/native-modules.md`

For general component building, styling, hooks, and SDK usage, everything you need is below.

---

## Project Structure

Expo projects (SDK 52+) use a `src/` directory by convention. The `app/` directory is **exclusively for routes** — all other code lives outside it.

```
src/
├── app/                    # Routes only (file-based routing)
│   ├── _layout.tsx         # Root layout
│   ├── index.tsx           # Entry screen (/)
│   ├── (tabs)/             # Tab group
│   │   ├── _layout.tsx     # Tab navigator config
│   │   ├── index.tsx       # First tab
│   │   └── profile.tsx     # Profile tab
│   └── (auth)/             # Auth group
│       ├── _layout.tsx
│       ├── sign-in.tsx
│       └── sign-up.tsx
├── components/             # Reusable UI components
│   ├── ui/                 # Primitives (Button, Card, Input)
│   └── features/           # Feature-specific (PostCard, UserAvatar)
├── hooks/                  # Custom hooks
├── utils/                  # Pure helper functions
├── constants/              # Theme, config, enums
├── services/               # API clients, storage wrappers
└── types/                  # Shared TypeScript types
```

Use **kebab-case** for filenames (`user-avatar.tsx`, `use-auth.ts`). This is Expo's default recommendation as of early 2026.

Route files inside `app/` define navigation structure. Keep them thin — they should import and render a screen component, not contain business logic:

```tsx
// src/app/(tabs)/profile.tsx — thin route file
import { ProfileScreen } from '@/components/features/profile-screen';
export default ProfileScreen;
```

## Component Patterns

### Functional Components with TypeScript

Always use TypeScript. Define prop interfaces explicitly, provide sensible defaults, and export named + default where appropriate.

```tsx
import { View, Text, Pressable, StyleSheet } from 'react-native';

interface ActionCardProps {
  title: string;
  subtitle?: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary';
}

export function ActionCard({
  title,
  subtitle,
  onPress,
  variant = 'primary',
}: ActionCardProps) {
  return (
    <Pressable
      style={({ pressed }) => [
        styles.card,
        variant === 'secondary' && styles.cardSecondary,
        pressed && styles.cardPressed,
      ]}
      onPress={onPress}
    >
      <Text style={styles.title}>{title}</Text>
      {subtitle && <Text style={styles.subtitle}>{subtitle}</Text>}
    </Pressable>
  );
}
```

### Hooks

Extract reusable logic into custom hooks. Name them `use-<thing>.ts` (kebab-case file, camelCase export).

```tsx
// src/hooks/use-debounced-value.ts
import { useState, useEffect } from 'react';

export function useDebouncedValue<T>(value: T, delay: number = 300): T {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debounced;
}
```

### Platform-Specific Code

Use Expo's module resolution for platform differences. Create `component.tsx` (web) and `component.native.tsx` (iOS/Android), or use `Platform.select()` for small differences.

```tsx
import { Platform, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  shadow: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
      shadowRadius: 4,
    },
    android: {
      elevation: 4,
    },
    default: {
      boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
    },
  }),
});
```

## Styling

### StyleSheet (Default)

Use `StyleSheet.create()` as the baseline. It's zero-config, performant, and always available.

```tsx
const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#fff',
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
});
```

Key React Native layout differences from CSS:
- `flexDirection` defaults to `'column'` (not `'row'`)
- Dimensions are unitless (density-independent pixels)
- No cascading — styles don't inherit from parent (except `Text` within `Text`)
- Use `gap` for spacing between flex children (supported in RN 0.71+)

### NativeWind (Tailwind for RN)

If the project uses NativeWind, use `className` props with Tailwind utilities. NativeWind compiles at build time, so there's no runtime cost.

```tsx
import { View, Text } from 'react-native';

export function Badge({ label }: { label: string }) {
  return (
    <View className="rounded-full bg-blue-100 px-3 py-1">
      <Text className="text-sm font-medium text-blue-800">{label}</Text>
    </View>
  );
}
```

Check for `nativewind` in `package.json` to know which approach to use. If the user hasn't chosen a styling approach, default to `StyleSheet.create()`.

### Theming

For light/dark mode, use `useColorScheme()` from `react-native` or Expo's `useColorScheme` from `expo` module. Define a theme constants file:

```tsx
// src/constants/colors.ts
export const Colors = {
  light: {
    text: '#11181C',
    background: '#fff',
    tint: '#0a7ea4',
    border: '#E5E7EB',
  },
  dark: {
    text: '#ECEDEE',
    background: '#151718',
    tint: '#67B2D1',
    border: '#2D2D2D',
  },
};
```

## Expo SDK Modules

When using Expo SDK modules, follow this pattern:

1. **Import from the correct package** — Each module is a separate package (`expo-camera`, `expo-location`, etc.)
2. **Check/request permissions first** — Most hardware APIs need permissions
3. **Handle the "not available" case** — Gracefully degrade when the device doesn't support it

```tsx
import * as Location from 'expo-location';
import { useEffect, useState } from 'react';

export function useCurrentLocation() {
  const [location, setLocation] = useState<Location.LocationObject | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        setError('Location permission denied');
        return;
      }
      const loc = await Location.getCurrentPositionAsync({});
      setLocation(loc);
    })();
  }, []);

  return { location, error };
}
```

### Common SDK modules and their packages

| Feature | Package | Needs Dev Build? |
|---|---|---|
| Camera | `expo-camera` | No (in Expo Go) |
| Image picking | `expo-image-picker` | No |
| File system | `expo-file-system` | No |
| Secure storage | `expo-secure-store` | No |
| Notifications | `expo-notifications` | Yes |
| Maps | `react-native-maps` | Yes |
| In-app purchases | `expo-in-app-purchases` | Yes |
| Haptics | `expo-haptics` | No |
| Linear gradient | `expo-linear-gradient` | No |
| Blur | `expo-blur` | No |
| Video | `expo-video` | No |
| Audio | `expo-audio` | No (beta) |

If a module requires a development build, mention that to the user — it won't work in Expo Go.

## State Management

For local component state, use `useState` and `useReducer`. For shared state across the app:

- **React Context** — Good for auth state, theme, small global state. Built-in, no dependencies.
- **Zustand** — Lightweight, minimal boilerplate. Good for medium complexity.
- **TanStack Query (React Query)** — Best for server state (API data fetching, caching, sync).

Suggest the simplest option that fits the need. Don't over-engineer state management for a simple feature.

```tsx
// Simple auth context example
import { createContext, useContext, useState, type ReactNode } from 'react';

interface AuthContextType {
  user: User | null;
  signIn: (token: string) => void;
  signOut: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  const signIn = async (token: string) => {
    // Store token, fetch user profile, update state
    await SecureStore.setItemAsync('token', token);
    const profile = await fetchProfile(token);
    setUser(profile);
  };

  const signOut = async () => {
    await SecureStore.deleteItemAsync('token');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
```

## Data Fetching

Use `fetch` or `axios` for API calls. For anything beyond a one-off fetch, use TanStack Query:

```tsx
import { useQuery } from '@tanstack/react-query';

export function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetch(`/api/users/${userId}`).then(r => r.json()),
  });
}
```

Wrap the app in `QueryClientProvider` in the root layout.

## Images

Use `expo-image` (not `Image` from `react-native`) for better performance, caching, and format support:

```tsx
import { Image } from 'expo-image';

<Image
  source={{ uri: 'https://example.com/photo.jpg' }}
  style={{ width: 200, height: 200 }}
  contentFit="cover"
  placeholder={{ blurhash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj' }}
  transition={200}
/>
```

## Lists

Use `FlashList` from `@shopify/flash-list` for performant lists (or `FlatList` if FlashList isn't installed). Always provide `estimatedItemSize` for FlashList:

```tsx
import { FlashList } from '@shopify/flash-list';

<FlashList
  data={items}
  renderItem={({ item }) => <ItemCard item={item} />}
  estimatedItemSize={80}
  keyExtractor={(item) => item.id}
/>
```

## Forms & Input

For forms, use `react-hook-form` with `zod` for validation if the project uses them, otherwise keep it simple with controlled components:

```tsx
import { TextInput, View, Text } from 'react-native';
import { useForm, Controller } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';

const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'At least 8 characters'),
});

type FormData = z.infer<typeof schema>;

export function LoginForm({ onSubmit }: { onSubmit: (data: FormData) => void }) {
  const { control, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  return (
    <View style={{ gap: 12 }}>
      <Controller
        control={control}
        name="email"
        render={({ field: { onChange, value } }) => (
          <TextInput
            value={value}
            onChangeText={onChange}
            placeholder="Email"
            keyboardType="email-address"
            autoCapitalize="none"
          />
        )}
      />
      {errors.email && <Text style={{ color: 'red' }}>{errors.email.message}</Text>}

      <Controller
        control={control}
        name="password"
        render={({ field: { onChange, value } }) => (
          <TextInput
            value={value}
            onChangeText={onChange}
            placeholder="Password"
            secureTextEntry
          />
        )}
      />
      {errors.password && <Text style={{ color: 'red' }}>{errors.password.message}</Text>}
    </View>
  );
}
```

## Animations

Use `react-native-reanimated` for performant animations. It runs on the UI thread, so animations stay smooth even when JS is busy.

```tsx
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';

export function BouncyButton({ children, onPress }) {
  const scale = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <Animated.View style={animatedStyle}>
      <Pressable
        onPressIn={() => { scale.value = withSpring(0.95); }}
        onPressOut={() => { scale.value = withSpring(1); }}
        onPress={onPress}
      >
        {children}
      </Pressable>
    </Animated.View>
  );
}
```

## Expo Go vs Development Builds

**Expo Go** is great for quick prototyping — it has common libraries pre-installed and lets you test instantly on a physical device. But it can't run custom native code or libraries that require native linking.

**Development builds** are your own customized version of Expo Go. Use them when your app needs: push notifications, custom native modules, libraries not in Expo Go, or any native configuration changes.

To create a development build:
```bash
npx expo install expo-dev-client
npx expo prebuild
npx expo run:ios  # or run:android
```

Or use EAS Build for cloud builds:
```bash
eas build --profile development --platform ios
```

If a user is building something that needs a dev build, mention this early so they don't get stuck trying it in Expo Go.

## New Architecture (SDK 52+)

React Native's New Architecture is the default in SDK 52+. This means:
- **JSI** replaces the old Bridge — synchronous native calls, better performance
- **Fabric** is the new rendering system
- **TurboModules** replace legacy native modules

In practice, most Expo SDK libraries already support the New Architecture. If the user is using third-party libraries, check compatibility. The key symptom of an incompatible library is a crash or error at startup mentioning "bridge" or "TurboModule".

## Common Pitfalls

- **Importing from wrong package**: `Image` should come from `expo-image`, not `react-native` (for better perf). `StatusBar` from `expo-status-bar`, not `react-native`.
- **Missing permissions**: Always check and request permissions before accessing hardware APIs.
- **Heavy computation on JS thread**: Use `InteractionManager.runAfterInteractions()` for expensive work, or move it to a native module/web worker.
- **Not handling keyboard**: Use `KeyboardAvoidingView` or `expo-keyboard-controller` so inputs don't get hidden behind the keyboard.
- **Forgetting safe areas**: Wrap screens in `SafeAreaView` from `react-native-safe-area-context` to avoid notches and system bars.
