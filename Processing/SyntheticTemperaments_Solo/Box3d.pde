class Box3d {
  
  float topMargin, bottomMargin, leftMargin, rightMargin, frontMargin, backMargin;
  float w, h, d;
  float x, y, z;
  
  Box3d(float left, float top, float back, float right, float bottom, float front){
    topMargin = top;
    bottomMargin = bottom;
    leftMargin = left;
    rightMargin = right;
    frontMargin = front;
    backMargin = back;
    
    w = abs(leftMargin) + rightMargin;
    h = abs(topMargin) + bottomMargin;
    d = abs(backMargin) + frontMargin;
    
    x = (rightMargin + leftMargin) * 0.5;
    y = (bottomMargin + topMargin) * 0.5;
    z = (frontMargin + backMargin) * 0.5;
  }
  
  void draw() {
    pushMatrix();
    translate(x,y,z);
    box(w, h, d);
    popMatrix();
  }
}