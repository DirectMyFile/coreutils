import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  var results = handleArguments(args, "cat", handle: (ArgParser parser) {
    parser.addFlag("count", abbr: "c", help: "Print the number of times each line occurred.");
    parser.addFlag("ignore-case", abbr: "i", help: "Ignore Case");
    parser.addFlag("repeated", abbr: "d", help: "Only Print Repeated Lines");
    parser.addFlag("zero-terminated", abbr: "z", help: "Terminate Lines with the ASCII NUL Character");
  }, fail: (result) => result.rest.length > 2);

  if (results["ignore-case"]) {
    print("ERROR: Ignoring the casing of lines is not yet supported.");
    exit(1);
  }

  File input = results.rest.length >= 1 ? new File(results.rest[0]) : new File("/dev/stdin");
  File of = results.rest.length == 2 ? new File(results.rest[0]) : new File("/dev/stdout");

  var lines = input.readAsLinesSync();

  if (results["count"]) {
    var ol = new Map<String, int>();
    for (var line in lines) {
      if (!ol.containsKey(line)) {
        ol[line] = 1;
      } else {
        ol[line] = ol[line] + 1;
      }
    }

    var out = "";
    for (var line in ol.keys) {
      if (results["repeated"] && ol[line] == 1) {
        continue;
      }
      out += "      ${ol[line]} ${line}\n";
    }

    if (results["zero-terminated"]) {
      out = out.replaceAll("\n", "\0");
    }

    of.writeAsStringSync(out);
  } else {
    lines = lines.where((it) => results["repeated"] ? lines.indexOf(it) != lines.lastIndexOf(it) : true).toSet();
    var d = results["zero-terminated"] ? "\u0000" : "\n";
    of.writeAsStringSync(lines.join(d) + d);
  }
}
