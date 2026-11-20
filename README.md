# Session Hub test prototype

Flutter Android prototype for launching COPS, Appco, Tricolab, and Greti and tracking a manual sign-in/sign-out checklist.

## Try it

1. Install Flutter and Android Studio on a computer with the Android SDK.
2. Connect an Android phone with USB debugging enabled, or start an Android emulator.
3. From this folder run `flutter pub get`, then `flutter run`.
4. Tap **Open app** for a service and enter its Android package name when asked. The service must already be installed on the phone.
5. Complete login or logout inside that app, return to Session Hub, and tap **Mark in/out**. The status is a manual checklist and is not verified against the target app.

You can find a package name in the Play Store URL (`id=com.example.app`), the app's published Android documentation, or by asking its vendor. The four COPS/Appco/Tricolab/Greti package names are not known yet.

## What it can and cannot do

- **Can:** open an installed app, one at a time, using its package name; keep a temporary checklist while the hub remains open.
- **Cannot:** enter credentials, read Google Authenticator codes, detect another app's signed-in state, or sign in/out on its behalf. Android isolates each app's data and sessions.
- **To enable real session control:** each service must support company SSO or provide an approved API to create/revoke sessions. The organization or app vendors need to configure that integration.

No passwords, MFA codes, or tokens are requested or stored by this prototype. Package names and checklist state currently reset when Session Hub is restarted.
