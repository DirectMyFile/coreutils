import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  var results = handleArguments(args, "echo", handle: (ArgParser parser) {
    parser.addFlag("noline", abbr: "n", help: "Don't output a newline");
    parser.addFlag("enable-backslash", abbr: "e", help: "Enable Interpretation of Backslash Escapes");
    parser.addFlag("disable-backslash", abbr: "E", help: "Disable Interpretation of Backslash Escapes");
  });

  var msg = results.rest.join(" ");

  if (results["enable-backslash"]) {
    msg = _unescape(msg);
  }

  if (results["noline"]) {
    stdout.write(msg);
  } else {
    print(msg);
  }
}

final RegExp _unicodeEscapeSequence = new RegExp(r"\\u([0-9a-fA-F]{4})");
final RegExp _unicodeEscape = new RegExp(r"[^\x20-\x7E]+");

final Map<String, String> _decodeTable = const {
  '\\': '\\',
  '/': '/',
  '"': '"',
  'b': '\b',
  'f': '\f',
  'n': '\n',
  'r': '\r',
  't': '\t'
};

String _unescape(String input) {
  for (var code in _decodeTable.keys) {
    if (input.contains("\\${code}")) {
      input = input.replaceAll("\\${code}", _decodeTable[code]);
    }
  }

  if (_unicodeEscapeSequence.hasMatch(input)) {
    input = input.replaceAllMapped(_unicodeEscapeSequence, (match) {
      var value = int.parse(match[1], radix: 16);

      if ((value >= 0xD800 && value <= 0xDFFF) || value > 0x10FFFF) {
        throw new Exception("Invalid Escape Code: value(${value})");
      }

      return new String.fromCharCode(value);
    });
  }

  return input;
}
