import org.ejml.simple.*; 

public static class LinearXforms {
  static SimpleMatrix identity() {
    return SimpleMatrix.identity(3);
  }

  // @param - angle in radians, counter clockwise around origin.
  static SimpleMatrix rotate(float angle) {
    SimpleMatrix m = identity();
    double cosine = Math.cos(angle);
    double sine = Math.sin(angle);
    m.set(0, 0, cosine);
    m.set(1, 1, cosine);
    m.set(0, 1, -sine);
    m.set(1, 0, sine);
    return m;
  }

  static SimpleMatrix translate(float x, float y) {
    SimpleMatrix m = identity();
    m.set(0, 2, x);
    m.set(1, 2, y);
    return m;
  }
  
  static SimpleMatrix scale(float scale_x, float scale_y) {
    SimpleMatrix m = identity();
    m.set(0, 0, scale_x);
    m.set(1, 1, scale_y);
    return m;
  }

  static SimpleMatrix toVector(PVector pv) {
    SimpleMatrix v = new SimpleMatrix(3, 1);
    v.set(0, 0, pv.x);
    v.set(1, 0, pv.y);
    v.set(2, 0, 1.0);
    return v;
  }

  static PVector toPVector(SimpleMatrix v) {
    return new PVector((float)v.get(0, 0), (float)v.get(1, 0));
  }
  
  static PVector multMatrixByPVector(SimpleMatrix m, PVector pv) {
    return toPVector(m.mult(toVector(pv)));
  }
}
