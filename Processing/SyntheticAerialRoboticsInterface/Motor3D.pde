class Motor3D extends PVector {

  float _length = 0;
  float _tempLength = 0;

  Motor3D(float _x, float _y, float _z) {
    super(_x, _y, _z);
  }

  void calculateLengthTo( PVector v ) {
    _tempLength = v.dist(this);
    _length = (_tempLength > 0.001) ? _tempLength : 0;
  }

  float getLength() {
    return _length;
  }
}