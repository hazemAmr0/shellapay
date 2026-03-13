# Research: Smart Bill Splitting App

**Feature**: `001-bill-split-app`
**Date**: 2026-03-13

## R1: Flutter Drag & Drop with Physics Animations

**Decision**: Use Flutter's built-in `Draggable` + `DragTarget` combined with `flutter_animate` and custom `SpringSimulation` via `AnimationController`.

**Rationale**: Flutter's native drag-and-drop system handles hit testing and gesture routing. For spring physics, `SpringSimulation` from `physics.dart` integrates directly with `AnimationController`. The `flutter_animate` package adds declarative animation chaining (fade, scale, slide) with minimal boilerplate.

**Alternatives considered**:
- **flame** (game engine): Overkill for UI-only animations; adds large dependency.
- **rive**: Great for designed animations but not suitable for physics-driven runtime interactions.
- **Custom GestureDetector + Transform**: Works but requires reimplementing drag-and-drop state management that `Draggable`/`DragTarget` already handle.

---

## R2: Google ML Kit Text Recognition v2 — Arabic Support

**Decision**: Use `google_mlkit_text_recognition` (v2) with `script: TextRecognitionScript.devanagari` is not needed — the default Latin script model handles English, and the `TextRecognitionScript.chinese` or `TextRecognitionScript.japanese` are also not needed. For Arabic, use the default model which auto-detects Arabic script as of ML Kit v2.

**Rationale**: ML Kit v2's default model supports Arabic and English natively on-device, zero network cost, ~20 MB model download on first use (cached). Recognized `TextBlock` objects include `text`, `boundingBox`, `recognizedLanguages`, and `lines`.

**Alternatives considered**:
- **Tesseract OCR (via flutter_tesseract_ocr)**: Lower accuracy for Arabic, larger model, no active Flutter maintenance.
- **AWS Textract / Google Cloud Vision**: High accuracy but requires network, per-request cost, and API key management.

---

## R3: AI Parsing — Receipt JSON Extraction

**Decision**: Use a Supabase Edge Function that proxies the request to an AI model API (e.g., Gemini, OpenAI, or Claude) with a fixed prompt template. The Edge Function holds the API key server-side.

**Rationale**: Keeps API keys off the mobile client. Edge Functions run on Deno, are free for up to 500K invocations/month on Supabase Pro, and deploy with `supabase functions deploy`. The fixed prompt is: _"You are an assistant for extracting data from restaurant receipts. Extract item names and prices accurately, ignoring phone numbers, addresses, and non-useful words. Return the result in JSON exclusively in this format: [{"item": "item name", "price": price}]."_

**Alternatives considered**:
- **Client-side model (TensorFlow Lite)**: Would avoid network dependency but model quality for structured extraction is significantly lower.
- **Direct API call from client**: Exposes API key in the app binary, which is a security risk.

---

## R4: Supabase Auth — Phone OTP

**Decision**: Use Supabase Auth with phone provider. Supabase provides `supabase.auth.signInWithOtp(phone:)` which sends an SMS OTP. Verify with `supabase.auth.verifyOTP(phone:, token:, type: OtpType.sms)`.

**Rationale**: Native Supabase feature, no additional service needed. SMS delivery is handled by Supabase's integrated Twilio backend (or custom SMS provider on Pro plan). The `supabase_flutter` package provides the Dart client.

**Alternatives considered**:
- **Firebase Auth**: Would require dual backend (Firebase + Supabase), adding complexity.
- **Custom OTP service**: Unnecessary when Supabase provides this out of the box.

---

## R5: Push Notifications Architecture

**Decision**: Use Firebase Cloud Messaging (FCM) for push notifications. Store FCM tokens in the Supabase `users` table. Trigger notifications from a Supabase Edge Function (or database webhook) when a new debt record is created.

**Rationale**: FCM is the industry standard for cross-platform push. The `firebase_messaging` Flutter package is mature. The notification trigger flow: Insert into `debts` table → Supabase database webhook → Edge Function → FCM API.

**Alternatives considered**:
- **OneSignal**: Good alternative but adds another third-party dependency. FCM is free and directly supported.
- **Supabase Realtime only**: Good for in-app but doesn't wake the app from background.

---

## R6: Shareable Image Generation

**Decision**: Use the `screenshot` Flutter package to capture a custom-designed widget as an image (PNG). The widget is a `RepaintBoundary`-wrapped summary card rendered off-screen. Share via `share_plus` package which supports WhatsApp intent.

**Rationale**: Client-side rendering avoids server costs and latency. The `screenshot` package captures any widget tree to `Uint8List`, which can be saved to temp storage and shared. `share_plus` handles platform-specific share sheets including WhatsApp.

**Alternatives considered**:
- **Server-side rendering (Puppeteer/Canvas)**: Adds server cost, latency, and complexity for what is essentially a styled card.
- **PDF generation**: Less shareable on WhatsApp; images are preferred.

---

## R7: Contact Import & User Discovery

**Decision**: Use `flutter_contacts` package to read device contacts (with permission). For user discovery, hash phone numbers client-side (SHA-256) and query Supabase for matching hashes.

**Rationale**: Phone number hashing preserves privacy — raw numbers are never sent to the server for discovery. The `flutter_contacts` package supports both iOS and Android with a unified API.

**Alternatives considered**:
- **Sending raw phone numbers**: Privacy concern — violates data minimization principle.
- **Contacts syncing to server**: Unnecessary for v1; client-side matching is sufficient.

---

## R8: State Management Architecture

**Decision**: Feature-scoped BLoCs with Freezed states and Dartz `Either`. One BLoC per screen or logical unit:
- `AuthBloc` — registration, OTP verification, session management
- `ScanBloc` — camera capture, OCR processing, AI parsing
- `ReviewBloc` — item editing, tax/service management
- `SplitBloc` — drag-and-drop assignment, item splitting, total calculation
- `ResultBloc` — summary generation, image creation, sharing
- `ContactsBloc` — contact import, group management
- `HistoryBloc` — outing list, detail view
- `OnboardingCubit` — walkthrough and tutorial state (simpler, uses Cubit)

**Rationale**: Feature-scoped BLoCs prevent god-objects and align with the Clean Architecture + Feature-First constitution principle. Cubits are used for simple state (onboarding) where event-driven logic is unnecessary.

**Alternatives considered**:
- **Single global BLoC**: Violates Clean Architecture and would become unmaintainable.
- **Riverpod**: Strong alternative but constitution mandates `flutter_bloc`.
