import 'dart:async';
import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/firebase_service.dart';

class MatchProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  MatchModel? _currentMatch;
  String? _activePlayerUid;
  int _currentTurnScore = 0;
  List<DartThrow> _currentDarts = [];
  int _multiplier = 1;
  StreamSubscription? _matchSubscription;

  MatchProvider({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  MatchModel? get currentMatch => _currentMatch;
  String? get activePlayerUid => _activePlayerUid;
  int get currentTurnScore => _currentTurnScore;
  int get multiplier => _multiplier;
  List<DartThrow> get currentDarts => _currentDarts;

  void setMatch(MatchModel match) {
    _currentMatch = match;
    _activePlayerUid ??= match.playerUids.first;
    _startMatchSubscription(match.id);
    notifyListeners();
  }

  void _startMatchSubscription(String matchId) {
    _matchSubscription?.cancel();
    _matchSubscription = _firebaseService.streamMatch(matchId).listen((match) {
      _currentMatch = match;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _matchSubscription?.cancel();
    super.dispose();
  }

  void setMultiplier(int m) {
    if (_multiplier == m) {
      _multiplier = 1;
    } else {
      _multiplier = m;
    }
    notifyListeners();
  }

  void addScore(int value) {
    if (_currentDarts.length >= 3 || _currentMatch?.status == 'Finished') return;

    int remaining = _currentMatch?.scores[_activePlayerUid] ?? 0;
    int throwScore = value * _multiplier;

    // Standard Dart rules (simple version):
    // 1. If you score more than remaining, you bust.
    // 2. In many variants, reaching 1 is also a bust (because you can't finish on 0 with a double).
    // For now, let's just do "below 0 is bust".
    
    if (_currentTurnScore + throwScore > remaining) {
      // BUST! 
      _currentTurnScore = 0;
      _currentDarts.add(DartThrow(value, _multiplier)); // Still add to record the throw
      submitTurn(isBust: true);
      return;
    }

    _currentTurnScore += throwScore;
    _currentDarts.add(DartThrow(value, _multiplier));
    _multiplier = 1;

    if (_currentTurnScore == remaining) {
      // WIN!
      submitTurn();
    } else if (_currentDarts.length == 3) {
      submitTurn();
    }
    notifyListeners();
  }

  void undoLastDart() {
    if (_currentDarts.isNotEmpty) {
      DartThrow last = _currentDarts.removeLast();
      _currentTurnScore -= (last.value * last.multiplier);
      notifyListeners();
    }
  }

  Future<void> submitTurn({bool isBust = false}) async {
    if (_currentMatch == null || _activePlayerUid == null) return;

    final matchId = _currentMatch!.id;
    final playerUid = _activePlayerUid!;
    final pointsScored = isBust ? 0 : _currentTurnScore;
    final darts = List<DartThrow>.from(_currentDarts);

    // Reset local turn state immediately for responsive UI
    _currentTurnScore = 0;
    _currentDarts = [];
    
    // Switch player locally (optimistic)
    int currentIndex = _currentMatch!.playerUids.indexOf(playerUid);
    int nextIndex = (currentIndex + 1) % _currentMatch!.playerUids.length;
    _activePlayerUid = _currentMatch!.playerUids[nextIndex];
    
    notifyListeners();

    // Update Firebase
    if (pointsScored > 0) {
      await _firebaseService.updateScore(matchId, playerUid, pointsScored);
    }
    
    await _firebaseService.recordTurn(
      matchId, 
      playerUid, 
      pointsScored, 
      darts.map((d) => {'value': d.value, 'multiplier': d.multiplier}).toList()
    );
  }
}
