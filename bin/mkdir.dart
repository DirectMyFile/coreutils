import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  var result = handleArguments(args, "mkdir", usage: "<path>", handle: (parser) {
    parser.addFlag("parents", negatable: false, abbr: "p", help: "Create Parent Directories");
  }, fail: (result) => result.rest.isEmpty);

  var recursive = result["parents"];

  for (var path in result.rest) {
    var dir = new Directory(path);

    if (await dir.exists()) {
      error("Directory '${path}' already exists.");
    } else {
      await dir.create(recursive: recursive);
    }
  }
}
