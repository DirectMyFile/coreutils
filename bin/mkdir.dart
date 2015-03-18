import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  var result = handleArguments(args, "mkdir", usage: "<path>", handle: (parser) {
    parser.addFlag("parents", negatable: false, abbr: "p", help: "Create Parent Directories");
  }, fail: (result) => result.rest.isEmpty);

  var recursive = result["parents"];

  for (var path in result.rest) {
    var dir = new Directory(path);

    if (dir.existsSync()) {
      print("ERROR: Directory '${path}' already exists.");
      exit(1);
    } else {
      dir.createSync(recursive: recursive);
    }
  }
}
