import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/graph_node.dart';
import '../../state/graph_provider.dart';
import '../../theme/cosmic_theme.dart';
import '../../widgets/cosmic_empty_state.dart';
import '../../widgets/glass_card.dart';
import 'cosmic_graph_canvas.dart';
import 'node_detail_sheet.dart';
import 'timeline_scrubber.dart';

import '../../state/dream_provider.dart';

class CosmicGraphScreen extends StatefulWidget {
  final VoidCallback? onGoToCapture;

  const CosmicGraphScreen({super.key, this.onGoToCapture});

  @override
  State<CosmicGraphScreen> createState() => _CosmicGraphScreenState();
}

class _CosmicGraphScreenState extends State<CosmicGraphScreen> {
  final TransformationController _transController = TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerView();
    });
  }

  void _centerView() {
    // Canvas is 2400x2400. Center it in viewport
    final media = MediaQuery.of(context).size;
    const worldSize = 2400.0;
    const initialScale = 0.85;

    final tx = (media.width - worldSize * initialScale) / 2;
    final ty = (media.height - worldSize * initialScale) / 2;

    _transController.value = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(initialScale);
  }

  @override
  void dispose() {
    _transController.dispose();
    super.dispose();
  }

  void _handleSelectNode(GraphProvider graphProvider, GraphNode node) async {
    await graphProvider.selectNode(node);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer<GraphProvider>(
          builder: (context, provider, _) {
            return NodeDetailSheet(
              node: node,
              connectedDreams: provider.selectedNodeDreams,
              isLoading: provider.isLoadingSheet,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final graphProvider = Provider.of<GraphProvider>(context);
    final dreamProvider = Provider.of<DreamProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Dream Signs Constellation',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
        ),
        actions: [
          if (!dreamProvider.isDemoMode)
            IconButton(
              tooltip: 'Preview Demo Constellation',
              icon: const Icon(Icons.science_outlined, color: CosmicColors.celestialCyan),
              onPressed: () async {
                await dreamProvider.setDemoMode(true);
                await graphProvider.setDemoMode(true);
              },
            ),
          // Reset view
          IconButton(
            tooltip: 'Center Constellation',
            icon: const Icon(Icons.filter_center_focus, color: CosmicColors.celestialCyan),
            onPressed: _centerView,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Graph Canvas or Empty State
          if (graphProvider.isLoading)
            const Center(
              child: CircularProgressIndicator(color: CosmicColors.astralViolet),
            )
          else if (!graphProvider.hasData)
            CosmicEmptyState(
              icon: Icons.hub_outlined,
              title: 'The Constellation is Still',
              message: 'When you record dreams and list symbols, places, and people, they form living stars connected by the dreams they share.',
              actionLabel: 'Record Dream to Ignite Stars',
              onAction: widget.onGoToCapture,
              secondaryActionLabel: 'Ignite Demo Constellation',
              onSecondaryAction: () async {
                await dreamProvider.setDemoMode(true);
                await graphProvider.setDemoMode(true);
              },
            )
          else ...[
            // Main Interactive Graph Canvas
            Positioned.fill(
              child: CosmicGraphCanvas(
                nodes: graphProvider.visibleNodes,
                edges: graphProvider.visibleEdges,
                transformationController: _transController,
                onDragNode: (node, delta) => graphProvider.dragNode(node, delta),
                onReleaseNode: (node) => graphProvider.releaseNode(node),
                onSelectNode: (node) => _handleSelectNode(graphProvider, node),
              ),
            ),

            // Top Legend Bar
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  borderRadius: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _LegendDot(color: CosmicColors.celestialCyan, label: 'Symbols'),
                      SizedBox(width: 10),
                      _LegendDot(color: CosmicColors.auraPink, label: 'People'),
                      SizedBox(width: 10),
                      _LegendDot(color: CosmicColors.starlightGold, label: 'Lucid Triggers'),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Timeline Growth Scrubber
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: TimelineScrubber(
                progress: graphProvider.timelineProgress,
                isPlaying: graphProvider.isPlaying,
                onTogglePlay: graphProvider.togglePlay,
                onScrub: graphProvider.setScrubberProgress,
                minDate: graphProvider.minDate,
                maxDate: graphProvider.maxDate,
                currentDate: graphProvider.activeCutoffDate,
                visibleNodesCount: graphProvider.visibleNodes.length,
                visibleEdgesCount: graphProvider.visibleEdges.length,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: CosmicColors.textSecondary),
        ),
      ],
    );
  }
}
