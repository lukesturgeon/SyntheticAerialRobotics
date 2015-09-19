String utils_getTimestamp() {
  String timestamp = "";

  timestamp += year() + "-";
  timestamp += nf(month(), 2) + "-";
  timestamp += nf(day(), 2) + "_";
  timestamp += nf(hour(), 2) + "-";
  timestamp += nf(minute(), 2) + "-";
  timestamp += nf(second(), 2);

  return timestamp;
}