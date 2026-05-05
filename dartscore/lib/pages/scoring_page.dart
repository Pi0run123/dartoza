import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';
import '../theme.dart';
import '../main.dart';
import 'dart_eye_page.dart';

class ScoringPage extends StatelessWidget {
  const ScoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Pressure Background
          const _PressureBackground(),
          
          SafeArea(
            child: Column(
              children: [
                const _ScoringHeader(),
                const _ScoreDisplay(),
                const _SassBot(),
                const Spacer(),
                const _Keypad(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoringHeader extends StatelessWidget {
  const _ScoringHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.menu, color: Colors.white54),
          Text(
            'MATCH STATS',
            style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
              letterSpacing: 3,
              color: Colors.white24,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye, color: AppTheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DartEyePage(cameras: cameras),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class _PressureBackground extends StatelessWidget {
  const _PressureBackground();

  @override
  Widget build(BuildContext context) {
    final pressure = context.select<MatchProvider, double>((p) => p.pressureLevel);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            AppTheme.accentRed.withValues(alpha: pressure * 0.2),
            AppTheme.background,
          ],
        ),
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();
    final match = provider.currentMatch;

    if (match == null) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: match.playerUids.map((uid) {
          bool isActive = provider.activePlayerUid == uid;
          return _PlayerCard(
            uid: uid,
            score: match.scores[uid] ?? 0,
            isActive: isActive,
            pressure: isActive ? provider.pressureLevel : 0.0,
          );
        }).toList(),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String uid;
  final int score;
  final bool isActive;
  final double pressure;

  const _PlayerCard({
    required this.uid,
    required this.score,
    required this.isActive,
    required this.pressure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          uid == 'p1' ? 'PLAYER 1' : 'PLAYER 2',
          style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
            color: isActive ? AppTheme.primary : Colors.grey,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            // Pressure Pulse
            if (isActive && pressure > 0)
              _PressurePulse(level: pressure),
            
            Container(
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary.withValues(alpha: 0.05) : Colors.transparent,
                border: Border.all(
                  color: isActive ? AppTheme.primary : Colors.white10,
                  width: isActive ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                '$score',
                style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(
                  color: isActive ? Colors.white : Colors.grey[800],
                  fontSize: 72,
                ),
              ),
            ),
            
            // Pressure Bar (Side)
            if (isActive && pressure > 0)
              Positioned(
                left: 0,
                top: 20,
                bottom: 20,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentRed.withValues(alpha: 0.5),
                        blurRadius: 8,
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PressurePulse extends StatefulWidget {
  final double level;
  const _PressurePulse({required this.level});

  @override
  State<_PressurePulse> createState() => _PressurePulseState();
}

class _PressurePulseState extends State<_PressurePulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 150,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentRed.withValues(alpha: 0.3 * widget.level * _controller.value),
                blurRadius: 20 * widget.level,
                spreadRadius: 5 * widget.level,
              )
            ],
          ),
        );
      },
    );
  }
}

class _SassBot extends StatelessWidget {
  const _SassBot();

  @override
  Widget build(BuildContext context) {
    final comment = context.select<MatchProvider, String>((p) => p.lastComment);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, color: AppTheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    comment,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const _ModifierButton(label: 'DOUBLE', multiplier: 2),
              const SizedBox(width: 16),
              const _ModifierButton(label: 'TRIPLE', multiplier: 3),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: 22,
            itemBuilder: (context, index) {
              if (index < 20) {
                return _KeyButton(value: index + 1);
              } else if (index == 20) {
                return _KeyButton(value: 25, label: '25');
              } else {
                return _KeyButton(value: 50, label: 'BULL');
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => context.read<MatchProvider>().undoLastDart(),
                  child: Text(
                    'UNDO', 
                    style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(color: Colors.redAccent)
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => context.read<MatchProvider>().submitTurn(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                  ),
                  child: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final int value;
  final String? label;
  const _KeyButton({required this.value, this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<MatchProvider>().addScore(value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label ?? '$value',
            style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModifierButton extends StatelessWidget {
  final String label;
  final int multiplier;
  const _ModifierButton({required this.label, required this.multiplier});

  @override
  Widget build(BuildContext context) {
    bool isActive = context.watch<MatchProvider>().multiplier == multiplier;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<MatchProvider>().setMultiplier(multiplier),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive ? [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ] : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
