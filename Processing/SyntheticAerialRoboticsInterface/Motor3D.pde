class Motor3D extends PVector {

  String  _label = "MOTOR";
  float   _length = 0;
  float   _tempLength = 0;
  float   _positionX2d = 0;
  float   _positionY2d = 0;

  Motor3D(float _x, float _y, float _z) {
    super(_x, _y, _z);
  }

  void setLabel(String l) {
    _label = l;
  }

  void draw2d() {
    pushMatrix();
    translate(_positionX2d, _positionY2d);
    pushStyle();

    fill(255);
    text(_label, 0, -25);
    text(_length, -3, -10);

    popStyle();
    popMatrix();
  }

  void calculateLengthTo( PVector v ) {
    _tempLength = v.dist(this);
    _length = (_tempLength > 0.001) ? _tempLength : 0;
  }

  void calculate2d() {
    _positionX2d = screenX(this.x, this.y, this.z);
    _positionY2d = screenY(this.x, this.y, this.z);
  }

  float getLengthCM() {
    return _length;
  }
}