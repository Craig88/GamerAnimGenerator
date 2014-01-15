import java.util.ArrayList;
import java.util.Arrays;
import java.awt.datatransfer.*;
import java.awt.Toolkit;
import java.awt.event.KeyEvent;

int currentFrame = 0;
int totalFrames = 1;
int s = 60;
int offx = 124;
int offy = 160;
int w = 8;
int h = 8;
int[][] canvas,buffer;
boolean autoUpdate;
ArrayList<int[][]> frames = new ArrayList<int[][]>();
boolean[] keys = new boolean[526];

boolean eraseMode;
PImage bg;
PImage[] menu = new PImage[26];
int mx = 164;//menu x offset
int my = 25;//menu y offset
int ms = 32;//menu item size
int pad = 4;//menu item padding
String[] menuLabels = {"Copy Code","Clear All Frames","Previous Frame","Next Frame","Add Blank Frame","Duplicate Current Frame","Remove Frame","Paint Mode","Erase Mode","Toggle Playback","Save Animation","Load Animation"};
String message = "";
final int GREEN = 0xFFA6CE91;

int now,delay = 200;//200ms delay, same as Gamer library Animation example
Slider animDelay = new Slider("delay",offx,109,243,33,16,300,200);

void setup(){
  frames.add(new int[8][8]);
  canvas = frames.get(0);
   
  bg       = loadImage("Gamer_animator_background.png");
  menu[0 ] = loadImage("copycode_s1.png");
  menu[1 ] = loadImage("copycode_s2.png");
  menu[2 ] = loadImage("x_s1.png");
  menu[3 ] = loadImage("x_s2.png");
  menu[4 ] = loadImage("left_s1.png");
  menu[5 ] = loadImage("left_s2.png");
  menu[6 ] = loadImage("right_s1.png");
  menu[7 ] = loadImage("right_s2.png");
  menu[8 ] = loadImage("+_s1.png");
  menu[9 ] = loadImage("+_s2.png");
  menu[10] = loadImage("duplicate_s1.png");
  menu[11] = loadImage("duplicate_s2.png");
  menu[12] = loadImage("-_s1.png");
  menu[13] = loadImage("-_s2.png");
  menu[14] = loadImage("paint_s1.png");
  menu[15] = loadImage("paint_s2.png");
  menu[16] = loadImage("erase_s1.png");
  menu[17] = loadImage("erase_s2.png");
  menu[18] = loadImage("play_s1.png");
  menu[19] = loadImage("play_s2.png");
  menu[20] = loadImage("save_s1.png");
  menu[21] = loadImage("save_s2.png");
  menu[22] = loadImage("load_s1.png");
  menu[23] = loadImage("load_s2.png");
  menu[24] = loadImage("pause_s1.png");
  menu[25] = loadImage("pause_s2.png");
  animDelay.bg = GREEN;
  
  size(bg.width,bg.height);
  frame.setTitle("DIY Gamer - Animator"); 
  textFont(loadFont("Arial-BoldMT-12.vlw"),12);
  now = millis();
}
void draw(){
  drawMenu();
  //playback -> update frames
  if (autoUpdate && totalFrames > 1) {
    if(millis() - now >= delay){
      currentFrame = ((currentFrame+1)%(totalFrames-1));
      canvas = frames.get(currentFrame);
      now = millis();
    }
  }
  //draw -> update current frame pixels
  if(mousePressed && ((mouseX >= offx && mouseX <= offx + (w*s))
                  &&  (mouseY >= offy && mouseY <= offy + (h*s)) )) {
    
     int dx = (mouseX-offx)/s;
     int dy = (mouseY-offy)/s;  
     if(dx < w && dy < h) canvas[dx][dy] = ((keyPressed && keyCode == SHIFT) || eraseMode ) ? 0 : 1;
  }
  //draw current frame
  for(int y = 0; y < h; y++){
    for(int x = 0; x < w; x++){
      fill(canvas[x][y] == 1 ? color(255) : color(255,0)); 
      stroke(0);
      strokeWeight(4);
      rect(x*s+offx,y*s+offy,s,s);
    }
  }
  drawOverlays(); 
}
void drawMenu(){
  image(bg,0,0);
  for(int i = 0 ; i < menuLabels.length; i++){
    image(menu[i*2],mx+((ms+pad)*i),my);
  }
  if(eraseMode) image(menu[17],mx+((ms+pad)*8),my);
  else          image(menu[15],mx+((ms+pad)*7),my); 
  if(autoUpdate) image(menu[24],mx+((ms+pad)*9),my);
  int menuIndex = isOverMenu();
  if(menuIndex >= 0){
    message = menuLabels[menuIndex];
    image(menu[menuIndex*2+1],mx+((ms+pad)*menuIndex),my);
    if(eraseMode) image(menu[16],mx+((ms+pad)*8),my);
    else          image(menu[14],mx+((ms+pad)*7),my);
    if(autoUpdate) image(menu[25],mx+((ms+pad)*9),my);
  }else message = "";  
  animDelay.update(mouseX,mouseY,mousePressed);
  animDelay.draw();
  delay = (int)animDelay.value;
}
void drawOverlays(){
  pushStyle();//draw frame number
    noStroke();
    String cf = (currentFrame+1) + " of " + totalFrames;
    rectMode(CORNER);
    fill(GREEN);
    rect(540,109,80,33);
    fill(0);
    text(cf,560,130);
  popStyle();
  fill(0);//draw tool tip around menu
  text(message,mouseX,mouseY-20);
}
void clearFrame(){
  for(int y = 0; y < h; y++) for(int x = 0; x < w; x++) canvas[x][y] = 0;
}
void invertFrame(){
  for(int y = 0; y < h; y++) for(int x = 0; x < w; x++) canvas[x][y] = 1-canvas[x][y];
}
void keyPressed(){
  keys[keyCode] = true;
  if (keyCode == LEFT && currentFrame > 0)  currentFrame--;
  if (keyCode == RIGHT && currentFrame < totalFrames-1) currentFrame++;
  if(keyCode == LEFT || keyCode == RIGHT) canvas = frames.get(currentFrame);
  if (checkKey(ALT) && checkKey(KeyEvent.VK_C)) copyFrame();
  if (checkKey(ALT) && checkKey(KeyEvent.VK_V)) pasteFrame();
}
void keyReleased(){
  keys[keyCode] = false;
  if(key == 'C') copyToClipboard();
  if(key == BACKSPACE) clearFrame();
  if(key == 'i') invertFrame();
  if(key == '=') addFrame();
  if(key == '+') cloneFrame();
  if(key == '-') removeFrame();
  if(key == 'x') clear();
  if(key == ' ') autoUpdate = !autoUpdate;
  if(key == 'e') eraseMode = !eraseMode;
  if(key == 's') saveAnimation();
  if(key == 'l') loadAnimation();
}
void mouseReleased(){
  int menuIndex = isOverMenu();
  if(menuIndex == 0) copyToClipboard();
  if(menuIndex == 1) clear();
  if(menuIndex == 2  && currentFrame > 0) currentFrame--;
  if(menuIndex == 3  && currentFrame < totalFrames-1) currentFrame++;
  if(menuIndex == 2 || menuIndex == 3) canvas = frames.get(currentFrame);
  if(menuIndex == 4) addFrame();
  if(menuIndex == 5) cloneFrame();
  if(menuIndex == 6) removeFrame();
  if(menuIndex == 7) eraseMode = false;
  if(menuIndex == 8) eraseMode = true;
  if(menuIndex == 9) autoUpdate = !autoUpdate;
  if(menuIndex == 10) saveAnimation();
  if(menuIndex == 11) loadAnimation();
}
boolean checkKey(int k) {
  if (keys.length >= k) return keys[k];  
  return false;
}
void addFrame(){
  frames.add(new int[8][8]);
  currentFrame++;
  canvas = frames.get(currentFrame); 
  totalFrames = frames.size();
}
void cloneFrame() {
  int[][] clone = new int[8][8];
  for(int y = 0; y < 8; y++) for(int x = 0; x < 8; x++) clone[x][y] = canvas[x][y];
//  frames.add(currentFrame,clone);
  frames.add(clone);
  currentFrame++;
  canvas = frames.get(currentFrame);
  totalFrames = frames.size();
}
void removeFrame(){
  if(totalFrames > 1){
    noLoop();
    frames.remove(currentFrame);
    currentFrame--;
    if(currentFrame < 0) currentFrame = 0;
    canvas = frames.get(currentFrame);
    totalFrames = frames.size();
    loop();
  }
}
void copyFrame() {
  buffer = new int[8][8];
  for(int y = 0; y < 8; y++) for(int x = 0; x < 8; x++) buffer[x][y] = canvas[x][y];
  println("copy frame");
}
void pasteFrame() {
  if(buffer != null)
    for(int y = 0; y < 8; y++) for(int x = 0; x < 8; x++) canvas[x][y] = buffer[x][y];
  println("pasted frame " + (buffer != null));
}
String getCode(){
  String out = "#define NUMFRAMES "+totalFrames+"\nbyte frames[NUMFRAMES][8] = {";
  for(int f = 0; f < totalFrames; f++){
    out += "\n\t\t{";
    int[][] cf = frames.get(f);
    for(int y = 0; y < 8; y++){
      String line = (y == 0 ? "" : "\t\t")+"B";
      for(int x = 0; x < 8; x++) line += cf[x][y];
      out += line;
      if(y < 7) out += ",\n";
    }
    if(f < totalFrames-1) out += "},\n";
  }
  out += "}};\n";
  return out;
}
void clear(){
  noLoop();
  frames.clear();
  frames.add(new int[8][8]);
  canvas = frames.get(0);
  currentFrame = 0;
  totalFrames = frames.size();
  loop();
}
void copyToClipboard(){
  StringSelection stringSelection = new StringSelection (getCode());
  Clipboard clpbrd = Toolkit.getDefaultToolkit ().getSystemClipboard ();
  clpbrd.setContents (stringSelection, null);
  javax.swing.JOptionPane.showMessageDialog(frame, "Your code is now copied to your clipboard!");
}
int isOverMenu(){
  int index = -1;
  for(int i = 0 ; i < menuLabels.length; i++){
    if((mouseX > mx+((ms+pad)*i) && mouseX < mx+((ms+pad)*(i+1)))&&
       (mouseY > my && mouseY < my+ms)){
         index = i;
         break;
       }
  }
  return index;
}
void saveAnimation(){
  String name = (String)javax.swing.JOptionPane.showInputDialog(frame, "name your creation", "Save Gamer animation on computer", javax.swing.JOptionPane.PLAIN_MESSAGE);
  if(name != null) {
    String csv = "";
    int npx = w * h;
    for(int[][] f : frames){
      for(int i = 0 ; i < npx ; i++){
        int x = i%w;
        int y = i/w;
        csv += f[x][y];
        if(i < npx-1) csv += ",";
      }
      csv += "\n";
    }
    saveStrings(name,csv.split("\n"));
  }
}
void loadAnimation(){
  String name = (String)javax.swing.JOptionPane.showInputDialog(frame, "re-edit your creation", "Load Gamer animation on computer", javax.swing.JOptionPane.PLAIN_MESSAGE);
  if(name != null) {
    String[] csv = loadStrings(name);
    if(csv != null){
      try{
        frames.clear();
        for(int i = 0 ; i < csv.length; i++){
          int[][] f = new int[w][h];
          String[] px = csv[i].split(",");
          for(int j = 0; j < px.length; j++){
            int x = j%w;
            int y = j/w;
            f[x][y] = Integer.parseInt(px[j]);
          }
          frames.add(f);
        }
        totalFrames = frames.size();
        canvas = frames.get(0);
      }catch(Exception e){
        loadError();
      }
    }else loadError();
  }
}
void loadError(){
  javax.swing.JOptionPane.showMessageDialog(frame, "Unfortunately there were errors loading your file!\nPlease check if the file exists and is formatted correctly");
}
class Slider{
  float w,h,x,y;//width, height and position
  float min,max,value;//slider values: minimum, maximum and current
  float cx,pw = 20;//current slider picker position, picker width
  
  color bg = color(0);//background colour
  color fg = color(255);//foreground colour
  
  String label;
  
  Slider(String label,float x,float y,float w,float h,float min,float max,float value){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.min = min;
    this.max = max;
    this.value = value;
    this.label = label;
    cx = map(value,min,max,x,x+w);
  }
  void update(int mx,int my,boolean md){
    if(md){
      if((mx >= x && mx <= (x+w)) &&
         (my >= y && my <= (y+h))){
        cx = mx;
        value = map(cx,x,x+w,min,max);
      }
    }
  }
  void draw(){
    pushStyle();
    noStroke();
    fill(bg);
    rect(x,y,w,h);
    fill(fg);
    rect(cx-pw*.5,y,pw,h);
//    rect(x,y,cx-x,h);
    fill(0);
    text(label+": "+(int)value,x+pw,y+h*.75);
    popStyle();
  }
}
