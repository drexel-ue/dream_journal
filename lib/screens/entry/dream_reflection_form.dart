import 'package:flutter/material.dart';
import '../../theme/cosmic_theme.dart';
import '../../widgets/botanical_divider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/sketch_canvas.dart';

class DreamReflectionForm extends StatefulWidget {
  final TextEditingController actionsEventsController;
  final TextEditingController meaningsAssociationsController;
  final TextEditingController recallContextController;
  final TextEditingController notesController;
  final TextEditingController otherWakingEmotionController;
  final List<String> selectedWakingEmotions;
  final ValueChanged<List<String>> onWakingEmotionsChanged;
  final bool isLucid;
  final ValueChanged<bool> onLucidChanged;
  final String? sketchData;
  final ValueChanged<String> onSketchChanged;

  const DreamReflectionForm({
    super.key,
    required this.actionsEventsController,
    required this.meaningsAssociationsController,
    required this.recallContextController,
    required this.notesController,
    required this.otherWakingEmotionController,
    required this.selectedWakingEmotions,
    required this.onWakingEmotionsChanged,
    required this.isLucid,
    required this.onLucidChanged,
    required this.sketchData,
    required this.onSketchChanged,
  });

  @override
  State<DreamReflectionForm> createState() => _DreamReflectionFormState();
}

class _DreamReflectionFormState extends State<DreamReflectionForm> {
  final List<String> _standardWakingEmotions = const [
    'Calm',
    'Confused',
    'Anxious',
    'Inspired',
  ];

  void _toggleEmotion(String emotion) {
    final list = List<String>.from(widget.selectedWakingEmotions);
    if (list.contains(emotion)) {
      list.remove(emotion);
    } else {
      list.add(emotion);
    }
    widget.onWakingEmotionsChanged(list);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dream Reflection',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: CosmicColors.lucidPurple,
                    ),
              ),
              // Lucid Badge Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isLucid
                      ? CosmicColors.starlightGold.withOpacity(0.2)
                      : CosmicColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isLucid
                        ? CosmicColors.starlightGold
                        : CosmicColors.borderSubtle,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isLucid ? Icons.star : Icons.star_border,
                      size: 14,
                      color: widget.isLucid ? CosmicColors.starlightGold : CosmicColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.isLucid ? 'Lucid Dream' : 'Non-Lucid',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.isLucid ? CosmicColors.starlightGold : CosmicColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Actions & Events
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actions & Events:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: CosmicColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '(What happened? List or describe key moments in chronological order.)',
                  style: TextStyle(fontSize: 12, color: CosmicColors.textMuted, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: widget.actionsEventsController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  decoration: const InputDecoration(
                    hintText: '1. Stood on the shore\n2. The water turned to stars\n3. Took off into the sky...',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Possible Meanings or Associations
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Possible Meanings or Associations:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: CosmicColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '(Does this dream relate to anything in your waking life? Does it remind you of something?)',
                  style: TextStyle(fontSize: 12, color: CosmicColors.textMuted, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: widget.meaningsAssociationsController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  decoration: const InputDecoration(
                    hintText: 'Felt related to my transition at work and yearning for freedom...',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // How the Dream Made You Feel Upon Waking & Lucidity Row
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How the Dream Made You Feel Upon Waking:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: CosmicColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _standardWakingEmotions.map((emotion) {
                    final isSelected = widget.selectedWakingEmotions.contains(emotion);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(emotion),
                      onSelected: (_) => _toggleEmotion(emotion),
                      selectedColor: CosmicColors.celestialCyan.withOpacity(0.35),
                      checkmarkColor: CosmicColors.celestialCyan,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Other:', style: TextStyle(fontSize: 13, color: CosmicColors.textSecondary)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: widget.otherWakingEmotionController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'e.g., Electrified, Rested, Nostalgic',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: CosmicColors.borderSubtle),
                const SizedBox(height: 10),

                // Lucid or Not?
                Row(
                  children: [
                    const Text(
                      'Lucid or Not?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const Spacer(),
                    ChoiceChip(
                      label: const Text('No'),
                      selected: !widget.isLucid,
                      onSelected: (val) {
                        if (val) widget.onLucidChanged(false);
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      avatar: widget.isLucid
                          ? const Icon(Icons.auto_awesome, size: 14, color: CosmicColors.starlightGold)
                          : null,
                      label: const Text('Yes (Lucid)'),
                      selected: widget.isLucid,
                      selectedColor: CosmicColors.starlightGold.withOpacity(0.3),
                      onSelected: (val) {
                        if (val) widget.onLucidChanged(true);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // When and How Did You Recall This Dream?
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'When and How Did You Recall This Dream?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: CosmicColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: widget.recallContextController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'e.g., Immediately upon waking, while lying still with eyes closed',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notes & Additional Thoughts
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notes & Additional Thoughts:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: CosmicColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: widget.notesController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Any sounds, textures, lucidity triggers, or morning reflections...',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sketch Box
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.brush, size: 18, color: CosmicColors.starlightGold),
                    const SizedBox(width: 8),
                    const Text(
                      'Sketch Box:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: CosmicColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'scene, symbol, or feeling',
                      style: TextStyle(
                        fontSize: 13,
                        color: CosmicColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SketchCanvas(
                  initialData: widget.sketchData,
                  onChanged: widget.onSketchChanged,
                  height: 250,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Botanical Ornament
          const BotanicalDivider(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
