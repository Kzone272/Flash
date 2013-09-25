/****************************************
 *				   ▲					*
 *				  ▲ ▲					*
 *				 ▲   ▲					*
 *				▲ ▲ ▲ ▲					*
 *			   ▲       ▲				*
 *			  ▲ ▲     ▲ ▲				*
 *			 ▲   ▲   ▲   ▲				*
 *			▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲				*
 *		   ▲               ▲			*
 *		  ▲ ▲    Kevin    ▲ ▲			*
 *		 ▲   ▲  Haslett  ▲   ▲			*
 *		▲ ▲ ▲ ▲	        ▲ ▲ ▲ ▲			*
 *	   ▲       ▲       ▲       ▲		*
 *	  ▲ ▲     ▲ ▲     ▲ ▲     ▲ ▲		*
 *	 ▲   ▲   ▲   ▲   ▲   ▲   ▲   ▲		*
 *	▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲ ▲		*
 *										*
 ****************************************/

package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Breakout extends MovieClip {
		
		public var bricksWide:int = 10;
		public var bricksHigh:int = 1;
		public var margin:Number = 2;
		public var sideBorder:Number = 5;
		public var topBorder:Number = 50;
		public var bWidth:Number = 0;
		public var bHeight:Number = 15;
		public var bricks:Array = new Array();
		public var b:Ball = new Ball();
		public var p:Brick = new Brick(null, bWidth, bHeight);
		public var xSpd:Number = 5;
		public var ySpd:Number = 5;
		public var dir:String = "";
		public var hiBeep:HiBeep = new HiBeep();
		public var loBeep:LoBeep = new LoBeep();
		public var whichSound:int = 0;
		public var htb:HitTestBox = new HitTestBox();
		public var mainTf:TextFormat = new TextFormat();
		public var centerTf:TextFormat = new TextFormat();
		public var subTf:TextFormat = new TextFormat();
		public var t1:TextField = new TextField();
		public var t2:TextField = new TextField();
		public var tLives:TextField = new TextField();
		public var tScore:TextField = new TextField();
		public var tCenter:TextField = new TextField();
		public var tSub:TextField = new TextField();
		public var lives:Number = 3;
		public var score:Number = 0;
		public var hitCount:Number = 0;
		public var totalBricks:Number = 0;
		public var level:Number = 0;
		public var paused:Boolean = false;
		public var end:Boolean = false;
		public var board:CircleBoard = new CircleBoard(b, 0xFFFFFF, .6, 550, 350);
		
		public function Breakout():void {
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
			
		public function addedToStage(e:Event):void {
			
			board.alpha = 0.1;
			board.y = topBorder;
			addChild(board);
			
			mainTf.color = 0xFFFFFF;
			mainTf.align = "center";
			mainTf.font = "Visitor TT1 BRK";
			mainTf.size = 48;
			
			centerTf.color = 0xFFFFFF;
			centerTf.align = "center";
			centerTf.font = "Visitor TT1 BRK";
			centerTf.size = 68;
			
			subTf.color = 0xFFFFFF;
			subTf.align = "center";
			subTf.font = "Visitor TT1 BRK";
			subTf.size = 24;
			
			addChild(t1)
			t1.text = "Lives:";
			t1.selectable = false;
			t1.width = 200;
			t1.height = 48;
			t1.x = 100 - t1.width/2;
			t1.y = 1;
			t1.setTextFormat(mainTf);
			
			addChild(t2);
			t2.text = "Score:";
			t2.selectable = false;
			t2.width = 200;
			t2.height = 48;
			t2.x = 375 - t2.width/2;
			t2.y = 0;
			t2.setTextFormat(mainTf);
			
			addChild(tLives)
			tLives.text = "0";
			tLives.selectable = false;
			tLives.width = 100;
			tLives.height = 48;
			tLives.x = 220 - tLives.width/2;
			tLives.y = 1;
			tLives.setTextFormat(mainTf);
			
			addChild(tScore);
			tScore.text = "0";
			tScore.selectable = false;
			tScore.width = 100;
			tScore.height = 48;
			tScore.x = 500 - tScore.width/2;
			tScore.y = 0;
			tScore.setTextFormat(mainTf);
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			
			newLevel();
			
		}
		
		public function keyDown(e:KeyboardEvent):void {
						
			if (e.keyCode == Keyboard.LEFT)
				dir = "left";
			if (e.keyCode == Keyboard.RIGHT)
				dir = "right";
			if (e.keyCode == Keyboard.SPACE)
				pause();
		
		}
		
		public function keyUp(e:KeyboardEvent):void {
			
			if (e.keyCode == Keyboard.LEFT && dir == "left" ||
				e.keyCode == Keyboard.RIGHT && dir == "right")
				dir = "";
			
		}
		
		public function enterFrame(e:Event):void {
			
			ball();
			paddle();
			checkHit();
			
		}
		
		public function checkHit():void {
			
			for (var i:int = 0; i < bricks.length; i++) {
				
				for (var j:int = 0; j < bricks[i].length; j++) {
					
					var hitDir:String = htb.hitTest(b.x, b.y, b.y - b.height/2, b.y + b.height/2,
													b.x - b.width/2, b.x + b.width/2,
													bricks[i][j].y - bricks[i][j].height/2,
													bricks[i][j].y + bricks[i][j].height/2,
													bricks[i][j].x - bricks[i][j].width/2, 
													bricks[i][j].x + bricks[i][j].width/2);
					
					if (hitDir == "up" || hitDir == "down") {
						
						removeChild(bricks[i][j]);
						bricks[i].splice(j, 1);
						
						hitCount++;
						
						if (hitCount >= totalBricks) {
							level++;
							newLevel();
						}
						
						b.update(7.5, Math.random()*0xFFFFFF);
						sound();
						
						score++;
						updateText();
						
						ySpd *=-1;
						
					} else if (hitDir == "left" || hitDir == "right") {
						
						removeChild(bricks[i][j]);
						bricks[i].splice(j, 1);
						
						hitCount++;
						
						if (hitCount >= totalBricks) {
							level++;
							newLevel();
						}
						
						b.update(7.5, Math.random()*0xFFFFFF);
						sound();
						
						score++;
						updateText();
						
						xSpd *=-1;
						
					}

				}
			}
			
		}
		
		public function ball():void {
			
			if (b.x < b.width/2) {
				
				b.x = b.width/2;
				xSpd *= -1;
				b.update(7.5, Math.random()*0xFFFFFF);
				sound();
				
			} else if (b.x > stage.stageWidth - b.width/2) {
				
				b.x = stage.stageWidth - b.width/2;
				xSpd *= -1;
				b.update(7.5, Math.random()*0xFFFFFF);
				sound();
				
			} else if (b.y < b.height/2 + topBorder) {
				
				b.y = b.height/2 + topBorder;
				ySpd *= -1;
				b.update(7.5, Math.random()*0xFFFFFF);
				sound();
				
			} else if (b.y > stage.stageHeight + 100) {
				
				reset();
				lives--;
				
				if (lives <= 0)
					endGame();
				
				updateText();
				
			}
			
			if (xSpd > 10)
				xSpd = 10;
				
			b.x += xSpd;
			b.y += ySpd;
			
		}
		
		public function paddle():void {
			
			if (dir == "left")			//The paddle movements are a lot smoother when you do them
				p.x -= 10;				//in enter frame. You just have to check if the direction
			else if (dir == "right")	//is left or right. String variables are probably a bad idea
				p.x += 10;				//here, but it's more understandable.

			if (p.x < p.width/2)
				p.x = p.width/2;
			else if (p.x > stage.stageWidth - p.width/2)
				p.x = stage.stageWidth - p.width/2;
			
			var hitDir:String = htb.hitTest(b.x, b.y, b.y - b.height/2, b.y + b.height/2,
											b.x - b.width/2, b.x + b.width/2,
											p.y - p.height/2, p.y + p.height/2,
											p.x - p.width/2, p.x + p.width/2);
			
			
			if (hitDir == "up") {
				
				b.update(7.5, Math.random()*0xFFFFFF);
				sound();
				
				ySpd *=-1;
				b.y = p.y - p.height/2 - b.height/2 + ySpd;
				xSpd += (b.x - p.x) / p.width/2 * 10;
				
			} else if (hitDir == "down") {
				
				b.update(7.5, Math.random()*0xFFFFFF);
				sound();
				
				ySpd *=-1;
				b.y = p.y + p.height/2 + b.height/2 + ySpd;
				xSpd += (b.x - p.x) / p.width/2 * 10;
				
			} else if (hitDir == "left") {
				
				b.update(7.5, Math.random()*0xFFFFFF);
				sound();
				
				xSpd *=-1;
				b.x = p.x - p.width/2 - b.width/2 + xSpd;
				
			} else if (hitDir == "right") {
				
				b.update(7.5, Math.random()*0xFFFFFF);
				sound();
				
				xSpd *=-1;
				b.x = p.x + p.width/2 + b.width/2 - xSpd;
				
			}
			
		}
		
		public function newLevel():void {
			
			totalBricks = bricksWide * bricksHigh;
			hitCount = 0;
			lives = 3 + level;
			
			clearBricks();
			
			bWidth = (stage.stageWidth - margin*(bricksWide - 1) - 2*sideBorder) / bricksWide;
			
			for (var i:int = 0; i < bricksWide; i++) {
				
				var workingX:Number = bWidth/2 + margin * i + bWidth * i + sideBorder;
				bricks[i] = new Array();
				
				for (var j:int = 0; j < bricksHigh; j++) {
					
					var workingY:Number = bHeight/2 + margin * j + bHeight * j + topBorder;
					
					var brick:Brick = new Brick(null, bWidth, bHeight);
					addChild(brick);
					brick.x = workingX;
					brick.y = workingY;
					
					bricks[i][j] = brick;
					
				}
				
			}
			
			bricks[0][0].update(bWidth, bHeight, 0x0000FF);
			bricks[bricksWide-1][0].update(bWidth, bHeight, 0x0000FF);
			bricks[0][bricksHigh-1].update(bWidth, bHeight, 0x0000FF);
			bricks[bricksWide-1][bricksHigh-1].update(bWidth, bHeight, 0x0000FF);
			
			bricksWide++;
			bricksHigh++;
			
			if (level == 0)
				pause("BREAKOUT", "Press The Spacebar To Start");
			else
				pause("Level " + String(level+1), "Press The Spacebar To Start");
			reset();
			
		}
		
		public function reset():void {
			
			addChild(b);
			b.x = stage.stageWidth/2;
			b.y = stage.stageHeight/2;
			
			addChild(p);
			p.x = stage.stageWidth/2;
			p.y = stage.stageHeight - 15;
			var pWidth:Number = 100-level*10;
			if (pWidth < 30)
				pWidth = 30;
			p.update(pWidth, 15, 0xFFFFFF);
			
			xSpd = (Math.random() * 8) - 4;
			ySpd = level + 5;
			if (ySpd > 8)
				ySpd = 8;
			
			dir = "";
			
			updateText();
			
		}
		
		public function pause(text:String = "PAUSED", textSub:String = ""):void {
			
			if (!paused) {
				
				paused = true;
				
				removeEventListener(Event.ENTER_FRAME, enterFrame);
				
				b.visible = false;
				p.visible = false;
				board.visible = false;
				
				for (var i:int = 0; i < bricks.length; i++) {
				
					for (var j:int = 0; j < bricks[i].length; j++) {
						
						bricks[i][j].visible = false;
						
					}
				}
				
				addChild(tCenter);
				tCenter.text = text;
				tCenter.selectable = false;
				tCenter.width = 550;
				tCenter.height = 60;
				tCenter.x = 275 - tCenter.width/2;
				tCenter.y = 170 - tCenter.height/2;
				tCenter.setTextFormat(centerTf);
				
				addChild(tSub);
				tSub.text = textSub;
				tSub.selectable = false;
				tSub.width = 550;
				tSub.height = 60;
				tSub.x = 275 - tCenter.width/2;
				tSub.y = 225 - tCenter.height/2;
				tSub.setTextFormat(subTf);
				
			} else if (paused) {
				
				paused = false;
				
				addEventListener(Event.ENTER_FRAME, enterFrame);
				
				b.visible = true;
				p.visible = true;
				board.visible = true;
				
				for (var k:int = 0; k < bricks.length; k++) {
				
					for (var l:int = 0; l < bricks[k].length; l++) {
						
						bricks[k][l].visible = true;;
						
					}
				}
				
				removeChild(tCenter);
				removeChild(tSub);
				
				if (end) {
					end = false;
					score = 0;
					level = 0;
					bricksWide = 10;
					bricksHigh = 1;
					newLevel();
				}
				
			}
			
		}
		
		public function endGame():void {
			
			clearBricks();
			end = true;
			pause("You Lose", "Press The Spacebar To Play Again");
			
		}
		
		public function updateText():void {	//Updates all text fields and sets
											//their respectife text formats.
			tLives.text = String(lives);
			tLives.setTextFormat(mainTf);
			
			tScore.text = String(score);
			tScore.setTextFormat(mainTf);
			
		}
		
		public function clearBricks():void {
			
			for (var i:int = 0; i < bricks.length; i++) {
				
				for (var j:int = 0; j < bricks[i].length; j++) {
					
					removeChild(bricks[i][j]);
					
				}
			}
			bricks.splice(0,bricks.length);
			
		}
		
		public function sound():void {
			
			if (whichSound == 0) {
				hiBeep.play();
				whichSound = 1;
			} else if (whichSound == 1) {
				loBeep.play();
				whichSound = 0;
			}
			
		}
		
	}
	
}