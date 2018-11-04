class Point { 
  public float x, y; 
  Point (float x, float y) {  
    this.x = x; 
    this.y = y; 
  } 
  float distance(Point a) {
    return(sqrt(pow(a.x - this.x, 2) + pow(a.y - this.y, 2))); 
  }
} 
