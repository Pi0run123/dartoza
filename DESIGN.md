# Design Document: DartScore Android Application

## 1. Introduction
DartScore is an Android application designed to facilitate dart games among friends. It provides a clean interface for score tracking, real-time multiplayer updates, and historical performance logging.

## 2. Project Goals
- **Real-time Tracking:** Provide a seamless interface to input scores during a live match.
- **Persistence:** Save all match results, player statistics, and history to a cloud database.
- **Social Integration:** Allow friends to join rooms or view shared match histories.
- **Offline Capability:** Enable local scoring with synchronization once a connection is restored.

## 3. Technology Stack
- **Language:** Kotlin
- **Framework:** Jetpack Compose (UI), Android Architecture Components (ViewModel, LiveData/Flow)
- **Backend:** Firebase
    - **Firebase Authentication:** For user sign-in and profile management.
    - **Cloud Firestore:** NoSQL database for real-time match data.
    - **Firebase Analytics:** To track app usage patterns.
- **Dependency Injection:** Hilt/Dagger

## 4. System Architecture
The app follows the **MVVM (Model-View-ViewModel)** architectural pattern to ensure separation of concerns and testability.

### 4.1 Layers
- **UI Layer (View):** Built with Jetpack Compose. Observes the StateFlow from ViewModels.
- **Domain Layer (ViewModel):** Handles business logic, calculates dart math (checkouts, remaining scores), and manages UI state.
- **Data Layer (Repository):** The single source of truth that abstracts the Firebase Firestore and local Room database.

## 5. Database Schema (Cloud Firestore)

### `users` Collection
- `uid`: String (Primary Key)
- `displayName`: String
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

## 9. Future Enhancements
- **Voice Control:** "Hey DartScore, I scored 60."
- **Bluetooth Integration:** Connect to electronic dartboards.
- **Global Leaderboards:** Compare stats with users worldwide.
