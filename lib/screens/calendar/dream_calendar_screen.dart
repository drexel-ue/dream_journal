import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/dream_entry.dart';
import '../../state/dream_provider.dart';
import '../../theme/cosmic_theme.dart';
import '../../widgets/glass_card.dart';
import '../list/dream_detail_screen.dart';

class DreamCalendarScreen extends StatefulWidget {
  final VoidCallback? onGoToCapture;

  const DreamCalendarScreen({super.key, this.onGoToCapture});

  @override
  State<DreamCalendarScreen> createState() => _DreamCalendarScreenState();
}

class _DreamCalendarScreenState extends State<DreamCalendarScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dreamProvider = Provider.of<DreamProvider>(context);
    final dreams = dreamProvider.dreams;
    final selectedDate = dreamProvider.selectedDate;

    // Group dreams by day string 'yyyy-MM-dd'
    final Map<String, List<DreamEntry>> dreamsByDay = {};
    for (final d in dreams) {
      final key = DateFormat('yyyy-MM-dd').format(d.date);
      dreamsByDay.putIfAbsent(key, () => []).add(d);
    }

    final selectedKey = DateFormat('yyyy-MM-dd').format(selectedDate);
    final selectedDayDreams = dreamsByDay[selectedKey] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dream Calendar',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Month navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: CosmicColors.celestialCyan),
                        onPressed: _prevMonth,
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_currentMonth),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: CosmicColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: CosmicColors.celestialCyan),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                ),

                // Days of week header (7 equal expanded columns aligned with grid)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: const [
                      Expanded(child: _WeekdayLabel('Sun')),
                      Expanded(child: _WeekdayLabel('Mon')),
                      Expanded(child: _WeekdayLabel('Tue')),
                      Expanded(child: _WeekdayLabel('Wed')),
                      Expanded(child: _WeekdayLabel('Thu')),
                      Expanded(child: _WeekdayLabel('Fri')),
                      Expanded(child: _WeekdayLabel('Sat')),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Calendar Grid Container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    padding: const EdgeInsets.all(6),
                    child: _buildMonthGrid(context, dreamProvider, dreamsByDay),
                  ),
                ),
                const SizedBox(height: 16),

                // Selected Date Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('EEEE, MMMM d').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: CosmicColors.lucidPurple,
                          ),
                        ),
                      ),
                      Text(
                        '${selectedDayDreams.length} ${selectedDayDreams.length == 1 ? 'dream' : 'dreams'}',
                        style: const TextStyle(fontSize: 12, color: CosmicColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),

          // Selected day dreams or empty placeholder
          if (selectedDayDreams.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.nights_stay_outlined,
                        size: 32,
                        color: CosmicColors.textMuted.withOpacity(0.45),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No dream recorded for this night',
                        style: TextStyle(color: CosmicColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, idx) {
                    final dream = selectedDayDreams[idx];
                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DreamDetailScreen(dream: dream),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dream.isLucid
                                  ? CosmicColors.starlightGold.withOpacity(0.2)
                                  : CosmicColors.astralViolet.withOpacity(0.2),
                            ),
                            child: Icon(
                              dream.isLucid ? Icons.star : Icons.auto_awesome,
                              size: 16,
                              color: dream.isLucid ? CosmicColors.starlightGold : CosmicColors.celestialCyan,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                if (dream.description.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    dream.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: CosmicColors.textSecondary),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18, color: CosmicColors.textMuted),
                        ],
                      ),
                    );
                  },
                  childCount: selectedDayDreams.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(
    BuildContext context,
    DreamProvider dreamProvider,
    Map<String, List<DreamEntry>> dreamsByDay,
  ) {
    final firstDayOfWeek = _currentMonth.weekday % 7; // Sunday = 0
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final totalCells = ((firstDayOfWeek + daysInMonth) / 7).ceil() * 7;

    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    final selectedKey = DateFormat('yyyy-MM-dd').format(dreamProvider.selectedDate);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.22,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayNumber = index - firstDayOfWeek + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final dayDreams = dreamsByDay[dateKey] ?? [];

        final isToday = dateKey == todayKey;
        final isSelected = dateKey == selectedKey;
        final hasLucid = dayDreams.any((d) => d.isLucid);
        final hasDream = dayDreams.any((d) => !d.isNoRecall);
        final hasNoRecall = dayDreams.any((d) => d.isNoRecall);

        return GestureDetector(
          onTap: () => dreamProvider.selectDate(date),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? CosmicColors.astralViolet.withOpacity(0.35)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? CosmicColors.astralViolet
                    : isToday
                        ? CosmicColors.celestialCyan.withOpacity(0.5)
                        : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? CosmicColors.celestialCyan
                              : isSelected
                                  ? Colors.white
                                  : CosmicColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Indicator dot or star
                      if (hasLucid)
                        const Icon(Icons.star, size: 7, color: CosmicColors.starlightGold)
                      else if (hasDream)
                        Container(
                          width: 4.5,
                          height: 4.5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CosmicColors.lucidPurple,
                          ),
                        )
                      else if (hasNoRecall)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: CosmicColors.textMuted, width: 0.8),
                          ),
                        )
                      else
                        const SizedBox(height: 4.5),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          color: CosmicColors.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
