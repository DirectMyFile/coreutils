import "package:coreutils/coreutils.dart";

void main() {
  init();

  print("Parent PID: ${SystemCalls.getParentProcessId()}");
  print("Error Number: ${SystemCalls.getErrorNumber()}");
  print("User ID: ${SystemCalls.getUserId()}");
  print("Effective User ID: ${SystemCalls.getEffectiveUserId()}");
  print("User Name: ${SystemCalls.getUserName()}");
  print("Group Name: ${SystemCalls.getGroupName()}");
  print("Load Averages: ${SystemCalls.getLoadAverage()}");
  print("Uptime: ${SystemCalls.getUptime()}");
}
