import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/cosmic_theme.dart';
import '../../widgets/glass_card.dart';

class TimelineScrubber extends StatefulWidget {
  final double progress;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final ValueChanged<double> onScrub;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateTime? currentDate;
  final int visibleNodesCount;
  final int visibleEdgesCount;
  final bool initialMinimized;

  const TimelineScrubber({
    super.key,
    required this.progress,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onScrub,
    this.minDate,
    this.maxDate,
    this.currentDate,
    this.visibleNodesCount = 0,
    this.visibleEdgesCount = 0,
    this.initialMinimized = false,
  });

  @override
  State<TimelineScrubber> createState() => _TimelineScrubberState();
}

class _TimelineScrubberState extends State<TimelineScrubber> {
  late bool _isMinimized;

  @override
  void initState() {
    super.initState();
    _isMinimized = widget.initialMinimized;
  }

  void _toggleMinimized() {
    setState(() {
      _isMinimized = !_isMinimized;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y');
    final activeDateText = widget.currentDate != null
        ? dateFormat.format(widget.currentDate!)
        : 'All Time';
    final minText = widget.minDate != null ? dateFormat.format(widget.minDate!) : '';
    final maxText = widget.maxDate != null ? dateFormat.format(widget.maxDate!) : '';

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
      child: _isMinimized
          ? _buildMinimizedPill(activeDateText)
          : _buildExpandedCard(context, activeDateText, minText, maxText),
    );
  }

  Widget _buildMinimizedPill(String activeDateText) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleMinimized,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xCC0E1022), // 80% opacity translucent dark cosmic glass
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: CosmicColors.astralViolet.withOpacity(0.4),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play/Pause miniature circular button
                  InkWell(
                    onTap: widget.onTogglePlay,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [CosmicColors.astralViolet, CosmicColors.celestialCyan],
                        ),
                      ),
                      child: Icon(
                        widget.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Date text
                  Text(
                    activeDateText,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: CosmicColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: CosmicColors.astralViolet.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${widget.visibleNodesCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: CosmicColors.celestialCyan,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Minimal chevron
                  const Icon(
                    Icons.keyboard_arrow_up,
                    size: 18,
                    color: CosmicColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedCard(
    BuildContext context,
    String activeDateText,
    String minText,
    String maxText,
  ) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: _buildExpandedControls(context, activeDateText, minText, maxText),
    );
  }

  Widget _buildExpandedControls(
    BuildContext context,
    String activeDateText,
    String minText,
    String maxText,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header info row with minimize button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.timeline, size: 16, color: CosmicColors.astralViolet),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Timeline: $activeDateText',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CosmicColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: CosmicColors.cardSurfaceHover,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.visibleNodesCount} signs • ${widget.visibleEdgesCount} links',
                    style: const TextStyle(fontSize: 11, color: CosmicColors.celestialCyan),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Minimize Timeline',
                  icon: const Icon(Icons.keyboard_arrow_down, size: 22, color: CosmicColors.textSecondary),
                  onPressed: _toggleMinimized,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Controls Row: Play/Pause button + Slider scrubber
        Row(
          children: [
            // Play/Pause button
            InkWell(
              onTap: widget.onTogglePlay,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [CosmicColors.astralViolet, CosmicColors.celestialCyan],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CosmicColors.astralViolet.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  widget.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Interactive Scrubbing Slider
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: CosmicColors.astralViolet,
                  inactiveTrackColor: CosmicColors.borderSubtle,
                  thumbColor: CosmicColors.celestialCyan,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayColor: CosmicColors.celestialCyan.withOpacity(0.2),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                ),
                child: Slider(
                  value: widget.progress,
                  min: 0.0,
                  max: 1.0,
                  onChanged: widget.onScrub,
                ),
              ),
            ),
          ],
        ),

        // Date Milestones
        if (widget.minDate != null &&
            widget.maxDate != null &&
            widget.minDate != widget.maxDate) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 46),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(minText, style: const TextStyle(fontSize: 10, color: CosmicColors.textMuted)),
                Text(maxText, style: const TextStyle(fontSize: 10, color: CosmicColors.textMuted)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
