# Feature Specification: Smart Bill Splitting App

**Feature Branch**: `001-bill-split-app`
**Created**: 2026-03-13
**Status**: Draft
**Input**: User description: "Smart bill splitting mobile app with OCR receipt scanning, drag-and-drop item assignment, and WhatsApp sharing for group outings"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Scan & Review a Receipt (Priority: P1)

A user takes a photo of a restaurant receipt using the in-app camera. The app reads the text from the receipt and uses AI to extract item names and prices. The user reviews the extracted data on a Review Screen, corrects any mistakes, and adds tax/service charges before moving on.

**Why this priority**: This is the foundational interaction — without accurate receipt data, no splitting can occur. It is the first step in every bill-splitting session.

**Independent Test**: A user can photograph a receipt, see items and prices listed on the Review Screen, edit incorrect entries, add tax/service, and confirm — all without needing friends, groups, or sharing.

**Acceptance Scenarios**:

1. **Given** the user is on the Home screen, **When** they tap the scan button and photograph a receipt, **Then** the app extracts item names and prices and displays them on the Review Screen within 10 seconds.
2. **Given** the Review Screen shows extracted items, **When** the user taps an item name or price, **Then** they can edit the value inline and the total recalculates immediately.
3. **Given** the Review Screen shows extracted items, **When** the user adds a tax/service amount, **Then** the total updates to include the added charges.
4. **Given** the camera fails to read any text, **When** the OCR returns empty results, **Then** the user is shown a friendly error message and offered the option to retake the photo or enter items manually.
5. **Given** the AI parser returns malformed data, **When** parsing fails, **Then** the user is prompted to enter items manually with a clear input form.

---

### User Story 2 - Split Items Among Friends via Drag & Drop (Priority: P1)

After reviewing the receipt, the user adds friends (from contacts or a saved group) and assigns items to people by dragging item cards onto friend avatars. If a dish was shared, the user can split a single item across multiple people.

**Why this priority**: The drag-and-drop splitting is the core differentiator and the "Aha Moment" of the app. Without it, the app has no unique value.

**Independent Test**: A user can add friends manually (by name), drag items to assign them, split a shared item, and see each person's calculated total — all with dummy receipt data.

**Acceptance Scenarios**:

1. **Given** the user has confirmed items on the Review Screen, **When** they proceed to the Split Screen, **Then** they see all items as draggable cards and a section to add friends.
2. **Given** friends are displayed on the Split Screen, **When** the user drags an item card onto a friend's avatar, **Then** the item is assigned to that friend with a spring-physics animation, haptic feedback, and the friend's running total updates with a number counter animation.
3. **Given** an item was shared by two or more people, **When** the user selects "Split Item" on a card, **Then** the app divides the item cost equally (or by custom ratio) among the selected friends.
4. **Given** tax and service charges exist, **When** all items are assigned, **Then** tax/service is proportionally distributed based on each person's subtotal.
5. **Given** all items are assigned, **When** the user taps "Calculate," **Then** a Results Screen displays each person's name and total amount owed.

---

### User Story 3 - Onboarding & First-Time Experience (Priority: P2)

A new user downloads the app and goes through a 3-screen walkthrough that explains the app's value (Scan, Split, Share). They register with their phone number via OTP, set up their profile (name + avatar), see a contextual explanation for contact-list access, and complete a tutorial with a dummy receipt to learn drag-and-drop.

**Why this priority**: Good onboarding drives activation and retention, but the core scanning and splitting must work first.

**Independent Test**: A new user can install, complete the walkthrough, register via OTP, set up a profile, grant or deny contact access, and complete the tutorial — all without a real receipt or real friends.

**Acceptance Scenarios**:

1. **Given** the user opens the app for the first time, **When** the app launches, **Then** a 3-screen walkthrough (Scan → Split → Share) is displayed with skip and next options.
2. **Given** the user finishes the walkthrough, **When** they proceed to registration, **Then** they can enter their phone number, receive an OTP, and verify it to create an account.
3. **Given** the user has verified their phone, **When** they are prompted for profile setup, **Then** they can enter their first name and optionally upload or take a profile photo.
4. **Given** the user has set up their profile, **When** the app requests contact-list access, **Then** a custom explanation screen appears first (before the system permission dialog) describing why access is useful.
5. **Given** onboarding is complete, **When** the tutorial starts, **Then** a dummy receipt with pre-filled items and fake friends is presented so the user can practice drag-and-drop splitting.

---

### User Story 4 - Share Results via WhatsApp (Priority: P2)

After splitting is complete, the user can generate a professionally designed summary image showing each person's share and a link to download the app. They can share this image directly to WhatsApp.

**Why this priority**: Sharing is the primary growth engine. Every share is a potential new user acquisition.

**Independent Test**: A user can view the results, generate the summary image, and share it via WhatsApp — using completed split data.

**Acceptance Scenarios**:

1. **Given** the split is complete, **When** the user is on the Results Screen, **Then** they see each person's name and total amount with a "Share" button.
2. **Given** the user taps "Share via WhatsApp," **When** the image is generated, **Then** a designed summary image is created containing each person's breakdown, the restaurant name, and a download link for the app.
3. **Given** the image is generated, **When** the user confirms sharing, **Then** the WhatsApp share intent opens with the image pre-attached.

---

### User Story 5 - Manage Contacts & Groups (Priority: P3)

A user can import friends from their phone contacts, create named groups (e.g., "Work Crew"), and add group members in one tap when starting a new bill split.

**Why this priority**: Groups and contacts reduce friction in repeat usage, but the core flow works with manually entered names.

**Independent Test**: A user can view imported contacts, create a group, add members, and select a group when starting a new split — without needing to scan a receipt.

**Acceptance Scenarios**:

1. **Given** the user has granted contact-list access, **When** they open the Contacts section, **Then** phone contacts are imported and displayed.
2. **Given** contacts are loaded, **When** the user creates a new group and names it, **Then** the group is saved and appears in their group list.
3. **Given** a group exists, **When** the user starts a new split, **Then** they can select the group to auto-add all members to the Split Screen.

---

### User Story 6 - Push Notifications to Registered Friends (Priority: P3)

When a bill is split, friends who are registered ShellaPay users automatically receive a push notification with the amount they owe.

**Why this priority**: Push notifications create the network effect but depend on having real registered users first.

**Independent Test**: A registered friend receives a push notification with the correct amount after a bill is split that includes them.

**Acceptance Scenarios**:

1. **Given** a split is complete and a friend is a registered ShellaPay user, **When** the split is saved, **Then** the friend receives a push notification showing the amount they owe and the restaurant name.
2. **Given** a friend is NOT a registered user, **When** the split is saved, **Then** no push notification is sent (WhatsApp sharing remains the fallback).

---

### User Story 7 - View Outing History (Priority: P3)

The user can view a chronological list of past outings with details (restaurant name, date, total, who was involved, who owes what).

**Why this priority**: History is a convenience and retention feature, not critical for the core flow.

**Independent Test**: A user with past splits can see each outing listed with correct date, total, and per-person breakdown.

**Acceptance Scenarios**:

1. **Given** the user has completed previous splits, **When** they open the History screen, **Then** a list of outings is displayed in reverse chronological order showing restaurant name, date, and total.
2. **Given** the user taps on a history item, **When** the detail view opens, **Then** they see the full item list, each person's share, and payment status.

---

### Edge Cases

- What happens when the receipt photo is blurry or unreadable? → Friendly error with retry and manual-entry fallback.
- What happens when a single item has a price of zero? → Allow it (could be a promo); display a warning.
- What happens when no friends are added but the user tries to split? → Prompt to add at least one friend.
- What happens when the user assigns only some items and tries to calculate? → Warn about unassigned items; allow proceeding with unassigned items attributed to the bill owner.
- What happens when two users split the same receipt from different phones? → Each session is independent; no conflict resolution needed in v1.
- What happens when the phone has no internet but the user scans a receipt? → OCR works offline; AI parsing fails gracefully with a message to connect and retry or enter items manually.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to photograph receipts using the in-app camera with a guided overlay frame.
- **FR-002**: System MUST extract text from receipt photos using on-device OCR (offline-capable, Arabic + English).
- **FR-003**: System MUST send raw OCR text to an AI parsing service that returns structured JSON of items and prices.
- **FR-004**: System MUST display extracted items on a Review Screen where users can edit names, prices, and add tax/service.
- **FR-005**: System MUST provide a drag-and-drop interface with spring-physics animations for assigning items to friends.
- **FR-006**: System MUST support splitting a single item across multiple people (equal or custom ratio).
- **FR-007**: System MUST proportionally distribute tax and service charges based on each person's subtotal.
- **FR-008**: System MUST calculate and display each person's total on a Results Screen.
- **FR-009**: System MUST generate a shareable summary image with per-person breakdown and app download link.
- **FR-010**: System MUST integrate WhatsApp sharing for the summary image.
- **FR-011**: System MUST support user registration via phone number + OTP verification.
- **FR-012**: System MUST allow users to set a display name and optional profile photo.
- **FR-013**: System MUST import phone contacts (with permission) to discover friends and existing users.
- **FR-014**: System MUST support creating, editing, and deleting named friend groups.
- **FR-015**: System MUST send push notifications to registered friends with their owed amount after a split.
- **FR-016**: System MUST persist all outings with full detail so users can view their split history.
- **FR-017**: System MUST provide a 3-screen onboarding walkthrough for first-time users.
- **FR-018**: System MUST include a tutorial with a dummy receipt for first-time drag-and-drop practice.
- **FR-019**: System MUST provide haptic feedback on successful drag-and-drop actions and confirmations.
- **FR-020**: System MUST default to dark mode with neon/gradient accent colors.
- **FR-021**: System MUST allow manual item entry as a fallback when OCR/AI parsing fails.

### Key Entities

- **User**: Represents a registered person with name, phone number, and avatar. The bill owner who initiates splits.
- **Contact**: A person from the user's phone contacts, with name and phone number. May or may not be a registered user.
- **Group**: A named collection of contacts (e.g., "Work Crew") for quick addition to splits.
- **Outing (Receipt)**: A single bill-splitting session tied to a place, date, total, tax/service, and the receipt image.
- **Receipt Item**: An individual line item on a receipt with name and price.
- **Item Split**: The assignment of a receipt item (or portion) to a specific contact, tracking split percentage.
- **Debt**: A record of how much one person owes another for a given outing, with payment status tracking.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete the full flow (scan → review → split → share) in under 3 minutes for a receipt with up to 15 items.
- **SC-002**: OCR + AI parsing correctly extracts at least 85% of item names and prices from printed Arabic and English receipts without user correction.
- **SC-003**: Drag-and-drop animations run at a consistent 60 fps on mid-range devices without dropped frames.
- **SC-004**: 90% of first-time users complete the onboarding tutorial (walkthrough + dummy receipt) without dropping off.
- **SC-005**: At least 50% of completed splits result in a WhatsApp share action within the first month of usage.
- **SC-006**: The app functions for receipt scanning (OCR) without an internet connection.
- **SC-007**: New user registration (phone + OTP) completes in under 60 seconds.
- **SC-008**: Users can recover from a failed scan (blurry photo or parsing error) within 2 taps (retake or manual entry).

## Assumptions

- The app targets the Middle East market primarily, with Arabic language support for OCR as a first-class requirement.
- The OTP authentication provider is managed by Supabase Auth (assumption from PRD).
- The AI parsing service API key is stored server-side and invoked via an edge function, not embedded in the client.
- The shareable summary image is generated client-side (no server rendering needed in v1).
- Payment tracking (marking debts as paid) is a simple toggle in v1, not integrated with any payment gateway.
- The app does not support editing a split after it has been shared/saved in v1.
- Contact matching (discovering registered users) is done by phone number hash lookup.
