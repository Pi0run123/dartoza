import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String id;
  final DateTime timestamp;
  final String gameType; // "501", "301"
  final List<String> playerUids;
  final Map<String, int> scores;
  final String status; // "Ongoing", "Finished"
  final String? winner;

  MatchModel({
    required this.id,
    required this.timestamp,
    required this.gameType,
    required this.playerUids,
    required this.scores,
    required this.status,
    this.winner,
  });

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return MatchModel(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      gameType: data['gameType'] ?? '501',
      playerUids: List<String>.from(data['players'] ?? []),
      scores: Map<String, int>.from(data['scores'] ?? {}),
      status: data['status'] ?? 'Ongoing',
      winner: data['winner'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': timestamp,
      'gameType': gameType,
      'players': playerUids,
      'scores': scores,
      'status': status,
      'winner': winner,
    };
  }
}

class Turn {
  final String id;
  final String playerUid;
  final int pointsScored;
  final List<DartThrow> dartsThrown;

  Turn({
    required this.id,
    required this.playerUid,
    required this.pointsScored,
    required this.dartsThrown,
  });
}

class DartThrow {
  final int value;
  final int multiplier; // 1, 2, 3

  DartThrow(this.value, this.multiplier);
}
