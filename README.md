# Store App

A Flutter technical assessment that demonstrates a maintainable store flow using the public Fake Store API.

## Features

- Authentication, sign-up, logout, and session persistence
- Product catalog with search and category filtering
- Product details with responsive purchase controls
- Persistent cart with quantity management
- Account screen and subtle interface animations

## Architecture

The project follows Clean Architecture with `Presentation -> Domain <- Data`. BLoC manages application state, GetIt provides dependency injection, Dio handles HTTP requests, GoRouter owns navigation, and SharedPreferences persists the session and cart behind local data sources.

## API

The app uses [Fake Store API](https://fakestoreapi.com). Its user-creation endpoint simulates a successful request but does not persist new users like a production backend. Use an existing API user to test login.

## Demo Login

- Username: `johnd`
- Password: `m38rmF$`

## Run

```bash
flutter pub get
flutter run
```

The API base URL can optionally be overridden:

```bash
flutter run --dart-define=API_BASE_URL=https://example.com
```

## Tests

```bash
flutter test
```
