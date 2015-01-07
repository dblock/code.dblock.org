/*
  Bolongas zBalls 1.0129 (Java 1.1) (29.01.98)
  ============================================================
  Daniel Doubrovkine (doubrov5@cuimail.unige.ch) 
  Olivier Chekroun (chekrou2@cuimail.unige.ch)
  (c) University of Geneva (Switzerland) - All Rights Reserved
  ============================================================
  zInterract class implements a base reactable reactor sprite
  ============================================================
 */
import java.applet.*;
import java.awt.*;
import java.util.*;

abstract class zInterract
{	
  public int abs(int arg){
    if (arg < 0) return(-arg); else return(arg);
  }
  private int speedVectorSize = 2;
  private int currentSVPos;
  private int[][] speedVector = new int[speedVectorSize][2];
  public boolean isMoving;
  protected int dx, new_dx;	
  protected int dy, new_dy;
  public Rectangle Field = new Rectangle();	
  protected zballs Parent;
  public Image Sprite;
  zInterract(zballs _Parent, boolean _isMoving, Image _Sprite){
    Parent = _Parent;
    isMoving = _isMoving;
    int xSum = 0;
    int ySum = 0;
    while ((xSum==0)||(ySum==0)){
      xSum = 0;
      ySum = 0;
      for (int i=0;i<speedVectorSize;i++){
	speedVector[i][0] = abs(Parent.RandomGenerator.nextInt()%2);
	speedVector[i][1] = abs(Parent.RandomGenerator.nextInt()%2);
	xSum+=speedVector[i][0];
	ySum+=speedVector[i][1];
      }}
    currentSVPos = 0;
    dx = 1;
    dy = 1;
    new_dx = dx;
    new_dy = dy;
    Sprite = _Sprite;
    Field.width = Sprite.getWidth(null);
    Field.height = Sprite.getHeight(null);
  }
  public void Launch(int x, int y){		
    Field.x = x;
    Field.y = y;
  }	
  public void getNextPosition(){
    if (isMoving) {
      dx = new_dx;
      dy = new_dy;
      currentSVPos++;
      if (speedVectorSize == currentSVPos) currentSVPos = 0;
      Field.x += dx * speedVector[currentSVPos][0];
      Field.y += dy * speedVector[currentSVPos][1];
    }
  }	
  abstract public boolean Interract(zInterract Collider);
  public void Paint(Graphics g){
    g.drawImage(Sprite, Field.x, Field.y, null);
  }
  public boolean Reacting(zInterract Collider){
    return (Collider.isMoving) && (Field.intersects(Collider.Field));
  }
  public boolean Beyond(zInterract Collider){
    return(Field.intersects(Collider.Field));
  }
  public void React(Point Position){
  }
}

