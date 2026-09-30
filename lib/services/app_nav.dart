import 'package:flutter/foundation.dart';

class SearchIntent {
  final String? query;
  final String? category;
  final String? tag;
  final bool focus;
  final String? sort; 
  const SearchIntent(
      {this.query, this.category, this.tag, this.focus = false, this.sort});
}

class AppNav {
  static final ValueNotifier<int> tab = ValueNotifier<int>(0);
  static final ValueNotifier<SearchIntent?> searchIntent =
      ValueNotifier<SearchIntent?>(null);

  static void openSearch(
      {String? query, String? category, String? tag, String? sort}) {
    searchIntent.value = SearchIntent(
      query: query,
      category: category,
      tag: tag,
      sort: sort,
      focus: query == null && category == null && tag == null && sort == null,
    );
    tab.value = 1;
  }
}
