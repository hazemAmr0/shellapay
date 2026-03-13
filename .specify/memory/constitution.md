<!--
  Sync Impact Report
  ===================
  Version change: 0.0.0 → 1.0.0 (MAJOR — initial ratification)
  
  Modified principles: N/A (initial creation)
  
  Added sections:
    - Principle I: Clean Architecture with Feature-First Organization
    - Principle II: Supabase-Powered Backend
    - Principle III: AI-Driven Data Pipeline
    - Principle IV: Interactive-First UX
    - Principle V: Growth & Network Effects
    - Section: Technology Stack & Constraints
    - Section: Development Workflow
    - Section: Governance
  
  Removed sections: N/A (initial creation)
  
  Templates requiring updates:
    ✅ plan-template.md — Constitution Check section aligns with principles
    ✅ spec-template.md — User Scenarios & Requirements sections align
    ✅ tasks-template.md — Phase structure supports feature-first delivery
  
  Follow-up TODOs: None
-->

# ShellaPay Constitution

## Core Principles

### I. Clean Architecture with Feature-First Organization

Every feature MUST follow the three-layer Clean Architecture pattern
(Presentation → Domain → Data) with feature-first directory organization.

- Dependencies MUST always point inward: Presentation → Domain ← Data.
- The Domain layer contains entities, repository interfaces, and use cases.
  It MUST NOT depend on any framework or external package.
- The Data layer implements repository interfaces and contains data sources
  and models. It MUST map data models to domain entities at the boundary.
- The Presentation layer contains BLoC/Cubit state management, pages,
  and widgets. Business logic MUST NOT reside in UI components.
- Shared/cross-cutting code (error handling, networking, utilities, reusable
  widgets) resides in a `core/` directory at the project root.
- Dependency injection MUST use GetIt as a service locator, with
  registrations organized per feature.

**Rationale**: Enforces testability, replaceability, and separation of
concerns across all features of the bill-splitting app.

### II. Supabase-Powered Backend

All server-side persistence, authentication, and real-time capabilities
MUST use Supabase (PostgreSQL).

- Authentication MUST use phone number + OTP via Supabase Auth.
- Database schema MUST follow the relational model defined in the PRD
  (Users, Contacts, Groups, Group_Members, Outings, Receipt_Items,
  Item_Splits, Debts).
- Row-Level Security (RLS) MUST be enabled on every table;
  users MUST only access their own data.
- Real-time subscriptions SHOULD be used for push-style updates
  to in-app notifications and debt status changes.
- Edge Functions SHOULD handle server-side AI parsing calls to keep
  API keys off the client.

**Rationale**: Supabase provides auth, database, real-time, and edge
functions in a single managed platform, reducing operational overhead.

### III. AI-Driven Data Pipeline

Receipt scanning and parsing MUST follow the two-stage pipeline:
(1) on-device OCR, (2) AI-powered JSON extraction.

- Stage 1: Google ML Kit Text Recognition v2 runs on-device for offline
  Arabic+English text extraction. No network call is required.
- Stage 2: Raw OCR text is sent to an AI model API (via Supabase Edge
  Function) with a fixed prompt to produce structured JSON
  (`[{"item": "...", "price": ...}]`).
- The parsed result MUST be presented on a Review Screen where the user
  can edit item names, prices, and add tax/service before proceeding
  to the split screen.
- OCR and AI parsing failures MUST surface user-friendly error messages
  and allow manual item entry as a fallback.

**Rationale**: On-device OCR keeps the app fast and offline-capable;
server-side AI parsing ensures accurate structured extraction without
shipping large models to the client.

### IV. Interactive-First UX

The primary interaction model MUST be drag-and-drop with physics-based
animations, targeting 60 fps on mid-range devices.

- Drag-and-drop MUST use spring physics for smooth item movement and
  an absorption effect when an item is assigned to a person.
- Haptic feedback MUST fire on successful drop and confirmation actions.
- Number counters MUST animate when a person's running total changes.
- The app MUST default to Dark Mode with neon/gradient accent colors.
- Card-based layouts MUST use rounded corners and subtle shadows.
- All interactive states (loading, error, success, empty) MUST be
  explicitly handled in every BLoC.

**Rationale**: The drag-and-drop bill-splitting experience is the app's
core differentiator — smooth, delightful interaction drives retention.

### V. Growth & Network Effects

Every completed bill split MUST produce shareable output and, where
possible, trigger in-app notifications to other registered users.

- A professionally designed summary image MUST be generated containing
  each person's total and a deep link / download link to the app.
- WhatsApp sharing MUST be a primary distribution channel.
- Push notifications MUST be sent to friends who are registered users
  of ShellaPay, informing them of their share amount.
- Contact-list access MUST be requested contextually (with a
  pre-permission explanation screen) to discover existing users and
  enable group creation.

**Rationale**: Viral sharing and network effects are the primary growth
engine — every bill split is an acquisition opportunity.

## Technology Stack & Constraints

| Layer               | Technology                                      |
|---------------------|-------------------------------------------------|
| Framework           | Flutter (Dart)                                  |
| State Management    | flutter_bloc (BLoC + Cubit)                     |
| DI                  | GetIt                                           |
| Error Handling      | Dartz (`Either<Failure, T>`)                    |
| Immutable State     | Freezed                                         |
| Backend / Auth / DB | Supabase (PostgreSQL, Auth, Edge Functions)     |
| OCR                 | Google ML Kit Text Recognition v2 (on-device)   |
| AI Parsing          | Cloud AI model API via Supabase Edge Function   |
| Notifications       | Firebase Cloud Messaging (FCM)                  |
| Target Platforms    | iOS 14+ and Android 6+ (API 23+)                |
| Performance         | 60 fps animations, < 3 s cold start             |
| Offline             | OCR works offline; AI parsing requires network   |

## Development Workflow

1. **Feature branches**: One branch per feature or user story
   (`feat/<feature-name>`).
2. **BLoC-first development**: Define Events and States before building
   UI. States MUST be immutable (Freezed). Use `Either<Failure, T>` for
   all repository return types.
3. **Testing discipline**: Unit tests MUST cover domain use cases and
   BLoC logic. Widget tests SHOULD cover critical UI flows. Integration
   tests SHOULD validate end-to-end user journeys.
4. **Code review gates**: All PRs MUST pass linting (`flutter analyze`),
   formatting (`dart format`), and existing tests before merge.
5. **Commit conventions**: Conventional Commits format
   (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`).

## Governance

- This constitution is the authoritative source of architectural and
  process decisions for ShellaPay. It supersedes informal agreements.
- Amendments MUST be documented with a version bump, rationale, and
  migration plan for any affected code.
- All code reviews MUST verify compliance with the principles above.
- Complexity additions (e.g., new external dependencies, additional
  architectural layers) MUST be justified against the Simplicity
  principle implicit in Clean Architecture.

**Version**: 1.0.0 | **Ratified**: 2026-03-13 | **Last Amended**: 2026-03-13
