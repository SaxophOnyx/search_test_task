class QueryHistory {
  static const int _maxEntries = 50;
  static const int _minKeyLength = 2;

  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _wordSeparator = RegExp(
    r'[^\p{L}\p{M}\p{N}]+',
    unicode: true,
  );

  final List<_HistoryEntry> _entries = <_HistoryEntry>[];

  void save(String query) {
    final _HistoryEntry entry = _HistoryEntry.create(query);
    if (entry.key.length < _minKeyLength || entry.words.isEmpty) return;

    _entries.removeWhere((_HistoryEntry e) => e.key == entry.key);
    _entries.insert(0, entry);

    if (_entries.length > _maxEntries) {
      _entries.removeRange(_maxEntries, _entries.length);
    }
  }

  List<String> suggest(String input, {int limit = 5}) {
    final _HistoryEntry probe = _HistoryEntry.create(input);

    if (probe.words.isEmpty) {
      return _entries.take(limit).map((_HistoryEntry e) => e.query).toList(growable: false);
    }

    final bool isLastWordComplete = input.trimRight().length != input.length;
    final String prefix = isLastWordComplete ? '${probe.key} ' : probe.key;

    final List<String> prefixMatches = <String>[];
    final List<String> wordMatches = <String>[];

    for (final _HistoryEntry entry in _entries) {
      if (entry.key == probe.key) continue;

      if (entry.key.startsWith(prefix)) {
        prefixMatches.add(entry.query);
      } else if (probe.words.every(entry.hasWordWithPrefix) &&
          (!isLastWordComplete || entry.words.contains(probe.words.last))) {
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

  const new({
    required this.query,
    required this.key,
    required this.words,
  });

  factory _HistoryEntry.create(String rawQuery) {
    final String query = QueryHistory.normalize(rawQuery);
    final String key = query.toLowerCase();
    final List<String> words = key
        .split(QueryHistory._wordSeparator)
        .where((String w) => w.isNotEmpty)
        .toList(growable: false);

    return _HistoryEntry(
      query: query,
      key: key,
      words: words,
    );
  }

  bool hasWordWithPrefix(String prefix) {
    return words.any((String w) => w.startsWith(prefix));
  }
}
