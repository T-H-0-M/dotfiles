# Expo Router Reference

Expo Router is a file-based routing library for React Native, built on React Navigation. Every file in the `app/` directory becomes a route automatically.

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Layout Files](#layout-files)
3. [Stack Navigation](#stack-navigation)
4. [Tab Navigation](#tab-navigation)
5. [Drawer Navigation](#drawer-navigation)
6. [Navigation Patterns](#navigation-patterns)
7. [Deep Linking & URL Handling](#deep-linking)
8. [Typed Routes](#typed-routes)
9. [Common Patterns](#common-patterns)

---

## Core Concepts

### Route Mapping

Files in `app/` map to URLs:

| File | Route |
|---|---|
| `app/index.tsx` | `/` |
| `app/about.tsx` | `/about` |
| `app/user/[id].tsx` | `/user/123` |
| `app/blog/[...slug].tsx` | `/blog/a/b/c` (catch-all) |
| `app/(tabs)/index.tsx` | `/` (grouped) |

### Route Groups

Directories wrapped in parentheses `(group-name)` create layout groups without affecting the URL:

```
app/
├── (auth)/
│   ├── _layout.tsx    # Stack for auth flow
│   ├── sign-in.tsx    # /sign-in (not /auth/sign-in)
│   └── sign-up.tsx    # /sign-up
├── (tabs)/
│   ├── _layout.tsx    # Tab navigator
│   ├── index.tsx      # /
│   └── settings.tsx   # /settings
└── _layout.tsx        # Root layout
```

Groups let you apply different navigators to different sets of screens without those group names showing up in the URL.

### Dynamic Routes

Use square brackets for dynamic segments:

```tsx
// app/user/[id].tsx
import { useLocalSearchParams } from 'expo-router';

export default function UserScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  return <Text>User {id}</Text>;
}
```

For catch-all routes, use `[...slug]`:

```tsx
// app/docs/[...slug].tsx
import { useLocalSearchParams } from 'expo-router';

export default function DocsScreen() {
  const { slug } = useLocalSearchParams<{ slug: string[] }>();
  // slug = ['guides', 'routing'] for /docs/guides/routing
}
```

---

## Layout Files

Every directory can have a `_layout.tsx` that wraps its child routes. This is where you define the navigator type (Stack, Tabs, Drawer) and configure shared UI like headers, tab bars, and drawers.

### Root Layout

The root `_layout.tsx` is the entry point. Use it for providers, fonts, splash screen, and the top-level navigator.

```tsx
// app/_layout.tsx
import { Stack } from 'expo-router';
import { useFonts } from 'expo-font';
import * as SplashScreen from 'expo-splash-screen';
import { useEffect } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { AuthProvider } from '@/hooks/use-auth';

SplashScreen.preventAutoHideAsync();

const queryClient = new QueryClient();

export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    'Inter-Regular': require('@/assets/fonts/Inter-Regular.ttf'),
    'Inter-Bold': require('@/assets/fonts/Inter-Bold.ttf'),
  });

  useEffect(() => {
    if (fontsLoaded) {
      SplashScreen.hideAsync();
    }
  }, [fontsLoaded]);

  if (!fontsLoaded) return null;

  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <Stack screenOptions={{ headerShown: false }}>
          <Stack.Screen name="(tabs)" />
          <Stack.Screen name="(auth)" />
          <Stack.Screen
            name="modal"
            options={{ presentation: 'modal' }}
          />
        </Stack>
      </AuthProvider>
    </QueryClientProvider>
  );
}
```

---

## Stack Navigation

Stack is the default navigator. Screens push on top of each other.

```tsx
// app/(auth)/_layout.tsx
import { Stack } from 'expo-router';

export default function AuthLayout() {
  return (
    <Stack
      screenOptions={{
        headerStyle: { backgroundColor: '#fff' },
        headerTintColor: '#000',
        headerTitleStyle: { fontWeight: '600' },
      }}
    >
      <Stack.Screen
        name="sign-in"
        options={{ title: 'Sign In' }}
      />
      <Stack.Screen
        name="sign-up"
        options={{ title: 'Create Account' }}
      />
    </Stack>
  );
}
```

### Navigating between screens

```tsx
import { Link, useRouter } from 'expo-router';

// Declarative (for simple links)
<Link href="/user/123">View Profile</Link>

// Imperative (for programmatic navigation)
const router = useRouter();
router.push('/user/123');       // Push onto stack
router.replace('/home');         // Replace current screen
router.back();                   // Go back
router.dismiss();                // Dismiss modal
router.navigate('/settings');    // Navigate, avoiding duplicates
```

---

## Tab Navigation

Use the `Tabs` component from `expo-router` for bottom tab navigation.

```tsx
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';

export default function TabLayout() {
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: '#0a7ea4',
        tabBarStyle: { paddingBottom: 4 },
        headerShown: false,
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="home" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="explore"
        options={{
          title: 'Explore',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="compass" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="person" size={size} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
```

### Stacks inside tabs

For screens that push within a specific tab (e.g., tapping a post in the Home tab to view its detail), create a nested stack inside that tab:

```
app/
├── (tabs)/
│   ├── _layout.tsx          # Tab navigator
│   ├── (home)/
│   │   ├── _layout.tsx      # Stack for home tab
│   │   ├── index.tsx        # Home feed
│   │   └── [postId].tsx     # Post detail (pushes within Home tab)
│   └── profile.tsx
```

```tsx
// app/(tabs)/(home)/_layout.tsx
import { Stack } from 'expo-router';

export default function HomeStack() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'Home' }} />
      <Stack.Screen name="[postId]" options={{ title: 'Post' }} />
    </Stack>
  );
}
```

### Hiding tabs on certain screens

Use `tabBarStyle: { display: 'none' }` in screen options, or better yet, put the screen outside the tabs group as a modal/push.

---

## Drawer Navigation

Install `expo-router` drawer support:

```bash
npx expo install @react-navigation/drawer react-native-gesture-handler react-native-reanimated
```

```tsx
// app/_layout.tsx (or a group layout)
import { Drawer } from 'expo-router/drawer';

export default function Layout() {
  return (
    <Drawer>
      <Drawer.Screen name="index" options={{ title: 'Home' }} />
      <Drawer.Screen name="settings" options={{ title: 'Settings' }} />
    </Drawer>
  );
}
```

---

## Navigation Patterns

### Auth flow (redirect unauthenticated users)

Use `Redirect` in the root layout or a route group:

```tsx
// app/(tabs)/_layout.tsx
import { Redirect } from 'expo-router';
import { useAuth } from '@/hooks/use-auth';

export default function TabsLayout() {
  const { user } = useAuth();

  if (!user) {
    return <Redirect href="/sign-in" />;
  }

  return (
    <Tabs>
      {/* ... */}
    </Tabs>
  );
}
```

### Modals

Define a modal screen in the root layout with `presentation: 'modal'`:

```tsx
// In root _layout.tsx
<Stack.Screen
  name="modal"
  options={{
    presentation: 'modal',
    headerShown: true,
  }}
/>
```

Navigate to it: `router.push('/modal')`. Dismiss with `router.dismiss()`.

### Not Found screen

Create a `+not-found.tsx` file to catch unmatched routes:

```tsx
// app/+not-found.tsx
import { Link, Stack } from 'expo-router';
import { View, Text } from 'react-native';

export default function NotFoundScreen() {
  return (
    <>
      <Stack.Screen options={{ title: 'Not Found' }} />
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <Text>This page doesn't exist.</Text>
        <Link href="/">Go home</Link>
      </View>
    </>
  );
}
```

---

## Deep Linking

Expo Router handles deep links automatically based on your file structure. The URL scheme is configured in `app.json`:

```json
{
  "expo": {
    "scheme": "myapp"
  }
}
```

This means `myapp://user/123` maps to `app/user/[id].tsx` automatically. For universal links (https://), configure `intentFilters` (Android) and `associatedDomains` (iOS) in `app.json`.

---

## Typed Routes

Enable typed routes in `app.json` for autocomplete on route paths:

```json
{
  "expo": {
    "experiments": {
      "typedRoutes": true
    }
  }
}
```

Then `router.push()` and `<Link href="">` will have type checking on the paths:

```tsx
router.push('/user/123');  // ✓ type-safe if app/user/[id].tsx exists
router.push('/nonexistent'); // ✗ TypeScript error
```

---

## Common Patterns

### Passing data between screens

Use query params for serializable data:

```tsx
router.push({ pathname: '/user/[id]', params: { id: '123', tab: 'posts' } });

// In the target screen:
const { id, tab } = useLocalSearchParams<{ id: string; tab?: string }>();
```

For complex data, use shared state (context, Zustand store, or TanStack Query cache) rather than trying to pass objects through params.

### Preventing back navigation

Use `router.replace()` instead of `router.push()` when you don't want the user to go back (e.g., after sign-in, replace with the home screen).

### Screen options from within a screen

You can set navigation options from inside a screen component:

```tsx
import { Stack } from 'expo-router';

export default function ProfileScreen() {
  return (
    <>
      <Stack.Screen options={{ title: 'My Profile', headerRight: () => <SettingsButton /> }} />
      {/* screen content */}
    </>
  );
}
```
