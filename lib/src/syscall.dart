part of coreutils;

class SystemCalls {
  static BinaryTypes types;
  static BinaryTypeHelper typeHelper;
  static DynamicLibrary libc;

  static void init() {
    types = new BinaryTypes();
    typeHelper = new BinaryTypeHelper(types);
    libc = DynamicLibrary.load(_getLibName(), types: types);

    libc.declare("""
    typedef unsigned int pid_t;

    pid_t getppid(void);
    pid_t getpgrp(void);
    int setpgid(pid_t pid, pid_t pgid);

    pid_t getsid(pid_t pid);
    pid_t setsid(void);

    void sync(void);
    char ** environ;
    """);
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

  static int getParentPid() {
    return libc.invokeEx("getppid");
  }

  static int getProcessGroupId() {
    return libc.invokeEx("getpgid");
  }

  static List<String> getEnvironmentPairs() {
    return libc.invokeEx("environ");
  }

  static void setProcessGroupId(int id) {
    var result = libc.invokeEx("setpgid", [pid, id]);

    if (result == -1) {
      throw new Exception("Failed to set pgid!");
    }
  }

  static int getSessionId(int pid) {
    return libc.invokeEx("getsid", [pid]);
  }

  static int setSessionId() {
    return libc.invokeEx("setsid");
  }
}
