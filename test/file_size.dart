import "package:coreutils/coreutils.dart";

main() {
  print(friendlyFileSize(toFileSizeBytes(50, FileSizeUnit.MEGABYTES)));
  print(friendlyFileSize(toFileSizeBytes(500, FileSizeUnit.MEGABYTES)));
  print(friendlyFileSize(toFileSizeBytes(1045, FileSizeUnit.MEGABYTES)));
  print(friendlyFileSize(toFileSizeBytes(10, FileSizeUnit.KILOBYTES)));
}
