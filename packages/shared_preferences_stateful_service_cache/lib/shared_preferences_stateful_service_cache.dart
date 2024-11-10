import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stateful_service/stateful_service.dart';

/// A [StatefulServiceCache] that uses [SharedPreferences] to cache the state.
class SharedPreferencesStatefulServiceCache<S> with StatefulServiceCache<S> {
  SharedPreferencesStatefulServiceCache({
    required String key,
    required String? Function(S) encode,
    required S Function(String) decode,
    bool clearOnDecodingError = true,
    SharedPreferencesAsync? sharedPreferences,
  })  : _key = key,
        _toString = encode,
        _fromString = decode,
        _clearOnDecodingError = clearOnDecodingError,
        _prefs = sharedPreferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;
  final String _key;
  final String? Function(S) _toString;
  final S Function(String) _fromString;
  final bool _clearOnDecodingError;

  /// Initializes the cache by loading the state from [SharedPreferences].
  @override
  @mustCallSuper
  Future<S?> init() async {
    final cachedValue = await _prefs.getString(_key);
    if (cachedValue == null) return null;
    try {
      return _fromString(cachedValue);
    } catch (_) {
      if (_clearOnDecodingError) {
        await clear();
      }
      rethrow;
    }
  }

  /// Closes the cache, a no-op for this implementation.
  @override
  @mustCallSuper
  Future<void> close() => Future.value(null);

  /// Persists the provided state in [SharedPreferences].
  @override
  Future<void> put(S state) async {
    final string = _toString(state);
    if (string != null) {
      await _prefs.setString(_key, string);
    }
  }

  /// Clears the cache by removing the value from [SharedPreferences].
  @override
  Future<void> clear() => _prefs.remove(_key);
}
