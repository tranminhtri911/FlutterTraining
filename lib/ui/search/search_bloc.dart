import 'package:rxdart/rxdart.dart';
import 'package:untitled/data/source/remote/repository/movie_repository.dart';

import 'search_sate.dart';

class SearchBloc {
  final Sink<String> onTextChanged;
  final Stream<SearchState> state;

  factory SearchBloc(MovieRepository movieRepository) {
    // ignore: close_sinks
    final onTextChanged = PublishSubject<String>();

    final state = onTextChanged
        // If the text has not changed, do not perform a new search
        .distinct()
        // Wait for the user to stop typing for 250ms before running a search
        .debounceTime(const Duration(milliseconds: 250))
        // Call the Github api with the given search term and convert it to a
        // State. If another search term is entered, flatMapLatest will ensure
        // the previous search is discarded so we don't deliver stale results
        // to the View.
        .switchMap<SearchState>((String term) => _search(term, movieRepository))
        // The initial state to deliver to the screen.
        .startWith(SearchNoTerm());

    return SearchBloc._(onTextChanged, state);
  }

  SearchBloc._(this.onTextChanged, this.state);

  void dispose() {
    onTextChanged.close();
  }

  static Stream<SearchState> _search(
          String term, MovieRepository movieRepository) =>
      term.isEmpty
          ? Stream.value(SearchNoTerm())
          : Rx.fromCallable(() => movieRepository.searchMovie(term, 1))
              .map((result) =>
                  result.isEmpty ? SearchEmpty() : SearchPopulated(result))
              .startWith(SearchLoading())
              .onErrorReturn(SearchError());
}