part of coreutils;

class ErrorNumbers {
  static const int EPERM = 1;
  static const int ENOENT = 2;
  static const int EACCES = 13;
  static const int EINVAL = 22;
}

class SystemCalls {
  static BinaryTypes types;
  static BinaryTypeHelper typeHelper;
  static DynamicLibrary libc;

  static void init() {
    types = new BinaryTypes();
    typeHelper = new BinaryTypeHelper(types);
    libc = DynamicLibrary.load(_getLibName(), types: types);

    var header = """
    typedef unsigned int pid_t;
    typedef unsigned int uid_t;
    typedef unsigned int gid_t;
    typedef unsigned int time_t;

    int errno;

    pid_t getpid(void);
    pid_t getppid(void);
    pid_t getpgrp(void);
    int setpgid(pid_t pid, pid_t pgid);

    pid_t getsid(pid_t pid);
    pid_t setsid(void);

    void sync(void);

    uid_t getuid(void);
    uid_t geteuid(void);
    int seteuid(uid_t uid);
    int setuid(uid_t uid);

    gid_t getgid(void);
    int setgid(gid_t gid);
    gid_t getegid(void);
    int setegid(gid_t gid);

    time_t time(time_t *t);
    double sqrt(double x);
    char *getlogin(void);

    struct group *getgrnam(const char *name);
    struct group *getgrgid(gid_t gid);
    int getgrnam_r(const char *name, struct group *grp, char *buf, size_t buflen, struct group **result);

    int getgrgid_r(gid_t gid, struct group *grp, char *buf, size_t buflen, struct group **result);

    struct group {
      char   *gr_name;
      char   *gr_passwd;
      gid_t   gr_gid;
      char  **gr_mem;
    };

    int getloadavg(double loadavg[], int nelem);
    char **environ;
    char *ttyname(int fd);
    int getgrouplist(const char *user, gid_t group, gid_t *groups, int *ngroups);
    struct passwd *getpwnam(const char *name);
    """;

    if (Platform.isLinux || Platform.isAndroid) {
      header += """
      int sysinfo(struct sysinfo *info);

      struct sysinfo {
        long uptime;
      };

      struct passwd {
        char   *pw_name;
        char   *pw_passwd;
        uid_t   pw_uid;
        gid_t   pw_gid;
        char   *pw_gecos;
        char   *pw_dir;
        char   *pw_shell;
      };
      """;
    } else {
      header += """
      typedef unsigned int suseconds_t;

      int sysctlbyname(const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen);

      struct timeval {
        time_t tv_sec;
        suseconds_t tv_usec;
      };

      struct passwd {
        char *pw_name;
        char *pw_passwd;
        uid_t pw_uid;
        gid_t pw_gid;
        time_t pw_change;
        char *pw_class;
        char *pw_gecos;
        char *pw_dir;
        char *pw_shell;
        time_t pw_expire;
        int pw_fields;
      };
      """;
    }

    libc.declare(header);
  }

  static String _getLibName() {
    var operatingSystem = Platform.operatingSystem;

    switch (operatingSystem) {
      case "macos":
        return "libSystem.dylib";
      case "android":
      case "linux":
        return "libc.so.6";
      case "windows":
        return "msvcr100.dll";
      default:
        throw new UnsupportedError("Unsupported Operating System: ${operatingSystem}");
    }
  }

  static void sync() {
    libc.invokeEx("sync");
  }

  static int getParentProcessId() {
    return libc.invokeEx("getppid");
  }

  static int getProcessGroupId() {
    return libc.invokeEx("getpgid", [getProcessId()]);
  }

  static void setProcessGroupId(int id) {
    var result = libc.invokeEx("setpgid", [pid, id]);

    if (result == -1) {
      throw new Exception("Failed to set pgid!");
    }
  }

  static int getProcessId() {
    return libc.invokeEx("getpid");
  }

  static String getUserName() {
    return typeHelper.readString(libc.invokeEx("getlogin"));
  }

  static String getGroupNameForId(int id) {
    BinaryData c = libc.invokeEx("getgrgid", [id]);
    if (c.isNullPtr) {
      throw new Exception("Failed to get group name!");
    }
    return typeHelper.readString(c.value["gr_name"]);
  }

  static List<double> getLoadAverage() {
    var c = types["double"].array(3).alloc();
    var result = libc.invokeEx("getloadavg", [c, 3]);
    if (result == -1) {
      throw new Exception("Failed to get load average.");
    }
    return c.value.map((double it) => it).toList();
  }

  static void addStruct(String name, Map<String, String> members) {
    var x = "struct ${name} {\n";
    for (var k in members.keys) {
      x += "${members[k]} ${k};\n";
    }
    x += "};";
    libc.declare(x);
  }

  static dynamic getSysCtlValue(String name, [String type = "char[]"]) {
    var len = types["size_t"].alloc();
    var n = typeHelper.allocString(name);

    libc.invokeEx("sysctlbyname", [n, types["void*"].nullPtr, len, types["void*"].nullPtr, 0]);

    if (type.endsWith("[]")) {
      type = type.substring(0, type.length - 2) + "[${len.value}]";
    }

    var t = types[type];
    var v = t.alloc();

    libc.invokeEx("sysctlbyname", [n, v, len, types["void*"].nullPtr, 0]);

    return readValue(v);
  }

  static dynamic readValue(data) {
    if (data is! BinaryData) {
      return data;
    }

    if (data.isNullPtr) {
      return null;
    }

    try {
      return readNativeString(data);
    } catch (e) {
    }

    var v = data.value;
    if (v is List) {
      v = v.map(readValue).toList();
    } else if (v is Map) {
      var out = {};
      for (var k in v.keys) {
        out[k] = readValue(v[k]);
      }
      return out;
    }
    return v;
  }

  static List<String> getEnvironment() {
    BinaryData data = types["char**"].extern(libc.symbol("environ"));
    var x = [];
    var l;
    var i = 0;
    while (!(l = data.getElementValue(i)).isNullPtr) {
      x.add(typeHelper.readString(l));
      i++;
    }
    return x;
  }

  static String getGroupName() {
    return getGroupNameForId(getGroupId());
  }

  static int getUptime() {
    if (Platform.isLinux || Platform.isAndroid) {
      return getSysInfo().value["uptime"];
    } else {
      return (new DateTime.now().millisecondsSinceEpoch ~/ 1000) - getSysCtlValue("kern.boottime", "struct timeval")["tv_sec"];
    }
  }

  static DateTime getStartupTime() {
    var st = new DateTime.now().subtract(getUptimeDuration());
    st = new DateTime.fromMillisecondsSinceEpoch(st.millisecondsSinceEpoch - st.millisecond);
    return st;
  }

  static Duration getUptimeDuration() {
    return new Duration(seconds: getUptime());
  }

  static BinaryData getSysInfo() {
    if (Platform.isMacOS) {
      throw new Exception("getSysInfo() is not supported on Mac.");
    }

    var instance = types["sysinfo"].alloc();
    var result = libc.invokeEx("getsysinfo", [instance]);
    if (result == -1) {
      throw new Exception("Failed to get sysinfo.");
    }
    return instance;
  }

  static int getSessionId(int pid) {
    return libc.invokeEx("getsid", [pid]);
  }

  static int setSessionId() {
    return libc.invokeEx("setsid");
  }

  static int getUserId() {
    return libc.invokeEx("getuid");
  }

  static int getEffectiveUserId() {
    return libc.invokeEx("geteuid");
  }

  static int getGroupId() {
    return libc.invokeEx("getgid");
  }

  static int getErrorNumber() {
    return INT_T.extern(libc.symbol("errno")).value;
  }

  static void setUserId(int id) {
    var r = libc.invokeEx("setuid", [id]);

    if (r == -1) {
      throw new Exception("Failed to setuid!");
    }
  }

  static final INT_T = types["int"];

  static Map<String, dynamic> getPasswordFileEntry(String user) {
    var u = typeHelper.allocString(user);
    BinaryData result = libc.invokeEx("getpwnam", [u]);

    if (result.isNullPtr) {
      throw new Exception("Unknown User");
    }

    var it = result.value;

    var map = {
      "name": typeHelper.readString(it["pw_name"]),
      "password": typeHelper.readString(it["pw_passwd"]),
      "uid": it["pw_uid"],
      "gid": it["pw_gid"],
      "full name": it["pw_gecos"].isNullPtr ? null : typeHelper.readString(it["pw_gecos"]),
      "home": typeHelper.readString(it["pw_dir"]),
      "shell": typeHelper.readString(it["pw_shell"])
    };

    if (Platform.isMacOS) {
      map["class"] = typeHelper.readString(it["pw_class"]);
      map["password changed"] = it["pw_change"];
      map["expiration"] = it["pw_expire"];
    }

    return map;
  }

  static List<int> getUserGroups(String name) {
    var gid = getPasswordFileEntry(name)["gid"];
    var lastn = 10;
    var count = INT_T.alloc(lastn);
    var results = types["gid_t"].array(lastn).alloc();
    var times = 0;

    while (true) {
      var c = libc.invokeEx("getgrouplist", [typeHelper.allocString(name), gid, results, count]);

      if (c == -1 || lastn != count.value) {
        if (times >= 8) {
          throw new Exception("Failed to get groups.");
        } else {
          count.value = count.value * 2;
          results = types["gid_t"].array(count.value).alloc();
          lastn = count.value;
        }
      } else {
        break;
      }

      times++;
    }

    return results.value;
  }

  static String getTtyName() {
    var x = libc.invokeEx("ttyname", [0]);
    if (x.isNullPtr) {
      return null;
    } else {
      return typeHelper.readString(x);
    }
  }
}

BinaryData alloc(String type, [value]) => SystemCalls.types[type].alloc(value);

String readNativeString(BinaryData input) {
  return SystemCalls.typeHelper.readString(input);
}

BinaryData toNativeString(String input) => SystemCalls.typeHelper.allocString(input);
