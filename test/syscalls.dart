import "package:coreutils/coreutils.dart";

void main() {
  init();

  print("Parent PID: ${SystemCalls.getParentPid()}");
  print("Environment Pairs: ${SystemCalls.getEnvironmentPairs()}");
}
