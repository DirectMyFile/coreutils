part of coreutils;

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

enum FileSizeUnit {
  BYTES, KILOBYTES, MEGABYTES, GIGABYTES, TERABYTES
}

int parseFileMode(String input) {
  var WHO = new RegExp(r"(a|u|g|o)");
  var PERM = new RegExp(r"(r|s|t|w|x|X|u|g|o)");
  var OP = new RegExp(r"(\+|\-|\=)");
  var ACTION = new RegExp("(${OP.pattern})(${PERM.pattern})+");

  var s = new StringScanner(input);

  String parseWho() {
    return s.lastMatch[1];
  }

  String parseOp([bool sb = false]) {
    if (!sb) {
      s.expect(OP);
    }

    return s.lastMatch[1];
  }

  List<String> parsePerms() {
    var out = [];
    while (s.scan(PERM)) {
      out.add(s.lastMatch[1]);
    }
    return out;
  }

  List<dynamic> parseAction([bool sb = false]) {
    return [parseOp(sb), parsePerms()];
  }

  List<dynamic> parseClause() {
    var whos = [];
    var actions = [];

    while (s.scan(WHO)) {
      whos.add(parseWho());
    }

    actions.add(parseAction());

    while (s.scan(ACTION)) {
      actions.add(parseAction(true));
    }

    return [
      whos,
      actions
    ];
  }

  List<dynamic> parseClauses() {
    var c = [];

    c.add(parseClause());

    while (s.scan(",")) {
      c.add(parseClause());
    }

    return c;
  }

  var clauses = parseClauses();
  s.expectDone();
  print(clauses);
  return 0;
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
