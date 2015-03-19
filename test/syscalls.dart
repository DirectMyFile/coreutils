import "package:coreutils/coreutils.dart";

void main() {
  init();

  print("Parent PID: ${SystemCalls.getParentProcessId()}");
  print("Error Number: ${SystemCalls.getErrorNumber()}");
  print("User Name: ${SystemCalls.getUserName()}");
  print("Group Name: ${SystemCalls.getGroupName()}");
}
