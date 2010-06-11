﻿package info.osmatrix.rmengine.components
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.special.Letter3DMaterial;
	import org.papervision3d.materials.special.LineMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.typography.Text3D;
	import org.papervision3d.typography.fonts.HelveticaBold;
	import org.papervision3d.view.Viewport3D;

	[SWF(width='800', height='600', backgroundColor='0x868686', frameRate='12')]
	public class Chart3D extends Sprite
	{
		private var confXML:XML;	// 坐标与摄像头配置
		
		private var d3oCord:DisplayObject3D = new DisplayObject3D();	// 环境对象容器
		private var d3oCube:DisplayObject3D = new DisplayObject3D();	// 立方体容器
		private var d3oAll:DisplayObject3D;	// 立方体容器
		
		private var debug:Boolean = false;
		private var msgP:TextField;
		
		// PV3D engine 运行时必须实例化的对象
		private var renderer:BasicRenderEngine;
		private var scene:Scene3D;
		private var viewport:Viewport3D;
		public var camera:Camera3D;

		public function Chart3D()
		{
			// 2D
			createMsgPanel();
			
			// 2.Initialise Papervision3D
			init3D();

			// 3.Create the 3D objects
			createScene();

			// Listen to mouse up and down events on the stage
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

		}
	
		private function init3D():void
		{

			// create viewport
			viewport = new Viewport3D(800, 600, true, false);
			//viewport.interactive = true;
			//viewport.x=stage.stageWidth/2-viewport.viewportWidth/2;
			//viewport.y=stage.stageHeight/2-viewport.viewportHeight/2;
			viewport.autoScaleToStage = false;
			viewport.autoCulling = true;
			viewport.autoClipping = true;

			addChild(viewport);

			// Create new camera with fov of 60 degrees (= default value)
			camera = new Camera3D();
			//camera = new DebugCamera3D(viewport);
			//camera.target = null;	//
			camera.target = DisplayObject3D.ZERO;	//Camera 类型：target/free
			
			// initialise the camera position (default = [0, 0, -1000])
			//camera.ortho = true;
			//camera.x = -100;
			//camera.y = -5000;
			camera.z = -300000;
			camera.orbit(60, -60);
			//camera.zoom = 0.8;
			camera.focus = 50;	// iso
			
			// Create a new scene where our 3D objects will be displayed
			scene = new Scene3D();

			// Create new renderer
			renderer = new BasicRenderEngine;

		}
		
		private function createScene():void
		{
			d3oAll = new DisplayObject3D();
			d3oAll.addChild(d3oCord);
			d3oAll.addChild(d3oCube);
			scene.addChild(d3oAll);
			
		}
		
		public function setup3D(w:Number,h:Number,bgcolor:uint,isDebug:Boolean):void
		{
			debug = isDebug;
					
			//
			var sp:Sprite = new Sprite();
			
			sp.graphics.beginFill(bgcolor);
			sp.graphics.drawRect(0, 0, w, h);
			sp.graphics.endFill();
			this.addChildAt(sp,0);
			
			//
			viewport.viewportWidth = w;
			viewport.viewportHeight = h;
			
			msgP.visible = false;
			if(debug)
			{
				// msgP 默认不可见
				msgP.visible = debug;
				
				viewport.graphics.lineStyle(2, 0x0000ff);
				viewport.graphics.drawRect(0, 0, viewport.viewportWidth, viewport.viewportHeight);

				// 为场景注册一个事件监听器，每当场景ENTER_FRAME的时候，ENTER_FRAME的频率就是输出影片时设置的每秒帧数。
				this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			
			
			
		}
		
		/**
		 *	创建3D物件
		 *
		 */
		public function updateScene(conf:XML,data:XML):void
		{
			// 坐标尺：3D文字标注
			createAxisFromXML(conf.axis[0]);
			
			createCubeFromXML(data);
			
			setCameraFromXML(conf.camera[0]);
			
			setPositionFromXML(conf.position[0]);
			
			renderer.renderScene(scene, camera, viewport);						
		}

		public function renderClick():void
		{
			renderer.renderScene(scene, camera, viewport);			
		}
		
		public function createAxisFromXML(axis:XML):void
		{
			var xMax:Number = axis.@xmax;
			var yMax:Number = axis.@ymax;
			var zMax:Number = axis.@zmax;
			
			var fillcolor:Number = axis.@backgroundcolor;

			if(debug)
			{
				// Create a default line material and a Lines3D object (container for Line3D objects)
				var defaultMaterial:LineMaterial = new LineMaterial(0xFFFFFF); // black
				var axes:Lines3D = new Lines3D(defaultMaterial);
				
				// Create a different colour line material for each axis
				var xAxisMaterial:LineMaterial = new LineMaterial(0xFF0000); // FF0000,red
				var yAxisMaterial:LineMaterial = new LineMaterial(0xFFFF00); // FFFF00,yello
				var zAxisMaterial:LineMaterial = new LineMaterial(0x0000FF); // 0000FF,blue
				
				// 创建原点对象
				var origin:Vertex3D = new Vertex3D(0, 0, 0);
				
				// Create a new line for each axis using the different materials and a width of 1.
				var xAxis:Line3D = new Line3D(axes, xAxisMaterial, 1, origin, new Vertex3D(xMax, 0, 0));
				var yAxis:Line3D = new Line3D(axes, yAxisMaterial, 1, origin, new Vertex3D(0, yMax, 0));
				var zAxis:Line3D = new Line3D(axes, zAxisMaterial, 1, origin, new Vertex3D(0, 0, zMax));
				
				// Add lines to the Lines3D container
				axes.addLine(xAxis);
				axes.addLine(yAxis);
				axes.addLine(zAxis);
	
				d3oCord.addChild(axes);
			}
			
			// Z轴
			var zXML:XML = axis..z[0];
			var zCount:int = zXML.@count;
			var zRotation:int = zXML.@rotation;
			var zTitle:String = zXML.@title;
			var zDx:Number 		= zXML.@dx;
			var zDTitle:Number = zXML.@dtitle;
			
			for(var iZ:int=0;iZ<=zCount;iZ++)
			{
				this.createText(zXML.mark[iZ].@text, xMax + zDx, 0, iZ*(zMax/zCount),zRotation);
			}
			
			var pZ:Plane = this.createPlane(fillcolor,200,200,zTitle,new TextFormat(null,"58"));
			pZ.x = xMax +zDx+zDTitle;
			pZ.y = -3500;
			pZ.z = zMax/2;
			pZ.scale = 50;
			pZ.rotationY +=270;
			
			// X轴
			var xXML:XML = axis..x[0];
			var xCount:int = xXML.@count;
			var xRotation:int = xXML.@rotation;
			var xTitle:String = xXML.@title;
			var xDz:Number = xXML.@dz;
			var xDTitle:Number = xXML.@dtitle;
			
			for(var iX:int=0;iX<=xCount;iX++)
			{
				this.createText(xXML.mark[iX].@text, iX*(xMax/xCount), 0, zMax + xDz, xRotation);
			}
			
			var pX:Plane = this.createPlane(fillcolor,200,200,xTitle,new TextFormat(null,"58"));
			pX.x = xMax/2;
			pX.y = 0;
			pX.z = zMax + xDz + xDTitle;
			pX.scale = 50;
			pX.rotationY +=270;
			
			
			//Y轴
			var yXML:XML = axis..y[0];
			var yCount:int = yXML.@count;
			var yRotation:int = yXML.@rotation;
			var yTitle:String = yXML.@title;
			var yDx:Number 		= yXML.@dx;
			var yDTitle:Number = yXML.@dtitle;
			
			for(var iY:int=0;iY<=yCount;iY++)
			{
				this.createText(yXML.mark[iY].@text, xMax + yDx, iY*(yMax/yCount), 0, yRotation);
			}
			
			var pY:Plane = this.createPlane(fillcolor,200,150,yTitle,new TextFormat(null,"58"));
			//pY.x =xMax+yDx+yDTitle;
			pY.x =xMax;
			pY.y = yMax + 50*150;
			pY.z = 0;
			pY.scale = 50;
			pY.rotationY +=270;
			
			// 创建2个平面材质，绘制网格时交替使用
			var materialA:ColorMaterial = new ColorMaterial(0x56526A);
			var materialB:ColorMaterial = new ColorMaterial(0x6A6A86);
			materialA.doubleSided = true;
			materialB.doubleSided = true;
			
			// 在X-Z正象限创建5X4网格            
			var materialRow:ColorMaterial = materialA;
			var materialCol:ColorMaterial = materialA;
			
			
			var widthGrid:Number = xMax/xCount;
			var heightGrid:Number = yMax/yCount;
			var depthGrid:Number = zMax/zCount;
			
			
			// 参数：x轴格数，z轴格数，宽，高，材质
			var material:ColorMaterial;
			
			for (var ixXZ:int = 0; ixXZ < xCount; ixXZ++)		// x轴方向5格
			{
				materialRow = (materialRow == materialA) ? materialB : materialA;
				materialCol = materialRow;
				
				for (var izXZ:int = 0; izXZ < zCount; izXZ++)		// z轴方向4格
				{
					materialCol = (materialCol == materialA) ? materialB : materialA;
					material = materialCol;
					
					var plane:Plane = new Plane(material, widthGrid, depthGrid, 10, 10);
					plane.rotationX -= 90;
					plane.x = widthGrid / 2 + ixXZ * widthGrid;
					plane.z = depthGrid / 2 + izXZ * depthGrid;
					plane.rotationZ -= 180;
					d3oCord.addChild(plane);
				}
			}
			
			// 在X-Y正象限创建5X2网格（10000x9000）
			materialA = new ColorMaterial(0x0000FF);
			materialB = new ColorMaterial(0xFF0000);
			materialA.doubleSided = true;
			materialB.doubleSided = true;

			materialRow = materialA;
			materialCol = materialA;
			
			for (var ixXY:int = 1; ixXY <= xCount; ixXY++)
			{
				materialRow = (materialRow == materialA) ? materialB : materialA;
				materialCol = materialRow;
				
				for (var iyXY:int = 1; iyXY <= yCount; iyXY++)
				{
					materialCol = (materialCol == materialA) ? materialB : materialA;
					material = materialCol;
					
					var pXY:Plane = new Plane(material, widthGrid, heightGrid, 10, 10);
					pXY.rotationY -= 180;
					pXY.x = widthGrid / 2 + (ixXY - 1) * widthGrid;
					pXY.y = heightGrid / 2 + (iyXY - 1) * heightGrid;
					pXY.rotationZ -= 180;
					d3oCord.addChild(pXY);
				}
			}			
		}
		
		public function createCubeFromXML(xml:XML):void
		{
			
			// 参数：宽，深，高，（x,*,z）
			var xZoom:int = xml.cube.@xzoom;
			var yZoom:int = xml.cube.@yzoom;
			var zZoom:int = xml.cube.@zzoom;

			var cw:int = xml.cube.@width;	// 宽
			var cd:int = xml.cube.@depth;	// 深
			
			var xmlList:XMLList = xml.r;
			var materialXMLList:XMLList = xml.cube.material;

			// 正相位立方体材质
			var materialList:MaterialsList = new MaterialsList();
			
//			materialList.addMaterial(new ColorMaterial(Number(xml.cube.material[0].@all)), "all");
//			materialList.addMaterial(new ColorMaterial(0x4795C4,1,true), "top");
//			materialList.addMaterial(new ColorMaterial(0xFF000,1,true), "bottom");
//			materialList.addMaterial(new ColorMaterial(0x448EBA,1,true), "front");
//			materialList.addMaterial(new ColorMaterial(0xFF000,	1,true), "back");
//			materialList.addMaterial(new ColorMaterial(0xFFAE00,1,true), "left");
//			materialList.addMaterial(new ColorMaterial(0x316788,1,true), "right");
			
			for each( var xmlRow:XML in xmlList)
			{
				for each(var mat:XML in materialXMLList)
				{
					var matValue:Number = mat.@value*1;
					var zValue:Number = xmlRow.@z * 1;
					
					if(zValue <= matValue)
					{
						materialList = new MaterialsList();
						//materialList.addMaterial(new ColorMaterial(Number(mat.@all)), "all");
						materialList.addMaterial(new ColorMaterial(Number(mat.@top),	1,false), "top");
						materialList.addMaterial(new ColorMaterial(Number(mat.@bottom),		1,false), "bottom");
						materialList.addMaterial(new ColorMaterial(Number(mat.@front),	1,false), "front");
						materialList.addMaterial(new ColorMaterial(Number(mat.@back),		1,false), "back");
						materialList.addMaterial(new ColorMaterial(Number(mat.@left),	1,false), "left");
						materialList.addMaterial(new ColorMaterial(Number(mat.@right),	1,false), "right");
						break;
					}
					// 超出的用最后一个
				}
				
				var p:Number3D = new Number3D();
				p.x = xmlRow.@x * xZoom;
				p.y = xmlRow.@z * zZoom;
				p.z = xmlRow.@y * yZoom;
				
				if(p.y == 0)
				{
					continue;
				}

				var ch:int;			// 高	
				
				ch = p.y;
				
				var cube1:Cube = new Cube(materialList, cw, cd, ch, 1, 1, 1);
				//cube1.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, handleMouseOverCube);
				//cube1.z = cw/2 + (i-1)*(cw + 30);
				cube1.z = p.x;
				cube1.y = ch / 2;
				cube1.x = p.z;
				//cube1.moveForward(28*i + 50);
				d3oCube.addChild(cube1);				
			}
		}
		
		public function setCameraFromXML(xml:XML):void
		{
			var index:int = xml.@default;
			
			setCamera(
				xml.view[index].point.@x,
				xml.view[index].point.@y,
				xml.view[index].point.@z,
				xml.view[index].rotation.@x,
				xml.view[index].rotation.@y,
				xml.view[index].rotation.@z
			);
		}
		
		private function createText(msg:String, x:Number = 0, y:Number = 0, z:Number = 0, rotationY:int=0):void
		{
			var text:String = msg;
			
			var materialText:Letter3DMaterial = new Letter3DMaterial(0x000000);
			materialText.doubleSided = true;

			//use a built-in font:
			var font3D:HelveticaBold = new HelveticaBold();
			//or use a custom font class generated with the font creation tool
			//font3D = new Courier();
			
			var text3D:Text3D = new Text3D(text, font3D ,materialText);
			
			text3D.align = "right";
			text3D.letterSpacing = -3;
			text3D.lineSpacing = -12;
			
			text3D.x = x;
			text3D.y = y;
			text3D.z = z;
			text3D.localRotationY = rotationY;
			text3D.scale = 20;
			
			//show outline
			text3D.material.lineThickness = 2;
			text3D.material.lineAlpha = 1;
			text3D.material.lineColor = 0xCCCCCC;
			
			d3oCord.addChild(text3D);			
		}
		
		// 外部接口函数
		public function setCamera(x:Number=129904,y:Number=150000,z:Number=-225000,rotX:Number = 30,rotY:Number =-30,rotZ:Number=0):void
		{
			//
			camera.x = x;
			camera.y = y;
			camera.z = z;
			
			camera.rotationX = rotX;
			camera.rotationY = rotY;
			camera.rotationZ = rotZ;
			
			showMsg();
			
		}
		
		public function setXML(xml:XML):void
		{
			createCubeFromXML(xml);
			
		}

		public function setPositionFromXML(xml:XML):void
		{
			d3oAll.rotationY += xml.point[0].@rotationY;
			
			d3oAll.x = xml.point[0].@x;
			d3oAll.y = xml.point[0].@y;
			d3oAll.z = xml.point[0].@z;
		}

		// 功能函数
		private function createMsgPanel():void
		{
			
			// 用于显示状态或调试
			msgP = new TextField();
			msgP.x = 20;
			msgP.y = 20;
			msgP.multiline = true;
			msgP.width = 500;
			
			this.addChild(msgP);
		}
		/**
		 * 实用功能方法：创建文本(Plane+movieMaterial+TextField)
		 *
		 * @param width		文本宽度
		 * @param height	文本高度
		 * @param message	文本
		 * @param format	文本格式
		 * @param alias		？
		 * @param transparent	透明
		 * @param smooth		平滑
		 * @return
		 *
		 */
		private function createPlane(color:uint,width:Number = 100, height:Number = 100, message:String = "default", format:TextFormat = null, alias:String = AntiAliasType.NORMAL, transparent:Boolean = false, smooth:Boolean = false):Plane
		{
			
			var mc:MovieClip = new MovieClip();
			var txt:TextField = new TextField();
			txt.wordWrap = true;
			txt.width = width;
			txt.height = height;
			txt.multiline = true;
			txt.htmlText = message;
			
			txt.autoSize = TextFieldAutoSize.CENTER;
			if (format)
				txt.setTextFormat(format);
			
			txt.antiAliasType = alias;
			
			mc.graphics.beginFill(color);
			mc.graphics.drawRect(0, 0, width, height);
			mc.graphics.endFill();
			
			mc.addChild(txt);
			
			var mat:MovieMaterial = new MovieMaterial(mc, transparent, false, true);
			mat.doubleSided = true;
			mat.smooth = smooth;
			mat.tiled = true;
			
			var p:Plane = new Plane(mat, width, height);
			d3oCord.addChild(p);
			
			return p;
		}
		
		// 摄像机鼠标操控的全局变量
		private var cameraPitch:Number = 60;
		private var cameraYaw:Number = -60;
		
		private var doRotation:Boolean = false;
		private var lastMouseX:int;
		private var lastMouseY:int;		
		// called when mouse down on stage，拖拽按下鼠标时使旋转有效，记下按下时的鼠标位置
		private function onMouseDown(event:MouseEvent):void
		{
			doRotation = true;
			lastMouseX = event.stageX;
			lastMouseY = event.stageY;
		}
		
		// called when mouse up on stage，拖拽释放鼠标时使旋转失效
		private function onMouseUp(event:MouseEvent):void
		{
			doRotation = false;
			
		}
		
		private function onEnterFrame(event:Event):void
		{
			// If the mouse button has been clicked then update the camera position
			if (doRotation)
			{
				
				// convert the change in mouse position into a change in camera angle
				var dPitch:Number = (mouseY - lastMouseY) / 2;
				var dYaw:Number = (mouseX - lastMouseX) / 2;
				
				// update the camera angles
				cameraPitch -= dPitch;
				cameraYaw -= dYaw;
				// limit the pitch of the camera
				if (cameraPitch <= 0)
				{
					cameraPitch = 0.1;
				}
				else if (cameraPitch >= 180)
				{
					cameraPitch = 179.9;
				}
				
				// reset the last mouse position
				lastMouseX = mouseX;
				lastMouseY = mouseY;
				
				// reposition the camera
				camera.orbit(cameraPitch, cameraYaw);
				
				showMsg();
			}
			// Render the 3D scene
			renderer.renderScene(scene, camera, viewport);
			
		}
		
		private function showMsg():void
		{
			msgP.text = "Point:("+Math.round(camera.x)+","+Math.round(camera.y)+","+Math.round(camera.z)+")\n"
				+"RotationX: "+Math.round(camera.rotationX)+"\n"+"RotationY: "+Math.round(camera.rotationY)+"\n"+"RotationZ: "+Math.round(camera.rotationZ)+"\n"
				+"Fov: "+camera.focus+"\n"
				+"Near: "+camera.near+"\n"
				+"Far: "+camera.far+"\n";			
		}
	}
}