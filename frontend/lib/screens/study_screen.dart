import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/top_app_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../components/pharmaq_card.dart';
import '../components/glass_card.dart';
import '../providers/assessment_provider.dart';
import '../services/api_service.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  final _searchController = TextEditingController();

  List<String> _stores = ['All'];
  List<String> _departments = ['All'];
  List<String> _examDays = ['All'];

  String _selectedStore = 'All';
  String _selectedDept = 'All';
  String _selectedDay = 'All';

  List<dynamic>? _questions;
  bool _isLoadingFilters = true;
  bool _isLoadingQuestions = false;
  bool _hasLoaded = false;

  Color get _primaryColor => Theme.of(context).colorScheme.primary;
  Color get _backgroundColor => Theme.of(context).colorScheme.surface;
  Color get _surfaceContainer => Theme.of(context).colorScheme.surfaceContainer;
  Color get _surfaceContainerHighest => Theme.of(context).colorScheme.surfaceContainerHighest;
  Color get _surfaceContainerLowest => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF09090b) : const Color(0xFFFFFFFF);
  Color get _outline => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3f3f46) : const Color(0xFFD4D4D8);
  Color get _outlineVariant => Theme.of(context).colorScheme.outlineVariant;
  Color get _tertiaryColor => Theme.of(context).colorScheme.secondary;
  Color get _errorColor => Theme.of(context).colorScheme.error;
  Color get _onSurfaceColor => Theme.of(context).colorScheme.onSurface;
  Color get _onSurfaceVariantColor => Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadFilterOptions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterOptions() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final questions = await apiService.getQuestions();
      final storesSet = <String>{};
      final specSet = <String>{};
      final daysSet = <String>{};

      for (var q in questions) {
        if (q['store'] != null) {
          final s = q['store'].toString().trim();
          if (s.isNotEmpty) storesSet.add(s);
        }
        if (q['speciality'] != null) {
          final sp = q['speciality'].toString().trim().split('|').first;
          if (sp.isNotEmpty) specSet.add(sp);
        }
        if (q['days'] != null) {
          final d = q['days'].toString().trim();
          if (d.isNotEmpty) daysSet.add(d);
        }
      }

      final sortedStores = storesSet.toList()..sort();
      final sortedSpecs = specSet.toList()..sort();
      final sortedDays = daysSet.toList()..sort();

      if (mounted) {
        setState(() {
          _stores = ['All', ...sortedStores];
          _departments = ['All', ...sortedSpecs];
          _examDays = ['All', ...sortedDays];
          _isLoadingFilters = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingFilters = false;
        });
      }
    }
  }

  void _handleLoadQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
      _hasLoaded = true;
    });
    try {
      final apiService = ref.read(apiServiceProvider);
      final questions = await apiService.getQuestions(
        store: _selectedStore == 'All' ? null : _selectedStore,
        speciality: _selectedDept == 'All' ? null : _selectedDept,
        days: _selectedDay == 'All' ? null : _selectedDay,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoadingQuestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingQuestions = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load study materials: $e'), backgroundColor: _errorColor),
        );
      }
    }
  }

  void _showDrugDetailsDialog(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['generic_name'] ?? 'UNKNOWN GENERIC',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: _onSurfaceColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Brand: ${item['drug_name'] ?? 'Generic Only'}',
                          style: TextStyle(fontSize: 16, color: _primaryColor, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _tertiaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _tertiaryColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      item['schedule'] ?? 'OTC',
                      style: TextStyle(color: _tertiaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: _outlineVariant),
              const SizedBox(height: 16),

              // Classification row
              Row(
                children: [
                  _buildClassificationBadge('VED Rating', item['ved'] ?? 'E'),
                  const SizedBox(width: 12),
                  _buildClassificationBadge('ABC Class', item['abc'] ?? 'A'),
                  const SizedBox(width: 12),
                  _buildClassificationBadge('SKU', item['sku'] ?? 'Y'),
                ],
              ),
              const SizedBox(height: 24),

              // Indication & Speciality
              _buildDetailSection('PRIMARY CLINICAL INDICATION', item['indication'] ?? 'No indication logged.'),
              _buildDetailSection('SPECIALITY DEPARTMENT', item['speciality'] ?? 'General Medicine'),
              _buildDetailSection('MANUFACTURER', item['company'] ?? 'Unknown Company'),
              _buildDetailSection('STORE', item['store'] ?? 'Pharmacy Store'),
              _buildDetailSection('STUDY TIME FRAME', item['days'] ?? 'General'),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassificationBadge(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _outlineVariant),
        ),
        child: Column(
          children: [
            Text(label.toUpperCase(), style: TextStyle(fontSize: 9, color: _onSurfaceVariantColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, color: _onSurfaceColor, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: _onSurfaceVariantColor, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _outlineVariant),
            ),
            child: Text(value, style: TextStyle(color: _onSurfaceColor, fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assessmentState = ref.watch(assessmentProvider);

    // Lock screen during active exam
    final isLocked = assessmentState.attemptId != null;

    if (isLocked) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: const TopAppBar(title: 'Study Material', showBackButton: false),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: GlassCard(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: _errorColor, size: 72),
                  const SizedBox(height: 24),
                  Text(
                    'Study Materials Locked',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: _onSurfaceColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Study materials are automatically locked during an active viva examination to ensure integrity. Please submit or discard your active assessment session first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _onSurfaceVariantColor, height: 1.4, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.push('/assessment'),
                      child: const Text('Go to Active Viva', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const TopAppBar(
        title: 'Study Material',
        showBackButton: false,
      ),
      body: _isLoadingFilters
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : Column(
              children: [
                // Search & Filters panel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search generic, brand, or indication...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Advanced Filters
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedStore,
                              isExpanded: true,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), labelText: 'Store'),
                              dropdownColor: _surfaceContainerHighest,
                              items: _stores.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)))).toList(),
                              onChanged: (val) => setState(() => _selectedStore = val!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedDept,
                              isExpanded: true,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), labelText: 'Dept'),
                              dropdownColor: _surfaceContainerHighest,
                              items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)))).toList(),
                              onChanged: (val) => setState(() => _selectedDept = val!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedDay,
                              isExpanded: true,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), labelText: 'Day'),
                              dropdownColor: _surfaceContainerHighest,
                              items: _examDays.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)))).toList(),
                              onChanged: (val) => setState(() => _selectedDay = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Load Questions Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isLoadingQuestions ? null : _handleLoadQuestions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A0012) : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: _isLoadingQuestions
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: _backgroundColor, strokeWidth: 2),
                                )
                              : const Icon(Icons.download, size: 20),
                          label: const Text('Load Questions', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Study Materials List
                Expanded(
                  child: !_hasLoaded
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.menu_book_outlined, size: 64, color: _onSurfaceVariantColor),
                              const SizedBox(height: 16),
                              Text(
                                'Select filters above and click "Load Questions".',
                                style: TextStyle(color: _onSurfaceVariantColor, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : _isLoadingQuestions
                          ? Center(child: CircularProgressIndicator(color: _primaryColor))
                          : _questions == null || _questions!.isEmpty
                              ? const Center(child: Text('No study materials matched your filters.'))
                              : GridView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12.0,
                                    mainAxisSpacing: 12.0,
                                    childAspectRatio: 0.95,
                                  ),
                                  itemCount: _questions!.length,
                                  itemBuilder: (context, index) {
                                    final item = _questions![index];
                                    return PharmaQCard(
                                      onTap: () => _showDrugDetailsDialog(item),
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: _surfaceContainerHighest,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Icon(Icons.medication, color: _tertiaryColor, size: 18),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _primaryColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item['ved'] ?? 'E',
                                                  style: TextStyle(color: _primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                                                ),
                                              )
                                            ],
                                          ),
                                          const Spacer(),
                                          Text(
                                            item['drug_name'] ?? 'Generic Drug',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: _onSurfaceColor),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item['generic_name'] ?? 'Unknown chemical',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 11, color: _onSurfaceVariantColor),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['speciality'] != null ? item['speciality'].toString().split('|').first : 'General',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 10, color: _outline, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 8),
                                          LinearProgressIndicator(
                                            value: 1.0, // Fully available indicator
                                            backgroundColor: _outlineVariant,
                                            color: _tertiaryColor,
                                            borderRadius: BorderRadius.circular(4),
                                            minHeight: 4,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
