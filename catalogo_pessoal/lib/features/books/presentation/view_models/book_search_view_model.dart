import 'package:catalogo_pessoal/features/books/data/book_suggestion.dart';
import 'package:catalogo_pessoal/features/books/data/open_library_book_repository.dart';
import 'package:flutter/foundation.dart';

enum BookSearchStatus { idle, loading, success, empty, failure }

class BookSearchViewModel extends ChangeNotifier {
  BookSearchViewModel(this._repository);

  final BookSearchRepository _repository;

  BookSearchStatus status = BookSearchStatus.idle;
  List<BookSuggestion> results = const [];
  String? errorMessage;

  Future<void> search(String query) async {
    status = BookSearchStatus.loading;
    errorMessage = null;
    results = const [];
    notifyListeners();
    try {
      results = await _repository.search(query);
      status = results.isEmpty
          ? BookSearchStatus.empty
          : BookSearchStatus.success;
    } on BookSearchException catch (error) {
      errorMessage = error.publicMessage;
      status = BookSearchStatus.failure;
    } on Object {
      errorMessage = 'Não foi possível pesquisar agora. Tente novamente.';
      status = BookSearchStatus.failure;
    }
    notifyListeners();
  }

  void reset() {
    status = BookSearchStatus.idle;
    results = const [];
    errorMessage = null;
    notifyListeners();
  }
}
