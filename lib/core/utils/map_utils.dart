// Utility to handle Hive's Map<dynamic, dynamic> and recursively cast to Map<String, dynamic>

class MapUtils {
  /// Recursively converts a Map of any dynamic types to Map<String, dynamic>
  /// This is essential when working with Hive data that needs to be passed to fromJson methods
  static Map<String, dynamic> ensureStringKeys(Map data) {
    return data.map((key, value) {
      final stringKey = key.toString();
      var finalValue = value;

      if (value is Map) {
        finalValue = ensureStringKeys(value);
      } else if (value is List) {
        finalValue = value.map((item) {
          if (item is Map) {
            return ensureStringKeys(item);
          }
          return item;
        }).toList();
      }

      return MapEntry(stringKey, finalValue);
    });
  }
}
