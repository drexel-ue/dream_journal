import 'package:flutter/material.dart';
import '../../theme/cosmic_theme.dart';
import '../../widgets/botanical_divider.dart';
import '../../widgets/glass_card.dart';

class BedtimeAffirmationScreen extends StatefulWidget {
  const BedtimeAffirmationScreen({super.key});

  @override
  State<BedtimeAffirmationScreen> createState() => _BedtimeAffirmationScreenState();
}

class _BedtimeAffirmationScreenState extends State<BedtimeAffirmationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  final List<String> _affirmations = [
    'I will remember my dreams when I wake up.',
    'Tonight, I will recognize when I am dreaming.',
    'My dream memories remain vivid and clear upon waking.',
    'Dreams are meaningful, and my awareness is expanding.',
  ];

  int _selectedAffirmationIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.12).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bedtime Intention',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Prime Your Subconscious',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: CosmicColors.celestialCyan,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Evening Affirmation',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 24,
                    color: CosmicColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 32),

            // Pulsating Celestial Breathing Orb
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          CosmicColors.lucidPurple.withOpacity(0.35),
                          CosmicColors.astralViolet.withOpacity(0.15),
                          Colors.transparent,
                        ],
                        stops: const [0.2, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CosmicColors.astralViolet.withOpacity(0.25),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CosmicColors.cardSurface,
                          border: Border.all(
                            color: CosmicColors.astralViolet.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.nights_stay,
                          size: 44,
                          color: CosmicColors.starlightGold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 36),

            // Main Affirmation Card
            GlassCard(
              padding: const EdgeInsets.all(24),
              hasGlow: true,
              child: Column(
                children: [
                  const Icon(Icons.format_quote, size: 28, color: CosmicColors.astralViolet),
                  const SizedBox(height: 8),
                  Text(
                    '"${_affirmations[_selectedAffirmationIndex]}"',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 19,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_affirmations.length, (idx) {
                      final isSelected = idx == _selectedAffirmationIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAffirmationIndex = idx),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isSelected ? CosmicColors.celestialCyan : CosmicColors.borderSubtle,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Gentle Waking Guidance from the chapter
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.wb_twilight, size: 18, color: CosmicColors.starlightGold),
                      SizedBox(width: 8),
                      Text(
                        'Morning Retracing Ritual',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CosmicColors.starlightGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'When you first wake up, lie still with your eyes closed before moving or speaking. Ask yourself:\n\n'
                    '• "Where was I just now?"\n'
                    '• "What was I feeling?"\n\n'
                    'This fragile moment is when dream memories are easiest to catch. Then open the journal to record.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: CosmicColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const BotanicalDivider(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
