import java.util.ArrayList;
import java.util.Arrays;
import java.awt.datatransfer.*;
import java.awt.Toolkit;
import java.awt.event.KeyEvent;

int currentFrame = 0;
int totalFrames = 1;
int s = 60;
int offx = 80;
int offy = 160;
int w = 8;
int h = 8;
int[][] canvas,buffer;
boolean autoUpdate;
ArrayList<int[][]> frames = new ArrayList<int[][]>();
boolean[] keys = new boolean[526];

boolean eraseMode;
PImage bg;
PImage[] menu = new PImage[20];
int mx = 164;//menu x offset
int my = 25;//menu y offset
int ms = 32;//menu item size
int pad = 4;//menu item padding
String[] menuLabels = {"Save","Clear All Frames","Previous Frame","Next Frame","Add Blank Frame","Duplicate Current Frame","Remove Frame","Toggle Erase","Toggle Playback"};
String message = "";
final int GREEN = 0xFFA6CE91;

int now,delay = 200;

void setup(){
  frames.add(new int[8][8]);
  canvas = frames.get(0);
  
  bg = loadImage("Gamer_animator_background.png");
  menu[0] = loadImage("save_s1.png");
  menu[1] = loadImage("x_s1.png");
  menu[2] = loadImage("left_s1.png");
  menu[3] = loadImage("right_s1.png");
  menu[4] = loadImage("+_s1.png");
  menu[5] = loadImage("duplicate_s1.png");
  menu[6] = loadImage("-_s1.png");
  menu[7] = loadImage("erase_square_s1.png");
  menu[8] = loadImage("play_s1.png");
  menu[9] = loadImage("save_s2.png");
  menu[10] = loadImage("x_s2.png");
  menu[11] = loadImage("left_s2.png");
  menu[12] = loadImage("right_s2.png");
  menu[13] = loadImage("+_s2.png");
  menu[14] = loadImage("duplicate_s2.png");
  menu[15] = loadImage("-_s2.png");
  menu[16] = loadImage("erase_square_s2.png");
  menu[17] = loadImage("play_s2.png");
  menu[18] = loadImage("erase_square_s3.png");
  menu[19] = loadImage("erase_square_s4.png");
  
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
  frame.setTitle((int)frameRate+" fps");
}
void drawMenu(){
  image(bg,0,0);
  for(int i = 0 ; i < menuLabels.length; i++){
    image(menu[i],mx+((ms+pad)*i),my);
  }
  if(eraseMode) image(menu[18],mx+((ms+pad)*7),my);
  if(autoUpdate) image(menu[17],mx+((ms+pad)*8),my);
  int menuIndex = isOverMenu();
  if(menuIndex >= 0){
    message = menuLabels[menuIndex];
    image(menu[menuIndex+menuLabels.length],mx+((ms+pad)*menuIndex),my);
    if(eraseMode) image(menu[19],mx+((ms+pad)*7),my);
    if(autoUpdate) image(menu[8],mx+((ms+pad)*8),my);
  }else message = "";  
}
void drawOverlays(){
  pushStyle();//draw frame number
    noStroke();
    String cf = (currentFrame+1) + " of " + totalFrames;
    rectMode(CENTER);
    fill(GREEN);
    rect(540,125,60,33);
    //rect(500,125,121,33);
    fill(0);
    text(cf,500,125);
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
  if(key == 'c') copyToClipboard();
  if(key == BACKSPACE) clearFrame();
  if(key == 'i') invertFrame();
  if(key == '=') addFrame();
  if(key == '+') cloneFrame();
  if(key == '-') removeFrame();
  if(key == 'n') clear();
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
  if(menuIndex == 7) eraseMode = !eraseMode;
  if(menuIndex == 8) autoUpdate = !autoUpdate;
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
    try{
      String[] csv = loadStrings(name);
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
      javax.swing.JOptionPane.showMessageDialog(frame, "Unfortunately there were errors loading your file!\nPlease check if the file exists and is formatted correctly");
    }
  }
}
