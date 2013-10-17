import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.ArrayList; 
import java.util.Arrays; 
import java.awt.datatransfer.*; 
import java.awt.Toolkit; 
import java.awt.event.KeyEvent; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class GamerAnimGenerator extends PApplet {







int currentFrame = 0;
int totalFrames = 1;
int s = 50;
int[][] canvas,buffer;
boolean autoUpdate,showHelp = true;
ArrayList<int[][]> frames = new ArrayList<int[][]>();
boolean[] keys = new boolean[526];

public void setup(){
  size(8*s,8*s);stroke(127);frameRate(24);
  frames.add(new int[8][8]);
  canvas = frames.get(0);
}
public void draw(){
  if (autoUpdate && totalFrames > 1) {
    currentFrame = ((currentFrame+1)%(totalFrames-1));
    canvas = frames.get(currentFrame);
  }
  try{
    if(mousePressed) canvas[mouseX/s][mouseY/s] = keyPressed ? 0 : 1;
  }catch(ArrayIndexOutOfBoundsException e){}
  for(int y = 0; y < 8; y++){
    for(int x = 0; x < 8; x++){
      fill(canvas[x][y] * 255); 
      rect(x*s,y*s,s,s);
    }
  }
  if(showHelp) {  pushStyle();fill(0,192,0);text("press SPACE to clear\npress 'i' to invert\nSHIFT+click to erase\npress 's' to save\npress 'c' to copy to clipboard\npress '=' to add a blank frame\npress '+' to duplicate the current frame\npress '-' to remove the current frame\npress 'n' to start from scratch\nLEFT and RIGHT keys navigate frames\nSPACE toggles playback\npress 'h' to toggle help",5,15);popStyle();  }
  frame.setTitle("frame " + (currentFrame+1) + " of " + totalFrames);
}
public void keyPressed(){
  keys[keyCode] = true;
  if (keyCode == LEFT && currentFrame > 0)  currentFrame--;
  if (keyCode == RIGHT && currentFrame < totalFrames-1) currentFrame++;
  if(keyCode == LEFT || keyCode == RIGHT) canvas = frames.get(currentFrame);
  if (checkKey(ALT) && checkKey(KeyEvent.VK_C)) copyFrame();
  if (checkKey(ALT) && checkKey(KeyEvent.VK_V)) pasteFrame();
}
public void keyReleased(){
  keys[keyCode] = false;
  if(key == 's') saveFile();
  if(key == 'c') copyToClipboard();
  if(key == BACKSPACE) for(int y = 0; y < 8; y++) for(int x = 0; x < 8; x++) canvas[x][y] = 0;
  if(key == 'i') for(int y = 0; y < 8; y++) for(int x = 0; x < 8; x++) canvas[x][y] = 1-canvas[x][y];
  if(key == '=') addFrame();
  if(key == '+') cloneFrame();
  if(key == '-') removeFrame();
  if(key == 'n') clear();
  if(key == ' ') autoUpdate = !autoUpdate;
  if(key == 'h') showHelp = !showHelp;
}
public boolean checkKey(int k) {
  if (keys.length >= k) return keys[k];  
  return false;
}
public void addFrame(){
  frames.add(new int[8][8]);
  currentFrame++;
  canvas = frames.get(currentFrame); 
  totalFrames = frames.size();
}
public void cloneFrame() {
  int[][] clone = new int[8][8];
  for(int y = 0; y < 8; y++) for(int x = 0; x < 8; x++) clone[x][y] = canvas[x][y];
  frames.add(clone);
  canvas = frames.get(currentFrame);
  currentFrame++;
  totalFrames = frames.size();
}
public void removeFrame(){
  noLoop();
  frames.remove(currentFrame);
  currentFrame--;
  canvas = frames.get(currentFrame);
  totalFrames = frames.size();
  loop();
}
public void copyFrame() {
  buffer = new int[8][8];
  for(int y = 0; y < 8; y++) for(int x = 0; x < 8; x++) buffer[x][y] = canvas[x][y];
  println("copy frame");
}
public void pasteFrame() {
  if(buffer != null)
    for(int y = 0; y < 8; y++) for(int x = 0; x < 8; x++) canvas[x][y] = buffer[x][y];
  println("paste frame");
}
public void saveFile(){
  String name = (String)javax.swing.JOptionPane.showInputDialog(frame, "name your creation", "Save Gamer Animation", javax.swing.JOptionPane.PLAIN_MESSAGE);
  if(name != null) saveToDisk(name+".txt");
}
public String getCode(){
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
public void saveToDisk(String file){
  saveStrings(file, getCode().split("\n"));
  println(file+" ready!");
}
public void clear(){
  noLoop();
  frames.clear();
  frames.add(new int[8][8]);
  canvas = frames.get(0);
  currentFrame = 0;
  totalFrames = frames.size();
  loop();
}
public void copyToClipboard(){
  StringSelection stringSelection = new StringSelection (getCode());
  Clipboard clpbrd = Toolkit.getDefaultToolkit ().getSystemClipboard ();
  clpbrd.setContents (stringSelection, null);
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "GamerAnimGenerator" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
