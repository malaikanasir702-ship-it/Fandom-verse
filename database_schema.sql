-- ================================================================================
-- FANDOM VERSE POCKET EDITION — ENTERPRISE DATABASE SCHEMA & SEED SCRIPT
-- Developer B Deliverable: SQLite 3.x Compliant DDL & DML Architecture
-- Database Name: fandom_verse.db
-- Generated for Cross-Platform Offline-First Synchronization
-- ================================================================================

PRAGMA foreign_keys = ON;

-- --------------------------------------------------------------------------------
-- 1. USERS TABLE (Fan & Admin Accounts, Roles, Badges, Fandom Preferences)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS users;
CREATE TABLE IF NOT EXISTS users (
    user_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL DEFAULT 'fan', -- 'fan' or 'admin'
    status TEXT NOT NULL DEFAULT 'active', -- 'active' or 'banned'
    avatar_url TEXT,
    bio TEXT,
    badges TEXT,                      -- JSON Array of string badges
    selected_fandoms TEXT,            -- JSON Array of selected categories
    created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- --------------------------------------------------------------------------------
-- 2. FANDOM CATEGORIES TABLE (Pillars of Fandom Universe)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS categories;
CREATE TABLE IF NOT EXISTS categories (
    category_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    icon_name TEXT,
    banner_url TEXT,
    color_hex TEXT
);

-- --------------------------------------------------------------------------------
-- 3. POSTS & LORE ARTICLES TABLE (Feed, Primers, Guides, Deep-Dive Lore)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS posts;
CREATE TABLE IF NOT EXISTS posts (
    post_id TEXT PRIMARY KEY,
    category_id TEXT NOT NULL,
    title TEXT NOT NULL,
    content_body TEXT NOT NULL,
    author_name TEXT,
    image_url TEXT,
    is_trending INTEGER DEFAULT 0,
    is_deep_dive INTEGER DEFAULT 0,
    tags TEXT,
    timestamp INTEGER NOT NULL,
    is_bookmarked INTEGER DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_posts_category ON posts(category_id);
CREATE INDEX IF NOT EXISTS idx_posts_trending ON posts(is_trending);
CREATE INDEX IF NOT EXISTS idx_posts_bookmarked ON posts(is_bookmarked);

-- --------------------------------------------------------------------------------
-- 4. FANDOM GLOSSARY TABLE (50+ Lexicon & Fan Slang Terms)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS glossary;
CREATE TABLE IF NOT EXISTS glossary (
    term_id TEXT PRIMARY KEY,
    term TEXT NOT NULL,
    definition TEXT NOT NULL,
    fandom_category TEXT,
    example_usage TEXT
);

CREATE INDEX IF NOT EXISTS idx_glossary_term ON glossary(term);

-- --------------------------------------------------------------------------------
-- 5. CONVENTIONS & EVENTS TABLE (GPS Radar, Venues, Ticketing)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS events;
CREATE TABLE IF NOT EXISTS events (
    event_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    city_name TEXT NOT NULL,
    venue_name TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    event_date INTEGER NOT NULL,
    ticket_link TEXT,
    banner_url TEXT,
    is_bookmarked INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_events_city ON events(city_name);
CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date);

-- --------------------------------------------------------------------------------
-- 6. MERCHANDISE CATALOG TABLE (Official Store Products & Props)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS merchandise;
CREATE TABLE IF NOT EXISTS merchandise (
    product_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    price REAL NOT NULL,
    original_price REAL,
    image_url TEXT NOT NULL,
    description TEXT,
    stock_count INTEGER DEFAULT 10,
    rating REAL DEFAULT 4.8,
    is_featured INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_merch_category ON merchandise(category);
CREATE INDEX IF NOT EXISTS idx_merch_price ON merchandise(price);

-- --------------------------------------------------------------------------------
-- 7. CART ITEMS TABLE (Simulated Cart Sessions)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS cart_items;
CREATE TABLE IF NOT EXISTS cart_items (
    cart_id TEXT PRIMARY KEY,
    product_id TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    selected_variant TEXT,
    added_at INTEGER NOT NULL,
    FOREIGN KEY (product_id) REFERENCES merchandise(product_id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------------------
-- 8. WISHLIST TABLE (Saved Merchandise with Price Drop Watch)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS wishlists;
CREATE TABLE IF NOT EXISTS wishlists (
    wish_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    saved_at INTEGER NOT NULL,
    FOREIGN KEY (product_id) REFERENCES merchandise(product_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_wishlists_user ON wishlists(user_id);

-- --------------------------------------------------------------------------------
-- 9. COMMUNITY DISCUSSIONS TABLE (Topic Boards, Upvotes)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS discussions;
CREATE TABLE IF NOT EXISTS discussions (
    thread_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    user_badge TEXT,
    category TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    upvotes INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL
);

-- --------------------------------------------------------------------------------
-- 10. DISCUSSION REPLIES TABLE (Nested Community Comments)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS discussion_replies;
CREATE TABLE IF NOT EXISTS discussion_replies (
    reply_id TEXT PRIMARY KEY,
    thread_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    reply_body TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (thread_id) REFERENCES discussions(thread_id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------------------
-- 11. CELEBRITY & STAR PROFILES TABLE (Voice Actors, Idols, Directors)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS star_profiles;
CREATE TABLE IF NOT EXISTS star_profiles (
    star_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    fandom_category TEXT NOT NULL,
    role_title TEXT NOT NULL,
    bio TEXT NOT NULL,
    image_url TEXT NOT NULL,
    social_handle TEXT,
    is_bookmarked INTEGER DEFAULT 0
);

-- --------------------------------------------------------------------------------
-- 12. SIMULATED ORDERS TABLE (Itemized Bills, QR Tokens, Tracking)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS simulated_orders;
CREATE TABLE IF NOT EXISTS simulated_orders (
    order_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    order_date INTEGER NOT NULL,
    total_amount REAL NOT NULL,
    items_summary TEXT NOT NULL,
    shipping_address TEXT NOT NULL,
    order_status TEXT DEFAULT 'Completed'
);

-- --------------------------------------------------------------------------------
-- 13. ADMIN AUDIT LOGS TABLE (Console Action Tracking)
-- --------------------------------------------------------------------------------
DROP TABLE IF EXISTS admin_audit_logs;
CREATE TABLE IF NOT EXISTS admin_audit_logs (
    log_id TEXT PRIMARY KEY,
    action_type TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    description TEXT NOT NULL,
    admin_email TEXT NOT NULL,
    timestamp INTEGER NOT NULL
);

-- ================================================================================
-- INITIAL SEED RECORDS (POPULATION DML)
-- ================================================================================

-- Users (Pre-configured Test Accounts)
INSERT INTO users (user_id, name, email, role, status, avatar_url, bio, badges, selected_fandoms, created_at)
VALUES 
('admin-01', 'Fandom Commander', 'admin@fandomverse.com', 'admin', 'active', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400', 'Lead Operations Administrator & Curator', '["Admin Commander", "System Architect"]', '["All"]', 1700000000),
('fan-01', 'Alex Mercer', 'fan@fandomverse.com', 'fan', 'active', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400', 'Anime & Gaming enthusiast', '["Master Lorekeeper", "Con Veteran 2025"]', '["Anime & Manga", "Gaming & Esports"]', 1700000000);

-- Categories
INSERT INTO categories (category_id, name, description, icon_name, banner_url, color_hex)
VALUES 
('cat_anime', 'Anime & Manga', 'Cosplay, Graphic Novels, Shonen & Seinen lore primers.', 'auto_awesome', 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800', '#9C27B0'),
('cat_gaming', 'Gaming & Esports', 'Speedruns, open-world RPG builds, competitive tournament meta.', 'sports_esports', 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800', '#00E676'),
('cat_scifi', 'Sci-Fi & Fantasy', 'Space operas, cybernetic lore, multi-century chronicles.', 'rocket_launch', 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800', '#00E5FF'),
('cat_comics', 'Marvel & DC Comics', 'Multiverse timelines, superhero dynasties, crossover arcs.', 'menu_book', 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800', '#FF1744'),
('cat_kpop', 'K-Pop & Idol Culture', 'Discographies, world tours, official lightsticks, member bios.', 'music_note', 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800', '#FF4081'),
('cat_movies', 'Pop Culture & Movies', 'Cinematic sagas, film festival debuts, directors cuts.', 'movie', 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800', '#FF9100');

-- Merchandise Products
INSERT INTO merchandise (product_id, name, category, price, original_price, image_url, description, stock_count, rating, is_featured)
VALUES 
('prod-001', 'Chrono Blade Neon Katana (Replica 1:1)', 'Replica Props', 149.99, 189.99, 'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=600', 'Forged high-density carbon alloy blade with interactive RGB LED edge lighting and display stand.', 6, 4.9, 1),
('prod-002', 'Cyber Otaku Oversized Hoodie [Night City]', 'Apparel', 69.50, 85.00, 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=600', 'Heavyweight 450 GSM French Terry cotton hoodie with reflective typography print and hidden thumb cuffs.', 18, 4.8, 1),
('prod-003', 'Valkyrie Prime Action Figure (Articulated)', 'Action Figures', 89.00, 110.00, 'https://images.unsplash.com/photo-1608889175123-8ee362201f81?w=600', 'Over 32 points of articulation with interchangeable hands, energy wings, and battle-damaged armor plates.', 4, 5.0, 1),
('prod-004', 'Infinite Multiverse Hardcover Omnibus Vol. 1', 'Manga/Comics', 54.99, 65.00, 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600', 'Over 850 pages collecting the legendary multiverse collision arc with exclusive author commentary.', 22, 4.7, 0),
('prod-005', 'Aero-Glow Smart Idol Lightstick v3', 'Digital Collectibles', 42.00, 50.00, 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600', 'Bluetooth synced concert lightstick capable of 16M colors with concert arena proximity sync protocol.', 35, 4.9, 1);

-- Conventions & Events
INSERT INTO events (event_id, title, description, city_name, venue_name, latitude, longitude, event_date, ticket_link, banner_url, is_bookmarked)
VALUES 
('evt-001', 'Tokyo Anime Expo 2026', 'The world’s largest gathering of animators, mangaka, voice actors, and global otaku fans at Big Sight.', 'Tokyo', 'Tokyo Big Sight Exhibition Center', 35.6298, 139.7942, 1785000000000, 'https://anime-expo.tokyo/tickets', 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800', 1),
('evt-002', 'San Diego International Comic-Con 2026', 'Hall H exclusive reveals, Hollywood superhero panels, and the world famous Masquerade cosplay contest.', 'San Diego', 'San Diego Convention Center', 32.7071, -117.1611, 1786500000000, 'https://comic-con.org/register', 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800', 1);

-- Simulated Orders
INSERT INTO simulated_orders (order_id, user_id, order_date, total_amount, items_summary, shipping_address, order_status)
VALUES 
('FV-89241', 'fan-01', 1735000000000, 204.49, 'Chrono Blade Neon Katana (x1), Mecha G-Zero Enamel Pin (x1)', 'Alex Mercer, 742 Evergreen Terrace, Sector 7-G, Neo Tokyo', 'Simulated Completed');

-- Admin Audit Logs
INSERT INTO admin_audit_logs (log_id, action_type, entity_type, description, admin_email, timestamp)
VALUES 
('log-01', 'SYSTEM_INIT', 'Core', 'Database schema initialized with 12 SQLite tables and offline indexes', 'admin@fandomverse.com', 1735000000000);
