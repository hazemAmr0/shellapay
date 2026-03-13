# Tasks: Smart Bill Splitting App

**Input**: Design documents from `/specs/001-bill-split-app/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are NOT explicitly requested in the spec. Test tasks are omitted. Add them later via `/speckit.checklist` if needed.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization, Flutter scaffolding, and dependency setup

- [x] T001 Initialize Flutter project with `flutter create` and configure `pubspec.yaml` with all dependencies (flutter_bloc, freezed, dartz, get_it, injectable, supabase_flutter, google_mlkit_text_recognition, firebase_messaging, flutter_contacts, share_plus, screenshot, flutter_animate, image_picker)
- [x] T002 [P] Create core directory structure: `lib/core/constants/`, `lib/core/error/`, `lib/core/network/`, `lib/core/utils/`, `lib/core/di/`, `lib/core/widgets/`
- [x] T003 [P] Create feature directory structure for all 9 features (auth, onboarding, scan, review, split, results, contacts, notifications, history) with data/domain/presentation subdirectories per plan.md
- [x] T004 [P] Configure analysis_options.yaml with flutter_lints rules and dart format settings
- [x] T005 [P] Create `.env` file template and add `flutter_dotenv` for environment variable loading (SUPABASE_URL, SUPABASE_ANON_KEY)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T006 Implement base `Failure` classes (ServerFailure, CacheFailure, NetworkFailure, ValidationFailure) in `lib/core/error/failures.dart`
- [x] T007 [P] Implement base `Exception` classes (ServerException, CacheException) in `lib/core/error/exceptions.dart`
- [x] T008 [P] Implement `UseCase<Type, Params>` abstract class with `Either<Failure, Type>` return in `lib/core/usecases/usecase.dart`
- [x] T009 [P] Implement `NetworkInfo` class for connectivity checking in `lib/core/network/network_info.dart`
- [x] T010 Implement Supabase client initialization and singleton in `lib/core/network/supabase_client.dart` using flutter_dotenv for URL and anon key
- [x] T011 [P] Create app-wide constants (colors, gradients, spacing, border radius) in `lib/core/constants/app_colors.dart` and `lib/core/constants/app_theme.dart` — dark mode with neon/gradient accents
- [x] T012 [P] Create `AppTheme` with dark mode `ThemeData` (card-based layout, rounded corners, shadows) in `lib/core/constants/app_theme.dart`
- [x] T013 Configure GetIt service locator root in `lib/core/di/injection_container.dart` with initialization function `initDependencies()`
- [x] T014 Create Supabase database migration files for all 9 tables (users, contacts, groups, group_members, outings, outing_participants, receipt_items, item_splits, debts) with RLS policies and indexes in `supabase/migrations/`
- [x] T015 [P] Create Supabase storage buckets (avatars: public read/owner write, receipts: owner read/write) in migration SQL
- [x] T016 Create `app.dart` with `MaterialApp`, `GoRouter` or named route setup, and `AppTheme` in `lib/app.dart`
- [x] T017 Create `main.dart` entry point that initializes Supabase, Firebase, DI container, and runs the app in `lib/main.dart`

**Checkpoint**: Foundation ready — user story implementation can now begin

---

## Phase 3: User Story 1 — Scan & Review a Receipt (Priority: P1) 🎯 MVP

**Goal**: Users can photograph a receipt, extract items via OCR + AI parsing, review/edit on a Review Screen, and add tax/service.

**Independent Test**: Photograph a receipt → see items on Review Screen → edit → add tax → confirm. No friends or sharing needed.

### Implementation for User Story 1

- [ ] T018 [P] [US1] Create `ReceiptItem` entity (item_name, price) in `lib/features/scan/domain/entities/receipt_item.dart`
- [ ] T019 [P] [US1] Create `ReceiptItemModel` (toJson, fromJson, toDomain) in `lib/features/scan/data/models/receipt_item_model.dart`
- [ ] T020 [US1] Create `ScanRepository` interface (scanReceipt, parseReceipt) in `lib/features/scan/domain/repositories/scan_repository.dart`
- [ ] T021 [P] [US1] Create `ScanReceipt` use case in `lib/features/scan/domain/usecases/scan_receipt.dart`
- [ ] T022 [P] [US1] Create `ParseReceipt` use case in `lib/features/scan/domain/usecases/parse_receipt.dart`
- [ ] T023 [US1] Implement `OcrDataSource` using google_mlkit_text_recognition (on-device, Arabic+English) in `lib/features/scan/data/datasources/ocr_data_source.dart`
- [ ] T024 [US1] Implement `AiParserRemoteDataSource` that calls Supabase Edge Function `parse-receipt` in `lib/features/scan/data/datasources/ai_parser_remote_data_source.dart`
- [ ] T025 [US1] Implement `ScanRepositoryImpl` (orchestrate OCR → AI parser → map to entities, handle offline/errors) in `lib/features/scan/data/repositories/scan_repository_impl.dart`
- [ ] T026 [US1] Deploy `parse-receipt` Supabase Edge Function in `supabase/functions/parse-receipt/index.ts` — accepts raw_text, calls AI API with fixed prompt, returns JSON items
- [ ] T027 [US1] Implement `ScanBloc` (events: StartScan, ProcessImage; states: Initial, Scanning, OcrComplete, Parsing, Parsed, Error) in `lib/features/scan/presentation/bloc/scan_bloc.dart`
- [ ] T028 [US1] Create `CameraPage` with guided overlay frame using `image_picker` or `camera` package in `lib/features/scan/presentation/pages/camera_page.dart`
- [ ] T029 [US1] Create `CameraOverlay` widget with guide frame for receipt alignment in `lib/features/scan/presentation/widgets/camera_overlay.dart`
- [ ] T030 [US1] Implement `ReviewBloc` (events: EditItem, AddItem, RemoveItem, SetTax, SetService, Confirm; states with editable items list) in `lib/features/review/presentation/bloc/review_bloc.dart`
- [ ] T031 [US1] Create `ReviewPage` displaying extracted items with inline editing, tax/service fields, and confirm button in `lib/features/review/presentation/pages/review_page.dart`
- [ ] T032 [P] [US1] Create `EditableItemCard` widget (tap to edit name/price, delete button) in `lib/features/review/presentation/widgets/editable_item_card.dart`
- [ ] T033 [P] [US1] Create `TaxServiceInput` widget (fields for tax and service amounts) in `lib/features/review/presentation/widgets/tax_service_input.dart`
- [ ] T034 [US1] Create `ManualEntryForm` widget for fallback when OCR/AI fails (add items manually) in `lib/features/review/presentation/widgets/manual_entry_form.dart`
- [ ] T035 [US1] Register US1 dependencies (data sources, repository, use cases, blocs) in `lib/core/di/injection_container.dart`

**Checkpoint**: User can scan a receipt, see extracted items, edit them, add tax/service, and confirm — fully functional and testable independently

---

## Phase 4: User Story 2 — Split Items Among Friends via Drag & Drop (Priority: P1) 🎯 MVP

**Goal**: After reviewing, user adds friends and assigns items via drag-and-drop with physics animations, including split-item support and proportional tax distribution.

**Independent Test**: Add friends manually → drag items to assign → split a shared item → see calculated totals with tax distributed.

### Implementation for User Story 2

- [ ] T036 [P] [US2] Create `Outing` entity (place_name, total, tax, service, status, items, participants) in `lib/features/split/domain/entities/outing.dart`
- [ ] T037 [P] [US2] Create `ItemSplit` entity (item, contact, percentage, amount) in `lib/features/split/domain/entities/item_split.dart`
- [ ] T038 [P] [US2] Create `Contact` entity (id, name, phone, avatar, registeredUserId) in `lib/features/contacts/domain/entities/contact.dart`
- [ ] T039 [P] [US2] Create `OutingModel`, `ItemSplitModel` (toJson, fromJson, toDomain) in `lib/features/split/data/models/`
- [ ] T040 [US2] Create `SplitRepository` interface (saveOuting, assignItem, splitItem, calculateTotals) in `lib/features/split/domain/repositories/split_repository.dart`
- [ ] T041 [P] [US2] Create `AssignItem` use case in `lib/features/split/domain/usecases/assign_item.dart`
- [ ] T042 [P] [US2] Create `SplitItem` use case in `lib/features/split/domain/usecases/split_item.dart`
- [ ] T043 [P] [US2] Create `CalculateTotals` use case (proportional tax/service distribution) in `lib/features/split/domain/usecases/calculate_totals.dart`
- [ ] T044 [P] [US2] Create `SaveOuting` use case in `lib/features/split/domain/usecases/save_outing.dart`
- [ ] T045 [US2] Implement `OutingRemoteDataSource` (CRUD outings, items, splits to Supabase) in `lib/features/split/data/datasources/outing_remote_data_source.dart`
- [ ] T046 [US2] Implement `SplitRepositoryImpl` in `lib/features/split/data/repositories/split_repository_impl.dart`
- [ ] T047 [US2] Implement `SplitBloc` (events: AddFriend, RemoveFriend, DragItem, DropItem, SplitItemAmong, Calculate; states with assignments map and running totals) in `lib/features/split/presentation/bloc/split_bloc.dart`
- [ ] T048 [US2] Create `SplitPage` with friend avatars at top, draggable item cards in the middle, and running totals in `lib/features/split/presentation/pages/split_page.dart`
- [ ] T049 [US2] Create `DraggableItemCard` widget with spring physics animation (Draggable + SpringSimulation) and haptic feedback on drag start in `lib/features/split/presentation/widgets/draggable_item_card.dart`
- [ ] T050 [US2] Create `FriendDropTarget` widget with absorption animation effect (DragTarget + scale/fade animation on drop, number counter animation for total update) in `lib/features/split/presentation/widgets/friend_drop_target.dart`
- [ ] T051 [US2] Create `SplitItemDialog` widget for dividing one item among multiple people (equal split or custom percentage) in `lib/features/split/presentation/widgets/split_item_dialog.dart`
- [ ] T052 [US2] Create `AddFriendSheet` bottom sheet for adding friends by name (manual entry for now; contacts integration in US5) in `lib/features/split/presentation/widgets/add_friend_sheet.dart`
- [ ] T053 [US2] Register US2 dependencies (data sources, repository, use cases, blocs) in `lib/core/di/injection_container.dart`

**Checkpoint**: User can add friends, drag items to assign, split shared items, see proportional tax distributed — fully functional and testable independently

---

## Phase 5: User Story 3 — Onboarding & First-Time Experience (Priority: P2)

**Goal**: New users see a 3-screen walkthrough, register via OTP, set up profile, see contact permission rationale, and complete a tutorial.

**Independent Test**: Launch fresh → walkthrough → register with phone → set name/avatar → permission screen → tutorial with dummy receipt.

### Implementation for User Story 3

- [ ] T054 [P] [US3] Create `User` entity (id, fullName, phone, avatarUrl) in `lib/features/auth/domain/entities/user.dart`
- [ ] T055 [P] [US3] Create `UserModel` (toJson, fromJson, toDomain) in `lib/features/auth/data/models/user_model.dart`
- [ ] T056 [US3] Create `AuthRepository` interface (signInWithOtp, verifyOtp, getCurrentUser, updateProfile, signOut) in `lib/features/auth/domain/repositories/auth_repository.dart`
- [ ] T057 [P] [US3] Create `SignInWithOtp` use case in `lib/features/auth/domain/usecases/sign_in_with_otp.dart`
- [ ] T058 [P] [US3] Create `VerifyOtp` use case in `lib/features/auth/domain/usecases/verify_otp.dart`
- [ ] T059 [P] [US3] Create `UpdateProfile` use case in `lib/features/auth/domain/usecases/update_profile.dart`
- [ ] T060 [US3] Implement `AuthRemoteDataSource` using supabase_flutter auth methods in `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- [ ] T061 [US3] Implement `AuthRepositoryImpl` in `lib/features/auth/data/repositories/auth_repository_impl.dart`
- [ ] T062 [US3] Implement `AuthBloc` (events: SendOtp, VerifyOtp, SaveProfile, CheckSession; states: Unauthenticated, OtpSent, Verifying, Authenticated, ProfileIncomplete, Error) in `lib/features/auth/presentation/bloc/auth_bloc.dart`
- [ ] T063 [US3] Create `LoginPage` with phone number input and send OTP button in `lib/features/auth/presentation/pages/login_page.dart`
- [ ] T064 [US3] Create `OtpPage` with 6-digit code input and verify button in `lib/features/auth/presentation/pages/otp_page.dart`
- [ ] T065 [US3] Create `ProfileSetupPage` with name field and avatar picker (camera/gallery) in `lib/features/auth/presentation/pages/profile_setup_page.dart`
- [ ] T066 [US3] Implement `OnboardingCubit` (track current page, skip, complete) in `lib/features/onboarding/presentation/bloc/onboarding_cubit.dart`
- [ ] T067 [US3] Create `WalkthroughPage` with 3 slides (Scan, Split, Share) using PageView, skip button, and page indicators in `lib/features/onboarding/presentation/pages/walkthrough_page.dart`
- [ ] T068 [P] [US3] Create `WalkthroughSlide` widget (illustration + title + subtitle) in `lib/features/onboarding/presentation/widgets/walkthrough_slide.dart`
- [ ] T069 [US3] Create `PermissionExplanationPage` with custom UI explaining contact access benefits and proceed/skip buttons in `lib/features/onboarding/presentation/pages/permission_explanation_page.dart`
- [ ] T070 [US3] Create `TutorialPage` with dummy receipt data and fake friends for drag-and-drop practice in `lib/features/onboarding/presentation/pages/tutorial_page.dart`
- [ ] T071 [US3] Implement auth guard / route redirect logic: if not authenticated → walkthrough → login; if no profile → profile setup in `lib/app.dart`
- [ ] T072 [US3] Register US3 dependencies (data sources, repository, use cases, blocs, cubit) in `lib/core/di/injection_container.dart`

**Checkpoint**: Full onboarding flow works end-to-end: walkthrough → OTP login → profile → permissions → tutorial

---

## Phase 6: User Story 4 — Share Results via WhatsApp (Priority: P2)

**Goal**: After splitting, generate a professional summary image and share via WhatsApp.

**Independent Test**: View results → generate image → share to WhatsApp with image attached.

### Implementation for User Story 4

- [ ] T073 [US4] Implement `ResultBloc` (events: LoadResults, GenerateImage, Share; states with per-person totals and generated image) in `lib/features/results/presentation/bloc/result_bloc.dart`
- [ ] T074 [US4] Create `ResultsPage` showing each person's name/total with "Share" button in `lib/features/results/presentation/pages/results_page.dart`
- [ ] T075 [US4] Create `PersonShareCard` widget (avatar, name, items list, subtotal, tax share, total) in `lib/features/results/presentation/widgets/person_share_card.dart`
- [ ] T076 [US4] Create `ShareImageBuilder` widget — a styled card layout (dark bg, neon accents, restaurant name, per-person breakdown, app download link) rendered off-screen for screenshot capture in `lib/features/results/presentation/widgets/share_image_builder.dart`
- [ ] T077 [US4] Implement image generation using `screenshot` package (RepaintBoundary → Uint8List → temp file) in `lib/features/results/presentation/bloc/result_bloc.dart`
- [ ] T078 [US4] Implement WhatsApp sharing via `share_plus` package (shareXFiles with image path) in `lib/features/results/presentation/bloc/result_bloc.dart`
- [ ] T079 [US4] Register US4 dependencies in `lib/core/di/injection_container.dart`

**Checkpoint**: User can view per-person results, generate a branded image, and share to WhatsApp

---

## Phase 7: User Story 5 — Manage Contacts & Groups (Priority: P3)

**Goal**: Import phone contacts, create groups, and add groups to splits with one tap.

**Independent Test**: Import contacts → create group → add members → select group when starting a split.

### Implementation for User Story 5

- [ ] T080 [P] [US5] Create `ContactModel` (toJson, fromJson, toDomain) in `lib/features/contacts/data/models/contact_model.dart`
- [ ] T081 [P] [US5] Create `Group` entity (id, name, members) in `lib/features/contacts/domain/entities/group.dart`
- [ ] T082 [P] [US5] Create `GroupModel` (toJson, fromJson, toDomain) in `lib/features/contacts/data/models/group_model.dart`
- [ ] T083 [US5] Create `ContactRepository` interface (importContacts, getContacts, createGroup, getGroups, addMemberToGroup, discoverUsers) in `lib/features/contacts/domain/repositories/contact_repository.dart`
- [ ] T084 [P] [US5] Create `ImportContacts` use case in `lib/features/contacts/domain/usecases/import_contacts.dart`
- [ ] T085 [P] [US5] Create `CreateGroup` use case in `lib/features/contacts/domain/usecases/create_group.dart`
- [ ] T086 [P] [US5] Create `DiscoverUsers` use case in `lib/features/contacts/domain/usecases/discover_users.dart`
- [ ] T087 [US5] Implement `ContactLocalDataSource` using flutter_contacts to read device contacts in `lib/features/contacts/data/datasources/contact_local_data_source.dart`
- [ ] T088 [US5] Implement `ContactRemoteDataSource` (CRUD contacts/groups in Supabase, call discover-users Edge Function) in `lib/features/contacts/data/datasources/contact_remote_data_source.dart`
- [ ] T089 [US5] Deploy `discover-users` Supabase Edge Function in `supabase/functions/discover-users/index.ts` — accepts phone_hashes array, returns matching registered users
- [ ] T090 [US5] Implement `ContactRepositoryImpl` (import from device, sync to Supabase, discover registered users via phone hash) in `lib/features/contacts/data/repositories/contact_repository_impl.dart`
- [ ] T091 [US5] Implement `ContactsBloc` (events: LoadContacts, ImportFromDevice, CreateGroup, SelectGroupForSplit; states with contacts list, groups list) in `lib/features/contacts/presentation/bloc/contacts_bloc.dart`
- [ ] T092 [US5] Create `ContactsPage` with tabs for All Contacts and Groups in `lib/features/contacts/presentation/pages/contacts_page.dart`
- [ ] T093 [US5] Create `GroupDetailPage` for viewing/editing group members in `lib/features/contacts/presentation/pages/group_detail_page.dart`
- [ ] T094 [P] [US5] Create `ContactListTile` widget in `lib/features/contacts/presentation/widgets/contact_list_tile.dart`
- [ ] T095 [P] [US5] Create `GroupCard` widget in `lib/features/contacts/presentation/widgets/group_card.dart`
- [ ] T096 [US5] Update `AddFriendSheet` (from US2) to support selecting from imported contacts and groups in `lib/features/split/presentation/widgets/add_friend_sheet.dart`
- [ ] T097 [US5] Register US5 dependencies in `lib/core/di/injection_container.dart`

**Checkpoint**: User can import contacts, create groups, and select groups when starting a split

---

## Phase 8: User Story 6 — Push Notifications to Registered Friends (Priority: P3)

**Goal**: After a split, registered friends automatically receive push notifications with their owed amount.

**Independent Test**: Complete a split with a registered friend → friend receives FCM push notification with amount and restaurant name.

### Implementation for User Story 6

- [ ] T098 [US6] Create `NotificationRepository` interface (registerToken, sendSplitNotification) in `lib/features/notifications/domain/repositories/notification_repository.dart`
- [ ] T099 [P] [US6] Create `RegisterFcmToken` use case in `lib/features/notifications/domain/usecases/register_fcm_token.dart`
- [ ] T100 [P] [US6] Create `SendSplitNotification` use case in `lib/features/notifications/domain/usecases/send_split_notification.dart`
- [ ] T101 [US6] Implement `NotificationRemoteDataSource` (register/update FCM token in users table, call send-notification Edge Function) in `lib/features/notifications/data/datasources/notification_remote_data_source.dart`
- [ ] T102 [US6] Deploy `send-notification` Supabase Edge Function in `supabase/functions/send-notification/index.ts` — looks up FCM token, sends FCM message with amount and restaurant name
- [ ] T103 [US6] Implement `NotificationRepositoryImpl` in `lib/features/notifications/data/repositories/notification_repository_impl.dart`
- [ ] T104 [US6] Implement `NotificationBloc` (events: RegisterToken, SendNotifications; states) in `lib/features/notifications/presentation/bloc/notification_bloc.dart`
- [ ] T105 [US6] Configure Firebase Messaging in `main.dart` — request permission, get token, register via bloc on app start
- [ ] T106 [US6] Integrate notification sending into split completion flow — after saving outing, trigger notifications for registered friends in `lib/features/split/presentation/bloc/split_bloc.dart`
- [ ] T107 [US6] Register US6 dependencies in `lib/core/di/injection_container.dart`

**Checkpoint**: Registered friends receive push notifications with their share after a split is completed

---

## Phase 9: User Story 7 — View Outing History (Priority: P3)

**Goal**: Users can browse past outings with details (restaurant, date, totals, per-person breakdown, payment status).

**Independent Test**: User with past splits → see history list → tap to view details with per-person shares and paid/unpaid status.

### Implementation for User Story 7

- [ ] T108 [P] [US7] Create `OutingSummary` entity (id, placeName, date, total, participantCount) in `lib/features/history/domain/entities/outing_summary.dart`
- [ ] T109 [P] [US7] Create `OutingSummaryModel` in `lib/features/history/data/models/outing_summary_model.dart`
- [ ] T110 [US7] Create `HistoryRepository` interface (getOutings, getOutingDetail, markDebtPaid) in `lib/features/history/domain/repositories/history_repository.dart`
- [ ] T111 [P] [US7] Create `GetOutings` use case in `lib/features/history/domain/usecases/get_outings.dart`
- [ ] T112 [P] [US7] Create `GetOutingDetail` use case in `lib/features/history/domain/usecases/get_outing_detail.dart`
- [ ] T113 [US7] Implement `HistoryRemoteDataSource` (query outings with participants, items, debts from Supabase) in `lib/features/history/data/datasources/history_remote_data_source.dart`
- [ ] T114 [US7] Implement `HistoryRepositoryImpl` in `lib/features/history/data/repositories/history_repository_impl.dart`
- [ ] T115 [US7] Implement `HistoryBloc` (events: LoadHistory, LoadDetail, MarkPaid; states with outing list and selected detail) in `lib/features/history/presentation/bloc/history_bloc.dart`
- [ ] T116 [US7] Create `HistoryPage` with reverse-chronological list of outings in `lib/features/history/presentation/pages/history_page.dart`
- [ ] T117 [US7] Create `OutingDetailPage` showing items, per-person shares, and paid/unpaid toggle in `lib/features/history/presentation/pages/outing_detail_page.dart`
- [ ] T118 [P] [US7] Create `OutingCard` widget (place name, date, total, participant avatars) in `lib/features/history/presentation/widgets/outing_card.dart`
- [ ] T119 [P] [US7] Create `DebtStatusBadge` widget (paid/unpaid badge with toggle) in `lib/features/history/presentation/widgets/debt_status_badge.dart`
- [ ] T120 [US7] Register US7 dependencies in `lib/core/di/injection_container.dart`

**Checkpoint**: Full history browsing with detail views and debt status toggling works

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T121 [P] Add loading skeleton widgets for all screens (shimmer effect) in `lib/core/widgets/loading_skeleton.dart`
- [ ] T122 [P] Add reusable error widget with retry action in `lib/core/widgets/error_widget.dart`
- [ ] T123 [P] Add empty state widgets (no history, no contacts, no groups) in `lib/core/widgets/empty_state.dart`
- [ ] T124 Implement Home/Dashboard page with scan button, recent outings, quick stats in `lib/features/split/presentation/pages/home_page.dart`
- [ ] T125 Add bottom navigation bar (Home, Contacts, History, Profile) in `lib/app.dart`
- [ ] T126 Polish all animations: verify 60 fps on drag-and-drop, tune spring constants, test haptic feedback on Android and iOS
- [ ] T127 [P] Add app icon and splash screen using flutter_native_splash and flutter_launcher_icons
- [ ] T128 [P] Add Arabic/English localization support using flutter_localizations and intl
- [ ] T129 Run `flutter analyze` and fix all lint warnings
- [ ] T130 Run quickstart.md verification checklist end-to-end

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational — scan/review core
- **User Story 2 (Phase 4)**: Depends on Foundational — drag-and-drop splitting
- **User Story 3 (Phase 5)**: Depends on Foundational — onboarding/auth
- **User Story 4 (Phase 6)**: Depends on US2 (needs results from split)
- **User Story 5 (Phase 7)**: Depends on Foundational — contacts/groups
- **User Story 6 (Phase 8)**: Depends on US2 + US5 (needs split + contacts with registered users)
- **User Story 7 (Phase 9)**: Depends on US2 (needs saved outings to display)
- **Polish (Phase 10)**: Depends on all desired user stories being complete

### User Story Dependencies

- **US1 (Scan & Review)**: Independent after Foundational
- **US2 (Split via Drag & Drop)**: Independent after Foundational (uses manual friend add)
- **US3 (Onboarding & Auth)**: Independent after Foundational
- **US4 (Share via WhatsApp)**: Requires US2 completed (needs split results)
- **US5 (Contacts & Groups)**: Independent after Foundational
- **US6 (Push Notifications)**: Requires US2 + US5 completed
- **US7 (History)**: Requires US2 completed (needs saved outings)

### Within Each User Story

- Entities/Models before repositories
- Repository interfaces before implementations
- Use cases before BLoCs
- BLoCs before pages
- Pages before widgets (or in parallel if independent)
- Edge Functions deployed before data sources that call them

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel
- After Foundational: US1, US2, US3, and US5 can start in parallel
- Within each story: entities/models marked [P] can run in parallel
- Within each story: use cases marked [P] can run in parallel

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL)
3. Complete Phase 3: User Story 1 (Scan & Review)
4. Complete Phase 4: User Story 2 (Split via Drag & Drop)
5. **STOP and VALIDATE**: Full scan → review → split → results flow works
6. Deploy/demo if ready

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. US1 (Scan & Review) → Core receipt processing works
3. US2 (Split & Drag-Drop) → **MVP! Full flow works end-to-end**
4. US3 (Onboarding & Auth) → Real user registration
5. US4 (WhatsApp Sharing) → Growth engine activated
6. US5 (Contacts & Groups) → Friction reduction for repeat users
7. US6 (Push Notifications) → Network effect enabled
8. US7 (History) → Retention feature
9. Polish → Production-ready

### Parallel Team Strategy

With multiple developers after Foundational:
- Developer A: US1 (Scan & Review)
- Developer B: US2 (Split & Drag-Drop)
- Developer C: US3 (Onboarding & Auth) + US5 (Contacts)

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
