import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createMatch(String gameType, List<String> playerUids) async {
    Map<String, int> initialScores = {
      for (var uid in playerUids) uid: int.parse(gameType)
    };
    
    DocumentReference ref = await _db.collection('matches').add({
      'timestamp': FieldValue.serverTimestamp(),
      'gameType': gameType,
      'players': playerUids,
      'scores': initialScores,
      'status': 'Ongoing',
    });
    
    return ref.id;
  }

  Stream<MatchModel> streamMatch(String matchId) {
    return _db.collection('matches').doc(matchId).snapshots().map((doc) => MatchModel.fromFirestore(doc));
  }

  Future<void> updateScore(String matchId, String playerUid, int pointsScored) async {
    DocumentReference ref = _db.collection('matches').doc(matchId);
    
    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;
      
      Map scores = snapshot.get('scores') as Map;
      int currentScore = scores[playerUid] ?? 0;
      int newScore = currentScore - pointsScored;
      
      if (newScore == 0) {
        transaction.update(ref, {
          'scores.$playerUid': newScore,
          'status': 'Finished',
          'winner': playerUid,
        });
      } else if (newScore > 1) {
        transaction.update(ref, {'scores.$playerUid': newScore});
      }
      // If newScore < 0 or == 1 (in double-out scenarios, though here we just do simple), it's a bust.
    });
  }

  Future<void> recordTurn(String matchId, String playerUid, int pointsScored, List<Map<String, int>> darts) async {
    await _db.collection('matches').doc(matchId).collection('turns').add({
      'playerUid': playerUid,
      'pointsScored': pointsScored,
      'dartsThrown': darts,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
