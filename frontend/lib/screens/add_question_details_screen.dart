import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';

class AddQuestionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? existingQuestion;

  const AddQuestionDetailsScreen({super.key, this.existingQuestion});

  @override
  State<AddQuestionDetailsScreen> createState() => _AddQuestionDetailsScreenState();
}

class _AddQuestionDetailsScreenState extends State<AddQuestionDetailsScreen> {
  late TextEditingController _genericController;
  late TextEditingController _brandController;
  late TextEditingController _companyController;
  late TextEditingController _indicationController;
  late TextEditingController _gspController;

  @override
  void initState() {
    super.initState();
    final q = widget.existingQuestion ?? {};
    _genericController = TextEditingController(text: q['generic_name'] ?? '');
    _brandController = TextEditingController(text: q['drug_name'] ?? '');
    _companyController = TextEditingController(text: q['company'] ?? '');
    _indicationController = TextEditingController(text: q['indication'] ?? '');
    _gspController = TextEditingController(text: q['gsp'] ?? '');
  }

  @override
  void dispose() {
    _genericController.dispose();
    _brandController.dispose();
    _companyController.dispose();
    _indicationController.dispose();
    _gspController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_genericController.text.trim().isEmpty || _brandController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generic and Brand names are required.'), backgroundColor: ObsidianTheme.error),
      );
      return;
    }

    final data = {
      if (widget.existingQuestion != null) 'id': widget.existingQuestion!['id'],
      'generic_name': _genericController.text.trim().toUpperCase(),
      'drug_name': _brandController.text.trim(),
      'company': _companyController.text.trim(),
      'indication': _indicationController.text.trim(),
      'gsp': _gspController.text.trim().isEmpty 
          ? '${_genericController.text.trim()}(500 mg)Tablet' 
          : _gspController.text.trim(),
    };

    context.push('/mentor/add-question/difficulty', extra: data);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingQuestion != null;

    return Scaffold(
      backgroundColor: ObsidianTheme.background,
      appBar: const TopAppBar(
        title: 'PharmaQ Editor',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? 'Edit Question' : 'Add New Question', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              isEdit ? 'Modifying clinical properties in drug bank.' : 'Drafting a clinical scenario for the drug repository.',
              style: const TextStyle(color: ObsidianTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            
            const Text('CORE IDENTIFICATION', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            const SizedBox(height: 16),
            TextField(
              controller: _genericController,
              decoration: const InputDecoration(labelText: 'Generic Name (e.g. ENALAPRIL)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Brand Name (e.g. Enam 5mg Tab)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: 'Manufacturer / Company'),
            ),
            const SizedBox(height: 24),

            const Text('CLINICAL DATA & SPECIFICATION', style: TextStyle(color: ObsidianTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            const SizedBox(height: 16),
            TextField(
              controller: _indicationController,
              decoration: const InputDecoration(labelText: 'Indication (Primary Clinical Use)'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _gspController,
              decoration: const InputDecoration(labelText: 'Strength & Dosage Form (e.g. 500mg Tablet)'),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _handleContinue,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isEdit ? 'Proceed to Review' : 'Continue to Difficulty'),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.pop();
              },
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Cancel & Return'),
            ),
          ],
        ),
      ),
    );
  }
}
