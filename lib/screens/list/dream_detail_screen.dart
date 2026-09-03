import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/dream_entry.dart';
import '../../state/dream_provider.dart';
import '../../state/graph_provider.dart';
import '../../theme/cosmic_theme.dart';
import '../../widgets/botanical_divider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/sketch_canvas.dart';
import '../entry/new_entry_screen.dart';

class DreamDetailScreen extends StatelessWidget {
  final DreamEntry dream;

  const DreamDetailScreen({super.key, required this.dream});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CosmicColors.cardSurface,
        title: const Text('Delete Dream Entry?'),
        content: const Text('This will remove the dream and its signs from your constellation graph.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: CosmicColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: CosmicColors.cosmicRed),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = Provider.of<DreamProvider>(context, listen: false);
      await provider.deleteDream(dream.id);
      if (context.mounted) {
        Provider.of<GraphProvider>(context, listen: false).loadGraph();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y • h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          dream.title.isNotEmpty ? dream.title : 'Dream Entry',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Dream',
            icon: const Icon(Icons.edit_outlined, color: CosmicColors.celestialCyan),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NewEntryScreen(
                    existingDream: dream,
                    onSaved: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Delete Dream',
            icon: const Icon(Icons.delete_outline, color: CosmicColors.cosmicRed),
            onPressed: () => _confirmDelete(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top metadata card
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormat.format(dream.date),
                        style: const TextStyle(
                          color: CosmicColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      if (dream.isLucid)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: CosmicColors.starlightGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: CosmicColors.starlightGold.withOpacity(0.6)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 13, color: CosmicColors.starlightGold),
                              SizedBox(width: 4),
                              Text(
                                'LUCID',
                                style: TextStyle(
                                  color: CosmicColors.starlightGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dream.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: CosmicColors.textPrimary,
                          fontSize: 22,
                        ),
                  ),
                  if (dream.isNoRecall) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CosmicColors.astralViolet.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 18, color: CosmicColors.celestialCyan),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Habit maintained: Logged with no immediate recall.',
                              style: TextStyle(color: CosmicColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Narrative Description
            if (dream.description.isNotEmpty) ...[
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: CosmicColors.lucidPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dream.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: CosmicColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Emotions Chips (During & Upon Waking)
            if (dream.emotionsDuring.isNotEmpty || dream.emotionsUponWaking.isNotEmpty) ...[
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dream.emotionsDuring.isNotEmpty) ...[
                      const Text(
                        'Emotions During Dream',
                        style: TextStyle(fontSize: 13, color: CosmicColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: dream.emotionsDuring.map((e) {
                          return Chip(
                            label: Text(e),
                            backgroundColor: CosmicColors.astralViolet.withOpacity(0.2),
                            side: const BorderSide(color: CosmicColors.borderLight),
                          );
                        }).toList(),
                      ),
                    ],
                    if (dream.emotionsDuring.isNotEmpty && dream.emotionsUponWaking.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: CosmicColors.borderSubtle),
                      ),
                    if (dream.emotionsUponWaking.isNotEmpty) ...[
                      const Text(
                        'Emotions Upon Waking',
                        style: TextStyle(fontSize: 13, color: CosmicColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: dream.emotionsUponWaking.map((e) {
                          return Chip(
                            label: Text(e),
                            backgroundColor: CosmicColors.celestialCyan.withOpacity(0.2),
                            side: const BorderSide(color: CosmicColors.borderLight),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Dream Signs & People
            if (dream.symbols.isNotEmpty || dream.people.isNotEmpty) ...[
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dream.symbols.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: CosmicColors.celestialCyan),
                          SizedBox(width: 6),
                          Text(
                            'Symbols & Objects (Dream Signs)',
                            style: TextStyle(fontSize: 13, color: CosmicColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: dream.symbols.map((s) {
                          return Chip(
                            avatar: const Icon(Icons.circle, size: 8, color: CosmicColors.celestialCyan),
                            label: Text(s),
                            backgroundColor: CosmicColors.cardSurface,
                            side: const BorderSide(color: CosmicColors.borderLight),
                          );
                        }).toList(),
                      ),
                    ],
                    if (dream.symbols.isNotEmpty && dream.people.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: CosmicColors.borderSubtle),
                      ),
                    if (dream.people.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.people_outline, size: 16, color: CosmicColors.auraPink),
                          SizedBox(width: 6),
                          Text(
                            'People & Characters',
                            style: TextStyle(fontSize: 13, color: CosmicColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: dream.people.map((p) {
                          return Chip(
                            avatar: const Icon(Icons.circle, size: 8, color: CosmicColors.auraPink),
                            label: Text(p),
                            backgroundColor: CosmicColors.cardSurface,
                            side: const BorderSide(color: CosmicColors.borderLight),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Actions & Events
            if (dream.actionsEvents.isNotEmpty) ...[
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actions & Events (Order of Moments)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CosmicColors.lucidPurple),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dream.actionsEvents,
                      style: const TextStyle(fontSize: 14, height: 1.5, color: CosmicColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Possible Meanings / Associations
            if (dream.meaningsAssociations.isNotEmpty) ...[
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Possible Meanings or Associations',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CosmicColors.lucidPurple),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dream.meaningsAssociations,
                      style: const TextStyle(fontSize: 14, height: 1.5, color: CosmicColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Recall Context & Notes
            if (dream.recallContext.isNotEmpty || dream.notes.isNotEmpty) ...[
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dream.recallContext.isNotEmpty) ...[
                      const Text(
                        'When & How Recalled:',
                        style: TextStyle(fontSize: 13, color: CosmicColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dream.recallContext,
                        style: const TextStyle(fontSize: 14, color: CosmicColors.textPrimary),
                      ),
                    ],
                    if (dream.recallContext.isNotEmpty && dream.notes.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: CosmicColors.borderSubtle),
                      ),
                    if (dream.notes.isNotEmpty) ...[
                      const Text(
                        'Notes & Additional Thoughts:',
                        style: TextStyle(fontSize: 13, color: CosmicColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dream.notes,
                        style: const TextStyle(fontSize: 14, color: CosmicColors.textPrimary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Sketch Box Display
            if (dream.sketchData != null && dream.sketchData!.isNotEmpty) ...[
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.brush, size: 16, color: CosmicColors.starlightGold),
                        SizedBox(width: 8),
                        Text(
                          'Sketch Box',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CosmicColors.starlightGold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SketchCanvas(
                      readOnly: true,
                      initialData: dream.sketchData,
                      height: 240,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),
            const BotanicalDivider(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
