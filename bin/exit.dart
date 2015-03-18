import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  init();

  var result = handleArguments(args, "exit");

  try {
    Process.killPid(SystemCalls.getParentProcessId());
  } on FormatException catch (e) {
    print("ERROR: Invalid Exit Code -> Not An Integer");
    exit(1);
  }
}
