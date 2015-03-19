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
    """;

    if (Platform.isLinux || Platform.isAndroid) {
      header += """
      int sysinfo(struct sysinfo *info);

      struct sysinfo {
        long uptime;
      };
      """;
    } else {
      header += """
      int sysctlbyname(const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen);
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
    return libc.invokeEx("getpgid");
  }

  static void setProcessGroupId(int id) {
    var result = libc.invokeEx("setpgid", [pid, id]);

    if (result == -1) {
      throw new Exception("Failed to set pgid!");
    }
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
    return c.value.map((double it) => it);
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
      throw new Exception("Uptime is not yet supported.");
    }
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
}

