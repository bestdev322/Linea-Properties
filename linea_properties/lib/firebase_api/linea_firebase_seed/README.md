# Linea Properties — Firebase Seed Script

Populates your Firestore database with all 13 collections, sample documents,
security rules, and indexes — ready to develop against immediately.

---

## What gets created

| Collection       | Sample docs | Subcollections              |
|------------------|-------------|-----------------------------|
| users            | 4           | notifications, ratings      |
| listings         | 3           | saves                       |
| visits           | 2           | —                           |
| chats            | 1           | messages (3 docs)           |
| subscriptions    | 1           | —                           |
| payments         | 2           | —                           |
| boosts           | 1           | —                           |
| rewards          | 1           | —                           |
| reports          | 1           | —                           |
| savedListings    | 1           | —                           |
| auditLogs        | 2           | —                           |
| config           | 2 (CM, NG)  | —                           |
| analytics        | 1 (today)   | —                           |

Also generates:
- `firestore.rules` — full security rules for all collections
- `firestore.indexes.json` — all composite indexes needed for app queries

---

## Prerequisites

- Node.js 18+
- Firebase CLI: `npm install -g firebase-tools`
- A Firebase project with Firestore enabled

---

## Setup (VS Code terminal)

### Step 1 — Install dependencies
```bash
npm install
```

### Step 2 — Authenticate
Choose ONE of the two methods below:

**Option A — Firebase CLI login (easiest for development)**
```bash
firebase login
```

**Option B — Service Account Key (for CI/CD or production)**
1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key" → download the JSON file
3. Pass it with the `--key` flag (see Step 3)

### Step 3 — Run the seed
```bash
# With Firebase CLI login:
node seed.js --project YOUR_PROJECT_ID

# With service account key:
node seed.js --project YOUR_PROJECT_ID --key ./serviceAccountKey.json

# Or set env vars and run:
FIREBASE_PROJECT_ID=your-project-id node seed.js
```

### Step 4 — Deploy rules and indexes
```bash
firebase deploy --only firestore:rules --project YOUR_PROJECT_ID
firebase deploy --only firestore:indexes --project YOUR_PROJECT_ID
```

---

## Sample user IDs for testing

| Role        | User ID               | Email                        |
|-------------|----------------------|------------------------------|
| Admin       | user_admin_001        | admin@lineaproperties.com    |
| Tenant      | user_tenant_001       | tenant1@example.com          |
| Contributor | user_contributor_001  | contrib1@example.com         |
| Locator     | user_locator_001      | locator1@example.com         |

---

## Notes

- Running the script multiple times is safe — all writes use `{ merge: true }`.
- The `analytics` collection is intended to be written by Cloud Functions only.
  The seed writes one document for today as a structural example.
- To reset: delete all collections in the Firebase Console, then re-run.
