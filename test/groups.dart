import "package:coreutils/coreutils.dart";

main() {
  init();

  var groups = SystemCalls.getUserGroups("alex");
  print(groups);
}
