/// Generic in-memory TTL-based cache manager.
class CacheManager<T> {
  final Map<String, _CacheEntry<T>> _cache = {};

  /// Retrieves the data associated with [key] if it exists and is not expired.
  /// Returns null otherwise.
  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data;
  }

  /// Stores [data] associated with [key] with a specific Time-To-Live (TTL).
  /// Default TTL is 5 minutes.
  void put(String key, T data, {Duration ttl = const Duration(minutes: 5)}) {
    _cache[key] = _CacheEntry<T>(
      data: data,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  /// Invalidates the cache entry for [key].
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Clears all entries from the cache.
  void clear() {
    _cache.clear();
  }
}

class _CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  _CacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
