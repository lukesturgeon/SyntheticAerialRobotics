class Motor3d extends PVector {

  float   screenX, screenY;
  String  _label = "MOTOR";
  float   _length, _tempLength, _prevLength = 0;
  float   _liveLength;

  Motor3d(float _x, float _y, float _z) {
    super(_x, _y, _z);
  }

  void setLabel(String l) {
    _label = l;
  }
  
  void setLiveLength(float len){
    _liveLength = len;
  }

  void draw2d() {
    pushMatrix();
    translate(screenX, screenY);
    pushStyle();

    noStroke();
    fill(255);

    ellipse(0, 0, 10, 10);
    textFont(bodyFont);
    text(_label, 0, -40);
    text("SIM:"+_length, 0, -25);
    text("ACT:"+_liveLength, 0, -10);

    popStyle();
    popMatrix();
  }

  boolean hasChanged() {    
    if (_length != _prevLength) {
      _prevLength = _length;
      return true;
    } else {
      return false;
    }
  }

  void calculate2d() {
    screenX = screenX(this.x, this.y, this.z);
    screenY = screenY(this.x, this.y, this.z);
  }

  void calculateLengthTo( PVector v ) {
    _tempLength = v.dist(this);
    _length = (_tempLength > 0.001) ? _tempLength : 0;
  }

  float getLengthCM() {
    return _length;
  }

  int getLengthMM() {
    return int(_length * 100);
  }
}