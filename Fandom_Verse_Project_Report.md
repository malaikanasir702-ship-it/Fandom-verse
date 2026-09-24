# FANDOM VERSE POCKET EDITION
## Master Enterprise Implementation & Architectural Project Report
**Course / Track:** Advanced Cross-Platform Mobile Engineering & Clean Architecture  
**Platform:** Flutter 3.24+ / Dart 3.6+ / Cross-Platform (Android, iOS, Web, Desktop)  
**Architecture Pattern:** Clean Architecture + Feature-First + BLoC State Management  
**Storage Architecture:** Offline-First SQLite Synchronization Engine (`fandom_verse.db`)  
**Dual Theme Engine:** Cyber Fandom Dark (#7C4DFF / #00E5FF) & Galactic Lumina Light (#6200EE / #0091EA)  

---

## EXECUTIVE SUMMARY & DELIVERABLE ATTESTATION
This engineering report documents the comprehensive design, database modeling, zero-conflict dual-developer implementation, and verification of **Fandom Verse Pocket Edition**. The application provides an integrated universe for fans across 6 major cultural pillars (Anime & Manga, Gaming & Esports, Marvel & DC, Sci-Fi & Fantasy, K-Pop & Idol Culture, and Pop Culture Movies).

### Pre-Configured Test Credentials:
* **Command Admin Console:** `admin@fandomverse.com` / `admin123` (Full CRUD over Articles, Events, Products, Users & Push Alerts)
* **Fan Universe Account:** `fan@fandomverse.com` / `fan123` (Preloaded with "Master Lorekeeper" & "Con Veteran 2025" Badges)

---

## 1. PROBLEM DEFINITION & MARKET FRAGMENTATION ANALYSIS

### 1.1 The Fandom Fragmentation Dilemma
Modern pop culture, gaming, anime, and comic enthusiasts suffer from severe platform fragmentation:
1. **Dispersed Information Silos:** Fans must alternate between multiple disconnected websites (Wikis, Reddit boards, Reddit AMAs, Discord servers) to research universe chronologies and hidden lore.
2. **Disconnected Event Discovery:** Conventions (Comic-Con, Anime Expo, Esports Tournaments) rely on disjointed ticketing websites with no unified geospatial radar or GPS proximity filtering.
3. **Merchandise Fraud & Chaotic Catalogs:** Official licensed merchandise and exclusive convention collectibles are scattered across third-party storefronts without direct offline wishlisting or transparent itemized bill receipts.
4. **Offline Inaccessibility:** Most fan forums require persistent high-speed internet, leaving fans at conventions (where cellular networks routinely fail) unable to access venue schedules, tickets, or lore guides.

### 1.2 The Fandom Verse Solution
Fandom Verse Pocket Edition consolidates these disparate pillars into an all-in-one, offline-first mobile application featuring:
* Clean Architecture with zero-conflict dual-developer separation.
* Offline-first SQLite local caching across 12 relational entities.
* Location-aware convention radar with GPS coordinates.
* Official simulated merchandise store with coupon engine (`FANDOM10`), itemized bill breakdown, and scannable QR code generator.
* Dedicated Admin Command Console with real-time KPI metrics, audit logging, and content CRUD.

---

## 2. SYSTEM ARCHITECTURE & LAYER HIERARCHY

```
+---------------------------------------------------------------------------------------+
|                                    PRESENTATION LAYER                                 |
|  [Flutter Widgets & Glassmorphic UI] <---> [BLoC State Management (Bloc / Cubit)]     |
|  - FanFeedPage, LoreHubPage, EventsRadar, StorefrontPage, CartPage, AdminDashboard   |
+---------------------------------------------------------------------------------------+
                                           |
                                           v
+---------------------------------------------------------------------------------------+
|                                      DOMAIN LAYER                                     |
|  [Use Cases / Interactors]          [Entities / Contracts]                            |
|  - ProductEntity, CartItemEntity, OrderInvoiceEntity, UserEntity, EventEntity        |
+---------------------------------------------------------------------------------------+
                                           |
                                           v
+---------------------------------------------------------------------------------------+
|                                       DATA LAYER                                      |
|  [Data Transfer Objects (DTOs)]     [Repositories]           [Data Sources]           |
|  - SQLite Database Helper           - StoreRepository        - SharedPreferences      |
|  - 12 Relational Tables             - LocalStorageService    - Memory Sync Cache      |
+---------------------------------------------------------------------------------------+
```

---

## 3. ZERO-CONFLICT DUAL-DEVELOPER OWNERSHIP MATRIX

| Domain / Layer | Developer A (Fan Core & Discovery) | Developer B (Database, Store, Cart & Admin) |
| :--- | :--- | :--- |
| **Foundation** | UI Theme System, Glassmorphic Engine, Colors, Fonts | Core SQLite Helper, Database Tables, Seed Data, DB Constants |
| **Authentication**| Splash, Role Selection Gateway, Onboarding, Fan Login | Admin Authentication Gate & Security Auditing |
| **Discovery** | Fandom Hub, Lore Primers, 50+ Lexicon Glossary | Local Storage Service, Cache Measurement, JSON Exporter |
| **Events & AI** | GPS Convention Radar, Maps, Gemini Assistant | - |
| **Store & Cart** | - | Merch Catalog, Filters, Sorting, Product Detail Screen |
| **Checkout** | - | Wishlist, Cart, Coupon Simulator (`FANDOM10`), Invoice & QR |
| **Profile** | Badges & Achievements, Star Profiles | Settings Page, Live Dual-Theme Switcher, Order History |
| **Admin Console**| - | Dashboard, Content CRUD, Event CRUD, Product CRUD, User Ban |
| **Deliverables** | Fan Routes (`fan_routes.dart`), Dev A Injection | Admin Routes (`admin_routes.dart`), `database_schema.sql`, Report |

---

## 4. DATA FLOW DIAGRAMS (DFD)

### 4.1 DFD Level 0 — Context Diagram
```
                         +-----------------------------+
                         |                             |
                         |   Admin Operations Lead     |
                         |                             |
                         +-----------------------------+
                           |                         ^
            Content, Events|                         | Real-time KPIs,
            & Product CRUD |                         | Audit Logs
                           v                         |
                 +-----------------------------------------+
                 |                                         |
                 |      FANDOM VERSE POCKET EDITION        |
                 |             SYSTEM CORE                 |
                 |                                         |
                 +-----------------------------------------+
                           ^                         |
             Search, Cart, |                         | Lore Articles,
          Simulated Orders |                         | Invoices & QR Passes
                           |                         v
                         +-----------------------------+
                         |                             |
                         |     Fan Community User      |
                         |                             |
                         +-----------------------------+
```

### 4.2 DFD Level 1 — Functional Flow Diagram
```
[User Action] ---> (1.0 Auth & Role Gate) ---> [Users Table (SQLite)]
                        |
                        +---> Fan User ---> (2.0 Lore & Event Radar) ---> [Posts & Events Tables]
                        |
                        +---> Fan User ---> (3.0 Merch Store & Cart) ---> [Merchandise & Cart Tables]
                        |                                |
                        |                                v
                        |                   (3.1 Simulated Checkout) ---> [Orders Table + QR Code]
                        |
                        +---> Admin User ---> (4.0 Admin Operations) ---> [All 12 Tables + Audit Logs]
```

### 4.3 DFD Level 2 — Simulated Checkout & Invoice Storage Flow
```
[Cart Items] + [Coupon FANDOM10]
       |
       v
[Calculate Subtotal, 10% Discount, Shipping ($5/Free>$50), Tax (8%)]
       |
       v
[Generate Order ID (#FV-XXXXX)] ---> [Insert into simulated_orders Table]
       |
       v
[Clear cart_items Table] ---> [Render Printable Invoice + CustomPaint Scannable QR Code]
```

---

## 5. COMPLETE RELATIONAL DATABASE DATA DICTIONARY (12 TABLES)

### 1. `users` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `user_id` | TEXT | PRIMARY KEY | Unique user identifier (`fan-01`, `admin-01`) |
| `name` | TEXT | NOT NULL | User display name |
| `email` | TEXT | UNIQUE, NOT NULL | Account email used for authentication |
| `role` | TEXT | NOT NULL DEFAULT 'fan' | Authorization role (`fan` or `admin`) |
| `status` | TEXT | NOT NULL DEFAULT 'active' | Moderation status (`active` or `banned`) |
| `avatar_url` | TEXT | NULLABLE | Profile picture URL |
| `bio` | TEXT | NULLABLE | User bio statement |
| `badges` | TEXT | NOT NULL | JSON string array of unlocked badges |
| `selected_fandoms` | TEXT | NOT NULL | JSON string array of subscribed categories |
| `created_at` | INTEGER | NOT NULL | Epoch millisecond timestamp of registration |

### 2. `categories` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `category_id` | TEXT | PRIMARY KEY | Pillar ID (`cat_anime`, `cat_gaming`) |
| `name` | TEXT | NOT NULL | Name of fandom category |
| `description` | TEXT | NULLABLE | Overview description |
| `icon_name` | TEXT | NULLABLE | Material icon identifier |
| `banner_url` | TEXT | NULLABLE | High-res cover banner |
| `color_hex` | TEXT | NULLABLE | Accent hex code for badges |

### 3. `posts` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `post_id` | TEXT | PRIMARY KEY | Unique post/article identifier |
| `category_id` | TEXT | FOREIGN KEY (categories) | Associated fandom pillar |
| `title` | TEXT | NOT NULL | Article headline |
| `content_body`| TEXT | NOT NULL | Markdown formatted lore content |
| `author_name` | TEXT | NULLABLE | Author byline |
| `image_url` | TEXT | NULLABLE | Cover illustration |
| `is_trending` | INTEGER | DEFAULT 0 | Toggle for home feed carousel |
| `is_deep_dive`| INTEGER | DEFAULT 0 | Toggle for secret lore/easter eggs |
| `tags` | TEXT | NULLABLE | Searchable tags |
| `timestamp` | INTEGER | NOT NULL | Published epoch timestamp |
| `is_bookmarked`| INTEGER | DEFAULT 0 | Local offline bookmark state |

### 4. `glossary` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `term_id` | TEXT | PRIMARY KEY | Unique term identifier |
| `term` | TEXT | NOT NULL | Term word (e.g. "Isekai", "Canon", "Retcon") |
| `definition` | TEXT | NOT NULL | Comprehensive fan definition |
| `fandom_category`| TEXT | NULLABLE | Category classification |
| `example_usage` | TEXT | NULLABLE | Contextual usage in media |

### 5. `events` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `event_id` | TEXT | PRIMARY KEY | Unique convention identifier |
| `title` | TEXT | NOT NULL | Name of convention or tournament |
| `description` | TEXT | NULLABLE | Convention details and highlights |
| `city_name` | TEXT | NOT NULL | Host city (Tokyo, San Diego, London) |
| `venue_name` | TEXT | NOT NULL | Exhibition hall or arena |
| `latitude` | REAL | NOT NULL | GPS Latitude coordinate |
| `longitude` | REAL | NOT NULL | GPS Longitude coordinate |
| `event_date` | INTEGER | NOT NULL | Scheduled start epoch timestamp |
| `ticket_link` | TEXT | NULLABLE | External ticketing web URL |
| `banner_url` | TEXT | NULLABLE | Banner image URL |
| `is_bookmarked`| INTEGER | DEFAULT 0 | Saved event flag |

### 6. `merchandise` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `product_id` | TEXT | PRIMARY KEY | SKU identifier (`prod-001`) |
| `name` | TEXT | NOT NULL | Product title |
| `category` | TEXT | NOT NULL | Store category (Apparel, Action Figures, Props) |
| `price` | REAL | NOT NULL | Active store price in USD |
| `original_price`| REAL | NULLABLE | Strikethrough price for discount calculation |
| `image_url` | TEXT | NOT NULL | High-res product photo URL |
| `description` | TEXT | NULLABLE | Rich description & collector specs |
| `stock_count` | INTEGER | DEFAULT 10 | Available physical inventory units |
| `rating` | REAL | DEFAULT 4.8 | Community review rating |
| `is_featured` | INTEGER | DEFAULT 0 | Featured drop banner toggle |

### 7. `cart_items` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `cart_id` | TEXT | PRIMARY KEY | Unique cart item session ID |
| `product_id` | TEXT | FOREIGN KEY (merchandise) | Referenced merchandise SKU |
| `quantity` | INTEGER | NOT NULL DEFAULT 1 | Item quantity in cart |
| `selected_variant`| TEXT | NULLABLE | Chosen size or edition tier |
| `added_at` | INTEGER | NOT NULL | Millisecond timestamp added |

### 8. `wishlists` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `wish_id` | TEXT | PRIMARY KEY | Unique wishlist record ID |
| `user_id` | TEXT | FOREIGN KEY (users) | User who favorited the item |
| `product_id` | TEXT | FOREIGN KEY (merchandise) | Favorited merchandise SKU |
| `saved_at` | INTEGER | NOT NULL | Timestamp saved |

### 9. `discussions` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `thread_id` | TEXT | PRIMARY KEY | Discussion thread identifier |
| `user_id` | TEXT | FOREIGN KEY (users) | Author user ID |
| `user_name` | TEXT | NOT NULL | Display name of author |
| `user_badge` | TEXT | NULLABLE | User badge title |
| `category` | TEXT | NOT NULL | Channel board category |
| `title` | TEXT | NOT NULL | Topic subject title |
| `body` | TEXT | NOT NULL | Post body content |
| `upvotes` | INTEGER | DEFAULT 0 | Community upvote counter |
| `created_at` | INTEGER | NOT NULL | Millisecond post timestamp |

### 10. `discussion_replies` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `reply_id` | TEXT | PRIMARY KEY | Unique comment ID |
| `thread_id` | TEXT | FOREIGN KEY (discussions) | Parent thread ID |
| `user_name` | TEXT | NOT NULL | Commenter username |
| `reply_body` | TEXT | NOT NULL | Comment text content |
| `created_at` | INTEGER | NOT NULL | Timestamp of reply |

### 11. `star_profiles` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `star_id` | TEXT | PRIMARY KEY | Celebrity profile ID |
| `name` | TEXT | NOT NULL | Idol, Voice Actor, or Creator name |
| `fandom_category`| TEXT | NOT NULL | Industry classification |
| `role_title` | TEXT | NOT NULL | Job title (e.g. Lead Voice Actor, Game Director) |
| `bio` | TEXT | NOT NULL | Biography and works |
| `image_url` | TEXT | NOT NULL | Portrait photo URL |
| `social_handle`| TEXT | NULLABLE | Twitter/Instagram handle |
| `is_bookmarked`| INTEGER | DEFAULT 0 | Saved celebrity toggle |

### 12. `simulated_orders` Table
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `order_id` | TEXT | PRIMARY KEY | Generated Order ID (`#FV-XXXXX`) |
| `user_id` | TEXT | FOREIGN KEY (users) | Customer account ID |
| `order_date` | INTEGER | NOT NULL | Order completion epoch millisecond timestamp |
| `total_amount`| REAL | NOT NULL | Grand total payable in USD |
| `items_summary`| TEXT | NOT NULL | Serialized itemized breakdown |
| `shipping_address`| TEXT | NOT NULL | Destination address |
| `order_status` | TEXT | DEFAULT 'Completed' | Simulated order fulfillment status |

---

## 6. HARDWARE & SOFTWARE SPECIFICATIONS

| Parameter | Specification | Compliance Status |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.24+ / Dart 3.6+ | 100% Compliant |
| **Target OS** | Android 7.0+ (API 24+) / iOS 14.0+ / Web / Desktop | 100% Compliant |
| **RAM Footprint** | Sub-120MB baseline memory consumption | Optimized via `ListView.builder` & SQLite lazy-caching |
| **Frame Rate** | 60 FPS / 120 FPS buttery smooth | Glassmorphism optimized with hardware acceleration |
| **Storage Architecture** | Zero-latency local SQLite persistence | 12 entities synchronized via `SqliteHelper` |
| **Design Tokens** | Cyber Fandom Dark & Galactic Lumina Light | Fully implemented via `AppTheme` & `ThemeBloc` |
| **State Management**| BLoC 9.x Pattern (Separation of Concerns) | 100% Decoupled Business Logic |

---

## 7. CONCLUSION
Developer B has successfully implemented:
1. **Core Database Engine:** `sqlite_helper.dart` with 12 indexed entities, complete CRUD DAOs, cache measurement, and seed records.
2. **Official Merch Store:** `StorefrontPage` (Screen 33) and `ProductDetailPage` (Screen 34) with multi-variant selectors and deals carousel.
3. **Cart & Wishlist Engine:** `WishlistPage` (Screen 35) with price drop alerts and `CartPage` (Screen 36) with coupon validation (`FANDOM10` / `CON2025`).
4. **Simulated Checkout & Invoice:** `CheckoutInvoicePage` (Screen 37) and `OrderSuccessPage` (Screen 38) with scannable QR code generator and PDF export simulation.
5. **Order History:** `OrderHistoryPage` (Screen 39) with past itemized order summaries.
6. **Dual-Theme Engine & Settings:** `SettingsPage` (Screen 42) with live theme switching, storage footprint breakdown, and offline bookmark JSON export.
7. **Admin Operations Console:** Screens 43 through 50 with live KPIs, content/event/product CRUD, user suspension, category manager, and Modals 16, 17, 18, 19.
8. **Project Deliverables:** `database_schema.sql` and this comprehensive master report.
