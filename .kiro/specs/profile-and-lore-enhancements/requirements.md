# Requirements Document

## Introduction

This document specifies the requirements for enhancements to the Fandom Verse Flutter application's Profile and Lore Hub features. The enhancements include profile picture upload capabilities, bio field persistence fixes, fandom preference management, content filtering, FAQ viewing, glossary detail pages, media navigation fixes, and trivia display improvements. These features improve user personalization, content discovery, and knowledge exploration within the offline-first Flutter application using BLoC state management and SQLite database.

## Glossary

- **Fan**: A user with role 'fan' in the users table who can personalize profile and browse content
- **Profile_Picture**: An image file selected from device gallery or camera representing the Fan
- **Bio**: A text field in the users table storing the Fan's biographical information
- **Fandom_Preference**: A category from the categories table that a Fan has marked as liked
- **Content_Filter**: A mechanism that shows only posts matching the Fan's selected Fandom_Preferences
- **FAQ_Entry**: A static question and answer pair displayed in the profile section
- **Glossary_Term**: An entry in the glossary table with term, definition, phonetic, fandom_category, and example_usage
- **Glossary_Details_Page**: A dedicated page displaying complete information for a single Glossary_Term
- **Media_Page**: The third tab in Lore Hub showing fan art gallery
- **Deep_Dive_Trivia**: Interactive quiz questions in the Deep Dive tab with multiple choice answers
- **Trivia_Results**: The score display and question feedback shown after answering Deep_Dive_Trivia
- **Advanced_Lore**: Additional deep lore content stored in the database for specific fandoms
- **Behind_The_Scenes**: Production and creation information for fandom content
- **Interviews**: Q&A content with creators, voice actors, or fandom personalities
- **Skeleton_Loader**: A loading placeholder component that should display during data fetch operations
- **Image_Picker**: The Flutter image_picker package for selecting images from gallery or camera
- **SQLite_Database**: The local fandom_verse.db database accessed through SqliteHelper
- **Profile_Bloc**: The BLoC managing profile state and events
- **FandomHub_Bloc**: The BLoC managing lore hub state including glossary and trivia
- **Auth_Bloc**: The BLoC managing authentication state and current user information

## Requirements

### Requirement 1: Profile Picture Upload

**User Story:** As a Fan, I want to upload a profile picture from my device gallery or camera, so that I can personalize my profile appearance.

#### Acceptance Criteria

1. WHEN a Fan taps the camera icon on the edit profile page, THE Application SHALL display a bottom sheet with "Gallery" and "Camera" options
2. WHEN a Fan selects "Gallery", THE Application SHALL open the device image picker in gallery mode
3. WHEN a Fan selects "Camera", THE Application SHALL open the device camera
4. WHEN a Fan selects an image from gallery or captures with camera, THE Application SHALL display the selected image as an instant preview in the profile avatar circle
5. WHEN a Fan saves the profile with a new profile picture, THE Profile_Bloc SHALL store the image file path in the avatar_url field of the users table
6. WHEN a Fan views their profile after saving, THE Application SHALL display the uploaded profile picture in the avatar circle
7. IF image selection fails or is cancelled, THEN THE Application SHALL display a snackbar message "Image selection cancelled" and retain the existing avatar
8. WHEN a Fan has no profile picture, THE Application SHALL display the first letter of their name in the avatar circle with the existing colored background

### Requirement 2: Bio Field Persistence Fix

**User Story:** As a Fan, I want my bio text to be saved and displayed correctly, so that my profile information persists across sessions.

#### Acceptance Criteria

1. WHEN a Fan enters text in the bio field and saves, THE Profile_Bloc SHALL update the bio column in the users table for that Fan's user_id
2. WHEN a Fan navigates away from edit profile after saving, THE SQLite_Database SHALL contain the updated bio text
3. WHEN a Fan views the edit profile page again, THE Application SHALL display the saved bio text in the bio input field
4. WHEN a Fan views their profile page, THE Application SHALL display the saved bio text in the profile details section (not in the home city field)
5. IF the bio field is empty when saving, THEN THE Profile_Bloc SHALL store an empty string in the bio column
6. WHEN the Auth_Bloc loads user profile on app start, THE Application SHALL retrieve the bio text from the users table and include it in the UserEntity

### Requirement 3: Fandom Liking System

**User Story:** As a Fan, I want to like fandoms and see my liked fandoms on my profile, so that I can track my favorite fandom categories.

#### Acceptance Criteria

1. WHEN a Fan views a fandom category card, THE Application SHALL display a heart icon button on the card
2. WHEN a Fan taps the heart icon on an unliked fandom, THE Application SHALL add that category_id to a new liked_fandoms TEXT column in the users table as a JSON array
3. WHEN a Fan taps the heart icon on a liked fandom, THE Application SHALL remove that category_id from the liked_fandoms JSON array
4. WHEN a Fan views a fandom category they have liked, THE Application SHALL display a filled heart icon in red color
5. WHEN a Fan views a fandom category they have not liked, THE Application SHALL display an outlined heart icon in secondary text color
6. WHEN a Fan views their profile page, THE Application SHALL display a "Liked Fandoms" section showing all category names from their liked_fandoms list
7. WHEN a Fan has no liked fandoms, THE Application SHALL display "No liked fandoms yet. Explore and like your favorites!" in the profile section
8. WHEN a Fan likes a fandom, THE Profile_Bloc SHALL update the liked_fandoms column in the SQLite_Database within 500 milliseconds

### Requirement 4: Preference-Based Content Filtering

**User Story:** As a Fan, I want to see content filtered by my preferences, so that I view posts relevant to my interests.

#### Acceptance Criteria

1. WHEN a Fan has selected preferences in the selected_fandoms field, THE Application SHALL use those category names as the content filter
2. WHEN a Fan views the home feed, THE Application SHALL query the posts table WHERE category_id matches any category in the Fan's selected_fandoms JSON array
3. WHEN a Fan has no selected preferences, THE Application SHALL display all posts from the posts table
4. WHEN a Fan updates their preferences through the interest selection flow, THE Application SHALL immediately re-query the posts table with the updated filter
5. WHEN a Fan views filtered content, THE Application SHALL display a chip or badge showing "Showing posts from [preference names]"
6. WHEN a Fan taps the filter badge, THE Application SHALL navigate to the preferences selection page
7. FOR ALL posts displayed, the timestamp SHALL be in descending order (newest first)
8. WHEN filtered posts are empty, THE Application SHALL display "No posts found for your preferences. Try selecting more fandoms!"

### Requirement 5: FAQ Viewer in Profile

**User Story:** As a Fan, I want to view frequently asked questions from my profile page, so that I can learn about the application features.

#### Acceptance Criteria

1. WHEN a Fan views the profile page, THE Application SHALL display an "FAQ" button or list tile in the profile settings section
2. WHEN a Fan taps the FAQ option, THE Application SHALL navigate to a dedicated FAQ page
3. THE FAQ page SHALL display at least 8 static question and answer pairs as expansion tiles
4. WHEN a Fan taps an FAQ question tile, THE Application SHALL expand the tile to reveal the answer text
5. WHEN a Fan taps an expanded FAQ tile, THE Application SHALL collapse the tile to hide the answer
6. THE FAQ entries SHALL include topics: account management, content discovery, offline features, community guidelines, merchandise, events, profile customization, and technical support
7. THE FAQ page SHALL include a search field that filters FAQ entries by question or answer text
8. WHEN a Fan types in the FAQ search field, THE Application SHALL display only FAQ entries containing the search text (case-insensitive)

### Requirement 6: Glossary Details Page

**User Story:** As a Fan, I want to view detailed information when clicking a glossary term, so that I can learn more about fandom terminology.

#### Acceptance Criteria

1. WHEN a Fan taps a glossary term card in the Glossary tab, THE Application SHALL navigate to a Glossary_Details_Page
2. THE Glossary_Details_Page SHALL display the term, phonetic pronunciation, definition, fandom_category, and example_usage from the glossary table
3. THE Glossary_Details_Page SHALL display a bookmark icon button that toggles the is_bookmarked value in the glossary table
4. WHEN a Fan taps the bookmark icon, THE FandomHub_Bloc SHALL update the is_bookmarked column for that term_id within 300 milliseconds
5. THE Glossary_Details_Page SHALL display a "Related Terms" section showing 3-5 other terms with the same fandom_category
6. WHEN a Fan taps a related term, THE Application SHALL navigate to that term's Glossary_Details_Page
7. THE Glossary_Details_Page SHALL include a back button in the app bar that returns to the Glossary tab
8. THE Glossary_Details_Page SHALL display a share icon that opens the native share dialog with the term and definition text

### Requirement 7: Media Page Navigation Fix

**User Story:** As a Fan, I want the media tab to display content without errors, so that I can browse fan art galleries.

#### Acceptance Criteria

1. WHEN a Fan taps the Media tab in Lore Hub, THE Application SHALL display the fan art gallery grid without "page not found" errors
2. WHEN a Fan taps a gallery item, THE Application SHALL navigate to a gallery detail view using an existing route
3. IF the '/gallery-view' route does not exist, THEN THE Application SHALL create the route in the app router with proper route registration
4. THE gallery detail view SHALL display the selected artwork image, title, artist name, and like count
5. THE gallery detail view SHALL include a back button that returns to the Media tab
6. WHEN the Media tab is loading data, THE Application SHALL display Skeleton_Loader placeholders in a 2-column grid
7. IF gallery data fails to load, THEN THE Application SHALL display "Unable to load gallery. Please try again." with a retry button
8. WHEN a Fan taps the retry button, THE FandomHub_Bloc SHALL re-fetch gallery data from the SQLite_Database or network

### Requirement 8: Deep Dive Trivia Results Display Fix

**User Story:** As a Fan, I want to see trivia results after answering questions, so that I know my score and can learn from explanations.

#### Acceptance Criteria

1. WHEN a Fan selects an answer option in Deep_Dive_Trivia, THE Application SHALL highlight the selected option with a border
2. WHEN the correct answer is index N, THE Application SHALL highlight option N with a green background color (AppColors.success with 15% opacity)
3. WHEN the selected answer is incorrect and is index M, THE Application SHALL highlight option M with a red background color (AppColors.error with 15% opacity)
4. WHEN a Fan answers a question, THE Application SHALL display the explanation text from the trivia question data in a glass container below the options
5. WHEN a Fan completes all trivia questions, THE Application SHALL display the final score as "Score: X / Y" where X is correct answers and Y is total questions
6. THE trivia score container SHALL use AppColors.darkAccentGold for the background and text color
7. WHEN trivia state is not displaying results, THEN THE Trivia_Results section SHALL be hidden
8. WHEN a Fan taps "Next Question" or "Restart Trivia", THE Application SHALL reset the answer highlight colors and hide the explanation container

### Requirement 9: Advanced Lore Section

**User Story:** As a Fan, I want to access advanced lore content in the Deep Dive tab, so that I can learn deeper fandom knowledge.

#### Acceptance Criteria

1. THE Deep Dive tab SHALL include a new "Advanced Lore" section below the trivia section
2. THE SQLite_Database SHALL include a new table advanced_lore with columns: lore_id TEXT PRIMARY KEY, fandom_category TEXT, title TEXT, content_body TEXT, difficulty_level TEXT, created_at INTEGER
3. WHEN a Fan scrolls to the Advanced Lore section, THE FandomHub_Bloc SHALL query the advanced_lore table
4. THE Application SHALL display advanced lore entries as expandable cards with title and difficulty_level badge
5. WHEN a Fan taps an advanced lore card, THE Application SHALL expand the card to show the full content_body
6. THE advanced lore cards SHALL use color coding: "Beginner" (green), "Intermediate" (orange), "Expert" (red)
7. WHEN no advanced lore entries exist in the database, THE Application SHALL display "Advanced lore content coming soon!"
8. WHEN advanced lore is loading, THE Application SHALL display Skeleton_Loader placeholders

### Requirement 10: Behind The Scenes Section

**User Story:** As a Fan, I want to view behind the scenes content, so that I can learn about production and creation processes.

#### Acceptance Criteria

1. THE Deep Dive tab SHALL include a new "Behind the Scenes" section below the Advanced Lore section
2. THE SQLite_Database SHALL include a new table behind_scenes with columns: scene_id TEXT PRIMARY KEY, fandom_category TEXT, title TEXT, description TEXT, media_type TEXT, media_url TEXT, created_at INTEGER
3. WHEN a Fan scrolls to the Behind the Scenes section, THE FandomHub_Bloc SHALL query the behind_scenes table
4. THE Application SHALL display behind the scenes entries as cards with thumbnail image, title, and media type icon
5. WHEN a Fan taps a behind the scenes card, THE Application SHALL navigate to a detail page showing the full description and media content
6. WHERE media_type is "video", THE Application SHALL display a video player component
7. WHERE media_type is "image", THE Application SHALL display the image with zoom capability
8. WHERE media_type is "article", THE Application SHALL display formatted text content

### Requirement 11: Interviews Section

**User Story:** As a Fan, I want to read interviews with creators and personalities, so that I can gain insights into fandom content.

#### Acceptance Criteria

1. THE Deep Dive tab SHALL include a new "Interviews" section below the Behind the Scenes section
2. THE SQLite_Database SHALL include a new table interviews with columns: interview_id TEXT PRIMARY KEY, interviewee_name TEXT, role_title TEXT, fandom_category TEXT, interview_date INTEGER, questions_json TEXT, image_url TEXT
3. WHEN a Fan scrolls to the Interviews section, THE FandomHub_Bloc SHALL query the interviews table
4. THE Application SHALL display interview entries as cards showing interviewee_name, role_title, and thumbnail image
5. WHEN a Fan taps an interview card, THE Application SHALL navigate to an interview detail page
6. THE interview detail page SHALL parse the questions_json field and display each question and answer pair in a formatted layout
7. THE interview detail page SHALL display the interviewee_name, role_title, image_url, and interview_date at the top
8. WHEN the interviews table is empty, THE Application SHALL display "Check back soon for exclusive interviews!"

### Requirement 12: Skeleton Loader Display Fix

**User Story:** As a Fan, I want to see loading placeholders while content loads, so that I know the app is fetching data.

#### Acceptance Criteria

1. WHEN the Glossary tab state is not FandomHubLoaded, THE Application SHALL display 6 Skeleton_Loader rectangles with height 80 and borderRadius 12
2. WHEN the Media tab state is not FandomHubLoaded, THE Application SHALL display 6 Skeleton_Loader rectangles in a 2-column grid with aspect ratio 0.85
3. WHEN the Advanced Lore section is loading, THE Application SHALL display 3 Skeleton_Loader rectangles with height 100
4. WHEN the Behind the Scenes section is loading, THE Application SHALL display 4 Skeleton_Loader rectangles in a 2-column grid
5. WHEN the Interviews section is loading, THE Application SHALL display 3 Skeleton_Loader rectangles with height 120
6. THE Skeleton_Loader component SHALL animate with a shimmer effect using the existing SkeletonLoader widget
7. WHEN data load completes, THE Application SHALL replace all Skeleton_Loader components with actual content within 100 milliseconds
8. IF data load fails, THEN THE Application SHALL replace Skeleton_Loader with error message and retry button

## Database Schema Changes

The following tables must be added to the SQLite_Database to support the new requirements:

```sql
-- For Requirement 9: Advanced Lore
CREATE TABLE IF NOT EXISTS advanced_lore (
    lore_id TEXT PRIMARY KEY,
    fandom_category TEXT NOT NULL,
    title TEXT NOT NULL,
    content_body TEXT NOT NULL,
    difficulty_level TEXT DEFAULT 'Intermediate',
    created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_advanced_lore_category ON advanced_lore(fandom_category);

-- For Requirement 10: Behind The Scenes
CREATE TABLE IF NOT EXISTS behind_scenes (
    scene_id TEXT PRIMARY KEY,
    fandom_category TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    media_type TEXT NOT NULL,
    media_url TEXT,
    created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_behind_scenes_category ON behind_scenes(fandom_category);

-- For Requirement 11: Interviews
CREATE TABLE IF NOT EXISTS interviews (
    interview_id TEXT PRIMARY KEY,
    interviewee_name TEXT NOT NULL,
    role_title TEXT NOT NULL,
    fandom_category TEXT NOT NULL,
    interview_date INTEGER NOT NULL,
    questions_json TEXT NOT NULL,
    image_url TEXT,
    created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_interviews_category ON interviews(fandom_category);

-- For Requirement 3: Fandom Liking System (alter existing users table)
-- Add column: liked_fandoms TEXT (stores JSON array of category_ids)
```

## Static FAQ Content

For Requirement 5, the following FAQ entries should be implemented:

1. **Q:** How do I personalize my profile?  
   **A:** Navigate to Profile > Edit Profile to upload a profile picture, update your bio, and manage your interests.

2. **Q:** How does content filtering work?  
   **A:** Select your favorite fandoms in the interest selection screen. Your home feed will show posts matching your preferences.

3. **Q:** Can I use the app offline?  
   **A:** Yes! Fandom Verse is offline-first. Browse cached posts, glossary, and events without internet.

4. **Q:** How do I bookmark content?  
   **A:** Tap the bookmark icon on any post, glossary term, or event to save it for later viewing.

5. **Q:** How do I report inappropriate content?  
   **A:** Long-press any post or discussion and select "Report". Our admin team reviews all reports within 24 hours.

6. **Q:** How do I purchase merchandise?  
   **A:** Browse the Store tab, add items to your cart, and complete checkout. We support cash on delivery and card payments.

7. **Q:** How do I RSVP to conventions?  
   **A:** Navigate to the Events tab, find your convention, and tap "RSVP". We'll send you reminders before the event.

8. **Q:** I found a bug. Where do I report it?  
   **A:** Email support@fandomverse.com with your device model, app version, and a description of the issue.

## Parser and Serializer Requirements

### Requirement 13: User Profile Serialization

**User Story:** As the Application, I need to serialize and deserialize UserEntity objects, so that user profile data persists correctly.

#### Acceptance Criteria

1. THE UserEntity class SHALL include a toMap() method that converts all fields to a Map<String, dynamic>
2. THE UserEntity class SHALL include a fromMap() factory constructor that creates a UserEntity from a Map<String, dynamic>
3. WHEN selected_fandoms is a List, THE toMap() method SHALL serialize it as a JSON string using jsonEncode
4. WHEN liked_fandoms is a List, THE toMap() method SHALL serialize it as a JSON string using jsonEncode
5. WHEN badges is a List, THE toMap() method SHALL serialize it as a JSON string using jsonEncode
6. THE fromMap() method SHALL deserialize JSON strings back to List<String> using jsonDecode
7. FOR ALL valid UserEntity objects, parsing the Map from toMap() with fromMap() SHALL produce an equivalent UserEntity (round-trip property)
8. IF a field is null in the Map, THEN THE fromMap() method SHALL use appropriate default values (empty string for text, empty list for arrays)

### Requirement 14: Glossary Term Serialization

**User Story:** As the Application, I need to serialize and deserialize GlossaryTerm objects, so that glossary data persists correctly.

#### Acceptance Criteria

1. THE GlossaryTerm class SHALL include a toMap() method that converts all fields to a Map<String, dynamic>
2. THE GlossaryTerm class SHALL include a fromMap() factory constructor that creates a GlossaryTerm from a Map<String, dynamic>
3. THE fromMap() method SHALL handle the phonetic field being null with a default empty string
4. THE fromMap() method SHALL convert the is_bookmarked INTEGER (0 or 1) to a boolean value
5. FOR ALL valid GlossaryTerm objects, parsing the Map from toMap() with fromMap() SHALL produce an equivalent GlossaryTerm (round-trip property)
6. WHEN a Map contains unexpected field types, THEN THE fromMap() method SHALL throw a FormatException with a descriptive error message
