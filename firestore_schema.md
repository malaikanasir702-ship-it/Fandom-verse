# Fandom-verse — Firestore Schema

> **Architecture:** SQLite-first with Firestore as remote source of truth.
> Field names follow **camelCase** in Firestore, **snake_case** in SQLite.

---

## Collections Overview

| # | Collection | Description |
|---|---|---|
| 1 | `users` | Fan & admin profiles |
| 2 | `categories` | Fandom categories |
| 3 | `fandom_posts` | News, lore & trending posts |
| 4 | `glossary` | Fandom terminology |
| 5 | `events` | Conventions & events |
| 6 | `products` | Merchandise store items |
| 7 | `discussions` | Community discussion threads |
| 8 | `star_profiles` | Celebrity / creator profiles |
| 9 | `orders` | Purchase orders |
| 10 | `audit_logs` | Admin action logs |
| 11 | `hero_stories` | Hero story slides |
| 12 | `advanced_lore` | Deep dive lore articles |
| 13 | `behind_scenes` | Behind-the-scenes media |
| 14 | `interviews` | Interviewee Q&A |
| 15 | `deep_dive_trivia` | Trivia quiz questions |
| 16 | `contact_inquiries` | Contact form submissions |

---

## 1. `users`

**Document ID:** Firebase Auth UID (e.g. `abc123uid`)

| Field | Type | Notes |
|---|---|---|
| `id` | `string` | Same as document ID |
| `user_id` | `string` | Same as `id` |
| `name` | `string` | Display name |
| `email` | `string` | Lowercase |
| `role` | `string` | `"fan"` \| `"admin"` |
| `status` | `string` | `"active"` \| `"suspended"` \| `"banned"` |
| `avatarUrl` | `string` | Profile picture URL |
| `avatar_url` | `string` | Duplicate for SQLite sync compat |
| `bio` | `string` | Short user bio |
| `badges` | `array<string>` | e.g. `["Novice Otaku", "Con Veteran 2025"]` |
| `selectedFandoms` | `array<string>` | e.g. `["Anime & Manga", "Gaming & Esports"]` |
| `createdAt` | `timestamp` | `FieldValue.serverTimestamp()` |

**Example:**
```json
{
  "id": "uid_abc123",
  "user_id": "uid_abc123",
  "name": "Alex Mercer",
  "email": "fan@fandomverse.com",
  "role": "fan",
  "status": "active",
  "avatarUrl": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400",
  "bio": "Anime watcher, speedrunner & convention fanatic.",
  "badges": ["Master Lorekeeper", "Con Veteran 2025"],
  "selectedFandoms": ["Anime & Manga", "Gaming & Esports"],
  "createdAt": "<server_timestamp>"
}
```

---

## 2. `categories`

**Document ID:** `category_id` (e.g. `cat_anime`)

| Field | Type | Notes |
|---|---|---|
| `category_id` | `string` | Primary key |
| `name` | `string` | e.g. `"Anime & Manga"` |
| `description` | `string` | Short description |
| `icon_name` | `string` | Material icon name |
| `banner_url` | `string` | Banner image URL |
| `color_hex` | `string` | HEX color e.g. `"#9C27B0"` |

**Valid category names:** `Anime & Manga`, `Gaming & Esports`, `Sci-Fi & Fantasy`, `Marvel & DC Comics`, `K-Pop & Idol Culture`, `Pop Culture & Movies`

**Example:**
```json
{
  "category_id": "cat_anime",
  "name": "Anime & Manga",
  "description": "Cosplay, Graphic Novels, Shonen & Seinen lore primers.",
  "icon_name": "auto_awesome",
  "banner_url": "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800",
  "color_hex": "#9C27B0"
}
```

---

## 3. `fandom_posts`

**Document ID:** `post_id` (e.g. `post-001`)

| Field | Type | Notes |
|---|---|---|
| `post_id` | `string` | Primary key |
| `category_id` | `string` | Ref to `categories` |
| `category` | `string` | Category name (denormalized) |
| `title` | `string` | Post title |
| `content_body` | `string` | Full article content |
| `author_name` | `string` | Author display name |
| `image_url` | `string` | Cover image URL |
| `is_trending` | `boolean` | `true` / `false` |
| `is_deep_dive` | `boolean` | `true` / `false` |
| `tags` | `array<string>` | e.g. `["#Anime", "#Shonen"]` |
| `timestamp` | `number` | Epoch milliseconds |

**Example:**
```json
{
  "post_id": "post-001",
  "category_id": "cat_anime",
  "category": "Anime & Manga",
  "title": "Top 10 Anime of 2026",
  "content_body": "This year has been incredible for anime fans...",
  "author_name": "Fandom Chronicler",
  "image_url": "https://images.unsplash.com/...",
  "is_trending": true,
  "is_deep_dive": false,
  "tags": ["#Anime", "#Top10"],
  "timestamp": 1735000000000
}
```

---

## 4. `glossary`

**Document ID:** `term_id` (e.g. `term-001`)

| Field | Type | Notes |
|---|---|---|
| `term_id` | `string` | Primary key |
| `term` | `string` | The fandom term |
| `definition` | `string` | Full definition |
| `fandom_category` | `string` | Related category name |
| `example_usage` | `string` | Usage example sentence |
| `phonetic` | `string` | Pronunciation guide |

**Example:**
```json
{
  "term_id": "term-001",
  "term": "Tsundere",
  "definition": "A character who is initially cold and hostile but gradually shows a warmer side.",
  "fandom_category": "Anime & Manga",
  "example_usage": "She acts like a tsundere — always arguing but secretly caring.",
  "phonetic": "tsoon-deh-reh"
}
```

---

## 5. `events`

**Document ID:** `event_id` (e.g. `evt-001`)

| Field | Type | Notes |
|---|---|---|
| `event_id` | `string` | Primary key |
| `title` | `string` | Event title |
| `description` | `string` | Full description |
| `cityName` | `string` | City location |
| `venueName` | `string` | Venue name |
| `latitude` | `number` | GPS latitude |
| `longitude` | `number` | GPS longitude |
| `eventDate` | `number` | Epoch milliseconds |
| `ticketLink` | `string` | External ticket URL |
| `bannerUrl` | `string` | Event banner image URL |
| `category` | `string` | Fandom category |
| `attendeesCount` | `number` | Expected attendance |

**Example:**
```json
{
  "event_id": "evt-001",
  "title": "Tokyo Anime Expo 2026",
  "description": "The world's largest gathering of animators and mangaka.",
  "cityName": "Tokyo",
  "venueName": "Tokyo Big Sight Exhibition Center",
  "latitude": 35.6298,
  "longitude": 139.7942,
  "eventDate": 1785000000000,
  "ticketLink": "https://anime-expo.tokyo/tickets",
  "bannerUrl": "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800",
  "category": "Anime & Manga",
  "attendeesCount": 48000
}
```

---

## 6. `products`

**Document ID:** `product_id` (e.g. `prod-001`)

| Field | Type | Notes |
|---|---|---|
| `product_id` | `string` | Primary key |
| `name` | `string` | Product name |
| `category` | `string` | e.g. `"Apparel"`, `"Action Figures"` |
| `price` | `number` | Current price (USD) |
| `originalPrice` | `number` \| `null` | Original price for discount display |
| `imageUrl` | `string` | Product image URL |
| `description` | `string` | Product description |
| `stockCount` | `number` | Available quantity |
| `rating` | `number` | 0.0 – 5.0 |
| `isFeatured` | `boolean` | Show in featured section |

**Product categories:** `Replica Props`, `Apparel`, `Action Figures`, `Manga/Comics`, `Digital Collectibles`

**Example:**
```json
{
  "product_id": "prod-001",
  "name": "Chrono Blade Neon Katana (Replica 1:1)",
  "category": "Replica Props",
  "price": 149.99,
  "originalPrice": 189.99,
  "imageUrl": "https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=600",
  "description": "Forged high-density carbon alloy blade with RGB LED edge lighting.",
  "stockCount": 6,
  "rating": 4.9,
  "isFeatured": true
}
```

---

## 7. `discussions`

**Document ID:** `thread_id` (e.g. `thread-001`)

| Field | Type | Notes |
|---|---|---|
| `thread_id` | `string` | Primary key |
| `user_id` | `string` | Author user ID |
| `user_name` | `string` | Author display name |
| `user_badge` | `string` | Author's top badge |
| `category` | `string` | Fandom category |
| `title` | `string` | Thread title |
| `body` | `string` | Thread content |
| `upvotes` | `number` | Vote count |
| `created_at` | `number` | Epoch milliseconds |

> **Note:** Replies are stored in SQLite only (`discussion_replies` table), not in Firestore.

**Example:**
```json
{
  "thread_id": "thread-001",
  "user_id": "uid_abc123",
  "user_name": "Alex Mercer",
  "user_badge": "Master Lorekeeper",
  "category": "Anime & Manga",
  "title": "Best Shonen Anime of All Time?",
  "body": "I think Fullmetal Alchemist Brotherhood sets the gold standard...",
  "upvotes": 42,
  "created_at": 1735000000000
}
```

---

## 8. `star_profiles`

**Document ID:** `star_id` (e.g. `star-001`)

| Field | Type | Notes |
|---|---|---|
| `star_id` | `string` | Primary key |
| `name` | `string` | Celebrity/creator name |
| `fandomCategory` | `string` | Related fandom category |
| `roleTitle` | `string` | e.g. `"Voice Actor"`, `"Mangaka"` |
| `bio` | `string` | Short biography |
| `imageUrl` | `string` | Profile image URL |
| `socialHandle` | `string` | e.g. `"@username"` |
| `famousWorks` | `array<string>` | List of known works |
| `seededAt` | `timestamp` | Used for ordering |

**Example:**
```json
{
  "star_id": "star-001",
  "name": "Hajime Isayama",
  "fandomCategory": "Anime & Manga",
  "roleTitle": "Mangaka",
  "bio": "Creator of Attack on Titan, one of the best-selling manga series.",
  "imageUrl": "https://images.unsplash.com/...",
  "socialHandle": "@Isayama_Hajime",
  "famousWorks": ["Attack on Titan"],
  "seededAt": "<server_timestamp>"
}
```

---

## 9. `orders`

**Document ID:** Auto-generated by Firestore (`add()`)

| Field | Type | Notes |
|---|---|---|
| `order_id` | `string` | App-generated ID (e.g. `FV-89241`) |
| `user_id` | `string` | Ref to `users` |
| `order_date` | `number` | Epoch milliseconds |
| `subtotal` | `number` | Before discounts/tax |
| `shipping_fee` | `number` | Shipping cost |
| `discount_amount` | `number` | Coupon discount |
| `tax_amount` | `number` | Applied tax |
| `total_amount` | `number` | Final charged amount |
| `applied_coupon` | `string` | Coupon code used (or `""`) |
| `shipping_address` | `string` | Full shipping address |
| `payment_method` | `string` | e.g. `"Cash on Delivery"` |
| `items_summary` | `string` | Human-readable items list |
| `order_status` | `string` | `"Completed"` \| `"Pending"` |
| `createdAt` | `timestamp` | `FieldValue.serverTimestamp()` |

**Valid coupon codes:** `FANDOM10` (10%), `CON2025` (15%), `OTAKU20` (20%), `SUPERFAN` (25%)

---

## 10. `audit_logs`

**Document ID:** `log_id` (e.g. `log-01`)

| Field | Type | Notes |
|---|---|---|
| `log_id` | `string` | Primary key |
| `action_type` | `string` | `"CREATE"` \| `"UPDATE"` \| `"DELETE"` \| `"BROADCAST"` |
| `entity_type` | `string` | e.g. `"Merchandise"`, `"Events"`, `"Push Alert"` |
| `description` | `string` | Human-readable action description |
| `admin_email` | `string` | Who performed the action |
| `timestamp` | `number` | Epoch milliseconds |

---

## 11. `hero_stories`

**Document ID:** `story_id` (e.g. `story-spiderman`)

| Field | Type | Notes |
|---|---|---|
| `story_id` | `string` | Primary key |
| `hero_name` | `string` | Character name |
| `category` | `string` | Fandom category |
| `avatar_url` | `string` | Hero avatar image |
| `ring_color_hex` | `string` | Story ring color e.g. `"#E51924"` |
| `tagline` | `string` | Short tagline |
| `origin_backstory` | `string` | Origin story text |
| `life_history` | `string` | Full life history |
| `powers_abilities` | `string` | Powers description |
| `first_appearance` | `string` | First media appearance |
| `slides` | `array<object>` | Story slides (see below) |
| `created_at` | `number` | Epoch milliseconds |

**Slide object structure:**
```json
{
  "imageUrl": "https://...",
  "caption": "With great power comes great responsibility.",
  "tag": "#SpiderMan"
}
```

---

## 12. `advanced_lore`

**Document ID:** `lore_id`

| Field | Type | Notes |
|---|---|---|
| `lore_id` | `string` | Primary key |
| `fandom_category` | `string` | Category filter |
| `title` | `string` | Article title |
| `content_body` | `string` | Full lore content |
| `difficulty_level` | `string` | `"Beginner"` \| `"Intermediate"` \| `"Expert"` |
| `created_at` | `number` | Epoch milliseconds |

---

## 13. `behind_scenes`

**Document ID:** `scene_id`

| Field | Type | Notes |
|---|---|---|
| `scene_id` | `string` | Primary key |
| `fandom_category` | `string` | Category filter |
| `title` | `string` | Content title |
| `description` | `string` | Description text |
| `media_type` | `string` | `"video"` \| `"image"` \| `"article"` |
| `media_url` | `string` \| `null` | Media resource URL |
| `created_at` | `number` | Epoch milliseconds |

---

## 14. `interviews`

**Document ID:** `interview_id`

| Field | Type | Notes |
|---|---|---|
| `interview_id` | `string` | Primary key |
| `interviewee_name` | `string` | Person being interviewed |
| `role_title` | `string` | Their role/title |
| `fandom_category` | `string` | Related category |
| `interview_date` | `number` | Epoch milliseconds |
| `questions_json` | `string` | JSON array of Q&A objects |
| `image_url` | `string` \| `null` | Portrait image |
| `created_at` | `number` | Epoch milliseconds |

**`questions_json` format:**
```json
[
  { "question": "What inspired you?", "answer": "My love for manga since childhood..." }
]
```

---

## 15. `deep_dive_trivia`

**Document ID:** `trivia_id`

| Field | Type | Notes |
|---|---|---|
| `trivia_id` | `string` | Primary key |
| `fandom_category` | `string` | Category filter |
| `question` | `string` | Trivia question text |
| `options_json` | `string` | JSON array of 4 answer strings |
| `correct_answer_index` | `number` | 0-based index of correct option |
| `explanation` | `string` | Explanation after answer |
| `created_at` | `number` | Epoch milliseconds |

**`options_json` format:**
```json
["Naruto", "Bleach", "One Piece", "Dragon Ball"]
```

---

## 16. `contact_inquiries`

**Document ID:** Auto-generated by Firestore (`add()`)

| Field | Type | Notes |
|---|---|---|
| `name` | `string` | Sender's name |
| `email` | `string` | Sender's email |
| `subject` | `string` | Inquiry subject |
| `message` | `string` | Full message |
| `createdAt` | `timestamp` | `FieldValue.serverTimestamp()` |

---

## Field Naming Reference (Firestore vs SQLite)

| Entity | Firestore (camelCase) | SQLite (snake_case) |
|---|---|---|
| User | `avatarUrl` | `avatar_url` |
| User | `selectedFandoms` | `selected_fandoms` |
| User | `createdAt` | `created_at` |
| Event | `cityName` | `city_name` |
| Event | `venueName` | `venue_name` |
| Event | `eventDate` | `event_date` |
| Event | `ticketLink` | `ticket_link` |
| Event | `bannerUrl` | `banner_url` |
| Event | `attendeesCount` | `attendees_count` |
| Product | `originalPrice` | `original_price` |
| Product | `imageUrl` | `image_url` |
| Product | `stockCount` | `stock_count` |
| Product | `isFeatured` | `is_featured` |
| StarProfile | `fandomCategory` | `fandom_category` |
| StarProfile | `roleTitle` | `role_title` |
| StarProfile | `socialHandle` | `social_handle` |
| StarProfile | `famousWorks` | *(not stored in SQLite)* |

---

## Collections NOT in Firestore (SQLite-only)

These tables exist only in local SQLite — no Firestore equivalent:

| SQLite Table | Reason |
|---|---|
| `cart_items` | Session-local, user-specific |
| `wishlists` | User-local data |
| `discussion_replies` | Nested under threads (SQLite) |
| `simulated_orders` | Local simulation only |
| `event_tickets` | Purchased via Stripe, stored locally |
| `notifications` | FCM-delivered, stored locally |
| `suspension_appeals` | Admin review only |
| `admin_audit_logs` | Also mirrored in `audit_logs` Firestore collection |
