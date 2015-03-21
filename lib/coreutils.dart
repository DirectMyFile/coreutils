library coreutils;

import "dart:async";
import "dart:io";
import "dart:io" as io;

import "package:args/args.dart";
import "package:crypto/crypto.dart";

import "package:binary_interop/binary_interop.dart";

export "package:args/args.dart";

part "src/syscall.dart";
part "src/format.dart";

const String VERSION = "1.0.0";

ArgResults handleArguments(List<String> args, String tool, {bool fail(ArgResults result), void handle(ArgParser parser), String usage}) {
  toolName = tool;
  var argp = new ArgParser();

  argp.addFlag("help", abbr: "h", negatable: false, help: "Displays this Help Message");
  argp.addFlag("version", abbr: "v", negatable: false, help: "Display Version");

  if (handle != null) {
    handle(argp);
  }

  ArgResults result;

  void printHelp() {
    print("Usage: ${tool} [options]${usage != null ? " ${usage}" : ""}");
    if (argp.usage.isNotEmpty) {
      print(argp.usage);
    }
    exit(1);
  }

  try {
    result = argp.parse(args);
  } on FormatException catch (e) {
    print("ERROR: ${e}");
    printHelp();
  }

  if (result["help"]) {
    printHelp();
  }

  if (result["version"]) {
    print("${tool} v${VERSION}");
    exit(0);
  }

  if (fail != null && fail(result)) {
    printHelp();
  }

  return result;
}

String encodeBase64(List<int> bytes) {
  return CryptoUtils.bytesToBase64(bytes);
}

List<int> decodeBase64(String input) {
  return CryptoUtils.base64StringToBytes(input);
}

String asHex(List<int> bytes) {
  return CryptoUtils.bytesToHex(bytes);
}

Future<List<int>> readStdin() async {
  var file = new File("/dev/stdin");

  return await file.readAsBytes();
}

void init() {
  SystemCalls.init();
}

Future<List<FileSystemEntity>> walkTreeBottomUp(Directory dir) async {
  var list = [];

  var items = await dir.list().toList();
  for (var item in items) {
    if (item is Directory) {
      list.addAll(await walkTreeBottomUp(item));
      list.add(item);
    } else {
      list.add(item);
    }
  }

  return list;
}

String formatDate(DateTime d, String format) {
  String tn(int n) {
    if (n <= 9) {
      return "0${n}";
    } else {
      return n.toString();
    }
  }

  return formatString(format, {
    "H": () => tn(d.hour),
    "I": () => ((d.hour + 11) % 12 + 1).toString(),
    "k": () => d.hour.toString().length == 1 ? " ${d.hour}" : d.hour.toString(),
    "l": () {
      var x = ((d.hour + 11) % 12 + 1).toString();

      if (x.length == 1) {
        x = " ${x}";
      }

      return x;
    },
    "M": () => tn(d.minute),
    "P": () => d.hour >= 12 ? "PM" : "AM",
    "r": () {
      var x = tn(((d.hour + 11) % 12 + 1));
      var y = tn(d.minute);
      var z = tn(d.second);
      var a = d.hour >= 12 ? "PM" : "AM";

      return "${x}:${y}:${z} ${a}";
    },
    "R": () {
      return "${tn(d.hour)}:${tn(d.minute)}";
    },
    "s": () => d.millisecondsSinceEpoch.toString(),
    "S": () => d.second.toString(),
    "T": () => "${tn(d.hour)}:${tn(d.minute)}:${tn(d.second)}",
    "X": () => "${tn(d.hour)}:${tn(d.minute)}:${tn(d.second)}",
    "z": () {
      var offset = d.timeZoneOffset;

      if (offset.isNegative) {
        return "-${offset.abs().inMinutes.toString().padLeft(4, '0')}";
      } else {
        return "+${offset.inMinutes.toString().padLeft(4, '0')}";
      }
    },
    ":z": () {
      var offset = d.timeZoneOffset;

      var x = offset.abs().inMinutes.toString().padLeft(4, '0');
      var z = x.substring(2);
      var y = x.substring(0, 2);

      if (offset.isNegative) {
        return "-${y}:${z}";
      } else {
        return "+${y}:${z}";
      }
    },
    "::z": () {
      var offset = d.timeZoneOffset;

      var x = offset.abs().inSeconds.toString().padLeft(6, '0');
      var y = x.substring(0, 2);
      var z = x.substring(2, 4);
      var a = x.substring(4);

      if (offset.isNegative) {
        return "-${y}:${z}:${a}";
      } else {
        return "+${y}:${z}:${a}";
      }
    },
    "%": "%",
    "n": "\n",
    "t": "\t",
    "Z": () => d.timeZoneName,
    "a": () => weekdayName(d.weekday).substring(0, 3),
    "A": () => weekdayName(d.weekday),
    "b": () => monthName(d.month).substring(0, 3),
    "B": () => monthName(d.month),
    "c": () {
      return "${weekdayName(d.weekday).substring(0, 3)}"
        + " ${monthName(d.month).substring(0, 3)}"
        + " ${tn(d.hour)}:${tn(d.minute)}:${tn(d.second)} ${d.year}";
    },
    "C": () => d.year.toString().substring(0, 2),
    "D": "%m/%d/%y",
    "x": "%m/%d/%y",
    "y": tn(int.parse(d.year.toString().substring(2))),
    "e": d.month.toString().padLeft(2, " "),
    "F": "%Y-%m-%d",
    "m": "${tn(d.month)}",
    "d": tn(d.day),
    "Y": "${d.year.toString().padLeft(4, "0")}"
  });
}

String weekdayName(int number) {
  switch (number) {
    case DateTime.SUNDAY:
      return "Sunday";
    case DateTime.MONDAY:
      return "Monday";
    case DateTime.TUESDAY:
      return "Tuesday";
    case DateTime.WEDNESDAY:
      return "Wednesday";
    case DateTime.THURSDAY:
      return "Thursday";
    case DateTime.FRIDAY:
      return "Friday";
    case DateTime.SATURDAY:
      return "Saturday";
    default:
      throw "Should never happen.";
  }
}

String monthName(int number) {
  switch (number) {
    case 1:
      return "January";
    case 2:
      return "Feburary";
    case 3:
      return "March";
    case 4:
      return "April";
    case 5:
      return "May";
    case 6:
      return "June";
    case 7:
      return "July";
    case 8:
      return "August";
    case 9:
      return "September";
    case 10:
      return "October";
    case 11:
      return "November";
    case 12:
      return "December";
  }
  return "(not a month?)";
}

enum FileSizeUnit {
  BYTES, KILOBYTES, MEGABYTES, GIGABYTES, TERABYTES
}

int toFileSizeBytes(int input, FileSizeUnit unit) {
  switch (unit) {
    case FileSizeUnit.BYTES:
      return input;
    case FileSizeUnit.KILOBYTES:
      return input * 1024;
    case FileSizeUnit.MEGABYTES:
      return toFileSizeBytes(input * 1024, FileSizeUnit.KILOBYTES);
    case FileSizeUnit.GIGABYTES:
      return toFileSizeBytes(input * 1024, FileSizeUnit.MEGABYTES);
    case FileSizeUnit.TERABYTES:
      return toFileSizeBytes(input * 1024, FileSizeUnit.GIGABYTES);
  }
}

String friendlyFileSize(int bytes) {
  if (bytes == 0) {
    return "0";
  }

  var kb = bytes / 1024;
  var mb = kb / 1024;
  var gb = mb / 1024;
  var tb = gb / 1024;

  String m(num x) {
    if (x is int) {
      return x.toString();
    } else if (x is double && x == x.round()) {
      return x.toInt().toString();
    } else {
      return x.toStringAsFixed(2);
    }
  }

  if (kb < 1) {
    return "${bytes}B";
  } else if (kb >= 1 && mb < 1) {
    return "${m(kb)}K";
  } else if (mb >= 0 && gb < 1) {
    return "${m(mb)}M";
  } else if (gb >= 0 && tb < 1) {
    return "${m(gb)}G";
  } else {
    return "${m(tb)}T";
  }
}

class FilePermission {
  final int index;
  final String _name;

  const FilePermission._(this.index, this._name);

  static const EXECUTE = const FilePermission._(0, 'EXECUTE');
  static const WRITE = const FilePermission._(1, 'WRITE');
  static const READ = const FilePermission._(2, 'READ');
  static const SET_UID = const FilePermission._(3, 'SET_UID');
  static const SET_GID = const FilePermission._(4, 'SET_GID');
  static const STICKY = const FilePermission._(5, 'STICKY');

  static const List<FilePermission> values = const [EXECUTE, WRITE, READ, SET_UID, SET_GID, STICKY];

  String toString() => 'FilePermission.$_name';
}

class FilePermissionRole {
  final int index;
  final String _name;

  const FilePermissionRole._(this.index, this._name);

  static const WORLD = const FilePermissionRole._(0, 'WORLD');
  static const GROUP = const FilePermissionRole._(1, 'GROUP');
  static const OWNER = const FilePermissionRole._(2, 'OWNER');

  static const List<FilePermissionRole> values = const [WORLD, GROUP, OWNER];

  String toString() => 'FilePermissionRole.$_name';
}

bool hasPermission(int fileStatMode, FilePermission permission, {FilePermissionRole role: FilePermissionRole.WORLD}) {
  var bitIndex = _getPermissionBitIndex(permission, role);
  return (fileStatMode & (1 << bitIndex)) != 0;
}

int _getPermissionBitIndex(FilePermission permission, FilePermissionRole role) {
  switch (permission) {
    case FilePermission.SET_UID: return 11;
    case FilePermission.SET_GID: return 10;
    case FilePermission.STICKY: return 9;
    default: return (role.index * 3) + permission.index;
  }
}

class IOUtils {
  static void exit(int code) {
    io.exit(code);
  }
}

void error(String msg, {bool exit: true, int exitCode: 1}) {
  print("ERROR: ${msg}");
  if (exit) {
    IOUtils.exit(exitCode);
  }
}

String toolName;
