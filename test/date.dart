import "package:coreutils/coreutils.dart";

void main(List<String> args) {
  print(formatDate(new DateTime.now(), args.join(" ")));
}
