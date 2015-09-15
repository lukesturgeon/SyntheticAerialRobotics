class Target3d extends PVector {

  float screenX, screenY;
  float _prevX, _prevY, _prevZ;

  Target3d(float _x, float _y, float _z) {
    super(_x, _y, _z);
  }

  boolean hasChanged() {
    if (this.x != _prevX || this.y != _prevY || this.z != _prevZ) {
      _prevX = this.x;
      _prevY = this.y;
      _prevZ = this.z;
      return true;
    } else {
      return false;
    }
  }

  void calculate2d() {
    screenX = screenX(this.x, this.y, this.z);
    screenY = screenY(this.x, this.y, this.z);
  }
}