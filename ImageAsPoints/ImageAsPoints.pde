/* TODO:
 *
 * o Animation. E.g. set nOfPoints to maximum and slowly lower the distance.  
 * o Growing circles. When they are added they grow instead of suddenly appearing. 
 * o Resize to fit image. Bug: Doesn't work properly if image is smaller than 640x640.
 */
 
import controlP5.*;
ControlP5 cp5;
Slider numberOfPoints_slider;

color c1 = #1a2a6c;
color c2 = #b21f1f;
color c3 = #fdbb2d;
color[] colors = {c1, c2, c3};
ArrayList<Point> points = new ArrayList<Point>();
float minDistance = 6;
int numberOfPoints = 100;
PImage img;
boolean safe = false;

void setup() {
  size(640, 640, P2D);
  // noLoop();
    // Dense random packing density is about 80%. So we can probably use something lower as
  // a maximum value. 
  float maxRange = (width*height)*0.6/(PI*pow(minDistance/2, 2));
  cp5 = new ControlP5(this);
  cp5.setFont(createFont("Arial",10));
  numberOfPoints_slider = cp5.addSlider("numberOfPoints")
     .setPosition(50,50)
     .setRange(0,1)
     .setValue(numberOfPoints)
     .setSliderMode(Slider.FLEXIBLE)
     //.setTriggerEvent(Slider.RELEASE)
     ;
     
   cp5.addSlider("minDistance")
     .setPosition(50,70)
     .setRange(2, 50)
     .setValue(minDistance)
     .setSliderMode(Slider.FLEXIBLE)
     //.setTriggerEvent(Slider.RELEASE)
     ;
     
   cp5.addBang("open")
     .setPosition(50,90)
     .setCaptionLabel("open")
     //.setTriggerEvent(Slider.RELEASE)
     ;
   
  safe = true;  
}

void open() {
  println("Here...");
  selectInput("Select a file to process:", "onLoadImage");
}

void onLoadImage(File selection) {
  println(selection.getAbsolutePath());
  
  img = loadImage(selection.getAbsolutePath());
  if(img.width > displayWidth || img.height > displayHeight) {
    surface.setSize(round(0.8*displayWidth), round(0.8*displayHeight));
    if(img.width > img.height) {
      img.resize(width, 0);
      println("done resizing w");
    } else {
      img.resize(0, height);
      println("done resizing h");
    } 
  }
  float maxRange = (width*height)*0.6/(PI*pow(minDistance/2, 2));
  numberOfPoints_slider.setRange(0,maxRange);
  loop();
 
}

void draw() {
  clear();
  noStroke();
  ellipseMode(CENTER);
  noFill();
  color c;
  float wh;
  for(int i = 0; i < points.size(); i++) {
     c = getAverageRGBCircle(img, (int)(points.get(i).x), (int)(points.get(i).y), (int)(minDistance/2));
     fill(c);
     wh = map(brightness(c), 0, 255, 0.2*minDistance, minDistance);
     ellipse(points.get(i).x, points.get(i).y, wh, wh);
  }
}

// https://sighack.com/post/averaging-rgb-colors-the-right-way
color getAverageRGBCircle(PImage img, int x, int y, int radius) {
  float r = 0;
  float g = 0;
  float b = 0;
  int num = 0;
  /* Iterate through a bounding box in which the circle lies */
  for (int i = x - radius; i < x + radius; i++) {
    for (int j = y - radius; j < y + radius; j++) {
      /* If the pixel is outside the canvas, skip it */
      if (i < 0 || i >= width || j < 0 || j >= height)
        continue;

      /* If the pixel is outside the circle, skip it */
      if (dist(x, y, i, j) > r)
        continue;

      /* Get the color from the image, add to a running sum */
      color c = img.get(i, j);
      r += red(c) * red(c);
      g += green(c) * green(c);
      b += blue(c) * blue(c);
      num++;
    }
  }
  /* Return the sqrt of the mean of the R, G, and B components */
  return color(sqrt(r/num), sqrt(g/num), sqrt(b/num));
}

void calcCircles() {
  //points.clear();
  if(numberOfPoints < points.size()) {
     int diff = points.size() - numberOfPoints;
     for(int i = diff; i > 0; i--) {
       points.remove(int(random(points.size())));
     }
  }
  
  Point candidate;
  int tries = 0;
  while(points.size() < numberOfPoints) {
     candidate = new Point(random(0, width), random(0, height));
     if(compareWithAll(points, candidate, minDistance)) {
       points.add(candidate);
       // println("Took", tries, "tries");
       tries = 0;
     } else {
       // If we have tried finding space for another point but havn't 
       // succeeded for 'threshold' number of tries, then it's probably 
       // very unlikely that we will find a spot. 
       if(tries > 50) {
         println("Could only find space for", points.size(), "balls. Error: ", numberOfPoints-points.size());
         break;
       }
       tries++;
     }
  } 
}

public void numberOfPoints(int points) {   
  if(img == null)
    return;
  numberOfPoints = points;
  calcCircles();
  
}

public void minDistance(float newDist) {
  if(img == null)
    return;
  minDistance = newDist;
  float maxRange = (width*height)*0.6/(PI*pow(minDistance/2, 2));
  numberOfPoints_slider.setRange(0,maxRange);
  calcCircles();  
}

boolean compareWithAll(ArrayList<Point> list, Point p, float dist) {
   for(int i = 0; i < list.size(); i++) {
     if(p.distance(list.get(i)) < dist) {
       return(false);
     }
   }
   return(true);
}
  
  

boolean compare(Point[] list, Point p, float dist) {
  return(true);  
}

color lerpColors(color[] arr, float step, int colorMode) {
  int sz = arr.length;
  if (sz == 1 || step <= 0.0) {
    return arr[0];
  } else if (step >= 1.0) {
    return arr[sz - 1];
  }
  float scl = step * (sz - 1);
  int i = int(scl);
  return lerpColor(arr[i], arr[i + 1], scl - i, colorMode);
}
