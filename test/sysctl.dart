import "package:coreutils/coreutils.dart";

void main() {
  init();

  print("Kernel Hostname: ${SystemCalls.getSysCtlValue("kern.hostname")}");
  print("Boot Time: ${SystemCalls.getSysCtlValue("kern.boottime", "struct timeval")["tv_sec"]}");
}
