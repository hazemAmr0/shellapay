# Contracts: Supabase Edge Functions

**Feature**: `001-bill-split-app`
**Date**: 2026-03-13

These are the server-side interfaces the mobile app communicates with beyond
direct Supabase database/auth calls.

---

## 1. parse-receipt

**Purpose**: Accept raw OCR text and return structured receipt items as JSON.

### Request

```
POST /functions/v1/parse-receipt
Authorization: Bearer <supabase-user-jwt>
Content-Type: application/json
```

```json
{
  "raw_text": "string — OCR-extracted text from the receipt"
}
```

### Response (200 OK)

```json
{
  "items": [
    { "item": "string — item name", "price": 0.00 }
  ],
  "raw_response": "string — raw AI model response (for debugging)"
}
```

### Error Responses

| Status | Body | Condition |
|--------|------|-----------|
| 400 | `{ "error": "raw_text is required" }` | Missing or empty input |
| 401 | `{ "error": "Unauthorized" }` | Invalid or missing JWT |
| 422 | `{ "error": "Failed to parse receipt", "raw_response": "..." }` | AI returned un-parseable output |
| 500 | `{ "error": "Internal server error" }` | AI API unreachable or unexpected failure |

### Behavior

1. Validate JWT (Supabase auto-verifies).
2. Validate `raw_text` is present and non-empty.
3. Call AI model API with fixed prompt + `raw_text`.
4. Parse AI response as JSON array.
5. Return structured items or 422 with raw response for debugging.

---

## 2. send-notification

**Purpose**: Send a push notification to a registered user about their share.

### Request

```
POST /functions/v1/send-notification
Authorization: Bearer <supabase-user-jwt>
Content-Type: application/json
```

```json
{
  "recipient_user_id": "uuid — registered user to notify",
  "outing_id": "uuid — the outing this debt belongs to",
  "amount": 0.00,
  "place_name": "string — restaurant/venue name",
  "sender_name": "string — name of the person who split the bill"
}
```

### Response (200 OK)

```json
{
  "success": true,
  "message_id": "string — FCM message ID"
}
```

### Error Responses

| Status | Body | Condition |
|--------|------|-----------|
| 400 | `{ "error": "Missing required fields" }` | Any required field missing |
| 404 | `{ "error": "Recipient not found or no FCM token" }` | User not registered or no token |
| 401 | `{ "error": "Unauthorized" }` | Invalid JWT |
| 500 | `{ "error": "Failed to send notification" }` | FCM delivery failure |

### Behavior

1. Validate JWT.
2. Validate all required fields.
3. Look up recipient's `fcm_token` from `users` table.
4. If no token → return 404.
5. Send FCM message with title: "💰 {sender_name} split a bill with you"
   and body: "You owe {amount} for {place_name}".
6. Return FCM message ID.

---

## 3. discover-users

**Purpose**: Check which phone number hashes correspond to registered users.

### Request

```
POST /functions/v1/discover-users
Authorization: Bearer <supabase-user-jwt>
Content-Type: application/json
```

```json
{
  "phone_hashes": ["string — SHA-256 hash of E.164 phone number"]
}
```

### Response (200 OK)

```json
{
  "registered_hashes": [
    {
      "phone_hash": "string",
      "user_id": "uuid",
      "full_name": "string",
      "avatar_url": "string | null"
    }
  ]
}
```

### Error Responses

| Status | Body | Condition |
|--------|------|-----------|
| 400 | `{ "error": "phone_hashes is required and must be an array" }` | Invalid input |
| 401 | `{ "error": "Unauthorized" }` | Invalid JWT |

### Behavior

1. Validate JWT.
2. Validate `phone_hashes` is a non-empty array (max 500 hashes per request).
3. Query `users` table for matching `phone_hash` values.
4. Return matched users with public profile info (no phone numbers exposed).
