#library('Gangnam');
#import ('dart:html');
#import ('package:box2d/box2d_browser.dart');
#import ('dart:math', prefix: 'Math');


class Sfx {
  AudioContext audioContext;
  List<Map> soundList;
  int soundFiles;

  Sfx() {
    audioContext = new AudioContext();
    soundList = new List<Map>();
    var soundsToLoad = [
      {"name": "OP", "url": "static/op.mp3"},
      {"name": "GANGNAM", "url": "static/gangnamstyle.mp3"},
    ];
    soundFiles = soundsToLoad.length;

    for (Map sound in soundsToLoad) {
      initSound(sound);
    }
  }

  bool allSoundsLoaded() => (soundFiles == 0);

  void initSound(Map soundMap) {
    HttpRequest req = new HttpRequest();
    req.open('GET', soundMap["url"], true);
    req.responseType = 'arraybuffer';
    req.on.load.add((Event e) {
      audioContext.decodeAudioData(
        req.response,
        (var buffer) {
            // successful decode
            print("...${soundMap["name"]} loaded...");
            soundList.add({"name": soundMap["name"], "buffer": buffer});
            soundFiles--;
        },
        (var error) {
          print("error loading ${soundMap["name"]}");
        }
      );
    });
    req.send();
  }

  void sfx(AudioBuffer buffer) {
    AudioBufferSourceNode source = audioContext.createBufferSource();
    source.connect(audioContext.destination, 0, 0);
    source.buffer = buffer;
    source.start(0);
  }

  void playSound(String sound) {
    for (Map m in soundList) {
      print(m);
      if (m["name"] == sound) {
        sfx(m["buffer"]);
        break;
      }
    }
  }
}


/** The default canvas width and height. */
 const int CANVAS_WIDTH = 2000;
 const int CANVAS_HEIGHT = 600;


 var oppa = new ImageElement("static/opppa.jpg");
 
/** The gravity vector's y value. */
 const num GRAVITY = -10;

/** The timestep and iteration numbers. */
 const num TIME_STEP = 1/10;
 const int VELOCITY_ITERATIONS = 10;
 const int POSITION_ITERATIONS = 10;

/** The drawing canvas. */
 CanvasElement canvas;

/** The canvas rendering context. */
CanvasRenderingContext2D ctx;

/** The transform abstraction layer between the world and drawing canvas. */
IViewportTransform viewport;

/** The debug drawing tool. */
DebugDraw debugDraw;

/** The physics world. */
World world;

/** Frame count for fps */
int frameCount;

/** HTML element used to display the FPS counter */
Element fpsCounter;

/** Microseconds for world step update */
int elapsedUs;

/** HTML element used to display the world step time */
Element worldStepTime;



// For timing the world.step call. It is kept running but reset and polled
// every frame to minimize overhead.
Stopwatch _stopwatch;


abstract class Demo {
  /** All of the bodies in a simulation. */
  List<Body> bodies;
  
  /** Scale of the viewport. */
  static const num _VIEWPORT_SCALE = 10;
  
// TODO(dominich): Make this library-private once optional positional
// parameters are introduced.
num viewportScale;

  var img = new ImageElement('static/land.gif', 2000, 300);

  Demo(String name, [Vector gravity, this.viewportScale = _VIEWPORT_SCALE])
      : bodies = new List<Body>() {
    _stopwatch = new Stopwatch()..start();
    query("#title").innerHTML = name;
    bool doSleep = false;
    if (null == gravity) gravity = new Vector(0, GRAVITY);
    world = new World(gravity, doSleep, new DefaultWorldPool());
  }

  /** Advances the world forward by timestep seconds. */
  void step(num timestamp) {
    _stopwatch.reset();
    world.step(TIME_STEP, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
    elapsedUs = _stopwatch.elapsedInUs();

    // Clear the animation panel and draw new frame.
    ctx.fillStyle = "efffde";
    ctx.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    ctx.fill();
    ctx.drawImage(img, 0, 300, img.width, img.height);
    picture();
    world.drawDebugData();

    window.requestAnimationFrame((num time) { step(time); });
  }

  /**
   * Creates the canvas and readies the demo for animation. Must be called
   * before calling runAnimation.
   */
  void initializeAnimation() {


    // Setup the canvas.
    canvas = new Element.tag('canvas');
    canvas.width = CANVAS_WIDTH;
    canvas.height = CANVAS_HEIGHT;

    document.body.nodes.add(canvas);
    ctx = canvas.getContext("2d");
    ctx.fillStyle = '#efffde';
    ctx.rect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    ctx.fill();
    //ctx.drawImage(img, 0.0, 0.0, img.width, img.height);
    // Create the viewport transform with the center at extents.
    final extents = new Vector(CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2);
    viewport = new CanvasViewportTransform(extents, extents);
    viewport.scale = viewportScale;
    // Create our canvas drawing tool to give to the world.
    debugDraw = new CanvasDraw(viewport, ctx);

    // Have the world draw itself for debugging purposes.
    world.debugDraw = debugDraw;
  }

  abstract void initialize();

  /**
   * Starts running the demo as an animation using an animation scheduler.
   */
  void runAnimation() {
    window.requestAnimationFrame((num time) { step(time); });
    
  }
}


Body fallingBox;
Body ball1;
Body ball2;
Body ball3;

var jumpcount=0;
var lives = 5;
var worlds;
var bods;

IViewportTransform view ;

class Gangnam extends Demo {
  Gangnam() : super("Gangnam Style") { }

  static void main() {
    final style = new Gangnam();
    style.initializeAnimation();
    style.initialize();
    style.runAnimation();
    
  }

  void initialize() {
    
    
    
    Body ground;
    worlds=world;
    bods = bodies;
    view = viewport;
    {
      PolygonShape sd = new PolygonShape();
      sd.setAsBox(100.0, 0.01);

      BodyDef bd = new BodyDef();
      bd.position.setCoords(0, -27.0);
      assert(world != null);
      ground = world.createBody(bd);
      bodies.add(ground);
      ground.createFixtureFromShape(sd);

      sd.setAsBoxWithCenterAndAngle(0.01, 50.0, new Vector(-100.0, 0.0), 0.0);
      ground.createFixtureFromShape(sd);
      sd.setAsBoxWithCenterAndAngle(0.01,50.0,new Vector(93.0,0.0), 0.0);
      ground.createFixtureFromShape(sd);
      

    }

    ConstantVolumeJointDef cvjd = new ConstantVolumeJointDef();

    num cx = 0.0;
    num cy = 10.0;
    int nBodies = 20;
    for (int i = 0; i < nBodies; ++i) {
      num angle = MathBox.translateAndScale(i, 0, nBodies, 0, Math.PI * 2);
      BodyDef bd = new BodyDef();
      bd.fixedRotation = true;


      Body body = world.createBody(bd);
      bodies.add(body);


      cvjd.addBody(body);


    }

    cvjd.frequencyHz = 10.0;
    cvjd.dampingRatio = 1.0;
    world.createJoint(cvjd);
    
    
    BodyDef bd2 = new BodyDef();
    bd2.type = BodyType.DYNAMIC;
    PolygonShape psd = new PolygonShape();
    psd.setAsBoxWithCenterAndAngle(3.0,5,new Vector(cx,cy+15.0),0.0);
    bd2.position = new Vector(cx,cy+15.0);
    fallingBox = world.createBody(bd2);
    bodies.add(fallingBox);
    fallingBox.createFixtureFromShape(psd, 3);

    
    // Create a bouncing balls.
    final bouncingCircle = new CircleShape();
    bouncingCircle.radius = 1.5;
    
    // Create fixture for that ball shape.
    final activeFixtureDef1 = new FixtureDef();
    activeFixtureDef1.density =  0.05;
    activeFixtureDef1.restitution = 1;
    activeFixtureDef1.shape = bouncingCircle;
    final activeBodyDef1 = new BodyDef();
    activeBodyDef1.position = new Vector(14, 17);
    activeBodyDef1.type = BodyType.DYNAMIC;
    activeBodyDef1.bullet = true;
    ball1 = worlds.createBody(activeBodyDef1);
    bodies.add(ball1);
    ball1.createFixture(activeFixtureDef1);
    
    final activeFixtureDef2 = new FixtureDef();
    activeFixtureDef2.density =  0.05;
    activeFixtureDef2.restitution = 1;
    activeFixtureDef2.shape = bouncingCircle;
    final activeBodyDef2 = new BodyDef();
    activeBodyDef2.position = new Vector(24, 17);
    activeBodyDef2.type = BodyType.DYNAMIC;
    activeBodyDef2.bullet = true;
    ball2 = worlds.createBody(activeBodyDef2);
    bodies.add(ball2);
    ball2.createFixture(activeFixtureDef2);
    
    
    final activeFixtureDef3 = new FixtureDef();
    activeFixtureDef3.density =  0.05;
    activeFixtureDef3.restitution = 1;
    activeFixtureDef3.shape = bouncingCircle;
    final activeBodyDef3 = new BodyDef();
    activeBodyDef3.position = new Vector(34, 17);
    activeBodyDef3.type = BodyType.DYNAMIC;
    activeBodyDef3.bullet = true;
    ball3 = worlds.createBody(activeBodyDef3);
    bodies.add(ball3);
    ball3.createFixture(activeFixtureDef3);
  
  }
}


void main() {
  Sfx sfx;
  sfx= new Sfx();
  Gangnam.main();
  BodyDef bd3 = new BodyDef();
  bd3.type = BodyType.DYNAMIC;
  var y=0;
  var temp=0;
  var bullets = new List <Body> ();
  Body bullet;
  Math.Random rand = new Math.Random();
  

  displayLives();

  var force;

  document.on.keyDown.add((KeyboardEvent event){
    
  switch (event.keyIdentifier) {
   case KeyName.LEFT: 
     
     debug();
     
     force = new Vector (-350,0);
     if (fallingBox.linearVelocity.x > -100) {
       fallingBox.applyLinearImpulse(force, fallingBox.worldCenter);
     }
     break;
   case KeyName.UP:
     
     if(jumpcount<4)
     {
      sfx.playSound("OP");
      jumpcount++;
     }
     else
     {
       sfx.playSound("GANGNAM");
       jumpcount=0;
     }
     debug();
     
     force=new Vector (0,2000);
     if(fallingBox.position.y < -4.0) { 
       fallingBox.applyLinearImpulse(force, fallingBox.worldCenter);
     }
     if(fallingBox.position.y > 4.0) {
       lives--;
       displayLives();
     }
     
     break;
     
   case KeyName.RIGHT:
     
     debug();
     
     force=new Vector (350,0);
     if(fallingBox.linearVelocity.x<100) {
       fallingBox.applyLinearImpulse(force, fallingBox.worldCenter);
     }
     break;
  }
 
  });
}


void debug() {

  if(ball1.active && ball1.position.y > 1) {
    worlds.destroyBody(ball1);
    ball1.active = false;
  }
  if(ball2.active && ball2.position.y > 1) {
    worlds.destroyBody(ball2);
    ball2.active = false;
  }
  if(ball3.active && ball3.position.y > 1) {
    worlds.destroyBody(ball3);
    ball3.active = false;
  }
  if(!ball1.active && !ball2.active && !ball3.active) {
    gameWin();
  }
 
}

void picture(){
  //ctx.save();
  //ctx.translate(fallingBox.worldCenter.x+700, fallingBox.worldCenter.y+100);
  //ctx.rotate(fallingBox.angle);
  ctx.drawImage(oppa, (fallingBox.worldCenter.x+97)*10, (fallingBox.worldCenter.y+495),60,100);
  //ctx.restore();
}

void displayLives() {
  query("#title").innerHTML = 'Lives:'.concat(lives.toString());
  if(lives < 1) {
    gameOver();
  }
}

void gameOver() {
  query("body").innerHTML = '<div class="game_over">Game over</div>';
}

void gameWin() {
  query("body").innerHTML = '<div class="game_over">Winner!!!</div>';
}
