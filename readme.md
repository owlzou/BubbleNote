A simple note app.

## Build

Dependices: `Node.js` & `elm`

1. `npm install`
2. Build for Android (use [Capacitor](https://capacitorjs.com/))

```
npx cap sync
npm run build:android // will open Android Studio
```

3. Build for Desktop (use [TAURI](https://tauri.studio/en/), [Setup for Windows](https://tauri.studio/en/docs/getting-started/setup-windows))

```
npm run build:desktop
```

output:`src-tauri/target/release/bundle`
