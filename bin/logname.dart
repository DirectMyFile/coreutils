import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  init();

  handleArguments(args, "logname", fail: (result) => result.rest.isNotEmpty);

  print(SystemCalls.getUserName());
}
