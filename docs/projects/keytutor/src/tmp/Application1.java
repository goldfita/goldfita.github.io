package tmp;

import javax.swing.*;
import java.awt.*;

public class Application1 {
  boolean packFrame = false;

  //Construct the application
  public Application1() {
    Frame1 frame = new Frame1();
    //Validate frames that have preset sizes
    //Pack frames that have useful preferred size info, e.g. from their layout
    if (packFrame) {
      frame.pack();
    }
    else {
      frame.validate();
    }
    //Center the window
    frame.setSize(500, 300);
    Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
    Dimension frameSize = frame.getSize();
    if (frameSize.height > screenSize.height) {
      frameSize.height = screenSize.height;
    }
    if (frameSize.width > screenSize.width) {
      frameSize.width = screenSize.width;
    }
    frame.setLocation((screenSize.width - frameSize.width) / 2, (screenSize.height - frameSize.height) / 2);
    frame.setVisible(true);

    getNextKey(frame);
    while(true) {
      if(frame.button_pressed) {
        frame.button_pressed = false;
        getNextKey(frame);
      }
      if(frame.button_pressed == false) {
        frame.random_button.setForeground(Color.blue);
        frame.random_button.setBackground(Color.blue);
        try { Thread.currentThread().sleep(120); }
        catch(InterruptedException IE) {}
        frame.random_button.setForeground(Color.black);
        frame.random_button.setBackground(Color.black);
        try { Thread.currentThread().sleep(120); }
        catch(InterruptedException IE) {}
      }
    }
  }

  //Main method
  public static void main(String[] args) {
    try {
      UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
    }
    catch(Exception e) {
      e.printStackTrace();
    }
    new Application1();

  }

  void getNextKey(Frame1 f) {
    int r = new java.util.Random().nextInt(42);
    switch (r) {
      case 0: f.current_key = '0'; f.random_button = f.zero; break;
      case 1: f.current_key = '1'; f.random_button = f.one; break;
      case 2: f.current_key = '2'; f.random_button = f.two; break;
      case 3: f.current_key = '3'; f.random_button = f.three; break;
      case 4: f.current_key = '4'; f.random_button = f.four; break;
      case 5: f.current_key = '5'; f.random_button = f.five; break;
      case 6: f.current_key = '6'; f.random_button = f.six; break;
      case 7: f.current_key = '7'; f.random_button = f.seven; break;
      case 8: f.current_key = '8'; f.random_button = f.eight; break;
      case 9: f.current_key = '9'; f.random_button = f.nine; break;
      case 10: f.current_key = 'w'; f.random_button = f.w; break;
      case 11: f.current_key = 'e'; f.random_button = f.e; break;
      case 12: f.current_key = 'r'; f.random_button = f.r; break;
      case 13: f.current_key = 't'; f.random_button = f.t; break;
      case 14: f.current_key = 'y'; f.random_button = f.y; break;
      case 15: f.current_key = 'u'; f.random_button = f.u; break;
      case 16: f.current_key = 'i'; f.random_button = f.i; break;
      case 17: f.current_key = 'o'; f.random_button = f.o; break;
      case 18: f.current_key = 'p'; f.random_button = f.p; break;
      case 19: f.current_key = 'a'; f.random_button = f.a; break;
      case 20: f.current_key = 's'; f.random_button = f.s; break;
      case 21: f.current_key = 'd'; f.random_button = f.d; break;
      case 22: f.current_key = 'f'; f.random_button = f.f; break;
      case 23: f.current_key = 'g'; f.random_button = f.g; break;
      case 24: f.current_key = 'h'; f.random_button = f.h; break;
      case 25: f.current_key = 'j'; f.random_button = f.j; break;
      case 26: f.current_key = 'k'; f.random_button = f.k; break;
      case 27: f.current_key = 'l'; f.random_button = f.l; break;
      case 28: f.current_key = ';'; f.random_button = f.semi_colon; break;
      case 29: f.current_key = '\''; f.random_button = f.apostrophe; break;
      case 30: f.current_key = 'z'; f.random_button = f.z; break;
      case 31: f.current_key = 'x'; f.random_button = f.x; break;
      case 32: f.current_key = 'c'; f.random_button = f.c; break;
      case 33: f.current_key = 'v'; f.random_button = f.v; break;
      case 34: f.current_key = 'b'; f.random_button = f.b; break;
      case 35: f.current_key = 'n'; f.random_button = f.n; break;
      case 36: f.current_key = 'm'; f.random_button = f.m; break;
      case 37: f.current_key = ','; f.random_button = f.comma; break;
      case 38: f.current_key = '.'; f.random_button = f.period; break;
      case 39: f.current_key = '/'; f.random_button = f.slash; break;
      case 40: f.current_key = ' '; f.random_button = f.space; break;
      case 41: f.current_key = 'q'; f.random_button = f.q; break;
    }
  }
}