package  {
	
	import flash.display.MovieClip;
	import flash.display.Graphics;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
	public class Tetris extends MovieClip {
		
		public const WIDTH:int = 10;
		public const HEIGHT:int = 22;
		public var DELAY:int;
		public var board:TetrisBoard;
		public var boardVisual:Array = new Array();
		public var gravTimer:Timer;
		public var currentBlocks:Array = new Array();
		public var pieceQueue:Array = new Array();
		public var currentPiece:String;
		public var currentRot:int;
		public var hold:String;
		public var level:int;
		public var score:int;
		public var lines:int;
		public var goal:int;
		public var paused:Boolean;
		public var pauseText:PauseText = new PauseText();
		public var goText:GOText = new GOText();
		public var spaceText:SpaceText = new SpaceText();
		public var held:Boolean;
		public var bgLoop:Sound = new Sound();
		public var bgControl:SoundChannel = new SoundChannel();
		public var pausePoint:Number = 0.00;
		public var muteBtn:MuteButton = new MuteButton();
		public var muted:Boolean = false;
		public var sfxBtn:SfxButton = new SfxButton();
		public var sfxMuted:Boolean = false;
		public var pointSound:Sound = new Sound;
		public var levelUpSound:Sound = new Sound;
		public var gameOverSound:Sound = new Sound();
		public var spaceStart:Boolean = false;
		
		public function Tetris() {
			
			bgLoop.load(new URLRequest("Tetris Dubstep Remix.mp3"));
			bgLoop.addEventListener(Event.COMPLETE, soundLoaded);
			pointSound.load(new URLRequest("Point.mp3"));
			levelUpSound.load(new URLRequest("Level Up.mp3"));
			gameOverSound.load(new URLRequest("Game Over.mp3"));
			
			muteBtn.x = 575;
			muteBtn.y = 25;
			addChild(muteBtn);
			muteBtn.addEventListener(MouseEvent.CLICK, muteClick);
			
			sfxBtn.x = 575;
			sfxBtn.y = 70;
			addChild(sfxBtn);
			sfxBtn.addEventListener(MouseEvent.CLICK, sfxClick);
			
			pauseText.x = 40;
			pauseText.y = 280;
			
			goText.x = 25;
			goText.y = 280;
			
			spaceText.x = 25;
			spaceText.y = 130;
			
			loaderInfo.addEventListener(Event.COMPLETE, stageLoaded);
		}
		
		public function soundLoaded(e:Event):void {
			playBgLoop();
		}
		
		public function playBgLoop():void {
			//Plays bg music and adds a listener for when it stops:
			bgControl = bgLoop.play(pausePoint);
			bgControl.addEventListener(Event.SOUND_COMPLETE, bgLoopEnd);
		}
		
		public function bgLoopEnd(e:Event):void {
			//Resets bg music:
			pausePoint = 0.00;
			playBgLoop();
		}
		
		public function muteClick(e:MouseEvent):void {
			//Mutes and unmutes
			if (!muted) {
				muteBtn.gotoAndStop(2);
				pausePoint = bgControl.position;
				bgControl.stop();
			} else if (muted) {
				muteBtn.gotoAndStop(1);
				playBgLoop();
			}
			muted = !muted;
			
		}
		
		public function sfxClick(e:MouseEvent):void {
			if (!sfxMuted)
				sfxBtn.gotoAndStop(2);
			else if (sfxMuted)
				sfxBtn.gotoAndStop(1);
			
			sfxMuted = !sfxMuted;
		}
		
		public function stageLoaded(e:Event):void {
			
			for (var j:int = 0; j < WIDTH; j++) {
				boardVisual[j] = new Array();
				for (var k:int = 0; k < HEIGHT - 2; k++) {
					
					var blocks:Blocks = new Blocks();
					blocks.stop();
					blocks.x = j * 20 + 30;
					blocks.y = k * 20 + 120;
					addChild(blocks);
					
					boardVisual[j][k] = blocks;
					
				}
			}
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			
			spaceToStart();
		}
		
		public function spaceToStart():void {
			addChild(spaceText);
			spaceStart = true;
		}
		
		public function newGame():void {
			
			score = 0;
			level = 1;
			lines = 0;
			goal = level * 5;
			DELAY = 1000;
			hold = 'none';
			paused = false;
			
			pieceHold.gotoAndStop(hold);
			
			updateText();
			
			board = new TetrisBoard(WIDTH, HEIGHT);
			board.addEventListener("collision", collision);
			gravTimer = new Timer(DELAY, 0);
			gravTimer.addEventListener(TimerEvent.TIMER, gravity);
			
			for (var i:int = 0; i < 4; i++) {
				pieceQueue[i] = newPieceType();
			}
			
			newTetrimino(pieceQueue[0]);
			
			gravTimer.start();
			
		}
		
		public function collision(e:Event):void {
			
			gravTimer.removeEventListener(TimerEvent.TIMER, gravity);
			gravTimer.stop();
			gameOver();
			
		}
		
		public function gameOver():void {
			
			if (!sfxMuted)
				gameOverSound.play();
				
			addChild(goText);
			
			var eraseTimer:Timer = new Timer(10, board.Height);
			eraseTimer.addEventListener(TimerEvent.TIMER, erase);
			eraseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, eraseComplete);
			eraseTimer.start();
			
			paused = true;
			
			getBlocks();
			for (var i:int = 0; i < currentBlocks.length; i++)
				board.b[currentBlocks[i][0]][currentBlocks[i][1]].fallen = true;
				
			currentBlocks.splice(0, currentBlocks.length);
			
			function erase(e:TimerEvent):void {
				
				for (var i:int = 0; i < board.Width; i++) {
					board.b[i][eraseTimer.currentCount] = null;
					drawBoard();
				}
			}
			
			function eraseComplete(e:TimerEvent):void {
				removeChild(goText);
				spaceToStart();
			}
			
		}
		
		public function pause():void {
			
			if (!paused) {
				gravTimer.stop();
				gravTimer.removeEventListener(TimerEvent.TIMER, gravity);
				addChild(pauseText);
				
				for (var i:int = 0; i < board.Width; i++)
					for (var j:int = 2; j < board.Height; j++)
						boardVisual[i][j-2].gotoAndStop('none');
				
			} else if (paused) {
				gravTimer.start();
				gravTimer.addEventListener(TimerEvent.TIMER, gravity);
				removeChild(pauseText);
				drawBoard();
			}
			
			paused = !paused;
			
		}
		
		public function keyDown(e:KeyboardEvent):void {
			
			if (e.keyCode == Keyboard.P) {
				pause();
				return
			}
			if (paused && !spaceStart)
				return
			
			if (e.keyCode == Keyboard.SPACE) {
				if (spaceStart) {
					spaceStart = false;
					newGame();
					removeChild(spaceText);
					return
				} else
					drop();
			}
			
			if (e.keyCode == Keyboard.UP) {
				rotate();
			} else if (e.keyCode == Keyboard.DOWN) {
				shift(0, 1, currentBlocks);
				gravTimer.stop();
				gravTimer.reset();
				gravTimer.start();
			} else if (e.keyCode == Keyboard.LEFT) {
				shift(-1, 0, currentBlocks);
			} else if (e.keyCode == Keyboard.RIGHT) {
				shift(1, 0, currentBlocks);
			} else if (e.keyCode == Keyboard.SHIFT) {
				holdPiece();
				held = true;
			}
		}
		
		public function gravity(e:TimerEvent):void {
			shift(0, 1, currentBlocks);
		}
		
		public function shift(xShift:int, yShift:int, blocks:Array):void {
			
			getBlocks();
			
			if (hitTest(xShift, yShift, blocks) == 1)
				return;
			else if (hitTest(xShift, yShift, blocks) == 2) {
				newTetrimino();
				return;
			}
			
			var tempBoard:TetrisBoard = new TetrisBoard(WIDTH, HEIGHT);
			
			for (var i:int = 0; i < board.Width; i++) {
				for (var j:int = 0; j < board.Height; j++) {
					if (board.b[i][j] != null && board.b[i][j].fallen)
						tempBoard.b[i][j] = board.b[i][j];
				}
			}
			
			for (var k:int = 0; k < 4; k++) {
				
				var xPos = blocks[k][0];
				var yPos = blocks[k][1];
				
				tempBoard.b[xPos + xShift][yPos + yShift] = board.b[xPos][yPos];
			}
			
			board.b = tempBoard.b;
			
			drawBoard();
		}
		
		public function rotate():void {
			
			//3D Rotation Matrix! WooooOOOOOOOOOoooooooooOOOOOOOOooooooo!
			var rots:Array = [[[[-1,-2],[0,-1],[1,0],[2,1]],//I
							   [[2,-1],[1,0],[0,1],[-1,2]],
							   [[1,2],[0,1],[-1,0],[-2,-1]],
							   [[-2,1],[-1,0],[0,-1],[1,-2]]],
						      [[[0,0],[0,0],[0,0],[0,0]],//O
							   [[0,0],[0,0],[0,0],[0,0]],
							   [[0,0],[0,0],[0,0],[0,0]],
							   [[0,0],[0,0],[0,0],[0,0]]],
							  [[[1,-1],[-1,-1],[0,0],[1,1]],//T
							   [[1,1],[1,-1],[0,0],[-1,1]],
							   [[-1,1],[1,1],[0,0],[-1,-1]],
							   [[-1,-1],[-1,1],[0,0],[1,-1]]],
						      [[[1,-1],[2,0],[-1,-1],[0,0]],//S
							   [[1,1],[0,2],[1,-1],[0,0]],
							   [[-1,1],[-2,0],[1,1],[0,0]],
							   [[-1,-1],[0,-2],[-1,1],[0,0]]],
						      [[[0,-2],[1,-1],[0,0],[1,1]],//Z
							   [[2,0],[1,1],[0,0],[-1,1]],
							   [[0,2],[-1,1],[0,0],[-1,-1]],
							   [[-2,0],[-1,-1],[0,0],[1,-1]]],
						      [[[0,-2],[-1,-1],[0,0],[1,1]],//J
							   [[2,0],[1,-1],[0,0],[-1,1]],
							   [[0,2],[1,1],[0,0],[-1,-1]],
							   [[-2,0],[-1,1],[0,0],[1,-1]]],
						      [[[2,0],[-1,-1],[0,0],[1,1]],//L
							   [[0,2],[1,-1],[0,0],[-1,1]],
							   [[-2,0],[1,1],[0,0],[-1,-1]],
							   [[0,-2],[-1,1],[0,0],[1,-1]]]];
			
			currentRot++;
			if (currentRot >= 4)
				currentRot = 0;
				
			var pieceNum:int;
			
			switch (currentPiece) {
				case 'I':
					pieceNum = 0;
					break;
				case 'O':
					pieceNum = 1;
					break;
				case 'T':
					pieceNum = 2;
					break;
				case 'S':
					pieceNum = 3;
					break;
				case 'Z':
					pieceNum = 4;
					break;
				case 'J':
					pieceNum = 5;
					break;
				case 'L':
					pieceNum = 6;
					break;
			}
			
			var newBlocks:Array = new Array();
			
			getBlocks();
			
			for (var l:int = 0; l < 4; l++) {
			
				newBlocks[l] = [currentBlocks[l][0] + rots[pieceNum][currentRot][l][0],
								currentBlocks[l][1] + rots[pieceNum][currentRot][l][1]];
				
			}
			
			if (hitTest(0, 0, newBlocks) > 0) {
				currentRot--;
				return;
			}
			
			var tempBoard:TetrisBoard = new TetrisBoard(WIDTH, HEIGHT);
			
			for (var i:int = 0; i < board.Width; i++) {
				for (var j:int = 0; j < board.Height; j++) {
					if (board.b[i][j] != null && board.b[i][j].fallen)
						tempBoard.b[i][j] = board.b[i][j];
				}
			}
			
			for (var k:int = 0; k < 4; k++) {
				
				tempBoard.b[newBlocks[k][0]][newBlocks[k][1]] = board.b[currentBlocks[k][0]][currentBlocks[k][1]];
			}
			
			board.b = tempBoard.b;
			
			drawBoard();
			
		}
		
		public function hitTest(xShift:int, yShift:int, blocks:Array):int {
			
			var tempBoard:TetrisBoard = new TetrisBoard();
			
			for (var i:int = 0; i < blocks.length; i++) {
				
				var xPos = blocks[i][0] + xShift;
				var yPos = blocks[i][1] + yShift;
				
				if (xPos < 0 || xPos >= board.Width || yPos < 0)
					return 1;
					
				if (yPos >= board.Height)
					return 2;
				
				if (board.b[xPos][yPos] != null && board.b[xPos][yPos].fallen)
					if (yShift > 0)
						return 2;
					else
						return 1
			}
			return 0;
		}
		
		public function getBlocks():void {
			
			for (var i:int = 0; i < board.Width; i++) {
				for (var j:int = 0; j < board.Height; j++) {
					
					if (board.b[i][j] != null && ! board.b[i][j].fallen)
						currentBlocks[board.b[i][j].num] = new Array(i, j);
					
				}
			}
			
		}
		
		public function checkLines():void {
			
			var completeLines:Array = new Array()
			
			for (var j:int = 0; j < board.Height; j++) {
				
				completeLines.push(j);
				
				for (var i:int = 0; i < board.Width; i++) {
					if (board.b[i][j] == null) {
						completeLines.pop();
						break;
					}
				}
			}
			
			if (completeLines.length > 0) {
				
				switch (completeLines.length) {
					case 1:
						score += 100 * level;
						break;
					case 2:
						score += 300 * level;
						break;
					case 3:
						score += 500 * level;
						break;
					case 4:
						score += 800 * level;
						break;
				}
				
				
				
				lines += completeLines.length;
				goal -= completeLines.length;
				updateText();
				
				if (goal <= 0)
					levelUp();
				else if (!sfxMuted)
					pointSound.play();
				
				for (var k:int = 0; k < board.Width; k++)
					for (var l:int = 0; l < completeLines.length; l++)
						board.b[k][completeLines[l]] = null;
				
				drawBoard();
				
				gravTimer.stop();
				
				var waitTimer:Timer;
				waitTimer = new Timer(300, 1);
				waitTimer.addEventListener(TimerEvent.TIMER, waitEvent);
				waitTimer.start();
				
				function waitEvent(e:TimerEvent):void {
					for (var m:int = 0; m < completeLines.length; m++)
						for (var n:int = 0; n < board.Width; n++)
							for (var o:int = completeLines[m]-1; o >= 0; o--)
								if ( (board.b[n][o] != null && ! board.b[n][o].fallen) ||
									 (board.b[n][o+1] != null && ! board.b[n][o+1].fallen) )
									continue;
								else
									board.b[n][o+1] = board.b[n][o]
								
					drawBoard();
					
					gravTimer.start();
				}
			}
		}
		
		public function drop():void {
			shift(0, getBottom(), currentBlocks);
			getBlocks();
			newTetrimino();
		}
		
		public function getBottom():int {
			
			getBlocks();
			
			var bottom:int = 99;
			
			for (var i:int = 0; i < currentBlocks.length; i++) {
				
				if (board.b[currentBlocks[i][0]][currentBlocks[i][1] + 1] != null &&
					! board.b[currentBlocks[i][0]][currentBlocks[i][1] + 1].fallen)
					continue;
				
				var currentBottom:int = 0;
				
				while (currentBlocks[i][1] + 1 + currentBottom < board.Height &&
					   board.b[currentBlocks[i][0]][currentBlocks[i][1] + 1 + currentBottom] == null) {
					currentBottom++;
				}
				if (currentBottom < bottom)
					bottom = currentBottom;
			}
			
			return bottom;
		}
		
		public function newTetrimino(type:String = ''):void {
			
			held = false;
			
			if (type == '') {
				pieceQueue.push(newPieceType());
				pieceQueue.shift()
				
				getBlocks();
				
				for (var i:int = 0; i < currentBlocks.length; i++)
					board.b[currentBlocks[i][0]][currentBlocks[i][1]].fallen = true;
			} else if (type == 'none') {
				pieceQueue.push(newPieceType());
				pieceQueue.shift()
			} else
				pieceQueue[0] = type;
			
			checkLines();
			
			board.addTetrimino(pieceQueue[0], 0, 2);
			getBlocks();
			
			gravTimer.stop();
			gravTimer.reset();
			gravTimer.start();
			
			currentRot = 0;
			currentPiece = pieceQueue[0];
			
			drawBoard();
		}
		
		public function newPieceType():String {
			
			var nextPiece:int = Math.random() * 7;
			
			switch (nextPiece) {
				case 0:
					return 'I'
					break;
				case 1:
					return 'O'
					break;
				case 2:
					return 'T'
					break;
				case 3:
					return 'S'
					break;
				case 4:
					return 'Z'
					break;
				case 5:
					return 'J'
					break;
				case 6:
					return 'L'
					break;
			}
			return '';
		}
		
		public function holdPiece():void {
			
			if (held)
				return;
			
			var temp:String;
			temp = hold;
			hold = currentPiece;
			currentPiece = temp;
			
			pieceHold.gotoAndStop(hold);
			
			getBlocks();
			
			for (var i:int = 0; i < currentBlocks.length; i++)
				board.b[currentBlocks[i][0]][currentBlocks[i][1]] = null;
			
			newTetrimino(currentPiece);
			
		}
		
		public function levelUp():void {
			
			if (!sfxMuted)
				levelUpSound.play();
			
			level++;
			goal += level * 5;
			updateText();
			
			var delays:Array = [1000, 700, 500, 300, 200, 150, 100, 90, 80, 70];
			
			if (DELAY > 70) {
				DELAY = delays[level - 1];
				gravTimer.delay = DELAY;
			}
			
		}
		
		public function updateText():void {
			
			levelText.text = String(level);
			scoreText.text = String(score);
			lineText.text = String(lines);
			goalText.text = String(goal);
			
		}
		
		public function drawBoard():void {
			
			graphics.clear();
			
			for (var i:int = 0; i < board.Width; i++) {
				for (var j:int = 2; j < board.Height; j++) {
					
					if (board.b[i][j] == null) {
						
						boardVisual[i][j-2].gotoAndStop('none');
						
						getBlocks();
						var bottom:int = getBottom();
						
						for (var a:int = 0; a < currentBlocks.length; a++)
							if (currentBlocks[a][0] == i && currentBlocks[a][1] + bottom == j)
								boardVisual[i][j-2].gotoAndStop('shadow');
						
						
					} else {
						
						 boardVisual[i][j-2].gotoAndStop(board.b[i][j].type);
						
					}
				}
			}
			
			pieceOne.gotoAndStop(pieceQueue[1]);
			pieceTwo.gotoAndStop(pieceQueue[2]);
			pieceThree.gotoAndStop(pieceQueue[3]);
			
		}
		
	}
	
}
