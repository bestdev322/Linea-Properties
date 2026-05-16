/**
 * Linea Properties — Firebase Firestore Seed Script
 * ─────────────────────────────────────────────────
 * Usage (VS Code terminal):
 *   1. npm install
 *   2. Set GOOGLE_APPLICATION_CREDENTIALS or run  firebase login  first
 *   3. node seed.js --project YOUR_PROJECT_ID
 *
 * What this does:
 *   • Creates all 13 top-level collections with sample documents
 *   • Creates all subcollections (notifications, ratings, messages, saves)
 *   • Sets up Firestore Security Rules file (firestore.rules)
 *   • Sets up Firestore Indexes file (firestore.indexes.json)
 *   • Prints a full summary when done
 */

const { initializeApp, cert, getApps } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');
const path = require('path');
const fs = require('fs');

// ─── CLI args ────────────────────────────────────────────────────────────────
const args = process.argv.slice(2);
const projectFlag = args.indexOf('--project');
const PROJECT_ID = projectFlag !== -1 ? args[projectFlag + 1] : process.env.FIREBASE_PROJECT_ID;
const SA_KEY_FLAG = args.indexOf('--key');
const SA_KEY_PATH = SA_KEY_FLAG !== -1 ? args[SA_KEY_FLAG + 1] : process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!PROJECT_ID) {
  console.error('\n❌  Missing --project flag.\n   Usage: node seed.js --project YOUR_PROJECT_ID\n');
  process.exit(1);
}

// ─── Init Firebase ───────────────────────────────────────────────────────────
function initFirebase() {
  if (getApps().length) return;
  const config = { projectId: PROJECT_ID };
  if (SA_KEY_PATH && fs.existsSync(SA_KEY_PATH)) {
    config.credential = cert(require(path.resolve(SA_KEY_PATH)));
    console.log('🔑  Using service account key:', SA_KEY_PATH);
  } else {
    console.log('🔑  Using Application Default Credentials (firebase login)');
  }
  initializeApp(config);
}

initFirebase();
const db = getFirestore();

// ─── Helpers ─────────────────────────────────────────────────────────────────
const now = Timestamp.now();
const future = (days) => Timestamp.fromDate(new Date(Date.now() + days * 864e5));
const past = (days) => Timestamp.fromDate(new Date(Date.now() - days * 864e5));

let totalWritten = 0;

async function set(ref, data) {
  await ref.set(data, { merge: true });
  totalWritten++;
}

function log(msg) { console.log('  ' + msg); }

// ═══════════════════════════════════════════════════════════════════════════════
// SEED DATA
// ═══════════════════════════════════════════════════════════════════════════════

// ─── 1. USERS ────────────────────────────────────────────────────────────────
async function seedUsers() {
  console.log('\n👥  Seeding: users');

  const users = [
    {
      id: 'user_admin_001',
      data: {
        uid: 'user_admin_001',
        email: 'admin@lineaproperties.com',
        phone: '+237600000001',
        displayName: 'Linea Admin',
        photoURL: '',
        role: 'admin',
        status: 'approved',
        language: 'en',
        country: 'CM',
        city: 'Douala',
        isEmailVerified: true,
        isPhoneVerified: true,
        isFacebookVerified: false,
        isIdVerified: true,
        idDocumentURL: '',
        idVerifiedAt: now,
        idVerifiedBy: null,
        fcmTokens: [],
        ratingAvg: 0,
        ratingCount: 0,
        createdAt: past(60),
        updatedAt: now,
        lastLoginAt: now,
        suspendedAt: null,
        suspendReason: '',
      },
    },
    {
      id: 'user_tenant_001',
      data: {
        uid: 'user_tenant_001',
        email: 'tenant1@example.com',
        phone: '+237600000002',
        displayName: 'Jean Paul Mbarga',
        photoURL: '',
        role: 'tenant',
        status: 'approved',
        language: 'fr',
        country: 'CM',
        city: 'Douala',
        isEmailVerified: true,
        isPhoneVerified: true,
        isFacebookVerified: true,
        isIdVerified: false,
        idDocumentURL: '',
        idVerifiedAt: null,
        idVerifiedBy: null,
        fcmTokens: ['fcm_token_sample_001'],
        ratingAvg: 4.5,
        ratingCount: 2,
        createdAt: past(30),
        updatedAt: now,
        lastLoginAt: past(1),
        suspendedAt: null,
        suspendReason: '',
      },
    },
    {
      id: 'user_contributor_001',
      data: {
        uid: 'user_contributor_001',
        email: 'contrib1@example.com',
        phone: '+237600000003',
        displayName: 'Amina Bello',
        photoURL: '',
        role: 'contributor',
        status: 'approved',
        language: 'en',
        country: 'CM',
        city: 'Yaounde',
        isEmailVerified: true,
        isPhoneVerified: true,
        isFacebookVerified: false,
        isIdVerified: true,
        idDocumentURL: 'gs://linea-app.appspot.com/ids/contrib1_id.jpg',
        idVerifiedAt: past(10),
        idVerifiedBy: db.doc('users/user_admin_001'),
        fcmTokens: [],
        ratingAvg: 0,
        ratingCount: 0,
        createdAt: past(20),
        updatedAt: now,
        lastLoginAt: past(2),
        suspendedAt: null,
        suspendReason: '',
      },
    },
    {
      id: 'user_locator_001',
      data: {
        uid: 'user_locator_001',
        email: 'locator1@example.com',
        phone: '+237600000004',
        displayName: 'Henri Nkomo',
        photoURL: '',
        role: 'locator',
        status: 'approved',
        language: 'fr',
        country: 'CM',
        city: 'Douala',
        isEmailVerified: true,
        isPhoneVerified: true,
        isFacebookVerified: true,
        isIdVerified: true,
        idDocumentURL: 'gs://linea-app.appspot.com/ids/locator1_id.jpg',
        idVerifiedAt: past(15),
        idVerifiedBy: db.doc('users/user_admin_001'),
        fcmTokens: ['fcm_token_sample_002'],
        ratingAvg: 4.8,
        ratingCount: 12,
        createdAt: past(45),
        updatedAt: now,
        lastLoginAt: now,
        suspendedAt: null,
        suspendReason: '',
      },
    },
  ];

  for (const u of users) {
    await set(db.collection('users').doc(u.id), u.data);
    log(`✓ users/${u.id}`);

    // subcollection: notifications
    await set(
      db.collection('users').doc(u.id).collection('notifications').doc('notif_001'),
      {
        type: 'listing_verified',
        title: 'Your listing was verified',
        body: 'Your property in Akwa has been verified and is now live.',
        isRead: false,
        refType: 'listing',
        refId: 'listing_001',
        createdAt: past(1),
      }
    );
    log(`  ✓ users/${u.id}/notifications/notif_001`);

    // subcollection: ratings (only for locator)
    if (u.id === 'user_locator_001') {
      await set(
        db.collection('users').doc(u.id).collection('ratings').doc('rating_001'),
        {
          fromUserId: db.doc('users/user_tenant_001'),
          fromName: 'Jean Paul Mbarga',
          score: 5,
          comment: 'Very professional and responsive.',
          listingId: db.doc('listings/listing_001'),
          visitId: db.doc('visits/visit_001'),
          createdAt: past(3),
        }
      );
      log(`  ✓ users/${u.id}/ratings/rating_001`);
    }
  }
}

// ─── 2. LISTINGS ─────────────────────────────────────────────────────────────
async function seedListings() {
  console.log('\n🏠  Seeding: listings');

  const listings = [
    {
      id: 'listing_001',
      data: {
        listingId: 'listing_001',
        title: '2-Bedroom Apartment in Akwa, Douala',
        description: 'Modern furnished apartment on the 3rd floor, secure building with 24/7 security. Close to main road.',
        propertyType: 'apartment',
        status: 'active',
        source: 'contributor_submitted',
        contributorId: db.doc('users/user_contributor_001'),
        locatorId: db.doc('users/user_locator_001'),
        claimedAt: past(5),
        claimedBy: db.doc('users/user_locator_001'),
        verifiedAt: past(8),
        verifiedBy: db.doc('users/user_admin_001'),
        rejectionReason: '',
        priceMin: 80000,
        priceMax: 100000,
        currency: 'XAF',
        bedrooms: 2,
        bathrooms: 1,
        area: 65,
        amenities: ['wifi', 'parking', 'security', 'water', 'electricity'],
        photos: [
          'gs://linea-app.appspot.com/listings/listing_001/photo1.jpg',
          'gs://linea-app.appspot.com/listings/listing_001/photo2.jpg',
          'gs://linea-app.appspot.com/listings/listing_001/photo3.jpg',
        ],
        country: 'CM',
        city: 'Douala',
        neighborhood: 'Akwa',
        address: 'Rue de la Paix, Akwa',
        geopoint: { lat: 4.0483, lng: 9.7043 },
        isBoosted: true,
        boostExpiresAt: future(5),
        boostTier: 'standard',
        isVerified: true,
        isDuplicate: false,
        viewCount: 142,
        chatCount: 8,
        visitRequestCount: 3,
        subscriptionTier: 'pro',
        autoUnpublishAt: future(25),
        graceEndsAt: future(28),
        createdAt: past(10),
        updatedAt: past(1),
      },
    },
    {
      id: 'listing_002',
      data: {
        listingId: 'listing_002',
        title: '3-Bedroom House in Bastos, Yaounde',
        description: 'Spacious standalone house with private garden and generator. Ideal for families.',
        propertyType: 'house',
        status: 'pending_verification',
        source: 'contributor_submitted',
        contributorId: db.doc('users/user_contributor_001'),
        locatorId: null,
        claimedAt: null,
        claimedBy: null,
        verifiedAt: null,
        verifiedBy: null,
        rejectionReason: '',
        priceMin: 200000,
        priceMax: 250000,
        currency: 'XAF',
        bedrooms: 3,
        bathrooms: 2,
        area: 120,
        amenities: ['parking', 'security', 'generator', 'garden', 'water'],
        photos: [
          'gs://linea-app.appspot.com/listings/listing_002/photo1.jpg',
          'gs://linea-app.appspot.com/listings/listing_002/photo2.jpg',
          'gs://linea-app.appspot.com/listings/listing_002/photo3.jpg',
        ],
        country: 'CM',
        city: 'Yaounde',
        neighborhood: 'Bastos',
        address: 'Avenue des Ambassadeurs, Bastos',
        geopoint: { lat: 3.8617, lng: 11.5164 },
        isBoosted: false,
        boostExpiresAt: null,
        boostTier: null,
        isVerified: false,
        isDuplicate: false,
        viewCount: 0,
        chatCount: 0,
        visitRequestCount: 0,
        subscriptionTier: null,
        autoUnpublishAt: null,
        graceEndsAt: null,
        createdAt: past(1),
        updatedAt: past(1),
      },
    },
    {
      id: 'listing_003',
      data: {
        listingId: 'listing_003',
        title: 'Studio Apartment in Bonamoussadi',
        description: 'Compact studio, ideal for a single professional. Fully tiled, indoor kitchen.',
        propertyType: 'apartment',
        status: 'paused',
        source: 'locator_direct',
        contributorId: null,
        locatorId: db.doc('users/user_locator_001'),
        claimedAt: null,
        claimedBy: null,
        verifiedAt: past(20),
        verifiedBy: db.doc('users/user_admin_001'),
        rejectionReason: '',
        priceMin: 40000,
        priceMax: 50000,
        currency: 'XAF',
        bedrooms: 0,
        bathrooms: 1,
        area: 28,
        amenities: ['wifi', 'water', 'electricity'],
        photos: [
          'gs://linea-app.appspot.com/listings/listing_003/photo1.jpg',
          'gs://linea-app.appspot.com/listings/listing_003/photo2.jpg',
          'gs://linea-app.appspot.com/listings/listing_003/photo3.jpg',
        ],
        country: 'CM',
        city: 'Douala',
        neighborhood: 'Bonamoussadi',
        address: 'Carrefour Maetur, Bonamoussadi',
        geopoint: { lat: 4.0672, lng: 9.7421 },
        isBoosted: false,
        boostExpiresAt: null,
        boostTier: null,
        isVerified: true,
        isDuplicate: false,
        viewCount: 56,
        chatCount: 2,
        visitRequestCount: 1,
        subscriptionTier: 'pro',
        autoUnpublishAt: future(10),
        graceEndsAt: future(13),
        createdAt: past(22),
        updatedAt: past(2),
      },
    },
  ];

  for (const l of listings) {
    await set(db.collection('listings').doc(l.id), l.data);
    log(`✓ listings/${l.id}`);

    // subcollection: saves
    if (l.id === 'listing_001') {
      await set(
        db.collection('listings').doc(l.id).collection('saves').doc('user_tenant_001'),
        { savedAt: past(2) }
      );
      log(`  ✓ listings/${l.id}/saves/user_tenant_001`);
    }
  }
}

// ─── 3. VISITS ───────────────────────────────────────────────────────────────
async function seedVisits() {
  console.log('\n📅  Seeding: visits');

  await set(db.collection('visits').doc('visit_001'), {
    visitId: 'visit_001',
    listingId: db.doc('listings/listing_001'),
    tenantId: db.doc('users/user_tenant_001'),
    locatorId: db.doc('users/user_locator_001'),
    contributorId: db.doc('users/user_contributor_001'),
    status: 'completed',
    proposedDates: [future(1), future(2), future(3)],
    scheduledAt: past(3),
    confirmedByTenantAt: past(3),
    confirmedByLocatorAt: past(3),
    confirmedByAdminAt: past(2),
    cancelledBy: null,
    cancelReason: '',
    gpsCheckIn: { lat: 4.0483, lng: 9.7043, timestamp: past(3) },
    rewardTriggered: true,
    rewardId: db.doc('rewards/reward_001'),
    notes: 'Tenant arrived on time. Visit went well.',
    createdAt: past(5),
    updatedAt: past(2),
  });
  log('✓ visits/visit_001');

  await set(db.collection('visits').doc('visit_002'), {
    visitId: 'visit_002',
    listingId: db.doc('listings/listing_001'),
    tenantId: db.doc('users/user_tenant_001'),
    locatorId: db.doc('users/user_locator_001'),
    contributorId: db.doc('users/user_contributor_001'),
    status: 'scheduled',
    proposedDates: [future(2), future(3)],
    scheduledAt: future(2),
    confirmedByTenantAt: null,
    confirmedByLocatorAt: now,
    confirmedByAdminAt: null,
    cancelledBy: null,
    cancelReason: '',
    gpsCheckIn: null,
    rewardTriggered: false,
    rewardId: null,
    notes: '',
    createdAt: past(1),
    updatedAt: now,
  });
  log('✓ visits/visit_002');
}

// ─── 4. CHATS ────────────────────────────────────────────────────────────────
async function seedChats() {
  console.log('\n💬  Seeding: chats');

  await set(db.collection('chats').doc('chat_001'), {
    chatId: 'chat_001',
    listingId: db.doc('listings/listing_001'),
    tenantId: db.doc('users/user_tenant_001'),
    locatorId: db.doc('users/user_locator_001'),
    participants: ['user_tenant_001', 'user_locator_001'],
    status: 'active',
    lastMessage: 'Is the apartment still available next week?',
    lastMessageAt: past(1),
    lastMessageBy: db.doc('users/user_tenant_001'),
    unreadCount: { user_locator_001: 1, user_tenant_001: 0 },
    blockedBy: null,
    reportedBy: null,
    reportReason: '',
    isAuditFlagged: false,
    createdAt: past(4),
    updatedAt: past(1),
  });
  log('✓ chats/chat_001');

  const messages = [
    {
      id: 'msg_001',
      senderId: db.doc('users/user_tenant_001'),
      text: 'Hello, I am interested in your listing in Akwa.',
      mediaURL: '',
      mediaType: null,
      isRead: true,
      readAt: past(3),
      isDeleted: false,
      deletedAt: null,
      createdAt: past(4),
    },
    {
      id: 'msg_002',
      senderId: db.doc('users/user_locator_001'),
      text: 'Hello Jean Paul! Yes it is available. When would you like to visit?',
      mediaURL: '',
      mediaType: null,
      isRead: true,
      readAt: past(2),
      isDeleted: false,
      deletedAt: null,
      createdAt: past(3),
    },
    {
      id: 'msg_003',
      senderId: db.doc('users/user_tenant_001'),
      text: 'Is the apartment still available next week?',
      mediaURL: '',
      mediaType: null,
      isRead: false,
      readAt: null,
      isDeleted: false,
      deletedAt: null,
      createdAt: past(1),
    },
  ];

  for (const msg of messages) {
    const { id, ...data } = msg;
    await set(db.collection('chats').doc('chat_001').collection('messages').doc(id), data);
    log(`  ✓ chats/chat_001/messages/${id}`);
  }
}

// ─── 5. SUBSCRIPTIONS ────────────────────────────────────────────────────────
async function seedSubscriptions() {
  console.log('\n💳  Seeding: subscriptions');

  await set(db.collection('subscriptions').doc('sub_001'), {
    subscriptionId: 'sub_001',
    locatorId: db.doc('users/user_locator_001'),
    tier: 'pro',
    status: 'active',
    maxListings: 5,
    hasAnalytics: true,
    analyticsLevel: 'full',
    hasBoostAccess: true,
    boostDiscount: 0,
    country: 'CM',
    priceLocal: 5000,
    currency: 'XAF',
    billingCycle: 'monthly',
    currentPeriodStart: past(5),
    currentPeriodEnd: future(25),
    graceEndsAt: future(28),
    cancelledAt: null,
    paymentReference: 'MTN_TXN_20240501_001',
    paymentProvider: 'mtn_momo',
    activeListingCount: 2,
    createdAt: past(5),
    updatedAt: past(5),
  });
  log('✓ subscriptions/sub_001');
}

// ─── 6. PAYMENTS ─────────────────────────────────────────────────────────────
async function seedPayments() {
  console.log('\n💰  Seeding: payments');

  await set(db.collection('payments').doc('pay_001'), {
    paymentId: 'pay_001',
    userId: db.doc('users/user_locator_001'),
    type: 'subscription',
    amount: 5000,
    currency: 'XAF',
    status: 'completed',
    provider: 'mtn_momo',
    providerRef: 'MTN_TXN_20240501_001',
    providerStatus: 'SUCCESS',
    refType: 'subscription',
    refId: 'sub_001',
    metadata: { tier: 'pro', country: 'CM' },
    createdAt: past(5),
    completedAt: past(5),
  });
  log('✓ payments/pay_001');

  await set(db.collection('payments').doc('pay_002'), {
    paymentId: 'pay_002',
    userId: db.doc('users/user_locator_001'),
    type: 'boost',
    amount: 2500,
    currency: 'XAF',
    status: 'completed',
    provider: 'orange_money',
    providerRef: 'OM_TXN_20240502_001',
    providerStatus: 'SUCCESS',
    refType: 'boost',
    refId: 'boost_001',
    metadata: { listingId: 'listing_001', days: 5 },
    createdAt: past(3),
    completedAt: past(3),
  });
  log('✓ payments/pay_002');
}

// ─── 7. BOOSTS ───────────────────────────────────────────────────────────────
async function seedBoosts() {
  console.log('\n🚀  Seeding: boosts');

  await set(db.collection('boosts').doc('boost_001'), {
    boostId: 'boost_001',
    listingId: db.doc('listings/listing_001'),
    locatorId: db.doc('users/user_locator_001'),
    tier: 'standard',
    placement: ['home', 'category'],
    durationDays: 5,
    status: 'active',
    approvedBy: db.doc('users/user_admin_001'),
    approvedAt: past(3),
    rejectionReason: '',
    amount: 2500,
    currency: 'XAF',
    paymentId: db.doc('payments/pay_002'),
    isSponsored: true,
    impressions: 312,
    clicks: 28,
    startsAt: past(3),
    expiresAt: future(2),
    createdAt: past(3),
  });
  log('✓ boosts/boost_001');
}

// ─── 8. REWARDS ──────────────────────────────────────────────────────────────
async function seedRewards() {
  console.log('\n🎁  Seeding: rewards');

  await set(db.collection('rewards').doc('reward_001'), {
    rewardId: 'reward_001',
    contributorId: db.doc('users/user_contributor_001'),
    listingId: db.doc('listings/listing_001'),
    visitId: db.doc('visits/visit_001'),
    amount: 1500,
    currency: 'XAF',
    status: 'paid',
    flagReason: '',
    approvedBy: db.doc('users/user_admin_001'),
    approvedAt: past(2),
    payoutMethod: 'mtn_momo',
    payoutPhone: '+237600000003',
    payoutReference: 'MTN_PAYOUT_20240503_001',
    paidAt: past(1),
    isFraudFlagged: false,
    fraudNote: '',
    createdAt: past(3),
  });
  log('✓ rewards/reward_001');
}

// ─── 9. REPORTS ──────────────────────────────────────────────────────────────
async function seedReports() {
  console.log('\n🚩  Seeding: reports');

  await set(db.collection('reports').doc('report_001'), {
    reportId: 'report_001',
    reportedBy: db.doc('users/user_tenant_001'),
    targetType: 'listing',
    targetId: 'listing_003',
    reason: 'inaccurate_info',
    description: 'The photos do not match the actual apartment.',
    status: 'open',
    resolvedBy: null,
    resolutionNote: '',
    resolvedAt: null,
    createdAt: past(1),
  });
  log('✓ reports/report_001');
}

// ─── 10. SAVED LISTINGS ──────────────────────────────────────────────────────
async function seedSavedListings() {
  console.log('\n❤️   Seeding: savedListings');

  await set(db.collection('savedListings').doc('user_tenant_001_listing_001'), {
    tenantId: db.doc('users/user_tenant_001'),
    listingId: db.doc('listings/listing_001'),
    savedAt: past(2),
  });
  log('✓ savedListings/user_tenant_001_listing_001');
}

// ─── 11. AUDIT LOGS ──────────────────────────────────────────────────────────
async function seedAuditLogs() {
  console.log('\n📋  Seeding: auditLogs');

  await set(db.collection('auditLogs').doc('log_001'), {
    actorId: db.doc('users/user_admin_001'),
    action: 'verify_listing',
    targetType: 'listing',
    targetId: 'listing_001',
    before: { status: 'pending_verification', isVerified: false },
    after: { status: 'active', isVerified: true },
    ip: '197.0.0.1',
    createdAt: past(8),
  });
  log('✓ auditLogs/log_001');

  await set(db.collection('auditLogs').doc('log_002'), {
    actorId: db.doc('users/user_admin_001'),
    action: 'approve_reward',
    targetType: 'reward',
    targetId: 'reward_001',
    before: { status: 'pending' },
    after: { status: 'approved' },
    ip: '197.0.0.1',
    createdAt: past(2),
  });
  log('✓ auditLogs/log_002');
}

// ─── 12. CONFIG ──────────────────────────────────────────────────────────────
async function seedConfig() {
  console.log('\n⚙️   Seeding: config');

  await set(db.collection('config').doc('CM'), {
    currency: 'XAF',
    rewardAmountPerVisit: 1500,
    subscriptionPrices: { free: 0, basic: 2000, pro: 5000, unlimited: 10000 },
    boostPricePerDay: { standard: 500, premium: 1200 },
    graceperiodDays: 3,
    maxPhotosPerListing: 10,
    featureFlags: {
      guestHouseBooking: false,
      aiRecommendations: false,
      mapView: true,
      facebookVerification: true,
    },
    supportedPaymentProviders: ['mtn_momo', 'orange_money'],
    isActive: true,
    updatedAt: now,
  });
  log('✓ config/CM');

  await set(db.collection('config').doc('NG'), {
    currency: 'NGN',
    rewardAmountPerVisit: 2000,
    subscriptionPrices: { free: 0, basic: 3000, pro: 7500, unlimited: 15000 },
    boostPricePerDay: { standard: 750, premium: 2000 },
    graceperiodDays: 3,
    maxPhotosPerListing: 10,
    featureFlags: {
      guestHouseBooking: false,
      aiRecommendations: false,
      mapView: true,
      facebookVerification: true,
    },
    supportedPaymentProviders: ['mtn_momo'],
    isActive: false,
    updatedAt: now,
  });
  log('✓ config/NG');
}

// ─── 13. ANALYTICS ───────────────────────────────────────────────────────────
async function seedAnalytics() {
  console.log('\n📊  Seeding: analytics');

  const today = new Date().toISOString().split('T')[0];
  await set(db.collection('analytics').doc(`platform_daily_${today}`), {
    date: today,
    newUsers: 12,
    newListings: 5,
    visitRequests: 8,
    completedVisits: 3,
    rewardsApproved: 3,
    totalRevenue: 17500,
    subscriptionRevenue: 15000,
    boostRevenue: 2500,
    activeSubscriptions: 4,
    byCountry: { CM: { newUsers: 12, newListings: 5, revenue: 17500 } },
    createdAt: now,
  });
  log(`✓ analytics/platform_daily_${today}`);
}

// ─── Write Firestore Rules ────────────────────────────────────────────────────
function writeRules() {
  const rules = `rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ── Helpers ────────────────────────────────────────────────────────────
    function isAuth() { return request.auth != null; }
    function isOwner(userId) { return request.auth.uid == userId; }
    function getUser() { return get(/databases/$(database)/documents/users/$(request.auth.uid)).data; }
    function hasRole(role) { return getUser().role == role; }
    function isAdmin() { return hasRole('admin'); }
    function isApproved() { return getUser().status == 'approved'; }

    // ── users ──────────────────────────────────────────────────────────────
    match /users/{userId} {
      allow read: if isAuth() && (isOwner(userId) || isAdmin());
      allow create: if isAuth() && isOwner(userId);
      allow update: if isAuth() && (isOwner(userId) || isAdmin());
      allow delete: if isAdmin();

      match /notifications/{notifId} {
        allow read, write: if isAuth() && isOwner(userId);
      }
      match /ratings/{ratingId} {
        allow read: if isAuth();
        allow create: if isAuth() && isApproved();
        allow update, delete: if isAdmin();
      }
    }

    // ── listings ───────────────────────────────────────────────────────────
    match /listings/{listingId} {
      allow read: if true;
      allow create: if isAuth() && isApproved() && (hasRole('locator') || hasRole('contributor'));
      allow update: if isAuth() && isApproved() && (
        hasRole('locator') && resource.data.locatorId == /databases/$(database)/documents/users/$(request.auth.uid)
        || isAdmin()
      );
      allow delete: if isAdmin();

      match /saves/{tenantId} {
        allow read, write: if isAuth() && isOwner(tenantId);
      }
    }

    // ── visits ─────────────────────────────────────────────────────────────
    match /visits/{visitId} {
      allow read: if isAuth() && (
        resource.data.tenantId == /databases/$(database)/documents/users/$(request.auth.uid)
        || resource.data.locatorId == /databases/$(database)/documents/users/$(request.auth.uid)
        || isAdmin()
      );
      allow create: if isAuth() && isApproved() && hasRole('tenant');
      allow update: if isAuth() && isApproved();
      allow delete: if isAdmin();
    }

    // ── chats ──────────────────────────────────────────────────────────────
    match /chats/{chatId} {
      allow read: if isAuth() && request.auth.uid in resource.data.participants;
      allow create: if isAuth() && isApproved() && hasRole('tenant');
      allow update: if isAuth() && request.auth.uid in resource.data.participants;
      allow delete: if isAdmin();

      match /messages/{messageId} {
        allow read: if isAuth() && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if isAuth() && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow update, delete: if isAdmin();
      }
    }

    // ── subscriptions ──────────────────────────────────────────────────────
    match /subscriptions/{subId} {
      allow read: if isAuth() && (
        resource.data.locatorId == /databases/$(database)/documents/users/$(request.auth.uid)
        || isAdmin()
      );
      allow create, update, delete: if isAdmin();
    }

    // ── payments ───────────────────────────────────────────────────────────
    match /payments/{payId} {
      allow read: if isAuth() && (
        resource.data.userId == /databases/$(database)/documents/users/$(request.auth.uid)
        || isAdmin()
      );
      allow create, update, delete: if isAdmin();
    }

    // ── boosts ─────────────────────────────────────────────────────────────
    match /boosts/{boostId} {
      allow read: if isAuth();
      allow create: if isAuth() && isApproved() && hasRole('locator');
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }

    // ── rewards ────────────────────────────────────────────────────────────
    match /rewards/{rewardId} {
      allow read: if isAuth() && (
        resource.data.contributorId == /databases/$(database)/documents/users/$(request.auth.uid)
        || isAdmin()
      );
      allow create, update, delete: if isAdmin();
    }

    // ── reports ────────────────────────────────────────────────────────────
    match /reports/{reportId} {
      allow read: if isAdmin();
      allow create: if isAuth() && isApproved();
      allow update, delete: if isAdmin();
    }

    // ── savedListings ──────────────────────────────────────────────────────
    match /savedListings/{docId} {
      allow read, write: if isAuth() && isOwner(resource.data.tenantId.id);
    }

    // ── auditLogs ──────────────────────────────────────────────────────────
    match /auditLogs/{logId} {
      allow read, write: if isAdmin();
    }

    // ── config ─────────────────────────────────────────────────────────────
    match /config/{country} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // ── analytics ──────────────────────────────────────────────────────────
    match /analytics/{docId} {
      allow read: if isAdmin();
      allow write: if false; // written by Cloud Functions only
    }
  }
}
`;
  fs.writeFileSync(path.join(__dirname, 'firestore.rules'), rules);
  console.log('\n📝  Written: firestore.rules');
}

// ─── Write Firestore Indexes ──────────────────────────────────────────────────
function writeIndexes() {
  const indexes = {
    indexes: [
      {
        collectionGroup: 'listings',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'status', order: 'ASCENDING' },
          { fieldPath: 'city', order: 'ASCENDING' },
          { fieldPath: 'createdAt', order: 'DESCENDING' },
        ],
      },
      {
        collectionGroup: 'listings',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'status', order: 'ASCENDING' },
          { fieldPath: 'propertyType', order: 'ASCENDING' },
          { fieldPath: 'priceMin', order: 'ASCENDING' },
        ],
      },
      {
        collectionGroup: 'listings',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'isBoosted', order: 'ASCENDING' },
          { fieldPath: 'boostExpiresAt', order: 'DESCENDING' },
        ],
      },
      {
        collectionGroup: 'listings',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'locatorId', order: 'ASCENDING' },
          { fieldPath: 'status', order: 'ASCENDING' },
        ],
      },
      {
        collectionGroup: 'listings',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'contributorId', order: 'ASCENDING' },
          { fieldPath: 'createdAt', order: 'DESCENDING' },
        ],
      },
      {
        collectionGroup: 'visits',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'tenantId', order: 'ASCENDING' },
          { fieldPath: 'status', order: 'ASCENDING' },
          { fieldPath: 'createdAt', order: 'DESCENDING' },
        ],
      },
      {
        collectionGroup: 'visits',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'locatorId', order: 'ASCENDING' },
          { fieldPath: 'status', order: 'ASCENDING' },
          { fieldPath: 'scheduledAt', order: 'ASCENDING' },
        ],
      },
      {
        collectionGroup: 'chats',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'participants', arrayConfig: 'CONTAINS' },
          { fieldPath: 'lastMessageAt', order: 'DESCENDING' },
        ],
      },
      {
        collectionGroup: 'rewards',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'contributorId', order: 'ASCENDING' },
          { fieldPath: 'status', order: 'ASCENDING' },
          { fieldPath: 'createdAt', order: 'DESCENDING' },
        ],
      },
      {
        collectionGroup: 'subscriptions',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'locatorId', order: 'ASCENDING' },
          { fieldPath: 'status', order: 'ASCENDING' },
        ],
      },
      {
        collectionGroup: 'boosts',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'status', order: 'ASCENDING' },
          { fieldPath: 'expiresAt', order: 'ASCENDING' },
        ],
      },
      {
        collectionGroup: 'payments',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'userId', order: 'ASCENDING' },
          { fieldPath: 'createdAt', order: 'DESCENDING' },
        ],
      },
      {
        collectionGroup: 'reports',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'status', order: 'ASCENDING' },
          { fieldPath: 'createdAt', order: 'DESCENDING' },
        ],
      },
      {
        collectionGroup: 'savedListings',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'tenantId', order: 'ASCENDING' },
          { fieldPath: 'savedAt', order: 'DESCENDING' },
        ],
      },
      {
        collectionGroup: 'auditLogs',
        queryScope: 'COLLECTION',
        fields: [
          { fieldPath: 'actorId', order: 'ASCENDING' },
          { fieldPath: 'createdAt', order: 'DESCENDING' },
        ],
      },
    ],
    fieldOverrides: [],
  };
  fs.writeFileSync(
    path.join(__dirname, 'firestore.indexes.json'),
    JSON.stringify(indexes, null, 2)
  );
  console.log('📝  Written: firestore.indexes.json');
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════════════════
async function main() {
  console.log('\n╔══════════════════════════════════════════╗');
  console.log('║   Linea Properties — Firebase Seeder    ║');
  console.log('╚══════════════════════════════════════════╝');
  console.log(`\n🔥  Project: ${PROJECT_ID}`);

  try {
    await seedUsers();
    await seedListings();
    await seedVisits();
    await seedChats();
    await seedSubscriptions();
    await seedPayments();
    await seedBoosts();
    await seedRewards();
    await seedReports();
    await seedSavedListings();
    await seedAuditLogs();
    await seedConfig();
    await seedAnalytics();
    writeRules();
    writeIndexes();

    console.log('\n╔══════════════════════════════════════════╗');
    console.log(`║  ✅  Done! ${totalWritten} documents written         ║`);
    console.log('╚══════════════════════════════════════════╝\n');
    console.log('📂  Files generated:');
    console.log('    • firestore.rules');
    console.log('    • firestore.indexes.json\n');
    console.log('💡  Next steps:');
    console.log('    1. firebase deploy --only firestore:rules');
    console.log('    2. firebase deploy --only firestore:indexes\n');
  } catch (err) {
    console.error('\n❌  Seed failed:', err.message);
    console.error(err.stack);
    process.exit(1);
  }
}

main();
