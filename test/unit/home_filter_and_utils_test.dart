import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/app/router/app_routes.dart';
import 'package:luminthor/core/utils/relative_date.dart';
import 'package:luminthor/features/editor/domain/source_search.dart';
import 'package:luminthor/features/home/presentation/viewmodels/home_filter.dart';
import 'package:luminthor/features/templates/domain/editor_templates.dart';
import 'package:luminthor/features/workspace/domain/entities/workspace_document.dart';

void main() {
  List<WorkspaceDocument> documents(List<String> names) => [
        for (final name in names)
          WorkspaceDocument(
              id: name, name: name, source: '', updatedAt: DateTime(2026)),
      ];

  group('HomeFilter', () {
    test('overview previews at most three files and templates', () {
      const filter = HomeFilter();
      final matches = filter.matchingDocuments(documents(['a', 'b', 'c', 'd']));
      expect(filter.visibleDocuments(matches), hasLength(3));
      expect(filter.visibleTemplates(EditorTemplates.templates),
          hasLength(HomeFilter.overviewLimit));
      expect(filter.showsHero, isTrue);
    });

    test('search is case-insensitive and hides the hero', () {
      final filter = const HomeFilter().search('  FATOR ');
      final matches = filter
          .matchingDocuments(documents(['meu-fatorial.lumi', 'ola.lumi']));
      expect(matches.map((d) => d.name), ['meu-fatorial.lumi']);
      expect(filter.showsHero, isFalse);
    });

    test('category narrows templates; switching section resets filters', () {
      final filter = const HomeFilter()
          .selectSection(HomeSection.templates)
          .selectCategory('Depuração');
      final templates = filter.visibleTemplates(EditorTemplates.templates);
      expect(templates, isNotEmpty);
      expect(templates.every((t) => t.category == 'Depuração'), isTrue);
      expect(filter.showsRecentFiles, isFalse);

      final reset = filter.search('x').selectSection(HomeSection.files);
      expect(reset.query, isEmpty);
      expect(reset.category, EditorTemplates.allCategories);
      expect(reset.showsTemplates, isFalse);
    });

    test('every template category is offered as a filter', () {
      for (final template in EditorTemplates.templates) {
        expect(EditorTemplates.categories, contains(template.category));
      }
    });
  });

  group('formatRelativeDate', () {
    final now = DateTime(2026, 11, 10, 12);

    test('formats recent and old dates', () {
      expect(formatRelativeDate(now, now: now), 'Agora');
      expect(
          formatRelativeDate(now.subtract(const Duration(minutes: 5)),
              now: now),
          'Há 5 min');
      expect(
          formatRelativeDate(now.subtract(const Duration(hours: 3)), now: now),
          'Há 3 h');
      expect(
          formatRelativeDate(now.subtract(const Duration(hours: 30)), now: now),
          'Ontem');
      expect(formatRelativeDate(DateTime(2026, 3, 4), now: now), '04/03/2026');
    });
  });

  group('countOccurrences', () {
    test('matches literal text case-insensitively', () {
      expect(countOccurrences('print(x); PRINT(y);', 'print'), 2);
      expect(countOccurrences('a.b axb', '.'), 1);
      expect(countOccurrences('(((', '('), 3);
      expect(countOccurrences('abc', '   '), 0);
    });
  });

  group('AppRoutes', () {
    test('builds typed locations', () {
      expect(AppRoutes.editorLocation(), '/editor');
      final fromLearning = AppRoutes.editorLocation(fromLearning: true);
      expect(AppRoutes.isFromLearning(Uri.parse(fromLearning)), isTrue);
      expect(AppRoutes.isFromLearning(Uri.parse('/editor')), isFalse);
      expect(AppRoutes.lessonLocation('primeiro-programa'),
          '/learn/lesson/primeiro-programa');
    });
  });
}
