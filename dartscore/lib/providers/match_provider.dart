import 'dart:async';
import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/firebase_service.dart';
import '../services/sound_service.dart';

class MatchProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  MatchModel? _currentMatch;
  String? _activePlayerUid;
  int _currentTurnScore = 0;
  List<DartThrow> _currentDarts = [];
  int _multiplier = 1;
  StreamSubscription? _matchSubscription;

  // New features
  double _pressureLevel = 0.0;
  String _lastComment = "Let's see what you've got.";
  
  MatchProvider({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  MatchModel? get currentMatch => _currentMatch;
  String? get activePlayerUid => _activePlayerUid;
  int get currentTurnScore => _currentTurnScore;
  int get multiplier => _multiplier;
  List<DartThrow> get currentDarts => _currentDarts;
  double get pressureLevel => _pressureLevel;
  String get lastComment => _lastComment;

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
      _calculatePressure();
      notifyListeners();
    });
  }

  void _calculatePressure() {
    if (_currentMatch == null || _activePlayerUid == null) return;
    int score = _currentMatch!.scores[_activePlayerUid] ?? 0;
    
    // Pressure increases as score gets lower (checkout range)
    if (score <= 170) {
      _pressureLevel = (170 - score) / 170;
      SoundService.startHeartbeat(_pressureLevel);
    } else {
      _pressureLevel = 0.0;
      SoundService.stopHeartbeat();
    }
  }

  @override
  void dispose() {
    _matchSubscription?.cancel();
    SoundService.dispose();
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
    
    if (_currentTurnScore + throwScore > remaining) {
      // BUST! 
      _lastComment = "Math is hard, isn't it? BUST!";
      _pressureLevel = 1.0; 
      SoundService.playCommentary('audio/roast_bust.mp3');
      _currentTurnScore = 0;
      _currentDarts.add(DartThrow(value, _multiplier));
      submitTurn(isBust: true);
      return;
    }

    _currentTurnScore += throwScore;
    _currentDarts.add(DartThrow(value, _multiplier));
    _multiplier = 1;

    // Check for commentary
    if (throwScore >= 60) {
      _lastComment = "BOOM! Great arrow!";
      SoundService.playEffect('audio/dart_hit.mp3');
    } else if (throwScore == 0) {
      _lastComment = "Was that a dart or a toothpick?";
      SoundService.playCommentary('audio/roast_miss.mp3');
    } else if (throwScore == 180) {
       _lastComment = "ONE HUNDRED AND EIGHTY!!!";
       SoundService.playEffect('audio/180_announcer.mp3');
    } else {
       SoundService.playEffect('audio/dart_hit.mp3');
    }

    if (_currentTurnScore == remaining) {
      // WIN!
      _lastComment = "GAME OVER! Incredible finish.";
      SoundService.playCommentary('audio/game_on.mp3');
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

    // Reset local turn state
    _currentTurnScore = 0;
    _currentDarts = [];
    
    // Switch player
    int currentIndex = _currentMatch!.playerUids.indexOf(playerUid);
    int nextIndex = (currentIndex + 1) % _currentMatch!.playerUids.length;
    _activePlayerUid = _currentMatch!.playerUids[nextIndex];
    
    _calculatePressure();
    notifyListeners();

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

