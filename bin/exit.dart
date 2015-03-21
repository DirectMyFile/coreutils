import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  init();

  var opts = handleArguments(args, "exit");

  try {
    Process.killPid(SystemCalls.getParentProcessId());
  } on FormatException catch (e) {
    error("Invalid Exit Code -> Not An Integer");
  }
}
