# Bugfix Requirements Document

## Introduction

Fandom Verse is a Flutter fan-community app built on Firebase Auth + Firestore, SQLite (sqflite),
the BLoC pattern, and GetIt dependency injection. A comprehensive audit of the codebase has
identified 16 distinct bugs and gaps that collectively prevent the app from being production-ready.
These range from a critical authentication bypass that allows password-free login, to split-brain
data flows where admin writes are never visible to fans, to in-memory-only persistence for user
interactions such as bookmarks and upvotes. This document captures every defective behavior, the
correct behavior that must replace it, and the surrounding behaviors that must be preserved
unchanged.

---

## Bug Analysis

### Current Behavior (Defect)

**Security**

1.1 WHEN Firebase is unavailable AND a user attempts to sign in offline THEN the system queries
SQLite by email only and returns the matching user record without comparing any password, allowing
anyone who knows a valid email address to authenticate successfully.

1.2 WHEN a fan navigates directly to a route such as `/admin-dashboard`, `/admin/content`, or any
other `/admin/*` path THEN the system renders the admin page regardless of whether the current
user is authenticated or has the `admin` role.

**Data Integrity – Split-Brain Admin/Fan Disconnect**

2.1 WHEN an admin creates or edits a lore article via `AdminBloc` (which writes to the SQLite
`posts` table) THEN `FandomHubBloc._onLoadContent` still reads from `FandomMockData` in-memory
constants, so fan-facing screens never reflect the admin's changes.

2.2 WHEN an admin creates or edits a convention event via `AdminBloc` (which writes to the SQLite
`events` table) THEN `EventCalendarBloc._onLoadEvents` still reads from `EventMockData` in-memory
constants, so the fan-facing event calendar never reflects the admin's changes.

2.3 WHEN an admin creates or edits a community discussion via `AdminBloc` THEN
`CommunityBloc._onLoadThreads` still reads from `CommunityMockData` in-memory constants for
both discussion threads and star profiles, so fan-facing community screens never reflect the
admin's changes.

**In-Memory Persistence – User Interactions Reset on Restart**

3.1 WHEN a fan toggles a bookmark on a fandom post THEN `FandomHubBloc._onToggleBookmarkPost`
updates the in-memory state only and never writes to the `is_bookmarked` column in the SQLite
`posts` table, so the bookmark is lost on every app restart.

3.2 WHEN a fan toggles a bookmark on an event THEN `EventCalendarBloc._onToggleBookmark` updates
in-memory state only and never writes to the `is_bookmarked` column in the SQLite `events` table,
so the bookmark is lost on every app restart.

3.3 WHEN a fan toggles RSVP on an event THEN `EventCalendarBloc._onToggleRsvp` updates in-memory
state only and never writes to the `is_rsvped` column in the SQLite `events` table, so the RSVP
status is lost on every app restart. (Note: the `is_rsvped` column does not yet exist in the
schema.)

3.4 WHEN a fan upvotes a community discussion thread THEN `CommunityBloc._onUpvoteThread` updates
in-memory state only and never writes to the `upvotes` column in the SQLite `discussions` table,
so upvote counts are lost on every app restart.

3.5 WHEN a fan bookmarks a star profile THEN `CommunityBloc._onToggleStarBookmark` updates
in-memory state only and never writes to the `is_bookmarked` column in the SQLite `star_profiles`
table, so the bookmark is lost on every app restart.

**Dependency Injection – Theme Preference Lost**

4.1 WHEN `ThemeBloc` is requested from the service locator THEN `sl.registerFactory<ThemeBloc>`
creates a brand-new instance on every call, discarding the persisted theme preference and causing
theme resets on every widget rebuild that re-requests the bloc.

**Database – Destructive Migration**

5.1 WHEN the SQLite database version number is bumped THEN `_onUpgrade` drops all 13 tables and
re-seeds from scratch, destroying every user-generated record including orders, audit logs, and
user accounts.

**Database – Cache Management Broken**

6.1 WHEN `clearOfflineCache()` is called THEN the method deletes only the `cart_items` table
rows, leaving all other cached content (posts, events, discussions, star profiles, etc.)
untouched, despite the method name implying a full cache clear.

6.2 WHEN `calculateCacheSizeMB()` is called THEN the method returns the hardcoded literal `45.2`
regardless of the actual database content, providing misleading storage information.

**Database – Dead Code and Schema Mismatch**

7.1 WHEN `database_tables.dart` defines the `DatabaseTables` class THEN the file is never
imported or used anywhere in the codebase, making it dead code. Additionally, its `users` table
DDL omits the `status` column that `sqlite_helper.dart` correctly includes, meaning if it were
ever used it would create an incompatible schema.

**Financial Data – Order Invoice Breakdown Lost**

8.1 WHEN an order is loaded from history via `OrderInvoiceEntity.fromDbMap` THEN `shippingFee`,
`discountAmount`, and `taxAmount` are hardcoded to `0.0` and `paymentMethod` is hardcoded to
`'Simulated Fast Pay'`, because the `simulated_orders` table does not store these fields and
`toDbMap()` does not serialize them, so the full financial breakdown is lost after checkout.

**Cart – Shipping Fee Inconsistency**

9.1 WHEN a user triggers checkout via `_onExecuteCheckout` with an empty cart THEN a `$5.00`
shipping fee is applied because `_onExecuteCheckout` uses `subtotal > 50.0 ? 0.0 : 5.00` without
the `subtotal == 0.0` guard that `_onLoadCart` already has, causing an inconsistent total.

**Admin KPI – Fabricated Baseline Numbers**

10.1 WHEN `getAdminDashboardMetrics()` is called THEN the method returns `1240 + users`,
`84 + posts`, and `16 + events` — adding hardcoded fake baseline numbers to the real SQLite
counts — producing inflated and misleading KPI figures on the admin dashboard.

**Entity Equality – Missing Equatable**

11.1 WHEN `EventEntity`, `FandomPost`, `GlossaryTerm`, `DiscussionThread`, or `StarProfile`
instances are compared by BLoC state equality checks THEN the comparison uses reference identity
instead of value equality because none of these entities extend `Equatable` or override
`==`/`hashCode`, potentially causing unnecessary widget rebuilds or missed UI updates.

**Search – No Debounce**

12.1 WHEN a user types in the store search field THEN `StoreBloc.SearchProductsEvent` is
dispatched on every individual keystroke with no debounce, triggering a SQLite query for every
character entered.

12.2 WHEN a user types in the fandom hub search field THEN `FandomHubBloc.SearchFandomContentEvent`
is dispatched on every individual keystroke with no debounce, triggering a state rebuild for
every character entered.

**Architecture – No Repository Layer**

13.1 WHEN BLoCs need data access THEN they depend directly on the concrete `SqliteHelper` class
rather than on abstract repository interfaces, violating the Dependency Inversion Principle and
making the data layer untestable in isolation.

**AI Assistant – Gemini Not Connected**

14.1 WHEN `_useOnlineGemini` is set to `true` via `SetAIModeEvent` and the user sends a chat
message THEN `AIAssistantBloc._onSendMessage` still calls `_generateFAQResponse` (the local
FAQ database lookup) instead of making any HTTP call to the Gemini API, so the online mode
toggle has no effect.

**Missing Packages – Features Cannot Work**

15.1 WHEN the app loads network images THEN there is no `cached_network_image` package in
`pubspec.yaml`, so every image re-downloads from the network on every widget rebuild with no
disk caching.

15.2 WHEN the app needs to store auth tokens securely THEN there is no `flutter_secure_storage`
package in `pubspec.yaml`, so tokens are stored in less-secure storage.

15.3 WHEN `AIAssistantBloc` needs to call the Gemini API THEN there is no `google_generative_ai`
package in `pubspec.yaml`, making the integration impossible to implement as planned.

---

### Expected Behavior (Correct)

**Security**

2.1 WHEN Firebase is unavailable AND a user attempts to sign in offline THEN the system SHALL
hash the supplied password with SHA-256 and a per-user salt, compare the result against the
stored password hash in SQLite, and reject the login with an `'invalid-credential'`
`FirebaseAuthException` if the hashes do not match.

2.2 WHEN a user navigates to any `/admin/*` route THEN the system SHALL check `AuthBloc` state
and the user's `role` field before rendering the route, redirect unauthenticated users to the
login screen, and redirect authenticated fans (non-admin role) to an "Access Denied" screen.

**Data Integrity – Split-Brain Admin/Fan Disconnect**

3.1 WHEN `FandomHubBloc` receives `LoadFandomHubContentEvent` THEN the system SHALL query the
SQLite `posts` table (using `SqliteHelper`) for trending and latest-news posts instead of reading
from `FandomMockData`, so admin-created and admin-edited articles are immediately visible to fans.

3.2 WHEN `EventCalendarBloc` receives `LoadAllEventsEvent` THEN the system SHALL query the SQLite
`events` table (using `SqliteHelper`) instead of reading from `EventMockData`, so admin-managed
events are immediately visible on the fan calendar.

3.3 WHEN `CommunityBloc` receives `LoadDiscussionThreadsEvent` or `LoadStarProfilesEvent` THEN
the system SHALL query the SQLite `discussions`, `discussion_replies`, and `star_profiles` tables
(using `SqliteHelper`) instead of reading from `CommunityMockData`.

**In-Memory Persistence – User Interactions**

4.1 WHEN a fan toggles a bookmark on a fandom post THEN the system SHALL persist the new
`is_bookmarked` value to the corresponding row in the SQLite `posts` table so that the bookmark
survives app restarts.

4.2 WHEN a fan toggles a bookmark on an event THEN the system SHALL persist the new `is_bookmarked`
value to the corresponding row in the SQLite `events` table so that the bookmark survives app
restarts.

4.3 WHEN a fan toggles RSVP on an event THEN the system SHALL persist the new `is_rsvped` value
(and updated `attendees_count`) to the corresponding row in the SQLite `events` table so that the
RSVP survives app restarts. The `events` table schema SHALL include an `is_rsvped` column.

4.4 WHEN a fan upvotes a community thread THEN the system SHALL persist the updated `upvotes`
value (and `is_upvoted` state) to the corresponding row in the SQLite `discussions` table so
that the upvote survives app restarts.

4.5 WHEN a fan bookmarks a star profile THEN the system SHALL persist the new `is_bookmarked`
value to the corresponding row in the SQLite `star_profiles` table so that the bookmark survives
app restarts.

**Dependency Injection – Theme Preference**

5.1 WHEN `ThemeBloc` is registered in the service locator THEN the system SHALL use
`sl.registerLazySingleton<ThemeBloc>(...)` so that a single instance is reused across all
injection points, preserving the persisted theme preference for the lifetime of the app.

**Database – Safe Migration**

6.1 WHEN the SQLite database version number is bumped THEN the system SHALL apply additive
migrations (e.g., `ALTER TABLE … ADD COLUMN`) without dropping any existing tables, preserving
all user-generated data across version upgrades.

**Database – Cache Management**

7.1 WHEN `clearOfflineCache()` is called THEN the system SHALL delete rows from all appropriate
cacheable content tables (posts, events, discussions, discussion_replies, star_profiles,
glossary), leaving user-owned data (users, orders, cart, wishlists, audit_logs) intact.

7.2 WHEN `calculateCacheSizeMB()` is called THEN the system SHALL return a value computed from
the actual on-disk SQLite database file size (or an aggregated row-count-based estimate) rather
than a hardcoded constant.

**Database – Dead Code**

8.1 WHEN `database_tables.dart` exists in the codebase THEN the system SHALL either remove the
file entirely or integrate it as the single source of truth for all DDL statements, with the
`users` table DDL corrected to include the `status` column.

**Financial Data – Order Invoice**

9.1 WHEN an order is created at checkout THEN the system SHALL persist `shipping_fee`,
`discount_amount`, `tax_amount`, `applied_coupon`, and `payment_method` to the
`simulated_orders` table alongside the existing fields.

9.2 WHEN an order is loaded from history via `OrderInvoiceEntity.fromDbMap` THEN the system SHALL
restore `shippingFee`, `discountAmount`, `taxAmount`, `appliedCoupon`, and `paymentMethod` from
the corresponding database columns rather than using hardcoded defaults.

**Cart – Shipping Fee**

10.1 WHEN a checkout is executed via `_onExecuteCheckout` THEN the system SHALL apply a `$0.00`
shipping fee when the cart subtotal is zero, matching the guard already present in `_onLoadCart`,
using a shared private `_calculateShippingFee(double subtotal)` method for both handlers.

**Admin KPI – Accurate Metrics**

11.1 WHEN `getAdminDashboardMetrics()` is called THEN the system SHALL return only the actual
SQLite row counts without any hardcoded additive baseline, so that `totalFans`, `publishedArticles`,
and `upcomingEvents` reflect real data.

**Entity Equality**

12.1 WHEN `EventEntity`, `FandomPost`, `GlossaryTerm`, `DiscussionThread`, and `StarProfile`
instances are compared THEN the system SHALL use value equality via `Equatable` (with appropriate
`props` lists) so that BLoC state change detection is accurate and avoids both spurious rebuilds
and missed updates.

**Search – Debounce**

13.1 WHEN a user types in the store search field THEN the system SHALL debounce
`SearchProductsEvent` by at least 300 ms using an `EventTransformer` before executing a SQLite
query, reducing redundant database calls.

13.2 WHEN a user types in the fandom hub search field THEN the system SHALL debounce
`SearchFandomContentEvent` by at least 300 ms using an `EventTransformer` before processing the
search, reducing redundant state emissions.

**Architecture – Repository Layer**

14.1 WHEN BLoCs need data access THEN the system SHALL depend on abstract repository interfaces
(e.g., `IStoreRepository`, `ICartRepository`, `IAdminRepository`, `IFandomHubRepository`,
`IEventsRepository`, `ICommunityRepository`) rather than on the concrete `SqliteHelper` class
directly, with concrete SQLite-backed implementations injected via GetIt.

**AI Assistant – Gemini Integration**

15.1 WHEN `_useOnlineGemini` is `true` AND the user sends a chat message AND the device has
network connectivity THEN the system SHALL make an actual API call to the Gemini model (using the
`google_generative_ai` package) and return the model's response as the AI reply.

**Missing Packages**

16.1 WHEN network images are displayed THEN the system SHALL use `cached_network_image` to cache
images to disk so they are not re-downloaded on every build.

16.2 WHEN auth tokens require secure storage THEN the system SHALL use `flutter_secure_storage`
to store sensitive credentials in the platform keychain / keystore.

16.3 WHEN the Gemini AI integration is implemented THEN `google_generative_ai` SHALL be present
in `pubspec.yaml` as an explicit dependency.

---

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a user signs in online with valid Firebase credentials THEN the system SHALL CONTINUE TO
authenticate via `FirebaseAuth`, sync the profile to SQLite, and return the user map as before.

3.2 WHEN a user signs up (online or offline) with a brand-new email THEN the system SHALL
CONTINUE TO create the user record in both Firebase/Firestore (when available) and SQLite, and
return the new user map.

3.3 WHEN admin routes are accessed by an authenticated admin-role user THEN the system SHALL
CONTINUE TO render those pages without interruption.

3.4 WHEN `FandomHubBloc` filters or searches content THEN the system SHALL CONTINUE TO apply
category filters and search queries against the loaded posts exactly as before.

3.5 WHEN `EventCalendarBloc` filters events by city or radius THEN the system SHALL CONTINUE TO
apply those filters to the loaded event list exactly as before.

3.6 WHEN `CommunityBloc` adds a reply to a thread or creates a new thread THEN the system SHALL
CONTINUE TO update the local state list in real time (optimistic UI), even while the SQLite write
happens asynchronously.

3.7 WHEN `CartBloc` adds items, updates quantities, removes items, applies coupons, or clears the
cart THEN the system SHALL CONTINUE TO read back from SQLite and recalculate totals exactly as
before.

3.8 WHEN `StoreBloc` loads, filters by category, sorts, or paginates products THEN the system
SHALL CONTINUE TO query the SQLite `merchandise` table and emit the correct product list.

3.9 WHEN `AdminBloc` creates, updates, or deletes articles, events, products, users, or
categories THEN the system SHALL CONTINUE TO write to the corresponding SQLite tables and
re-trigger a dashboard stats reload.

3.10 WHEN the database is first created (`onCreate`) THEN the system SHALL CONTINUE TO create all
tables, indexes, and seed data exactly as specified in the current `_createAllTables`,
`_createAllIndexes`, and `_seedAllData` routines.

3.11 WHEN `AIAssistantBloc` operates in offline mode (i.e., `_useOnlineGemini` is `false`) THEN
the system SHALL CONTINUE TO answer questions using the local FAQ keyword-matching database and
generic fallback responses as before.

3.12 WHEN `ThemeBloc` receives a toggle event THEN the system SHALL CONTINUE TO persist the
selected theme to `SharedPreferences` and emit the correct `ThemeMode` to listening widgets.

3.13 WHEN a simulated checkout completes successfully THEN the system SHALL CONTINUE TO emit
`CheckoutSuccess(invoice)`, clear the cart, and reset the active coupon and discount rate.

3.14 WHEN `ProfileBloc` loads or updates a user profile THEN the system SHALL CONTINUE TO read
from and write to the SQLite `users` table as before.

---

## Bug Condition Summary

### Fix Checking Properties

```pascal
// BUG 1 — Offline Auth Password Bypass
FUNCTION isBugCondition_1(X)
  INPUT: X = { email: String, password: String, firebaseAvailable: Bool }
  OUTPUT: boolean
  RETURN NOT X.firebaseAvailable AND X.email matches existing SQLite user
END FUNCTION

FOR ALL X WHERE isBugCondition_1(X) DO
  result ← signIn'(X)
  ASSERT (X.passwordHash = storedHash(X.email)) OR result = AuthFailure
END FOR

// BUG 2 — Admin Route Guard Missing
FUNCTION isBugCondition_2(X)
  INPUT: X = { route: String, userRole: String, isAuthenticated: Bool }
  OUTPUT: boolean
  RETURN X.route starts with '/admin'
END FUNCTION

FOR ALL X WHERE isBugCondition_2(X) DO
  result ← navigate'(X)
  ASSERT (X.isAuthenticated AND X.userRole = 'admin') OR result = Redirected
END FOR
```

### Preservation Properties

```pascal
// All non-buggy inputs must behave identically before and after the fix

FOR ALL X WHERE NOT isBugCondition_1(X) DO
  ASSERT signIn(X) = signIn'(X)   // Online Firebase auth unchanged
END FOR

FOR ALL X WHERE NOT isBugCondition_2(X) DO
  ASSERT navigate(X) = navigate'(X)   // Fan routes unaffected
END FOR
```
