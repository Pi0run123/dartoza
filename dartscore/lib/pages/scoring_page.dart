import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';
import '../theme.dart';

class ScoringPage extends StatelessWidget {
  const ScoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _ScoreDisplay(),
            const Spacer(),
            const _Keypad(),
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
          return Column(
            children: [
              Text(
                uid == 'p1' ? 'PLAYER 1' : 'PLAYER 2',
                style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                  color: isActive ? AppTheme.primary : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: isActive ? BoxDecoration(
                  border: Border.all(color: AppTheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ) : null,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '${match.scores[uid]}',
                  style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(
                    color: isActive ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ModifierButton(label: 'DOUBLE', multiplier: 2),
              _ModifierButton(label: 'TRIPLE', multiplier: 3),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => context.read<MatchProvider>().undoLastDart(),
                  child: const Text('UNDO', style: TextStyle(color: Colors.red)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<MatchProvider>().submitTurn(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('CONFIRM'),
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
    return GestureDetector(
      onTap: () => context.read<MatchProvider>().addScore(value),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              label ?? '$value',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
    return GestureDetector(
      onTap: () => context.read<MatchProvider>().setMultiplier(multiplier),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
