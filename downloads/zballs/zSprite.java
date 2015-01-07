/*
  Bolongas zBalls 1.0129 (Java 1.1) (29.01.98)
  ============================================================
  Daniel Doubrovkine (doubrov5@cuimail.unige.ch) 
  Olivier Chekroun (chekrou2@cuimail.unige.ch)
  (c) University of Geneva (Switzerland) - All Rights Reserved
  ============================================================
  zSprite class implements a solid reactor at any position
  ============================================================
 */

import zInterract;
import java.applet.*;
import java.awt.*;

class zSprite extends zInterract {		
  zSprite(zballs _Parent, Image _Sprite, int x, int y){				
    super(_Parent, false, _Sprite);
    Launch(x, y);
  }	
  public boolean Interract(zInterract Collider){
    if ((Collider.isMoving)&&(Reacting(Collider))){
      Parent.InterractSound();
      if (Collider.Field.y > Field.y + Field.height - Collider.Field.height) {
	Collider.new_dy = abs(Collider.dy);
      } else if (Collider.Field.y < Field.y) {
	Collider.new_dy = -abs(Collider.dy);
      }			

      if (Collider.Field.x > Field.x + Field.width - Collider.Field.width) {
	Collider.new_dx = abs(Collider.dx); 
      } else if (Collider.Field.x < Field.x) {
	Collider.new_dx = -abs(Collider.dx);
      }			
    }		
    return(false);
  }
  public void Paint(Graphics g){
    g.drawImage(Sprite, Field.x, Field.y, null);		
  }
}

