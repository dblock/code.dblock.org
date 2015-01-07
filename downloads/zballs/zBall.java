/*
  Bolongas zBalls 1.0129 (Java 1.1) (29.01.98)
  ============================================================
  Daniel Doubrovkine (doubrov5@cuimail.unige.ch) 
  Olivier Chekroun (chekrou2@cuimail.unige.ch)
  (c) University of Geneva (Switzerland) - All Rights Reserved
  ============================================================
  zBall class implements a solid moving reactable reactor
  ============================================================
 */

import zInterract;
import java.applet.*;
import java.awt.*;

class zBall extends zInterract{
  long lastGenBall = 0;
  zBall(zballs _Parent, Image _Sprite){		
    super(_Parent, true, _Sprite);
    lastGenBall = System.currentTimeMillis();
  }
  public void Launch(int x, int y){
    super.Launch(x, y);
    Field.width = Sprite.getWidth(null);
    Field.height = Sprite.getHeight(null);
  }
  public void React(Point Position){
    if (Field.contains(Position)) {
      if (Parent.worldImage == Sprite) {
	zInterract azBall;
	if (Parent.soundEnabled) Parent.explSound.play();
	Parent.InterractableObjects.removeElement(this);
	for(int i=0;i< (Parent.InterractableObjects.size()); i++){
	  azBall = (zInterract) Parent.InterractableObjects.elementAt(i);
	  if (azBall instanceof zBall) {
	    ((zBall) azBall).Sprite = Parent.worldImage;
	    return;
	  }}
	Parent.NBalls*=2;
	Parent.currentImage = Parent.levelImage;
	Parent.showStatus("Well done! Let's try something harder!");
	if (Parent.soundEnabled) Parent.levelSound.play();
	Parent.run();
      } else if (Parent.normalImage == Sprite) {
	long currentGenBall = System.currentTimeMillis();
	if (currentGenBall - lastGenBall > 1000){
	  lastGenBall = currentGenBall;
	  Parent.CreateRandomBall(Parent.normalImage);
	}
      }
    }
  }
  public boolean Interract(zInterract Collider){		
    if ((Collider.isMoving)&&(Reacting(Collider))) {
      Parent.InterractSound();
      if (Collider.Field.y > Field.y + Field.height - Collider.Field.height/2) {
        Collider.new_dy = abs(Collider.dy);
        new_dy = -abs(dy);
      } else if (Collider.Field.y+Collider.Field.height/2 < Field.y) {
	Collider.new_dy = -abs(Collider.dy);
        new_dy = abs(dy);
      }			      
      if (Collider.Field.x > Field.x + Field.width - Collider.Field.width/2) {
	Collider.new_dx = abs(Collider.dx); 
        new_dx = -abs(dx);              
      } else if (Collider.Field.x+Collider.Field.width/2 < Field.x) {
	Collider.new_dx = -abs(Collider.dx);
        new_dx = abs(dx);
      }				
    }		
    return(false);
  }
  public void Paint(Graphics g){
        super.Paint(g);        
  }
}


