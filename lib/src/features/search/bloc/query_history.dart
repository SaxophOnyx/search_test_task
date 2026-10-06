class QueryHistory {
  static const int _maxEntries = 50;
  static const int _minKeyLength = 2;

  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _wordSeparator = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

  final List<_HistoryEntry> _entries = <_HistoryEntry>[];

  void save(String query) {
    final _HistoryEntry entry = _HistoryEntry.create(query);
    if (entry.key.length < _minKeyLength || entry.words.isEmpty) return;

    _entries.removeWhere(
      (_HistoryEntry e) => e.wordSetKey == entry.wordSetKey,
    );
    _entries.insert(0, entry);

    if (_entries.length > _maxEntries) {
      _entries.removeRange(_maxEntries, _entries.length);
    }
  }

  List<String> suggest(String input, {int limit = 5}) {
    final _HistoryEntry probe = _HistoryEntry.create(input);

    if (probe.words.isEmpty) {
      return _entries
          .take(limit)
          .map((_HistoryEntry e) => e.query)
          .toList(growable: false);
    }

    final List<String> prefixMatches = <String>[];
    final List<String> wordMatches = <String>[];

    for (final _HistoryEntry entry in _entries) {
      if (entry.key == probe.key) continue;

      if (entry.key.startsWith(probe.key)) {
        prefixMatches.add(entry.query);
      } else if (probe.words.every(entry.hasWordWithPrefix)) {
        wordMatches.add(entry.query);
      }

      if (prefixMatches.length >= limit) break;
    }

    return <String>[
      ...prefixMatches,
      ...wordMatches,
    ].take(limit).toList(growable: false);
  }

  static String normalize(String query) {
    return query.trim().replaceAll(_whitespace, ' ');
  }
}

class _HistoryEntry {
  final String query;
  final String key;
  final List<String> words;
  final String wordSetKey;

  const new({
    required this.query,
    required this.key,
    required this.words,
    required this.wordSetKey,
  });

  factory _HistoryEntry.create(String rawQuery) {
    final String query = QueryHistory.normalize(rawQuery);
    final String key = query.toLowerCase();
    final List<String> words = key
        .split(QueryHistory._wordSeparator)
        .where((String w) => w.isNotEmpty)
        .toList(growable: false);
    final List<String> sortedWords = <String>[...words.toSet()]..sort();

    return _HistoryEntry(
      query: query,
      key: key,
      words: words,
      wordSetKey: sortedWords.join(' '),
    );
  }

  bool hasWordWithPrefix(String prefix) {
    return words.any((String w) => w.startsWith(prefix));
  }
}
