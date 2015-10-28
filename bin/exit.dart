import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  init();

  var opts = handleArguments(args, "exit");

  try {
    Process.killPid(getParentProcessId());
  } on FormatException {
    error("Invalid Exit Code -> Not An Integer");
  }
}
