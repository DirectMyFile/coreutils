import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  var result = handleArguments(args, "rmdir", usage: "<path>", handle: (parser) {
    parser.addFlag("parents", negatable: false, abbr: "p", help: "Delete Parent Directories");
  }, fail: (result) => result.rest.isEmpty);

  var recursive = result["parents"];

  for (var path in result.rest) {
    var dir = new Directory(path);

    if (!(await dir.exists())) {
      error("Directory '${path}' does not exist.");
    } else {
      if (recursive) {
        List<Directory> dirs = (await walkTreeBottomUp(dir)).where((it) => it is Directory).toList();

        for (Directory d in dirs) {
          if (d.listSync().any((it) => it is! Directory)) {
            error("Directory '${d.path}' is not empty.");
          } else {
            await d.delete();
          }
        }

        var children = await dir.list().toList();
        if (children.any((it) => it is! Directory)) {
          error("Directory '${dir.path}' is not empty.");
        } else {
          await dir.delete();
        }
      } else {
        var children = await dir.list().toList();
        if (children.isNotEmpty) {
          error("Directory '${dir.path}' is not empty.");
        } else {
          await dir.delete();
        }
      }
    }
  }
}
