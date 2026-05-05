import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dartscore/pages/scoring_page.dart';
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
  testWidgets('Scoring page renders players', (WidgetTester tester) async {
    // Set a realistic phone size to avoid overflow
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockFirebase = MockFirebaseService();
    final matchProvider = MatchProvider(firebaseService: mockFirebase);
    
    MatchModel demoMatch = MatchModel(
      id: 'test_match',
      timestamp: DateTime.now(),
      gameType: '501',
      playerUids: ['p1', 'p2'],
      scores: {'p1': 501, 'p2': 501},
      status: 'Ongoing',
    );
    matchProvider.setMatch(demoMatch);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: matchProvider,
        child: const MaterialApp(
          home: ScoringPage(),
        ),
      ),
    );

    // Verify player names are present
    expect(find.text('PLAYER 1'), findsOneWidget);
    expect(find.text('PLAYER 2'), findsOneWidget);
    
    // Verify initial scores
    expect(find.text('501'), findsNWidgets(2));
  });
}
