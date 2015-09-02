String utils_getUniqueFileName() {
  String str = "";

  int y = year();
  str += String.valueOf(y);

  int j = month();
  str += "-"+String.valueOf(j);

  int d = day();
  str += "-"+String.valueOf(d);

  int h = hour();
  str += "_"+String.valueOf(h);

  int m = minute();
  str += "-"+String.valueOf(m);

  int s = second();
  str += "-"+String.valueOf(s);

  return str;
}