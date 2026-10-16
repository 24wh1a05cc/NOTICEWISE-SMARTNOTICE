# NoticeWise – SmartNotice: Project Conventions

## Project Identity

- **Application name:** NoticeWise – SmartNotice
- **Package name:** `com.noticewise.smartnotice`
- **Primary platform:** Android-first, iOS where practical
- **Language:** Dart with null safety
- **Framework:** Flutter (stable channel)

## Architecture

- Feature-first clean architecture
- Pattern: Presentation → Application (state) → Domain → Data
- Repositories abstract all backend access; widgets never call Firebase directly
- Riverpod for dependency injection and state management
- go_router for navigation and role-based routing

## Code Style

- Follow the Dart style guide and Flutter conventions
- Run `flutter format .` before every commit
- Run `flutter analyze` and fix all issues before declaring work complete
- File naming: `snake_case.dart`
- Class naming: `PascalCase`
- Variables and functions: `camelCase`
- Constants: `kCamelCase` or `SCREAMING_SNAKE_CASE` (prefer `kCamelCase`)
- Widget files named after the widget they export
- One public class/widget per file

## State Management

- Use `riverpod` with code generation (`@riverpod`) where practical
- Providers live in their feature's `application/` or `presentation/providers/` layer
- Make async states explicit: loading, data, error — use `AsyncValue`
- Immutable state models; use `copyWith` for updates

## Navigation

- All routes defined in `lib/app/router/`
- Named routes via GoRoute with path and name constants
- Role-aware redirects in the router guard; widgets don't navigate based on role checks
- Deep-link paths must be documented in the router

## Firebase

- Firebase initialization in `lib/app/firebase/`
- Widgets never import `firebase_core`, `cloud_firestore`, `firebase_auth`, or `firebase_storage` directly
- All Firebase access goes through repository classes
- Security rules must be specified before any Firestore read/write is implemented

## Environment and Secrets

- Never commit `google-services.json`, `GoogleService-Info.plist`, `.env`, or any file containing API keys
- Document required environment variables in `.env.example`
- Use `--dart-define` or `flutter_dotenv` for compile-time config
- `.gitignore` must cover all secret files before the first commit

## Testing

- Unit tests for domain logic, repositories, and controllers
- Widget tests for key screens
- Test files mirror the `lib/` structure under `test/`
- Mocks generated with `mockito` or `mocktail`
- Tests must pass before a feature is declared complete

## Specification Workflow

- Spec files live in `.kiro/specs/<spec_name>/`
- Each spec contains: `requirements.md`, `design.md`, `tasks.md`
- No implementation until the spec is explicitly approved
- Deadline placeholder: `[DD-MMM-YYYY]`

## Naming Conventions for Features

- `auth` — authentication and session
- `notices` — notice feed, details, read tracking
- `admin` — admin notice management
- `search` — search and filters
- `notifications` — push notifications and in-app history
- `bookmarks` — bookmark management
- `profile` — user profile and settings
- `smart_features` — AI-assisted notice analysis
