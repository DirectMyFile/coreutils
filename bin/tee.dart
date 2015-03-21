import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
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
    if (!(await file.parent.exists())) {
      error("'${file.path}': No Such File or Directory.");
      files.remove(file);
    }

    if (!(await file.exists())) {
      await file.create();
    }
  }

  var outs = <RandomAccessFile>[];

  for (var file in files) {
    outs.add(await file.open(mode: opts["append"] ? FileMode.APPEND : FileMode.WRITE));
  }

  stdin.listen((data) async {
    for (var o in outs) {
      await o.writeFrom(data);
    }
  }).onDone(() async {
    for (var o in outs) {
      await o.close();
    }
  });
}
