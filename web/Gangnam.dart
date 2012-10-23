#library('Gangnam');
#import ('dart:html');
#import ('package:box2d/box2d_browser.dart');
#import ('dart:math', prefix: 'Math');
#source('demo.dart');


Body fallingBox;
Body ball1;
Body ball2;
Body ball3;

var lives = 5;
var worlds;
var bods;
IViewportTransform view ;

class Gangnam extends Demo {
  Gangnam() : super("Gangnam Style") { }

  static void main() {
    final style = new Gangnam();
    style.initialize();
    style.initializeAnimation();
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
      sd.setAsBoxWithCenterAndAngle(0.01,50.0,new Vector(100.0,0.0), 0.0);
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
    psd.setAsBoxWithCenterAndAngle(3.0,1.5,new Vector(cx,cy+15.0),0.95);
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
  var jumpcount;
  document.on.keyDown.add((KeyboardEvent event){
    
  switch (event.keyIdentifier) {
   case KeyName.LEFT: 
     
     debug();
     
     force = new Vector (-150,0);
     if (fallingBox.linearVelocity.x > -100) {
       fallingBox.applyLinearImpulse(force, fallingBox.worldCenter);
     }
     break;
   case KeyName.UP:
     

     debug();
     
     force=new Vector (0,700);
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
     
     force=new Vector (150,0);
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
