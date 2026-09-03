import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/graph_node.dart';
import '../../models/dream_entry.dart';
import '../../theme/cosmic_theme.dart';
import '../../widgets/glass_card.dart';
import '../list/dream_detail_screen.dart';

class NodeDetailSheet extends StatelessWidget {
  final GraphNode node;
  final List<DreamEntry> connectedDreams;
  final bool isLoading;

  const NodeDetailSheet({
    super.key,
    required this.node,
    required this.connectedDreams,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y');
    final lucidityPct = (node.lucidityRate * 100).round();

    return Container(
      decoration: const BoxDecoration(
        color: CosmicColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: CosmicColors.borderLight, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CosmicColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: node.categoryColor.withOpacity(0.2),
                  border: Border.all(color: node.categoryColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: node.glowColor.withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  node.category == 'person' ? Icons.person : Icons.auto_awesome,
                  color: node.categoryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20),
                    ),
                    Text(
                      '${node.category.toUpperCase()} • ${node.count} ${node.count == 1 ? 'DREAM' : 'DREAMS'}',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.bold,
                        color: node.categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Lucidity correlation pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: CosmicColors.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: lucidityPct > 40
                        ? CosmicColors.starlightGold
                        : CosmicColors.borderSubtle,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: lucidityPct > 40 ? CosmicColors.starlightGold : CosmicColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$lucidityPct% Lucid',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: lucidityPct > 40 ? CosmicColors.starlightGold : CosmicColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // First / Last seen info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'First: ${dateFormat.format(node.firstSeen)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: CosmicColors.textMuted),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Latest: ${dateFormat.format(node.lastSeen)}',
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: CosmicColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: CosmicColors.borderSubtle),
          const SizedBox(height: 10),

          Text(
            'Dreams Connected to "${node.name}"',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CosmicColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Connected dreams list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: CosmicColors.astralViolet),
                  )
                : connectedDreams.isEmpty
                    ? const Center(
                        child: Text(
                          'No connected dreams found.',
                          style: TextStyle(color: CosmicColors.textMuted),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: connectedDreams.length,
                        itemBuilder: (context, idx) {
                          final dream = connectedDreams[idx];
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DreamDetailScreen(dream: dream),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                if (dream.isLucid)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.star, size: 14, color: CosmicColors.starlightGold),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dream.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: CosmicColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        dateFormat.format(dream.date),
                                        style: const TextStyle(fontSize: 11, color: CosmicColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, size: 16, color: CosmicColors.textMuted),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
