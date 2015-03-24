import "package:coreutils/coreutils.dart";

main() {
  print(parseFileMode("+x"));
  print(parseFileMode("go-r"));
  print(parseFileMode("=rw,+X"));
  print(parseFileMode("u=rwx,go=rx"));
  print(parseFileMode("u=rwx,go=u-w"));
  print(parseFileMode("go="));
  print(parseFileMode("g=u-w"));
}
