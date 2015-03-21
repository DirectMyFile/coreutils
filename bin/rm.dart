import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  var opts = handleArguments(args, "rm", handle: (ArgParser parser) {
    parser.addFlag("recursive", abbr: "r", help: "Recursive Remove", negatable: false);
    parser.addFlag("force", abbr: "f", help: "Ignore Bad Arguments", negatable: false);
    parser.addFlag("preserve-root", help: "Preserve the root filesystem", negatable: true);
  }, fail: (x) => x.rest.isEmpty);

  var entities = <FileSystemEntity>[];

  for (var p in opts.rest) {
    if (p == "/" && opts["preserve-root"]) {
      error("You can't remove the root directory because you asked to preserve the root.");
    }

    var t = await FileSystemEntity.type(p);

    if (t == FileSystemEntityType.NOT_FOUND) {
      if (!opts["force"]) {
        error("'${p}' does not exist.");
      }
    } else {
      if (t == FileSystemEntityType.DIRECTORY) {
        entities.add(new Directory(p));
      } else {
        entities.add(new File(p));
      }
    }

    for (var entity in entities) {
      if (entity is Directory && !opts["recursive"]) {
        var children = await (entity as Directory).list().toList();
        if (children.isNotEmpty) {
          error("Failed to remove '${entity.path}': Directory not empty.", exit: false);
          continue;
        }
      }

      await entity.delete(recursive: opts["recursive"]);
    }
  }
}
