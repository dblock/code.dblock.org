/*
  Bolongas zBalls 1.0129 (Java 1.1) (29.01.98)
  ============================================================
  Daniel Doubrovkine (doubrov5@cuimail.unige.ch) 
  Olivier Chekroun (chekrou2@cuimail.unige.ch)
  (c) University of Geneva (Switzerland) - All Rights Reserved
  ============================================================
  zballs is the applet class controlling any kind of 
  zInterract class instances through a vector of reactable
  objects
  ============================================================
 */
import zInterract;
import java.applet.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;

public class zballs extends Applet implements Runnable, MouseListener, MouseMotionListener
{
  int aw, ah;
  Button quitButton = new Button("Restart !");
  Button soundButton = new Button("Sound !");
  public boolean soundEnabled = true;
  public Random RandomGenerator = new Random(1234);
  private boolean Loading = true;	
  private Thread m_zballs = null;	
  public Vector InterractableObjects = new Vector();
  private MediaTracker tracker = new MediaTracker(this); 
  private Image imgBuf;
  private Graphics contBuf;
  public int NBalls;
  public int MaxBalls;;
  public void init(){     
    showStatus("zzzzz.... Balls - initializing..., please be patient.");
    Loaded = false;
  }
  public void paint(Graphics g){	
    if (imgBuf!=null) g.drawImage(imgBuf,0,0,this);
  }
  public void start(){
    if (m_zballs == null) {
      currentImage = introImage;
      NBalls = 3;
      MaxBalls = 3;
      m_zballs = new Thread(this);
      m_zballs.start();
    }
  }
  public void stop(){
    if (m_zballs != null) {
	m_zballs.stop();
	m_zballs = null;
      }
  }
  private int abs(int arg){
    if (arg < 0) return(-arg); else return(arg);
  }
  private boolean Intersects(zInterract aObject){		
    for (int i=0;i<InterractableObjects.size();i++)
      if (((zInterract) InterractableObjects.elementAt(i)).Beyond(aObject)) return(true);
    return(false);		
  }
  private void Loose(){
    currentImage = overImage;
    if (soundEnabled) looseSound.play();
    intro();
    currentImage = introImage;
    run();
  }
  public int remainingBalls(){
    return (MaxBalls * NBalls) - (InterractableObjects.size()-10);
  }
  public void CreateRandomBall(Image useImage){
    if (remainingBalls() <= 0) {
        NBalls = 3;
	showStatus("Hey! You gotta DESTROY balls, looser!");
	Loose();
        }
    zBall aBall = new zBall(this, useImage);
    aBall.Launch(abs(RandomGenerator.nextInt() % ah), abs(RandomGenerator.nextInt() % aw));
    while (Intersects(aBall))
      aBall.Launch(abs(RandomGenerator.nextInt() % ah), abs(RandomGenerator.nextInt() % aw));	
    InterractableObjects.addElement(aBall); 
    if (soundEnabled) squishSound.play();
  }
  public void paintBack(Graphics g){
    for (int i=0;i<aw;i+=backImage.getWidth(null))
      for (int j=0;j<ah;j+=backImage.getHeight(null))
	g.drawImage(backImage, i, j, null);
  }
  public Image normalImage;
  public Image worldImage;
  public Image backImage;
  private Image backImageFill;
  public Image u36Image;
  public Image currentImage;
  public Image introImage;
  public Image levelImage;
  public Image overImage;
  public Image lWall;
  public Image tWall;

  public AudioClip ballSound;
  public AudioClip introSound;
  public AudioClip levelSound;
  public AudioClip looseSound;
  public AudioClip explSound;
  public AudioClip squishSound;
  public boolean WaitingClick;
  public boolean Interraction;
  public void intro(){
    WaitingClick = true;
    contBuf.drawImage(backImageFill, 0, 0, null);
    contBuf.drawImage(currentImage, (aw - currentImage.getWidth(null)) / 2, (ah - currentImage.getHeight(null)) / 2, null);
    paint(this.getGraphics());
    try{
      while(WaitingClick) m_zballs.sleep(100);
    } catch (Exception dummy){;}
    introSound.stop();
    levelSound.stop();
    looseSound.stop();
  }
  private boolean Loaded;
  public void InterractSound(){
    if (!Interraction) {
	Interraction = true;
	if (soundEnabled) ballSound.play();
      }
  }
  public void run(){	
    InterractableObjects.removeAllElements();
    if (!Loaded){
      this.add(quitButton);
      this.add(soundButton);
      this.addMouseListener(this);
      this.addMouseMotionListener(this);
      quitButton.addMouseListener(new MouseAdapter(){
	public void mousePressed(MouseEvent e){
	  stop();
	  start();
	}
      });
      soundButton.addMouseListener(new MouseAdapter(){
	public void mousePressed(MouseEvent e){
	  soundEnabled=!soundEnabled;
	  if (!soundEnabled){
	    ballSound.stop();
	    introSound.stop();
	    levelSound.stop();
	    looseSound.stop();
	    explSound.stop();
	    squishSound.stop();
	  }
	}
      });
      showStatus("Parallelizing level 14 digital zBuffer ...");
      normalImage = getImage(getDocumentBase(), "images/ball.gif");
      worldImage = getImage(getDocumentBase(), "images/world.gif");
      backImage = getImage(getDocumentBase(), "images/back.gif");
      u36Image = getImage(getDocumentBase(), "images/police.gif");
      introImage = getImage(getDocumentBase(), "images/intro.gif");
      levelImage = getImage(getDocumentBase(), "images/harder.gif");
      overImage = getImage(getDocumentBase(), "images/over.gif");
      showStatus("Randomizing field coefficients ...");
      lWall = getImage(getDocumentBase(), "images/lwall.gif");
      tWall = getImage(getDocumentBase(), "images/twall.gif");
      showStatus("Preparing magnetic multithread degaus ...");
      introSound = getAudioClip(getDocumentBase(), "sounds/intro.au");
      levelSound = getAudioClip(getDocumentBase(), "sounds/level.au");
      looseSound = getAudioClip(getDocumentBase(), "sounds/loose.au");
      explSound = getAudioClip(getDocumentBase(), "sounds/expl.au");
      ballSound = getAudioClip(getDocumentBase(), "sounds/ball.au");
      squishSound = getAudioClip(getDocumentBase(), "sounds/squish.au");
      showStatus("Calculating FFT ...");
      tracker.addImage(levelImage, 0);
      tracker.addImage(overImage, 0);
      tracker.addImage(normalImage, 0);
      tracker.addImage(introImage, 0);
      tracker.addImage(worldImage, 0);
      tracker.addImage(u36Image, 0);
      tracker.addImage(backImage, 0);
      tracker.addImage(lWall, 0);
      tracker.addImage(tWall, 0);
      try{tracker.waitForAll();}catch(Exception e){};
      showStatus("Finalizing magic number ...");
      aw = tWall.getWidth(null);
      ah = getSize().height;
      resize(aw, ah);
      imgBuf = createImage(aw,ah);
      contBuf = imgBuf.getGraphics();
      backImageFill = createImage(aw, ah);
      paintBack(backImageFill.getGraphics());
      currentImage = introImage;
      if (soundEnabled) introSound.play();
      Loaded = true;
      showStatus("Welcome to zzzzz....Balls - another fine Bolonga(s) game!");
    }
    InterractableObjects.addElement(new zWall(this, 1, tWall));
    InterractableObjects.addElement(new zWall(this, 2, tWall));
    InterractableObjects.addElement(new zWall(this, 3, lWall));
    InterractableObjects.addElement(new zWall(this, 4, lWall));
    InterractableObjects.addElement(new zSprite(this, u36Image, aw/2, 250));
    InterractableObjects.addElement(new zSprite(this, u36Image, aw/2-u36Image.getWidth(null), 150));
    for (int i=0;i<NBalls;i++) CreateRandomBall(normalImage);
    CreateRandomBall(worldImage);
    int paintRun = 0;
    try{
      intro();
      long startTime = System.currentTimeMillis();
      long remainingTime;
      while (true){		       
	paintRun = (paintRun+1)%5;
	if (paintRun == 1) contBuf.drawImage(backImageFill, 0, 0, null);
	Interraction = false;
	zInterract azElt;
        for (int i=InterractableObjects.size()-1;i>=0;i--){
	  azElt = (zInterract) InterractableObjects.elementAt(i);
	  azElt.React(mousePosition);
	  for (int j=InterractableObjects.size()-1;j>i;j--) {
	    azElt.Interract(((zInterract) InterractableObjects.elementAt(j)));
	  }
	}	
        for (int i=InterractableObjects.size()-1;i>=0;i--){
	  azElt = (zInterract) InterractableObjects.elementAt(i);
	  azElt.getNextPosition();
	  if (paintRun==1) azElt.Paint(contBuf);
	}	
	if (paintRun==1) {
	  paint(this.getGraphics());
	  m_zballs.sleep(50);
	}
	ballSound.stop();
	remainingTime = (NBalls+10) * 1000 - (System.currentTimeMillis() - startTime);
	showStatus("You still have " + remainingTime/1000 + " secs and " + remainingBalls() + " balls ... ");
	if (remainingTime < 0) {
	  showStatus("Zzzz.... You were sleeping! You time is up!");
	  Loose();
	}
      }
    }catch(Exception e){
    }
  }
  public Point mousePosition = new Point();
  public void mouseMoved(MouseEvent evt){
    mousePosition.x = evt.getX();
    mousePosition.y = evt.getY();
  }
  public void mousePressed(MouseEvent e) {
    if (WaitingClick) WaitingClick = false;
    }
  public void mouseDragged(MouseEvent e) {;}
  public void mouseReleased(MouseEvent e) {;}
  public void mouseClicked(MouseEvent e) {;}
  public void mouseEntered(MouseEvent e) {;}
  public void mouseExited(MouseEvent e) {;}
  public void mouse(MouseEvent e) {;}
}
