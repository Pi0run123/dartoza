# Design Document: DartScore Android Application

## 1. Introduction
DartScore is a "Digital Referee" application designed to facilitate dart games among friends. It provides a clean interface for score tracking, real-time multiplayer updates, and historical performance logging, while enhancing the competitive atmosphere with psychological triggers and social integration.

## 2. Project Goals
- **Real-time Tracking:** Provide a seamless interface to input scores during a live match.
- **Persistence:** Save all match results, player statistics, and history to a cloud database.
- **Social Integration:** Allow friends to join rooms or view shared match histories.
- **Offline Capability:** Enable local scoring with synchronization once a connection is restored.
- **Atmospheric Engagement:** Use audio and visual cues to heighten the tension and "vibe" of a professional match.

## 3. Technology Stack
- **Language:** Dart / Flutter (Cross-platform)
- **Backend:** Firebase
    - **Firebase Authentication:** For user sign-in and profile management.
    - **Cloud Firestore:** NoSQL database for real-time match data.
    - **Firebase Functions:** For compiling Match Cards and processing highlights.
    - **Cloud Storage:** For storing "Dart-Eye" snapshots.

## 4. System Architecture
The app follows the **MVVM (Model-View-ViewModel)** architectural pattern.

## 5. Database Schema (Cloud Firestore)

### `users` Collection
- `uid`: String (Primary Key)
- `displayName`: String
- `rival_stats`: Map (Head-to-head records)
- `badges`: List (Achievements like "The Robin Hood")

### `matches` Collection
- `id`: String
- `timestamp`: DateTime
- `gameType`: String
- `playerUids`: List
- `scores`: Map
- `status`: String
- `gallery`: List (URLs of "Dart-Eye" snapshots)
- `heatmaps`: Map (Segment-specific hit data)

## 6. Pro-Level Creative Features

### 6.1 The "Pressure Gauge" (Predictive Analytics)
Using a simple algorithm, the app calculates who is "feeling the heat." If a player is on a double to win and misses, their "Pressure Meter" rises. 
- **UI:** The score display pulses red or adds a heartbeat animation.
- **Audio:** A subtle heartbeat sound effect through the phone’s speakers to heighten tension.

### 6.2 "Sass-Bot" Trash Talk (Audio/Text)
An optional toggle for an AI commentator that "praises" or "roasts" players based on their scores.
- **Score < 10:** "Was that a dart or a toothpick?"
- **Score = 180:** "ONE HUNDRED AND EIGHTY!" (Classic announcer audio).
- **A "Bust":** "Math is hard, isn't it?"

### 6.3 AR "Dart-Eye" Camera
A quick-access camera button to snap photos of contested segments or winning 180s. Photos are saved in the match gallery for post-match bragging rights.

## 7. Creative Feature Modules

### 7.1 The "Crowd Noise" Engine
 Mimics professional PDC matches with a background "Pub Ambience" loop.
- **Dynamic Volume:** Quieter during checkouts (concentration), erupts in a roar during "Max" or "Big Fish" (170 checkout) hits.

### 7.2 Performance Heatmaps
A Virtual Dartboard UI for post-match analysis.
- **Logic:** Players can tap the specific segment they hit.
- **Output:** Generates a "Heatmap" showing accuracy trends (e.g., drifting into 5 or 1 when aiming for 20).

### 7.3 "Match Highlights" Generator
Firebase Functions compile a "Match Card" image at the end of a session.
- **Content:** Winner name, high checkout, "Comeback of the Night" stat, and winning dart photo.
- **Sharing:** One-tap sharing to Instagram/WhatsApp.

## 8. Hardware Integration
- **Smartwatch Companion:** WearOS/watchOS module for quick score input at the board.
- **LED Sync:** Integration with Philips Hue or Govee lights to flash green on a win.

- `email`: String
- `stats`: Map (totalWins, totalGames, highestCheckout)

### `matches` Collection
- `matchId`: String (Primary Key)
- `timestamp`: Timestamp
- `gameType`: String (e.g., "501", "301", "Cricket")
- `players`: List of UIDs
- `scores`: Map (PlayerUID -> CurrentScore)
- `status`: String ("Ongoing", "Finished")
- `winner`: String (UID)

### `turns` Sub-collection (within a match)
- `turnId`: String
- `playerUid`: String
- `pointsScored`: Int
- `dartsThrown`: List of [Value, Multiplier]

## 6. Key Features & Workflows

### 6.1 Match Creation
1. User selects "New Game".
2. User chooses Game Mode (301/501).
3. User invites friends via a unique Match Code or selects from a Friends List.
4. Match document is initialized in Firestore.

### 6.2 Scoring Loop
1. The app highlights the active player.
2. User inputs three dart values using a custom numeric keypad.
3. The app validates the score (e.g., prevents "Bust").
4. On "Confirm", the `turns` sub-collection is updated.
5. Firestore listeners trigger a UI update for all participants in the match.

### 6.3 Checkout Suggestions
For 501/301 games, the app will provide a "Checkout Table" logic that suggests combinations (e.g., "T20, T15, D10") when a player reaches a finishable score.

## 7. UI/UX Design Principles
- **High Contrast:** Large numbers for visibility from a distance (where the dartboard is located).
- **One-Handed Operation:** Primary buttons (1-20, Double, Triple) placed within thumb reach.
- **Dark Mode Support:** Defaulting to dark mode to reduce battery consumption and glare.

## 8. Security
- **Firestore Security Rules:** Ensure users can only write to matches they are participants in.
- **Data Validation:** Server-side checks (via Firebase Functions or Rules) to prevent impossible scores (e.g., scoring >180 in one turn).

## 10. Implementation Status

### Core Features (v1.0) - DONE ✅
- [x] **Basic scoring engine**: 501/301 support with "Bust" logic.
- [x] **Multi-player turn management**: Smooth switching between players.
- [x] **Firebase integration**: Live match syncing and turn recording.
- [x] **Glassmorphic Keypad**: High-precision input with multipliers.

### Pro-Level Features (Digital Referee) - IMPLEMENTED 🚀
- [x] **The "Pressure Gauge"**: Predictive tension tracking. UI pulses and background gradients react to pressure. Integrated heartbeat audio logic.
- [x] **Sass-Bot Commentary**: Dynamic AI-style commentary triggered by match events. Audio trigger system integrated.
- [x] **AR Dart-Eye**: Kinetic guidance system with cyber-grid overlay for precision visualization.
- [x] **Kinetic Dark UI**: Fully implemented "Void and Neon" aesthetic using Stitch design tokens.

### Upcoming Features 🛠️
- [ ] **Audio Assets**: Integration of high-fidelity .mp3 files.
- [ ] **Match Card Generation**: End-of-match stats summary image.
