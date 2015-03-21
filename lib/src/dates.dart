part of coreutils;

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
