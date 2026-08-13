# Store App

A Flutter technical assessment using the public Fake Store API.

## Run

```bash
flutter pub get
flutter run
```

The default API base URL is `https://fakestoreapi.com`. It can be overridden:

```bash
flutter run --dart-define=API_BASE_URL=https://example.com
```

## Architecture

Features follow `Presentation -> Domain <- Data`.

- Presentation: Flutter UI and event/state BLoCs.
- Domain: immutable entities, repository contracts, and use cases.
- Data: Dio data sources, models, repository implementations, and persistence.
- GetIt owns dependency composition and GoRouter owns navigation.

Auth uses separate BLoCs for login submission, sign-up submission, and the global authenticated session. The login token is combined with the matching `/users` account record because `/auth/login` returns only a token.

## Persistence

SharedPreferences stores only the token, user ID, username, and email behind the auth local data source. Passwords are never persisted.

## Verification

The implemented project was checked with:

```bash
dart format .
flutter analyze
flutter test
```
