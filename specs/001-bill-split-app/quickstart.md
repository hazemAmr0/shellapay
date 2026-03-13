# Quickstart: Smart Bill Splitting App

**Feature**: `001-bill-split-app`
**Date**: 2026-03-13

## Prerequisites

- Flutter SDK ≥ 3.22 (Dart ≥ 3.4)
- A Supabase project with Auth (Phone OTP enabled), Database, Storage, and Edge Functions
- A Firebase project with Cloud Messaging enabled
- An AI model API key (Gemini, OpenAI, or Claude) configured in Supabase Edge Function secrets
- Android Studio or Xcode for platform builds

## Setup Steps

### 1. Clone & Install

```bash
git clone <repo-url>
cd shellapay
flutter pub get
```

### 2. Configure Supabase

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Enable Phone Auth in Authentication → Providers → Phone
3. Copy your project URL and anon key
4. Create `.env` file at project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 3. Run Database Migrations

Apply the SQL migrations in order from `supabase/migrations/` to create:
- Tables: users, contacts, groups, group_members, outings, outing_participants, receipt_items, item_splits, debts
- RLS policies for all tables
- Indexes for performance
- Storage buckets: avatars, receipts

### 4. Deploy Edge Functions

```bash
supabase functions deploy parse-receipt
supabase functions deploy send-notification
```

Set secrets:
```bash
supabase secrets set AI_API_KEY=your-api-key
supabase secrets set FCM_SERVER_KEY=your-fcm-key
```

### 5. Configure Firebase

1. Add Firebase to the Flutter project: `flutterfire configure`
2. Enable Cloud Messaging in the Firebase Console
3. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### 6. Run the App

```bash
flutter run
```

## Verification Checklist

- [ ] App launches with onboarding walkthrough (3 screens)
- [ ] Phone OTP registration works
- [ ] Camera opens with guided overlay
- [ ] OCR extracts text from a receipt
- [ ] AI parsing returns structured items JSON
- [ ] Review screen allows editing items and adding tax
- [ ] Drag-and-drop assigns items to friends with animations
- [ ] Split item divides cost among multiple people
- [ ] Results screen shows per-person totals
- [ ] WhatsApp share generates and shares summary image
- [ ] History screen lists past outings
- [ ] Push notification arrives for registered friends
