part of coreutils;

/**
 * Provides a Common way to format strings based on the way coreutils usually does formatting.
 */
String formatString(String input, [Map<String, dynamic> values = const {}]) {
  for (var key in values.keys) {
    if (!input.contains("%${key}")) {
      continue;
    }

    var v = values[key];
    if (v is Function) {
      v = v();
    }

    input = input.replaceAll("%${key}", v);
  }

  return input;
}
