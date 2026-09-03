import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/dream_entry.dart';
import '../../state/dream_provider.dart';
import '../../theme/cosmic_theme.dart';
import '../../widgets/cosmic_empty_state.dart';
import '../../widgets/glass_card.dart';
import 'dream_detail_screen.dart';

import '../../state/graph_provider.dart';

class DreamListScreen extends StatefulWidget {
  final VoidCallback? onGoToCapture;

  const DreamListScreen({super.key, this.onGoToCapture});

  @override
  State<DreamListScreen> createState() => _DreamListScreenState();
}

class _DreamListScreenState extends State<DreamListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dreamProvider = Provider.of<DreamProvider>(context);
    final dreams = dreamProvider.dreams;
    final streak = dreamProvider.streak;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dream Chronicle',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20),
        ),
        actions: [
          if (!dreamProvider.isDemoMode)
            IconButton(
              tooltip: 'Preview Demo Mode',
              icon: const Icon(Icons.science_outlined, size: 20, color: CosmicColors.celestialCyan),
              onPressed: () async {
                await dreamProvider.setDemoMode(true);
                if (context.mounted) {
                  await Provider.of<GraphProvider>(context, listen: false).setDemoMode(true);
                }
              },
            ),
          // Streak pill
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: streak > 0
                  ? CosmicColors.starlightGold.withOpacity(0.18)
                  : CosmicColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: streak > 0
                    ? CosmicColors.starlightGold.withOpacity(0.5)
                    : CosmicColors.borderSubtle,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: streak > 0 ? CosmicColors.starlightGold : CosmicColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak Day Streak',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: streak > 0 ? CosmicColors.starlightGold : CosmicColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => dreamProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search dreams, symbols, emotions, characters...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: CosmicColors.celestialCyan),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              dreamProvider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilterChip(
                      selected: dreamProvider.lucidFilter,
                      label: const Text('Lucid Only'),
                      avatar: const Icon(Icons.star, size: 14, color: CosmicColors.starlightGold),
                      selectedColor: CosmicColors.starlightGold.withOpacity(0.25),
                      checkmarkColor: CosmicColors.starlightGold,
                      onSelected: (_) => dreamProvider.toggleLucidFilter(),
                    ),
                    if (dreamProvider.tagFilter != null) ...[
                      const SizedBox(width: 8),
                      InputChip(
                        label: Text('Sign: ${dreamProvider.tagFilter}'),
                        avatar: const Icon(Icons.tag, size: 14, color: CosmicColors.celestialCyan),
                        onDeleted: () => dreamProvider.setTagFilter(null),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${dreams.length} ${dreams.length == 1 ? 'entry' : 'entries'}',
                      style: const TextStyle(fontSize: 12, color: CosmicColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Dreams List or Empty State
          Expanded(
            child: dreamProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: CosmicColors.astralViolet),
                  )
                : dreams.isEmpty
                    ? CosmicEmptyState(
                        icon: Icons.nightlight_round,
                        title: 'Your Dream Cosmos is Clear',
                        message: _searchController.text.isNotEmpty || dreamProvider.lucidFilter
                            ? 'No entries match your search filters.'
                            : 'No dreams recorded yet. Wake up, open the app, and capture your night visions immediately before they fade!',
                        actionLabel: _searchController.text.isNotEmpty ? null : 'Record First Dream',
                        onAction: widget.onGoToCapture,
                        secondaryActionLabel: _searchController.text.isNotEmpty ? null : 'Explore in Demo Mode',
                        onSecondaryAction: () async {
                          await dreamProvider.setDemoMode(true);
                          if (context.mounted) {
                            await Provider.of<GraphProvider>(context, listen: false).setDemoMode(true);
                          }
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: dreams.length,
                        itemBuilder: (context, index) {
                          final dream = dreams[index];
                          return _DreamCard(dream: dream);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _DreamCard extends StatelessWidget {
  final DreamEntry dream;

  const _DreamCard({required this.dream});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DreamDetailScreen(dream: dream),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormat.format(dream.date),
                style: const TextStyle(fontSize: 12, color: CosmicColors.textMuted),
              ),
              if (dream.isLucid)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: CosmicColors.starlightGold.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: CosmicColors.starlightGold.withOpacity(0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 11, color: CosmicColors.starlightGold),
                      SizedBox(width: 3),
                      Text(
                        'LUCID',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: CosmicColors.starlightGold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dream.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: CosmicColors.textPrimary,
            ),
          ),
          if (dream.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              dream.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: CosmicColors.textSecondary, height: 1.35),
            ),
          ],
          const SizedBox(height: 12),
          // Chips Row
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ...dream.symbols.take(3).map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: CosmicColors.cardSurfaceHover,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: CosmicColors.celestialCyan.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, size: 6, color: CosmicColors.celestialCyan),
                        const SizedBox(width: 4),
                        Text(s, style: const TextStyle(fontSize: 11, color: CosmicColors.textPrimary)),
                      ],
                    ),
                  )),
              ...dream.people.take(2).map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: CosmicColors.cardSurfaceHover,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: CosmicColors.auraPink.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 10, color: CosmicColors.auraPink),
                        const SizedBox(width: 4),
                        Text(p, style: const TextStyle(fontSize: 11, color: CosmicColors.textPrimary)),
                      ],
                    ),
                  )),
              if (dream.sketchData != null && dream.sketchData!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: CosmicColors.cardSurfaceHover,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: CosmicColors.starlightGold.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.brush, size: 10, color: CosmicColors.starlightGold),
                      SizedBox(width: 4),
                      Text('Sketch', style: TextStyle(fontSize: 11, color: CosmicColors.starlightGold)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
