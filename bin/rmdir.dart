import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  var result = handleArguments(args, "rmdir", usage: "<path>", handle: (parser) {
    parser.addFlag("parents", negatable: false, abbr: "p", help: "Delete Parent Directories");
  }, fail: (result) => result.rest.isEmpty);

  var recursive = result["parents"];

  for (var path in result.rest) {
    var dir = new Directory(path);

    if (!dir.existsSync()) {
      print("ERROR: Directory '${path}' does not exist.");
      exit(1);
    } else {
      if (recursive) {
        List<Directory> dirs = walkTreeBottomUp(dir).where((it) => it is Directory).toList();

        for (Directory d in dirs) {
          if (d.listSync().any((it) => it is! Directory)) {
            print("ERROR: Directory '${d.path}' is not empty.");
          } else {
            d.deleteSync();
          }
        }

        if (dir.listSync().any((it) => it is! Directory)) {
          print("ERROR: Directory '${dir.path}' is not empty.");
        } else {
          dir.deleteSync();
        }
      } else {
        if (dir.listSync().isNotEmpty) {
          print("ERROR: Directory '${dir.path}' is not empty.");
        } else {
          dir.deleteSync();
        }
      }
    }
  }
}
