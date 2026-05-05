import 'package:flutter_test/flutter_test.dart';
import 'package:dartscore/providers/match_provider.dart';
import 'package:dartscore/models/match_model.dart';

import 'package:dartscore/services/firebase_service.dart';

class MockFirebaseService implements FirebaseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  
  @override
  Future<String> createMatch(String gameType, List<String> playerUids) async => "test_id";
  
  @override
  Future<void> updateScore(String matchId, String playerUid, int pointsScored) async {}
  
  @override
  Future<void> recordTurn(String matchId, String playerUid, int pointsScored, List<Map<String, int>> darts) async {}

  @override
  Stream<MatchModel> streamMatch(String matchId) => Stream.empty();
}

void main() {
  group('MatchProvider Logic Tests', () {
    late MatchProvider provider;
    late MockFirebaseService mockFirebase;

    setUp(() {
      mockFirebase = MockFirebaseService();
      provider = MatchProvider(firebaseService: mockFirebase);
      MatchModel demoMatch = MatchModel(
        id: 'test_match',
        timestamp: DateTime.now(),
        gameType: '501',
        playerUids: ['p1', 'p2'],
        scores: {'p1': 501, 'p2': 501},
        status: 'Ongoing',
      );
      provider.setMatch(demoMatch);
    });

    test('Initial scores are correct', () {
      expect(provider.currentMatch!.scores['p1'], 501);
      expect(provider.activePlayerUid, 'p1');
    });

    test('Adding simple score updates turn score', () {
      provider.addScore(20);
      expect(provider.currentTurnScore, 20);
    });

    test('Multiplier works correctly (Double)', () {
      provider.setMultiplier(2);
      provider.addScore(20);
      expect(provider.currentTurnScore, 40);
    });

    test('Multiplier works correctly (Triple)', () {
      provider.setMultiplier(3);
      provider.addScore(20);
      expect(provider.currentTurnScore, 60);
    });

    test('Undo removes last score', () {
      provider.addScore(20);
      provider.addScore(5);
      expect(provider.currentTurnScore, 25);
      provider.undoLastDart();
      expect(provider.currentTurnScore, 20);
    });

    test('Bust logic works', () {
      // Set remaining score to 20
      MatchModel lowScoreMatch = MatchModel(
        id: 'test_match',
        timestamp: DateTime.now(),
        gameType: '501',
        playerUids: ['p1', 'p2'],
        scores: {'p1': 20, 'p2': 501},
        status: 'Ongoing',
      );
      provider.setMatch(lowScoreMatch);

      provider.addScore(25); // Score > 20
      
      expect(provider.currentTurnScore, 0); // Should be reset
      expect(provider.activePlayerUid, 'p2'); // Should switch player
    });

    test('Winning score switches to next player and finishes turn', () {
      MatchModel winMatch = MatchModel(
        id: 'test_match',
        timestamp: DateTime.now(),
        gameType: '501',
        playerUids: ['p1', 'p2'],
        scores: {'p1': 40, 'p2': 501},
        status: 'Ongoing',
      );
      provider.setMatch(winMatch);

      provider.setMultiplier(2);
      provider.addScore(20); // 40 points, exactly remaining
      
      expect(provider.currentTurnScore, 0);
      expect(provider.activePlayerUid, 'p2');
    });
  });
}
