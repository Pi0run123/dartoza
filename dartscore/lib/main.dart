import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'pages/scoring_page.dart';
import 'providers/match_provider.dart';
import 'models/match_model.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DartScoreApp());
}

class DartScoreApp extends StatelessWidget {
  const DartScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchProvider()),
      ],
      child: MaterialApp(
        title: 'DartScore',
        theme: AppTheme.darkTheme,
        home: const AppLoader(),
      ),
    );
  }
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  @override
  void initState() {
    super.initState();
    _initMatch();
  }

  Future<void> _initMatch() async {
    // For demo purposes, we create a match if one doesn't exist
    // In a real app, this would be via a "New Game" screen
    final provider = context.read<MatchProvider>();
    
    // Simulating match creation
    MatchModel demoMatch = MatchModel(
      id: 'demo_match',
      timestamp: DateTime.now(),
      gameType: '501',
      playerUids: ['p1', 'p2'],
      scores: {'p1': 501, 'p2': 501},
      status: 'Ongoing',
    );
    
    provider.setMatch(demoMatch);
  }

  @override
  Widget build(BuildContext context) {
    return const ScoringPage();
  }
}
