import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/obsidian_theme.dart';
import '../components/top_app_bar.dart';
import '../components/pharmaq_card.dart';
import '../providers/admin_provider.dart';

class RoleManagementScreen extends ConsumerStatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  ConsumerState<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends ConsumerState<RoleManagementScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Employees, Mentors
  String _selectedDepartment = 'All';
  bool _isFetched = false;

  @override
  Widget build(BuildContext context) {
    final employeesAsync = _isFetched ? ref.watch(employeesProvider) : null;

    return Scaffold(
      backgroundColor: ObsidianTheme.background,
      appBar: const TopAppBar(
        title: 'PharmaQ Admin',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Role Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ObsidianTheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Assign and verify organizational hierarchies.',
                style: TextStyle(
                  fontSize: 14,
                  color: ObsidianTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: ObsidianTheme.onSurfaceVariant),
                  hintText: 'Search by name or ID...',
                ),
              ),
              const SizedBox(height: 24),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', _selectedFilter == 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Employees', _selectedFilter == 'Employees'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Mentors', _selectedFilter == 'Mentors'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // User List
              if (employeesAsync == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      const Icon(Icons.people_outline, size: 64, color: ObsidianTheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      const Text(
                        'Employee directory is not loaded.',
                        style: TextStyle(color: ObsidianTheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _isFetched = true),
                        icon: const Icon(Icons.download),
                        label: const Text(
                          'Fetch Employee Directory',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              else
                employeesAsync.when(
                  loading: () => const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32.0), child: CircularProgressIndicator(color: ObsidianTheme.primary))),
                  error: (err, _) => Center(child: Text('Error loading employees: $err', style: const TextStyle(color: ObsidianTheme.error))),
                data: (employees) {
                  // Collect unique departments
                  final departmentsSet = <String>{'All'};
                  for (var e in employees) {
                    final dept = (e['department'] ?? e['work_area'] ?? e['store'] ?? 'General Pharmacy').toString().trim();
                    if (dept.isNotEmpty) {
                      departmentsSet.add(dept);
                    }
                  }
                  final List<String> departmentsList = departmentsSet.toList()..sort();

                  if (!departmentsList.contains(_selectedDepartment)) {
                    _selectedDepartment = 'All';
                  }

                  // Apply local filters
                  Iterable<dynamic> filtered = employees;
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    filtered = filtered.where((e) =>
                      e['name1'].toString().toLowerCase().contains(query) ||
                      e['emp_id'].toString().toLowerCase().contains(query)
                    );
                  }

                  if (_selectedDepartment != 'All') {
                    filtered = filtered.where((e) {
                      final dept = (e['department'] ?? e['work_area'] ?? e['store'] ?? 'General Pharmacy').toString().trim();
                      return dept.toLowerCase() == _selectedDepartment.toLowerCase();
                    });
                  }
                  
                  final List<dynamic> filteredList = filtered.toList();
                  final List<dynamic> finalResult = [];

                  for (var e in filteredList) {
                    final des = e['designation'].toString().toLowerCase();
                    final roleStr = (e['role'] ?? e['employee_role'] ?? e['privilege'] ?? '').toString().toLowerCase();
                    final isAdmin = des.contains('admin') || des.contains('analyst') || roleStr == 'admin';
                    final isMentor = !isAdmin && (des.contains('mentor') || des.contains('supervisor') || roleStr == 'mentor');
                    final isEmployee = !isAdmin && !isMentor;
                    
                    if (_selectedFilter == 'Employees' && !isEmployee) continue;
                    if (_selectedFilter == 'Mentors' && !isMentor) continue;
                    finalResult.add(e);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Department Dropdown Filter
                      DropdownButtonFormField<String>(
                        key: ValueKey('dept_filter_$_selectedDepartment'),
                        initialValue: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Filter Department',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        dropdownColor: ObsidianTheme.surfaceContainerHighest,
                        items: departmentsList.map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d, style: const TextStyle(fontSize: 13)),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedDepartment = val);
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      if (finalResult.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(child: Text('No employees match your search/filter.', style: TextStyle(color: ObsidianTheme.onSurfaceVariant))),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: finalResult.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = finalResult[index];
                            final des = user['designation'].toString().toLowerCase();
                            final roleStr = (user['role'] ?? user['employee_role'] ?? user['privilege'] ?? '').toString().toLowerCase();
                            final isAdmin = des.contains('admin') || des.contains('analyst') || roleStr == 'admin';
                            final isMentor = !isAdmin && (user['designation'].toString().toLowerCase().contains('mentor') || user['designation'].toString().toLowerCase().contains('supervisor') || roleStr == 'mentor');
                            final dept = (user['department'] ?? user['work_area'] ?? user['store'] ?? 'General Pharmacy').toString().trim();

                            return PharmaQCard(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: ObsidianTheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: ObsidianTheme.outlineVariant),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: ObsidianTheme.primary.withValues(alpha: 0.7),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user['name1'] ?? 'No Name',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: ObsidianTheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'ID: ${user['emp_id']}  |  Dept: $dept',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: ObsidianTheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isAdmin
                                              ? ObsidianTheme.tertiary.withValues(alpha: 0.05)
                                              : isMentor
                                                  ? ObsidianTheme.primary.withValues(alpha: 0.05)
                                                  : Colors.transparent,
                                          border: Border.all(
                                            color: isAdmin
                                                ? ObsidianTheme.tertiary
                                                : isMentor
                                                    ? ObsidianTheme.primary
                                                    : ObsidianTheme.outlineVariant,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isAdmin
                                              ? 'ADMIN'
                                              : isMentor
                                                  ? 'MENTOR'
                                                  : 'EMPLOYEE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                            color: isAdmin
                                                ? ObsidianTheme.tertiary
                                                : isMentor
                                                    ? ObsidianTheme.primary
                                                    : ObsidianTheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      if (!isAdmin) ...[
                                        const SizedBox(height: 8),
                                        InkWell(
                                          onTap: () => _toggleRole(user, isMentor),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.swap_horiz, size: 14, color: ObsidianTheme.onSurfaceVariant),
                                              SizedBox(width: 4),
                                              Text(
                                                'CHANGE ROLE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: -0.5,
                                                  color: ObsidianTheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),

              // Security Policy Alert
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ObsidianTheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ObsidianTheme.tertiary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: ObsidianTheme.tertiary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Access Level Security',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ObsidianTheme.tertiary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Changes to user roles are logged and audited. Mentors gain access to question creation and difficulty logic configuration panels.',
                            style: TextStyle(
                              fontSize: 12,
                              color: ObsidianTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ObsidianTheme.primary : ObsidianTheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ObsidianTheme.primary : ObsidianTheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0a0012) : ObsidianTheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _toggleRole(Map<String, dynamic> user, bool currentIsMentor) async {
    final success = await ref.read(adminProvider.notifier).toggleEmployeeRole(user, currentIsMentor);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: ObsidianTheme.tertiary, size: 20),
                SizedBox(width: 8),
                Text('Role updated successfully', style: TextStyle(color: ObsidianTheme.onSurface)),
              ],
            ),
            backgroundColor: ObsidianTheme.surfaceContainerHighest,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update employee role.'),
            backgroundColor: ObsidianTheme.error,
          ),
        );
      }
    }
  }
}
