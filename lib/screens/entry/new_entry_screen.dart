import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/dream_entry.dart';
import '../../state/dream_provider.dart';
import '../../state/graph_provider.dart';
import '../../theme/cosmic_theme.dart';
import 'dream_details_form.dart';
import 'dream_reflection_form.dart';

class NewEntryScreen extends StatefulWidget {
  final DreamEntry? existingDream;
  final VoidCallback? onSaved;

  const NewEntryScreen({
    super.key,
    this.existingDream,
    this.onSaved,
  });

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _peopleController;
  late TextEditingController _symbolsController;
  late TextEditingController _otherEmotionController;

  late TextEditingController _actionsEventsController;
  late TextEditingController _meaningsAssociationsController;
  late TextEditingController _recallContextController;
  late TextEditingController _notesController;
  late TextEditingController _otherWakingEmotionController;

  late DateTime _selectedDate;
  List<String> _selectedEmotions = [];
  List<String> _selectedWakingEmotions = [];
  bool _isLucid = false;
  String? _sketchData;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final d = widget.existingDream;
    _selectedDate = d?.date ?? DateTime.now();

    _titleController = TextEditingController(text: d?.title ?? '');
    _descriptionController = TextEditingController(text: d?.description ?? '');
    _peopleController = TextEditingController(text: d?.people.join(', ') ?? '');
    _symbolsController = TextEditingController(text: d?.symbols.join(', ') ?? '');
    _otherEmotionController = TextEditingController();

    _actionsEventsController = TextEditingController(text: d?.actionsEvents ?? '');
    _meaningsAssociationsController = TextEditingController(text: d?.meaningsAssociations ?? '');
    _recallContextController = TextEditingController(text: d?.recallContext ?? '');
    _notesController = TextEditingController(text: d?.notes ?? '');
    _otherWakingEmotionController = TextEditingController();

    _selectedEmotions = d != null ? List.from(d.emotionsDuring) : ['Peaceful'];
    _selectedWakingEmotions = d != null ? List.from(d.emotionsUponWaking) : ['Calm'];
    _isLucid = d?.isLucid ?? false;
    _sketchData = d?.sketchData;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _peopleController.dispose();
    _symbolsController.dispose();
    _otherEmotionController.dispose();
    _actionsEventsController.dispose();
    _meaningsAssociationsController.dispose();
    _recallContextController.dispose();
    _notesController.dispose();
    _otherWakingEmotionController.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(RegExp(r'[,;]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty && _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Dream Title or Description to record.'),
          backgroundColor: CosmicColors.astralViolet,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final allEmotionsDuring = List<String>.from(_selectedEmotions);
      if (_otherEmotionController.text.trim().isNotEmpty) {
        allEmotionsDuring.add(_otherEmotionController.text.trim());
      }

      final allWakingEmotions = List<String>.from(_selectedWakingEmotions);
      if (_otherWakingEmotionController.text.trim().isNotEmpty) {
        allWakingEmotions.add(_otherWakingEmotionController.text.trim());
      }

      final peopleList = _parseTags(_peopleController.text);
      final symbolsList = _parseTags(_symbolsController.text);

      final dream = DreamEntry(
        id: widget.existingDream?.id ?? const Uuid().v4(),
        date: _selectedDate,
        title: _titleController.text.trim().isEmpty
            ? 'Dream on ${_selectedDate.month}/${_selectedDate.day}'
            : _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        isNoRecall: false,
        emotionsDuring: allEmotionsDuring,
        people: peopleList,
        symbols: symbolsList,
        actionsEvents: _actionsEventsController.text.trim(),
        meaningsAssociations: _meaningsAssociationsController.text.trim(),
        emotionsUponWaking: allWakingEmotions,
        isLucid: _isLucid,
        recallContext: _recallContextController.text.trim(),
        notes: _notesController.text.trim(),
        sketchData: _sketchData,
      );

      final dreamProvider = Provider.of<DreamProvider>(context, listen: false);
      await dreamProvider.saveDream(dream);

      // Refresh graph provider as well so the constellation updates instantly
      if (mounted) {
        Provider.of<GraphProvider>(context, listen: false).loadGraph();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: CosmicColors.celestialCyan),
                const SizedBox(width: 8),
                Text(
                  widget.existingDream != null ? 'Dream entry updated!' : 'Dream recorded in your cosmos!',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: CosmicColors.cardSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (widget.onSaved != null) {
          widget.onSaved!();
        } else if (widget.existingDream != null) {
          Navigator.of(context).pop();
        } else {
          // Reset form for fresh morning state
          _clearForm();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _peopleController.clear();
    _symbolsController.clear();
    _otherEmotionController.clear();
    _actionsEventsController.clear();
    _meaningsAssociationsController.clear();
    _recallContextController.clear();
    _notesController.clear();
    _otherWakingEmotionController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedEmotions = ['Peaceful'];
      _selectedWakingEmotions = ['Calm'];
      _isLucid = false;
      _sketchData = null;
    });
    _tabController.animateTo(0);
  }

  Future<void> _handleNoRecall() async {
    final dreamProvider = Provider.of<DreamProvider>(context, listen: false);
    await dreamProvider.logNoRecall();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged "No Recall". Habit maintained — dreams matter!'),
          backgroundColor: CosmicColors.astralViolet,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (widget.onSaved != null) {
        widget.onSaved!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingDream != null ? 'Edit Dream' : 'Dream Capture',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
        ),
        actions: [
          if (widget.existingDream == null) ...[
            if (!Provider.of<DreamProvider>(context).isDemoMode)
              IconButton(
                tooltip: 'Preview Demo Mode',
                icon: const Icon(Icons.science_outlined, size: 20, color: CosmicColors.celestialCyan),
                onPressed: () async {
                  await Provider.of<DreamProvider>(context, listen: false).setDemoMode(true);
                  if (context.mounted) {
                    await Provider.of<GraphProvider>(context, listen: false).setDemoMode(true);
                  }
                },
              ),
            TextButton.icon(
              onPressed: _handleNoRecall,
              icon: const Icon(Icons.nights_stay_outlined, size: 16, color: CosmicColors.textMuted),
              label: const Text(
                'No Recall',
                style: TextStyle(color: CosmicColors.textSecondary, fontSize: 13),
              ),
            ),
          ],
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(widget.existingDream != null ? 'Update' : 'Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CosmicColors.astralViolet,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: CosmicColors.astralViolet,
          indicatorWeight: 3,
          labelColor: CosmicColors.textPrimary,
          unselectedLabelColor: CosmicColors.textMuted,
          tabs: const [
            Tab(
              icon: Icon(Icons.auto_stories, size: 18),
              text: '1. Dream Details',
            ),
            Tab(
              icon: Icon(Icons.psychology_alt, size: 18),
              text: '2. Reflection & Sketch',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DreamDetailsForm(
            titleController: _titleController,
            descriptionController: _descriptionController,
            peopleController: _peopleController,
            symbolsController: _symbolsController,
            otherEmotionController: _otherEmotionController,
            selectedEmotions: _selectedEmotions,
            onEmotionsChanged: (list) => setState(() => _selectedEmotions = list),
            selectedDate: _selectedDate,
            onDateChanged: (dt) => setState(() => _selectedDate = dt),
          ),
          DreamReflectionForm(
            actionsEventsController: _actionsEventsController,
            meaningsAssociationsController: _meaningsAssociationsController,
            recallContextController: _recallContextController,
            notesController: _notesController,
            otherWakingEmotionController: _otherWakingEmotionController,
            selectedWakingEmotions: _selectedWakingEmotions,
            onWakingEmotionsChanged: (list) => setState(() => _selectedWakingEmotions = list),
            isLucid: _isLucid,
            onLucidChanged: (lucid) => setState(() => _isLucid = lucid),
            sketchData: _sketchData,
            onSketchChanged: (data) => setState(() => _sketchData = data),
          ),
        ],
      ),
    );
  }
}
