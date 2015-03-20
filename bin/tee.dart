import "dart:io";

import "package:coreutils/coreutils.dart";

void main(List<String> args) {
  var opts = handleArguments(args, "tee", usage: "[FILE]", handle: (argp) {
    argp.addFlag("append", abbr: "a", help: "Append to the File");
  });

  var files = <File>[];

  if (opts.rest.isNotEmpty) {
    for (var f in opts.rest) {
      files.add(new File(f));
    }
  }

  files.add(new File("/dev/stdout"));

  for (var file in new List<File>.from(files)) {
    if (!file.parent.existsSync()) {
      print("ERROR: '${file.path}': No Such File or Directory.");
      files.remove(file);
    }

    if (!file.existsSync()) {
      file.createSync();
    }
  }

  var outs = <RandomAccessFile>[];

  for (var file in files) {
    outs.add(file.openSync(mode: opts["append"] ? FileMode.APPEND : FileMode.WRITE));
  }

  stdin.listen((data) {
    for (var o in outs) {
      o.writeFromSync(data);
    }
  }).onDone(() {
    for (var o in outs) {
      o.closeSync();
    }
  });
}
