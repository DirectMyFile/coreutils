import "package:coreutils/coreutils.dart";

main() async {
  init();

  print("UPTIME: ${SystemCalls.getUptime()} seconds");
  print("START TIME: ${SystemCalls.getStartupTime()}");
}
