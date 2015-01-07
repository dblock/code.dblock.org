/*
  Bolongas zBalls 1.0129 (Java 1.1) (29.01.98)
  ============================================================
  Daniel Doubrovkine (doubrov5@cuimail.unige.ch) 
  Olivier Chekroun (chekrou2@cuimail.unige.ch)
  (c) University of Geneva (Switzerland) - All Rights Reserved
  ============================================================
  zWall class implements a solid reactor wall on any external 
              virtaul edge of the container
  ============================================================
 */

import zInterract;
import java.applet.*;
import java.awt.*;

class zWall extends zInterract{		
  private int thickness = 5;
  private int orientation;	
  //north=1, south=2, east=3, west=4
  zWall(zballs _Parent, int orient, Image _Sprite){				
    super(_Parent, false, _Sprite);
    orientation = orient;		
    switch (orientation){
    case 1: 
      thickness = _Sprite.getHeight(null);
      Field.x = 0;
      Field.y = 0;
      Field.height = thickness - 1;
      Field.width = Parent.getSize().width;
      break;
    case 2: 
      thickness = _Sprite.getHeight(null);
      Field.x = 0;
      Field.y = Parent.getSize().height - thickness;
      Field.height = thickness - 1;
      Field.width = Parent.getSize().width;
      break;
    case 3: 
      thickness = _Sprite.getWidth(null);
      Field.x = 0;
      Field.y = 0;
      Field.height = Parent.getSize().height;
      Field.width = thickness - 1;
      break;
    case 4: 
      thickness = _Sprite.getWidth(null);
      Field.x = Parent.getSize().width - thickness;
      Field.y = 0;
      Field.width = thickness  - 1;
      Field.height = Parent.getSize().height;
      break;
    }			
  }	
  public boolean Interract(zInterract Collider){
    if ((Collider.isMoving)&&(Reacting(Collider))) {
      Parent.InterractSound();
      switch (orientation){
      case 1: if (Collider.dy > 0) break; Collider.new_dy = -Collider.dy; Collider.Field.y = Field.y + Field.height; break;
      case 2: if (Collider.dy < 0) break; Collider.new_dy = -Collider.dy; Collider.Field.y = Field.y - Collider.Field.height; break;
      case 3: if (Collider.dx > 0) break; Collider.new_dx = -Collider.dx; Collider.Field.x = Field.x + Field.width; break;
      case 4: if (Collider.dx < 0) break; Collider.new_dx = -Collider.dx; Collider.Field.x = Field.x - Collider.Field.width;break;
      }
    }
    return(false);
  }
  public void Launch(int x, int y){
  }
  public boolean Beyond(zInterract Collider){		
    switch (orientation){
    case 1: if (Collider.Field.y < Field.y + thickness) Collider.Field.y = Field.y + Field.height; break;
    case 2: if (Collider.Field.y + Collider.Field.height > Field.y) Collider.Field.y = Field.y - Collider.Field.height; break;
    case 3: if (Collider.Field.x < Field.x + thickness) Collider.Field.x = Field.x + Field.width; break;
    case 4: if (Collider.Field.x + Collider.Field.width > Field.x) Collider.Field.x = Field.x - Collider.Field.width;break;
    }			
    return(false);
  }
}

