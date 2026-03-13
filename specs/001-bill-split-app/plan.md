# Implementation Plan: Smart Bill Splitting App

**Branch**: `001-bill-split-app` | **Date**: 2026-03-13 | **Spec**: [spec.md](file:///c:/Users/pablo/Desktop/flutter%20projects/shellapay/specs/001-bill-split-app/spec.md)
**Input**: Feature specification from `/specs/001-bill-split-app/spec.md`

## Summary

Build a Flutter mobile app that lets users photograph restaurant receipts, extract items via on-device OCR + server-side AI parsing, assign items to friends via drag-and-drop with physics animations, and share the split results via WhatsApp or push notifications. The backend is Supabase (PostgreSQL, Auth, Edge Functions, Storage) with FCM for push.

## Technical Context

**Language/Version**: Dart ≥ 3.4, Flutter ≥ 3.22
**Primary Dependencies**: flutter_bloc, freezed, dartz, get_it, injectable, supabase_flutter, google_mlkit_text_recognition, firebase_messaging, flutter_contacts, share_plus, screenshot, flutter_animate
**Storage**: Supabase PostgreSQL with RLS; Supabase Storage for avatars and receipt images
**Testing**: flutter_test, bloc_test, mocktail
**Target Platform**: iOS 14+ and Android API 23+
**Project Type**: Mobile app (cross-platform Flutter)
**Performance Goals**: 60 fps drag-and-drop animations, < 3s cold start, < 10s scan-to-review
**Constraints**: OCR must work offline; AI parsing requires network; client-side image generation
**Scale/Scope**: ~12 screens, ~8 BLoCs, 9 database tables, 3 Edge Functions

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Clean Architecture + Feature-First | ✅ PASS | Project structure uses `lib/features/` with data/domain/presentation per feature |
| II. Supabase-Powered Backend | ✅ PASS | All auth, DB, storage, and edge functions use Supabase |
| III. AI-Driven Data Pipeline | ✅ PASS | ML Kit OCR (on-device) → Edge Function AI parser → Review Screen |
| IV. Interactive-First UX | ✅ PASS | Spring physics, haptics, number counter animations, dark mode planned |
| V. Growth & Network Effects | ✅ PASS | WhatsApp share image + FCM push notifications designed |

**Post-Phase 1 re-check**: All principles remain compliant. No violations to track.

## Project Structure

### Documentation (this feature)

```text
specs/001-bill-split-app/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── edge-functions.md
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── constants/           # App-wide constants, theme, colors
│   ├── error/               # Failure classes, exceptions
│   ├── network/             # Supabase client, network info
│   ├── utils/               # Extensions, helpers, formatters
│   ├── di/                  # GetIt service locator setup
│   └── widgets/             # Shared reusable widgets
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/ # Supabase Auth data source
│   │   │   ├── models/      # UserModel (DTO)
│   │   │   └── repositories/ # AuthRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/    # User entity
│   │   │   ├── repositories/ # AuthRepository interface
│   │   │   └── usecases/    # SignInWithOtp, VerifyOtp, GetCurrentUser
│   │   └── presentation/
│   │       ├── bloc/        # AuthBloc
│   │       ├── pages/       # LoginPage, OtpPage, ProfileSetupPage
│   │       └── widgets/     # PhoneInput, OtpInput, AvatarPicker
│   ├── onboarding/
│   │   └── presentation/
│   │       ├── bloc/        # OnboardingCubit (simple state)
│   │       ├── pages/       # WalkthroughPage, TutorialPage
│   │       └── widgets/     # WalkthroughSlide, TutorialOverlay
│   ├── scan/
│   │   ├── data/
│   │   │   ├── datasources/ # CameraDataSource, OcrDataSource, AiParserRemoteDataSource
│   │   │   ├── models/      # ReceiptItemModel
│   │   │   └── repositories/ # ScanRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/    # ReceiptItem
│   │   │   ├── repositories/ # ScanRepository
│   │   │   └── usecases/    # ScanReceipt, ParseReceipt
│   │   └── presentation/
│   │       ├── bloc/        # ScanBloc
│   │       ├── pages/       # CameraPage
│   │       └── widgets/     # CameraOverlay, GuideFrame
│   ├── review/
│   │   ├── data/            # (uses scan domain entities)
│   │   └── presentation/
│   │       ├── bloc/        # ReviewBloc
│   │       ├── pages/       # ReviewPage
│   │       └── widgets/     # EditableItemCard, TaxServiceInput
│   ├── split/
│   │   ├── data/
│   │   │   ├── datasources/ # OutingRemoteDataSource
│   │   │   ├── models/      # OutingModel, ItemSplitModel
│   │   │   └── repositories/ # SplitRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/    # Outing, ItemSplit
│   │   │   ├── repositories/ # SplitRepository
│   │   │   └── usecases/    # AssignItem, SplitItem, CalculateTotals, SaveOuting
│   │   └── presentation/
│   │       ├── bloc/        # SplitBloc
│   │       ├── pages/       # SplitPage
│   │       └── widgets/     # DraggableItemCard, FriendDropTarget, SplitItemDialog
│   ├── results/
│   │   └── presentation/
│   │       ├── bloc/        # ResultBloc
│   │       ├── pages/       # ResultsPage
│   │       └── widgets/     # PersonShareCard, ShareImageBuilder
│   ├── contacts/
│   │   ├── data/
│   │   │   ├── datasources/ # ContactLocalDataSource (device), ContactRemoteDataSource (Supabase)
│   │   │   ├── models/      # ContactModel, GroupModel
│   │   │   └── repositories/ # ContactRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/    # Contact, Group
│   │   │   ├── repositories/ # ContactRepository
│   │   │   └── usecases/    # ImportContacts, CreateGroup, DiscoverUsers
│   │   └── presentation/
│   │       ├── bloc/        # ContactsBloc
│   │       ├── pages/       # ContactsPage, GroupDetailPage
│   │       └── widgets/     # ContactListTile, GroupCard, AddFriendSheet
│   ├── notifications/
│   │   ├── data/
│   │   │   ├── datasources/ # NotificationRemoteDataSource
│   │   │   └── repositories/ # NotificationRepositoryImpl
│   │   ├── domain/
│   │   │   ├── repositories/ # NotificationRepository
│   │   │   └── usecases/    # SendSplitNotification, RegisterFcmToken
│   │   └── presentation/
│   │       └── bloc/        # NotificationBloc
│   └── history/
│       ├── data/
│       │   ├── datasources/ # HistoryRemoteDataSource
│       │   ├── models/      # OutingSummaryModel
│       │   └── repositories/ # HistoryRepositoryImpl
│       ├── domain/
│       │   ├── entities/    # OutingSummary
│       │   ├── repositories/ # HistoryRepository
│       │   └── usecases/    # GetOutings, GetOutingDetail
│       └── presentation/
│           ├── bloc/        # HistoryBloc
│           ├── pages/       # HistoryPage, OutingDetailPage
│           └── widgets/     # OutingCard, DebtStatusBadge
├── app.dart                 # MaterialApp, routing, theme
└── main.dart                # Entry point, DI init

supabase/
├── migrations/              # SQL migration files
└── functions/
    ├── parse-receipt/       # Edge Function: OCR text → JSON items
    ├── send-notification/   # Edge Function: FCM push
    └── discover-users/      # Edge Function: phone hash lookup

test/
├── features/
│   ├── auth/
│   ├── scan/
│   ├── split/
│   └── ...
└── core/
```

**Structure Decision**: Flutter mobile app with feature-first Clean Architecture.
Each of the 8 features (auth, onboarding, scan, review, split, results, contacts,
notifications, history) follows the data/domain/presentation layering.
Backend logic is isolated in 3 Supabase Edge Functions. Database migrations
live in `supabase/migrations/`.

## Complexity Tracking

> No Constitution Check violations — no complexity justifications needed.
