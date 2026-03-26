# Khidma Pro

Kuwait-first home services reliability platform built with **FastAPI** (backend) and **Flutter** (iOS/Android frontend).

This MVP focuses on operational trust for high-frequency household services (AC, plumbing, electrical), with transparent KWD pricing, role-based booking logic, and booking lifecycle tracking.

## Kuwait-First MVP Scope

- **Launch country:** Kuwait
- **Supported launch cities:** `Kuwait City`, `Al Ahmadi`
- **Pricing currency:** KWD
- **Core flow:** Customer login -> service selection -> booking creation -> booking status tracking

## Tech Stack

- **Frontend:** Flutter, Riverpod, Dio
- **Backend:** FastAPI, SQLAlchemy, JWT auth
- **Database:** SQLite (default local dev), PostgreSQL-ready design
- **Testing:** pytest (backend), flutter_test (frontend)

## Repository Structure

```text
backend/
  app/
    core/
    db/
    routers/
    main.py
    models.py
    schemas.py
    security.py
    dependencies.py
  tests/
    test_bookings.py
  requirements.txt

frontend/
  lib/
    core/
    screens/
    main.dart
  test/
    model_test.dart
  pubspec.yaml
```

## Run Backend Locally (FastAPI)

### 1) Setup Python environment

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2) Start API server

```bash
uvicorn app.main:app --reload
```

Server runs at: `http://127.0.0.1:8000`

Health check:

```bash
curl http://127.0.0.1:8000/health
```

## Run Backend Tests

```bash
cd backend
pytest -q
```

What is covered in `test_bookings.py`:

- Booking creation succeeds for `Kuwait City`
- Booking creation succeeds for `Al Ahmadi`
- Booking creation fails for unsupported cities

## Run Frontend Locally (Flutter)

### 1) Install dependencies

```bash
cd frontend
flutter pub get
```

### 2) Confirm API base URL

Default base URL is in:

`frontend/lib/core/state.dart`

```dart
return ApiClient(baseUrl: 'http://127.0.0.1:8000');
```

If using a physical device/emulator, change this to a reachable host IP if needed.

### 3) Run app

```bash
flutter run
```

## Run Frontend Tests

```bash
cd frontend
flutter test
```

What is covered in `model_test.dart`:

- `ServiceItem.fromJson` parsing
- `Booking.fromJson` parsing and datetime conversion

## Notes for Production Hardening

- Move secrets (`jwt_secret`, DB URL) to environment variables
- Add Alembic migrations and production PostgreSQL
- Add refresh tokens and logout revocation strategy
- Add provider onboarding, review/dispute flows, and payment capture integrations
