import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class StudyFilters {
  final String searchQuery;
  final String store;
  final String speciality;
  final String days;

  StudyFilters({
    this.searchQuery = '',
    this.store = 'All',
    this.speciality = 'All',
    this.days = 'All',
  });

  StudyFilters copyWith({
    String? searchQuery,
    String? store,
    String? speciality,
    String? days,
  }) {
    return StudyFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      store: store ?? this.store,
      speciality: speciality ?? this.speciality,
      days: days ?? this.days,
    );
  }
}

class StudyFilterNotifier extends Notifier<StudyFilters> {
  @override
  StudyFilters build() {
    return StudyFilters();
  }

  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setStore(String store) => state = state.copyWith(store: store);
  void setSpeciality(String spec) => state = state.copyWith(speciality: spec);
  void setDays(String days) => state = state.copyWith(days: days);
  void reset() => state = StudyFilters();
}

final studyFiltersProvider = NotifierProvider<StudyFilterNotifier, StudyFilters>(() {
  return StudyFilterNotifier();
});

final studyMaterialsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final filters = ref.watch(studyFiltersProvider);
  
  final questions = await apiService.getQuestions(
    store: filters.store == 'All' ? null : filters.store,
    speciality: filters.speciality == 'All' ? null : filters.speciality,
    days: filters.days == 'All' ? null : filters.days,
    search: filters.searchQuery.trim().isEmpty ? null : filters.searchQuery.trim(),
  );
  return questions;
});
