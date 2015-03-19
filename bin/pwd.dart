import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  handleArguments(args, "pwd", fail: (result) => result.rest.isNotEmpty);

  print(Directory.current.absolute.path);
}
