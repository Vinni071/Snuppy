import 'package:flutter/foundation.dart';
import 'package:luminthor/features/templates/domain/editor_templates.dart';
import 'package:luminthor/features/workspace/domain/entities/workspace_document.dart';

/// Home destinations, in navigation order.
enum HomeSection { home, files, templates, learning }

/// What the Home shows for the selected section, search and category.
///
/// This is page-local UI state: `/` and `/learn` are separate pages, so it is
/// held by the screen rather than by a global provider.
@immutable
class HomeFilter {
  /// The overview only previews this many recent files and templates.
  static const overviewLimit = 3;

  final HomeSection section;

  /// Lower-cased, trimmed search text.
  final String query;
  final String category;

  const HomeFilter({
    this.section = HomeSection.home,
    this.query = '',
    this.category = EditorTemplates.allCategories,
  });

  /// Switching sections always starts from a clean search.
  HomeFilter selectSection(HomeSection section) => HomeFilter(section: section);

  HomeFilter search(String text) => HomeFilter(
        section: section,
        query: text.toLowerCase().trim(),
        category: category,
      );

  HomeFilter selectCategory(String category) =>
      HomeFilter(section: section, query: query, category: category);

  bool get showsLearning => section == HomeSection.learning;
  bool get showsHero => section == HomeSection.home && query.isEmpty;
  bool get showsRecentFiles => section != HomeSection.templates;
  bool get showsTemplates => section != HomeSection.files;
  bool get showsCategoryFilter => section == HomeSection.templates;

  List<WorkspaceDocument> matchingDocuments(
          Iterable<WorkspaceDocument> documents) =>
      documents
          .where((document) => document.name.toLowerCase().contains(query))
          .toList();

  List<WorkspaceDocument> visibleDocuments(
      List<WorkspaceDocument> matchingDocuments) {
    return section == HomeSection.home
        ? matchingDocuments.take(overviewLimit).toList()
        : matchingDocuments;
  }

  List<CodeTemplate> visibleTemplates(Iterable<CodeTemplate> templates) {
    final matches = templates
        .where((template) =>
            (category == EditorTemplates.allCategories ||
                template.category == category) &&
            '${template.title} ${template.description} ${template.category}'
                .toLowerCase()
                .contains(query))
        .toList();
    return section == HomeSection.home && query.isEmpty
        ? matches.take(overviewLimit).toList()
        : matches;
  }
}
