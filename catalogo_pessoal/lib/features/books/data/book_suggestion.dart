class BookSuggestion {
  const BookSuggestion({
    required this.key,
    required this.title,
    required this.authors,
    this.firstPublishYear,
    this.coverId,
  });

  final String key;
  final String title;
  final List<String> authors;
  final int? firstPublishYear;
  final int? coverId;

  String? get coverUrl => coverId == null
      ? null
      : 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';

  String get description {
    final parts = <String>[];
    if (authors.isNotEmpty) parts.add('Autor: ${authors.join(', ')}');
    if (firstPublishYear != null) parts.add('Publicado em $firstPublishYear');
    return parts.join('\n');
  }
}
