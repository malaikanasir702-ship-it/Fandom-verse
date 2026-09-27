# Implementation Plan: Profile and Lore Enhancements

## Overview

This implementation plan breaks down 14 requirements into discrete coding tasks covering database migrations, entity creation and serialization, BLoC state management, UI components, and navigation fixes. The implementation follows Flutter/Dart best practices with BLoC pattern for state management and SQLite for offline-first data persistence.

## Tasks

- [x] 1. Database schema setup and migrations
  - Create database migration script for new tables (advanced_lore, behind_scenes, interviews)
  - Add liked_fandoms column to users table
  - Create database table constants in database_tables.dart
  - Add index creation for new tables (idx_advanced_lore_category, idx_behind_scenes_category, idx_interviews_category)
  - _Requirements: 3.2, 9.2, 10.2, 11.2_

- [x] 2. Create new domain entities
  - [x] 2.1 Create AdvancedLoreEntity with serialization methods
    - Implement fromDbMap and toDbMap methods
    - Add Equatable props
    - Include validation for difficulty levels
    - _Requirements: 9.2, 9.4_
  
  - [x] 2.2 Create BehindScenesEntity with serialization methods
    - Implement fromDbMap and toDbMap methods
    - Add Equatable props
    - Support media_type validation
    - _Requirements: 10.2, 10.4_
  
  - [x] 2.3 Create InterviewEntity with JSON parsing
    - Implement fromDbMap with questions_json parsing
    - Create QuestionAnswer nested class
    - Add toDbMap with JSON encoding
    - _Requirements: 11.2, 11.6_

- [ ] 3. Fix UserEntity serialization and add liked_fandoms
  - [ ] 3.1 Enhance UserEntity with liked_fandoms field
    - Add likedFandoms List<String> field
    - Update constructor with default empty list
    - _Requirements: 3.2, 3.8_
  
  - [ ] 3.2 Fix toMap() serialization method
    - Ensure bio field is included in map
    - Serialize liked_fandoms as JSON string
    - Serialize selected_fandoms and badges correctly
    - _Requirements: 2.1, 13.1, 13.3, 13.4_
  
  - [ ] 3.3 Fix fromMap() deserialization method
    - Create parseList helper function for JSON arrays
    - Handle null bio with empty string default
    - Parse liked_fandoms from JSON string
    - Handle both List and String types for fandoms
    - _Requirements: 2.3, 13.2, 13.6, 13.8_
  
  - [ ]* 3.4 Write unit tests for UserEntity serialization
    - Test round-trip serialization (toMap → fromMap)
    - Test null field handling
    - Test JSON array parsing for fandoms
    - _Requirements: 13.7_

- [ ] 4. Fix GlossaryTerm serialization
  - [ ] 4.1 Enhance GlossaryTerm fromMap with validation
    - Add required field validation (term_id, term)
    - Handle null phonetic with empty string
    - Convert INTEGER is_bookmarked to boolean
    - Add FormatException for invalid types
    - _Requirements: 14.2, 14.3, 14.4, 14.6_
  
  - [ ] 4.2 Verify GlossaryTerm toMap method
    - Convert boolean is_bookmarked to INTEGER (0/1)
    - Include all fields in map
    - _Requirements: 14.1_
  
  - [ ]* 4.3 Write unit tests for GlossaryTerm serialization
    - Test round-trip serialization
    - Test null phonetic handling
    - Test is_bookmarked conversion
    - Test FormatException on invalid input
    - _Requirements: 14.5_

- [ ] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Implement Profile BLoC enhancements
  - [ ] 6.1 Add new events to ProfileEvent
    - Create UpdateAvatarEvent with userId and imagePath
    - Create ToggleLikeFandomEvent with userId and categoryId
    - _Requirements: 1.5, 3.2_
  
  - [ ] 6.2 Enhance ProfileLoaded state with likedFandoms
    - Add likedFandoms List<String> field
    - Update constructor and copyWith method
    - _Requirements: 3.6_
  
  - [ ] 6.3 Implement _onUpdateAvatar event handler
    - Update avatar_url in users table using SqliteHelper
    - Trigger LoadUserProfileEvent on success
    - Emit ProfileError on failure
    - _Requirements: 1.5_
  
  - [ ] 6.4 Implement _onToggleLikeFandom event handler
    - Get current user from ProfileLoaded state
    - Add or remove categoryId from liked_fandoms list
    - Update users table with JSON encoded liked_fandoms
    - Trigger LoadUserProfileEvent to refresh state
    - _Requirements: 3.2, 3.3, 3.8_

- [ ] 7. Implement FandomHub BLoC enhancements
  - [ ] 7.1 Add new events for advanced content
    - Create LoadAdvancedLoreEvent with optional categoryFilter
    - Create LoadBehindScenesEvent with optional categoryFilter
    - Create LoadInterviewsEvent with optional categoryFilter
    - Create ToggleGlossaryBookmarkEvent for glossary details
    - _Requirements: 6.4, 9.3, 10.3, 11.4_
  
  - [ ] 7.2 Enhance FandomHubLoaded state
    - Add advancedLore List<AdvancedLoreEntity> field
    - Add behindScenes List<BehindScenesEntity> field
    - Add interviews List<InterviewEntity> field
    - Update constructor and copyWith method
    - _Requirements: 9.3, 10.3, 11.4_
  
  - [ ] 7.3 Implement _onLoadAdvancedLore event handler
    - Query advanced_lore table with optional category filter
    - Parse rows to AdvancedLoreEntity list
    - Emit FandomHubLoaded with updated advancedLore
    - Handle empty results with empty list
    - _Requirements: 9.3, 9.7_
  
  - [ ] 7.4 Implement _onLoadBehindScenes event handler
    - Query behind_scenes table with optional category filter
    - Parse rows to BehindScenesEntity list
    - Emit FandomHubLoaded with updated behindScenes
    - _Requirements: 10.3_
  
  - [ ] 7.5 Implement _onLoadInterviews event handler
    - Query interviews table with optional category filter
    - Parse rows to InterviewEntity list with JSON parsing
    - Emit FandomHubLoaded with updated interviews
    - _Requirements: 11.4_
  
  - [ ] 7.6 Implement _onToggleGlossaryBookmark event handler
    - Update is_bookmarked column in glossary table
    - Emit updated state within 300ms
    - _Requirements: 6.3, 6.4_

- [ ] 8. Checkpoint - Verify BLoC implementations
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Implement profile picture upload component
  - [ ] 9.1 Create ProfilePicturePicker widget
    - Display current avatar or name initial in colored circle
    - Add camera icon overlay button
    - Implement onImageSelected callback
    - Handle null currentAvatarUrl
    - _Requirements: 1.1, 1.8_
  
  - [ ] 9.2 Implement image source selection bottom sheet
    - Create _showImageSourceSheet method
    - Display "Gallery" and "Camera" options
    - Handle gallery selection with ImagePicker.pickImage(source: ImageSource.gallery)
    - Handle camera selection with ImagePicker.pickImage(source: ImageSource.camera)
    - _Requirements: 1.1, 1.2, 1.3_
  
  - [ ] 9.3 Implement image preview and error handling
    - Display selected image instantly in avatar circle
    - Show snackbar on image selection cancelled
    - Show snackbar on permission denied
    - Retain existing avatar on error
    - _Requirements: 1.4, 1.7_
  
  - [ ] 9.4 Integrate ProfilePicturePicker in EditProfilePage
    - Add ProfilePicturePicker to edit profile page
    - Wire onImageSelected to dispatch UpdateAvatarEvent
    - Handle save to persist avatar_url
    - Verify avatar displays on profile page after save
    - _Requirements: 1.5, 1.6_

- [ ] 10. Fix bio field persistence
  - [ ] 10.1 Verify bio TextFormField in EditProfilePage
    - Initialize TextEditingController from user.bio
    - Set maxLines to 4 and maxLength to 200
    - Add proper label and hint text
    - _Requirements: 2.1_
  
  - [ ] 10.2 Fix bio save in UpdateProfileDetailsEvent handler
    - Ensure bio value from controller is passed to event
    - Verify ProfileBloc updates bio column (not other field)
    - Handle empty bio with empty string
    - _Requirements: 2.1, 2.2, 2.5_
  
  - [ ] 10.3 Verify bio display on profile page
    - Display saved bio in profile details section
    - Ensure bio is not displayed in home_city field
    - Show empty state if bio is empty
    - _Requirements: 2.4_
  
  - [ ] 10.4 Verify bio loads on app start
    - Check AuthBloc loads bio from users table
    - Verify UserEntity includes bio field
    - Test bio persists across app restarts
    - _Requirements: 2.3, 2.6_

- [ ] 11. Implement fandom liking system
  - [ ] 11.1 Create FandomLikeButton widget
    - Display heart icon (filled if liked, outlined if not)
    - Use AppColors.comicRed for liked state
    - Use AppColors.comicGray for unliked state
    - Implement onToggle callback
    - _Requirements: 3.1, 3.4, 3.5_
  
  - [ ] 11.2 Integrate FandomLikeButton in fandom category cards
    - Add FandomLikeButton to each category card
    - Pass categoryId and isLiked from user's liked_fandoms
    - Wire onToggle to dispatch ToggleLikeFandomEvent
    - _Requirements: 3.1, 3.2, 3.3_
  
  - [ ] 11.3 Implement "Liked Fandoms" section on profile page
    - Query category names from categories table using liked_fandoms IDs
    - Display category names in profile section
    - Show "No liked fandoms yet. Explore and like your favorites!" when empty
    - _Requirements: 3.6, 3.7_

- [ ] 12. Implement preference-based content filtering
  - [ ] 12.1 Update home feed query to use selected_fandoms filter
    - Modify posts query to filter by category_id IN selected_fandoms
    - Return all posts when selected_fandoms is empty
    - Order by timestamp DESC (newest first)
    - _Requirements: 4.1, 4.2, 4.3, 4.7_
  
  - [ ] 12.2 Create FilterBadgeChip widget
    - Display "Showing posts from [preference names]" when filter active
    - Hide chip when no preferences selected
    - Make chip tappable to navigate to preferences page
    - _Requirements: 4.5, 4.6_
  
  - [ ] 12.3 Add filter badge to home feed page
    - Place FilterBadgeChip above posts list
    - Wire onTap to navigate to interest selection page
    - Update display when preferences change
    - _Requirements: 4.5_
  
  - [ ] 12.4 Handle filtered results and empty state
    - Display empty state when no posts match preferences
    - Show "No posts found for your preferences. Try selecting more fandoms!"
    - Re-query posts when preferences update
    - _Requirements: 4.4, 4.8_

- [ ] 13. Checkpoint - Test profile and filtering features
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 14. Implement FAQ page
  - [ ] 14.1 Create FAQPage with static entries
    - Define List<FAQEntry> with 8 static Q&A pairs
    - Create FAQEntry class with question and answer fields
    - Use ExpansionTile for each FAQ entry
    - _Requirements: 5.3, 5.6_
  
  - [ ] 14.2 Add FAQ search functionality
    - Add TextField for search input
    - Filter FAQ entries by question or answer text (case-insensitive)
    - Update ListView with filtered results in real-time
    - _Requirements: 5.7, 5.8_
  
  - [ ] 14.3 Add FAQ navigation from profile page
    - Add "FAQ" list tile or button in profile settings section
    - Wire onTap to navigate to FAQPage
    - _Requirements: 5.1, 5.2_
  
  - [ ] 14.4 Implement FAQ expansion behavior
    - Expand tile to show answer on tap
    - Collapse tile to hide answer on second tap
    - Allow multiple tiles expanded simultaneously
    - _Requirements: 5.4, 5.5_

- [ ] 15. Implement glossary details page
  - [ ] 15.1 Create GlossaryDetailsPage widget
    - Accept GlossaryTerm parameter in constructor
    - Design page layout with AppBar, content sections
    - Add back button in AppBar
    - _Requirements: 6.1, 6.7_
  
  - [ ] 15.2 Display glossary term details
    - Display term name in hero section
    - Display phonetic pronunciation
    - Display definition in glass container
    - Display fandom_category with category color badge
    - Display example_usage with term highlighted
    - _Requirements: 6.2_
  
  - [ ] 15.3 Implement bookmark toggle button
    - Add bookmark FAB button
    - Wire to dispatch ToggleGlossaryBookmarkEvent
    - Update icon based on is_bookmarked state
    - Ensure update completes within 300ms
    - _Requirements: 6.3, 6.4_
  
  - [ ] 15.4 Implement related terms section
    - Query glossary table WHERE fandom_category = term.fandomCategory LIMIT 5
    - Display as horizontal scrollable list
    - Exclude current term from related terms
    - _Requirements: 6.5_
  
  - [ ] 15.5 Implement related term navigation
    - Make each related term card tappable
    - Navigate to new GlossaryDetailsPage with selected term
    - _Requirements: 6.6_
  
  - [ ] 15.6 Add share functionality
    - Add share icon button in AppBar
    - Use Share.share with term and definition text
    - _Requirements: 6.8_

- [ ] 16. Fix media page navigation
  - [ ] 16.1 Add gallery-view route to app router
    - Define galleryView constant in app_router.dart
    - Add case for '/gallery-view' in generateRoute
    - Accept GalleryItem as route argument
    - _Requirements: 7.3_
  
  - [ ] 16.2 Create GalleryViewPage widget
    - Accept GalleryItem parameter
    - Display image with InteractiveViewer for zoom
    - Display title, artist name, and like count
    - Add back button in AppBar
    - _Requirements: 7.4, 7.5_
  
  - [ ] 16.3 Update Media tab navigation
    - Replace broken navigation with Navigator.pushNamed(AppRouter.galleryView)
    - Pass selected GalleryItem as arguments
    - Verify navigation works without errors
    - _Requirements: 7.1, 7.2_
  
  - [ ] 16.4 Add skeleton loaders and error handling
    - Display SkeletonLoader in 2-column grid while loading
    - Show error message with retry button on load failure
    - Wire retry to dispatch reload event
    - _Requirements: 7.6, 7.7, 7.8_

- [ ] 17. Fix deep dive trivia results display
  - [ ] 17.1 Enhance TriviaQuestionCard state management
    - Add _selectedIndex int? field
    - Add _showResults bool field
    - Track user's selected answer
    - _Requirements: 8.1_
  
  - [ ] 17.2 Implement answer highlighting logic
    - Create _getOptionColor(int index) method
    - Highlight correct answer with AppColors.success.withOpacity(0.15)
    - Highlight incorrect selection with AppColors.error.withOpacity(0.15)
    - Return transparent color before answer submission
    - _Requirements: 8.2, 8.3_
  
  - [ ] 17.3 Display explanation after answer
    - Show explanation text in glass container below options
    - Display only after answer is selected
    - Hide when moving to next question
    - _Requirements: 8.4, 8.8_
  
  - [ ] 17.4 Implement score display
    - Create score container with AppColors.darkAccentGold background
    - Display "Score: X / Y" format
    - Show after all questions completed
    - Hide during question answering
    - _Requirements: 8.5, 8.6, 8.7_

- [ ] 18. Checkpoint - Test lore hub features
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 19. Implement advanced lore section
  - [ ] 19.1 Create AdvancedLoreCard widget
    - Display title and difficulty badge when collapsed
    - Expand to show full content_body on tap
    - Use StatefulWidget for expand/collapse state
    - _Requirements: 9.4, 9.5_
  
  - [ ] 19.2 Implement difficulty color coding
    - Map "Beginner" to AppColors.success (green)
    - Map "Intermediate" to AppColors.warning (orange)
    - Map "Expert" to AppColors.error (red)
    - Apply color to difficulty badge
    - _Requirements: 9.6_
  
  - [ ] 19.3 Add Advanced Lore section to Deep Dive tab
    - Position below trivia section
    - Dispatch LoadAdvancedLoreEvent on tab view
    - Display list of AdvancedLoreCard widgets
    - _Requirements: 9.1, 9.3_
  
  - [ ] 19.4 Add skeleton loaders and empty state
    - Display 3 SkeletonLoader rectangles while loading
    - Show "Advanced lore content coming soon!" when empty
    - _Requirements: 9.7, 9.8_

- [ ] 20. Implement behind the scenes section
  - [ ] 20.1 Create BehindScenesCard widget
    - Display thumbnail image with cached_network_image
    - Display title overlay
    - Display media type icon badge (video/image/article)
    - Make card tappable
    - _Requirements: 10.4_
  
  - [ ] 20.2 Create BehindScenesDetailPage widget
    - Display full description
    - Render media based on media_type (video/image/article)
    - Add video player for "video" type
    - Add zoomable image for "image" type
    - Display formatted text for "article" type
    - _Requirements: 10.5, 10.6, 10.7, 10.8_
  
  - [ ] 20.3 Add Behind the Scenes section to Deep Dive tab
    - Position below Advanced Lore section
    - Dispatch LoadBehindScenesEvent on view
    - Display 2-column grid of BehindScenesCard widgets
    - _Requirements: 10.1, 10.3_
  
  - [ ] 20.4 Add skeleton loaders
    - Display 4 SkeletonLoader rectangles in 2-column grid while loading
    - _Requirements: 12.4_

- [ ] 21. Implement interviews section
  - [ ] 21.1 Create InterviewCard widget
    - Display circular avatar image
    - Display interviewee_name as title
    - Display role_title as subtitle
    - Make card tappable
    - _Requirements: 11.5_
  
  - [ ] 21.2 Create InterviewDetailPage widget
    - Display hero image at top
    - Display interviewee_name, role_title, interview_date header
    - Parse questions_json and display Q&A pairs
    - Use alternating background colors for questions/answers
    - _Requirements: 11.6, 11.7_
  
  - [ ] 21.3 Add Interviews section to Deep Dive tab
    - Position below Behind the Scenes section
    - Dispatch LoadInterviewsEvent on view
    - Display list of InterviewCard widgets
    - _Requirements: 11.1, 11.4_
  
  - [ ] 21.4 Add skeleton loaders and empty state
    - Display 3 SkeletonLoader rectangles while loading
    - Show "Check back soon for exclusive interviews!" when empty
    - _Requirements: 11.8, 12.5_

- [ ] 22. Fix skeleton loader displays across app
  - [ ] 22.1 Update Glossary tab skeleton loaders
    - Display 6 SkeletonLoader rectangles with height 80, borderRadius 12
    - Show during FandomHubLoading state
    - Replace with content when FandomHubLoaded
    - _Requirements: 12.1, 12.7_
  
  - [ ] 22.2 Update Media tab skeleton loaders
    - Display 6 SkeletonLoader rectangles in 2-column grid
    - Set childAspectRatio to 0.85
    - Show during loading state
    - _Requirements: 12.2_
  
  - [ ] 22.3 Verify skeleton loader animations
    - Ensure shimmer effect is working
    - Verify smooth transition to content (within 100ms)
    - Test error state transitions to retry button
    - _Requirements: 12.6, 12.7, 12.8_

- [ ] 23. Final integration and testing
  - [ ] 23.1 Integration testing for profile features
    - Test profile picture upload end-to-end
    - Test bio save and display
    - Test fandom liking and profile display
    - _Requirements: 1.6, 2.3, 3.6_
  
  - [ ] 23.2 Integration testing for content filtering
    - Test filter badge display
    - Test home feed filtering by preferences
    - Test empty state when no matching posts
    - _Requirements: 4.2, 4.5, 4.8_
  
  - [ ] 23.3 Integration testing for lore hub
    - Test glossary details navigation
    - Test bookmark toggle
    - Test related terms navigation
    - Test advanced content sections display
    - _Requirements: 6.1, 6.4, 6.6, 9.3, 10.3, 11.4_
  
  - [ ] 23.4 Integration testing for trivia and media
    - Test trivia answer highlighting
    - Test score display
    - Test media gallery navigation
    - _Requirements: 7.2, 8.2, 8.5_

- [ ] 24. Final checkpoint - Complete implementation
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Database migrations should be tested on a copy of production data
- Image picker requires platform permissions (camera, photo library) - verify AndroidManifest.xml and Info.plist
- All BLoC events should complete within documented time limits (300-500ms)
- Skeleton loaders improve perceived performance during data fetches
- Use cached_network_image for all network images to support offline mode
- JSON serialization must handle null values gracefully with defaults
- Test serialization round-trips (toMap → fromMap) to ensure data integrity

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "2.1", "2.2", "2.3"] },
    { "id": 1, "tasks": ["3.1", "3.2", "3.3", "4.1", "4.2"] },
    { "id": 2, "tasks": ["3.4", "4.3", "6.1", "6.2", "7.1", "7.2"] },
    { "id": 3, "tasks": ["6.3", "6.4", "7.3", "7.4", "7.5", "7.6"] },
    { "id": 4, "tasks": ["9.1", "9.2", "10.1", "11.1", "14.1", "15.1", "16.1", "17.1", "19.1", "20.1", "21.1"] },
    { "id": 5, "tasks": ["9.3", "10.2", "11.2", "14.2", "15.2", "16.2", "17.2", "19.2", "20.2", "21.2"] },
    { "id": 6, "tasks": ["9.4", "10.3", "11.3", "12.1", "14.3", "15.3", "15.4", "16.3", "17.3", "19.3", "20.3", "21.3"] },
    { "id": 7, "tasks": ["10.4", "12.2", "12.3", "14.4", "15.5", "15.6", "16.4", "17.4", "19.4", "20.4", "21.4", "22.1", "22.2"] },
    { "id": 8, "tasks": ["12.4", "22.3", "23.1", "23.2", "23.3", "23.4"] }
  ]
}
```
