import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/cosmic_theme.dart';
import '../../widgets/botanical_divider.dart';
import '../../widgets/glass_card.dart';

class DreamDetailsForm extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController peopleController;
  final TextEditingController symbolsController;
  final TextEditingController otherEmotionController;
  final List<String> selectedEmotions;
  final ValueChanged<List<String>> onEmotionsChanged;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DreamDetailsForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.peopleController,
    required this.symbolsController,
    required this.otherEmotionController,
    required this.selectedEmotions,
    required this.onEmotionsChanged,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<DreamDetailsForm> createState() => _DreamDetailsFormState();
}

class _DreamDetailsFormState extends State<DreamDetailsForm> {
  final List<String> _standardEmotions = const [
    'Happy',
    'Sad',
    'Fearful',
    'Confused',
    'Excited',
    'Angry',
    'Peaceful',
  ];

  void _toggleEmotion(String emotion) {
    final list = List<String>.from(widget.selectedEmotions);
    if (list.contains(emotion)) {
      list.remove(emotion);
    } else {
      list.add(emotion);
    }
    widget.onEmotionsChanged(list);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: CosmicColors.astralViolet,
              surface: CosmicColors.cardSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      widget.onDateChanged(DateTime(
        picked.year,
        picked.month,
        picked.day,
        widget.selectedDate.hour,
        widget.selectedDate.minute,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Dream Details',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: CosmicColors.lucidPurple,
                    ),
              ),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 16, color: CosmicColors.celestialCyan),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(widget.selectedDate),
                        style: const TextStyle(
                          color: CosmicColors.textSecondary,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dream Title:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: CosmicColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: widget.titleController,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'e.g., The Silver Ocean and the Clock Tower',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: CosmicColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '(Write a summary of the dream in as much detail as possible. Use present tense for immediacy.)',
                  style: TextStyle(fontSize: 12, color: CosmicColors.textMuted, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: widget.descriptionController,
                  maxLines: 6,
                  style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'I am walking down a corridor with blue glowing tiles...',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Emotions Felt During Dream
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emotions Felt During the Dream:',
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
                  children: _standardEmotions.map((emotion) {
                    final isSelected = widget.selectedEmotions.contains(emotion);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(emotion),
                      onSelected: (_) => _toggleEmotion(emotion),
                      selectedColor: CosmicColors.astralViolet.withOpacity(0.4),
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
                        controller: widget.otherEmotionController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'e.g., Awe, Melancholy, Wonder',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // People or Figures
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 18, color: CosmicColors.auraPink),
                    const SizedBox(width: 8),
                    const Text(
                      'People or Figures in the Dream:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: CosmicColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '(List key characters, entities, or people. Separate with commas to build graph connections.)',
                  style: TextStyle(fontSize: 12, color: CosmicColors.textMuted, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: widget.peopleController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'e.g., Grandmother, Old Friend Alex, Tall Shadow, Guide',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Symbols & Objects
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 18, color: CosmicColors.celestialCyan),
                    const SizedBox(width: 8),
                    const Text(
                      'Symbols & Objects:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: CosmicColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '(What stood out? Animals, numbers, places, colors, recurring dream signs. Comma-separated.)',
                  style: TextStyle(fontSize: 12, color: CosmicColors.textMuted, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: widget.symbolsController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'e.g., Flying, Luminescent Ocean, Gold Clock, White Owl, Labyrinth',
                  ),
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
