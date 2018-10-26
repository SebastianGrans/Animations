
import controlP5.*;


ControlP5 cp5;
Button btn; 

color c1 = #1a2a6c;
color c2 = #b21f1f;
color c3 = #fdbb2d;
color[] colors = new color[]{c1, c2, c3};

boolean showMore = false;

float velocity = PI/300;
float angle = 0;
float radius = 200;
float deltaR = 10;
float divs = 0.5;

void setup() {
  size(640, 640, P2D);
  cp5 = new ControlP5(this);
  
  PFont font = createFont("GillSans.ttc", 15);
  cp5.setFont(font);
  cp5.setColorBackground(lerpColors(colors, 0.85, RGB));
  cp5.setColorForeground(lerpColors(colors, 0.40, RGB));
  cp5.setColorActive(lerpColors(colors, 0.95, RGB));
  
  cp5.addSlider("divs")
     .setPosition(50,30)
     .setRange(0.25,0.5)
     .setWidth(500)
     .setHeight(20)
     .setSliderMode(Slider.FLEXIBLE) 
     ;
   cp5.addSlider("velocity")
     .setPosition(50,60)
     .setRange(0,PI/100)
     .setWidth(500)
     .setHeight(20)
     .setSliderMode(Slider.FLEXIBLE)
     .setCaptionLabel("Velocity");
     ;
     
   cp5.addSlider("deltaR")
     .setPosition(50,90)
     .setRange(1,100)
     .setWidth(500)
     .setHeight(20)
     .setSliderMode(Slider.FLEXIBLE)
     .setCaptionLabel("Delta r");
     ;
     
  btn = cp5.addButton("button")
     .setValue(100)
     .setPosition(40,height-40)
     .setSize(50,20)
     .setLabel("More");
     ;
 
    
}

boolean skip = true;
public void button() {
  
  // For some reason ControlP5 or processing calls this function before everything is
  // setup. This ugly hack throws away the first call. :(
  print("Called");
  if(skip) {
    skip = false;
    return;
  }
  if(showMore) {
    println("Less.");
    btn.setCaptionLabel("More");
    surface.setSize(640, 640);
    showMore = !showMore;
  } else {
    print("More.");
    btn.setCaptionLabel("Less");
    surface.setSize(960, 640);
    showMore = !showMore;
  }  
}

void draw() {
  pushMatrix();
  background(colors[2]);
  if(showMore) {
    translate(width/3, (height/2)+(radius/4));
  } else {
    translate(width/2, (height/2)+(radius/4));
  } 
   
  ellipseMode(RADIUS);
  noStroke();
  float[] center = new float[]{0, 0};
  int c = 0;
  float angleCounter = angle;
  FloatList[] xy = new FloatList[2];
  xy[0] = new FloatList();
  xy[1] = new FloatList();
  
  // Nice anglecounters: PI/(c+1), 
  for(float i = radius; i > 1; i -= deltaR, angleCounter -= PI/divs, c++) {
    // println(c, "X, Y:", center[0], center[1], "R:", radius, "alpha:", angleCounter);
    color thisColor = lerpColors(colors, (i/radius) - 0.1, RGB);
    // println("Color: ", thisColor, "lerp:", i/radius);
    fill(thisColor);
    
    if(showMore) {
      xy[0].append(center[0]);
      xy[1].append(center[1]);
      pushMatrix();
        translate(width/2, 0);
        point(2*center[0], 2*center[1]);
        text(c, 2*center[0]+10, 2*center[1]+10);
      popMatrix();  
    }
    
    ellipse(center[0], center[1], i, i);
    center = newCenter(center[0], center[1], deltaR, angleCounter);
  }
    
  angle += velocity;
  popMatrix();
}

// Move x & y dist units along the angle (in rad)
float[] newCenter(float x, float y, float dist, float angle) {
  float newx = x + dist*cos(angle);
  float newy = y + dist*sin(angle);
  return new float[]{newx, newy};
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
