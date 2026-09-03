import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/dream_provider.dart';
import '../state/graph_provider.dart';
import '../theme/cosmic_theme.dart';

class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final dreamProvider = Provider.of<DreamProvider>(context);

    if (!dreamProvider.isDemoMode) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
        ),
        boxShadow: [
          BoxShadow(
            color: CosmicColors.astralViolet.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(Icons.science_outlined, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'PREVIEW MODE: Testing with sample dreams. Your personal journal is completely safe and untouched.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                await dreamProvider.setDemoMode(false);
                if (context.mounted) {
                  await Provider.of<GraphProvider>(context, listen: false).setDemoMode(false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6D28D9),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: const Size(0, 28),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Exit Demo',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
