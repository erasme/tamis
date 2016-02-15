import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import processing.serial.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
 
// The serial port
Serial arduinoPort;
byte[] data = new byte[4096];
int dataCount = 0;
// pressure read from the sensor
float pressure = 0;
float filteredPressure = 0;
// gravity orientation read from the sensor
PVector orientationVector = new PVector(1, 0, 0);
// initial gravity orientation from the measured resting values
PVector initialVector = new PVector(0.9686334,-0.24481943,-0.042577293);
// delta orientation to correct the badly integrated gravity sensor
PVector deltaVector = new PVector(0, 0, 0);
// the object that handle the particles to display
ParticleSystem ps;

Minim minim;
AudioPlayer player;
AudioOutput out;
Oscil wave;
Oscil wave2;
Oscil wave3;
Oscil wave4;
Oscil mod;
Oscil mod2;

void setup() {
	//size(800, 600, OPENGL);
	size(displayWidth, displayHeight, OPENGL);

	// tune to improve performance
	hint(DISABLE_DEPTH_MASK);
	noSmooth();

	ps = new ParticleSystem();

	deltaVector = new PVector(1, 0, 0);
	deltaVector.sub(initialVector);

	arduinoPort = new Serial(this, "/dev/ttyACM0", 9600);
	arduinoPort.clear();

	minim = new Minim(this);
	out = minim.getLineOut(Minim.MONO, 2048);

	wave = new Oscil(440, 1f, Waves.SINE);
	wave2 = new Oscil(640, 1f, Waves.SINE);
	wave4 = new Oscil(44, 1f, Waves.SQUARE);
	wave3 = new Oscil(160, 1f, Waves.SINE);

	mod = new Oscil(2, 0.3f, Waves.SINE);
	mod.patch(wave.amplitude);
	mod.patch(wave2.amplitude);
	mod.patch(wave4.amplitude);
	mod2 = new Oscil(2, 0.1f, Waves.SINE);
	mod2.patch(wave3.amplitude);

	wave.patch(out);
	wave2.patch(out);
	wave3.patch(out);
	wave4.patch(out);

//	player = minim.loadFile("11026.mp3");
//	player.loop();

	noCursor();
}

void draw () {
	// handle data from the Arduino
	while (arduinoPort.available() > 0) {
		int inByte = arduinoPort.read();
		if(inByte == '\n') {
  println("something to read");
			try {
				arduinoData(new String(data, 0, dataCount));
			}
			catch(Exception e) {}
			dataCount = 0;
		}
		else if(inByte != -1) {
			data[dataCount++] = (byte)inByte;
			if(dataCount >= data.length) {
				dataCount = 0;
			}
		}
	}

//	player.setGain(pressure * 30);

	filteredPressure = filteredPressure * 0.95 + pressure * 0.05;
	mod.setAmplitude(filteredPressure * 0.4);
	mod.setFrequency(2 + filteredPressure * 2);

	// clear the background to black
	background(0);

	// generate a number of new particles that depends on the pressure
	ps.generate(int(pressure * 100), new PVector(width / 2, height / 2));
	// update the position of the flow of particles depending on the gravity vector
	ps.update(orientationVector);
	// display all our particules
	ps.display();

	//println("Frame rate: " + int(frameRate));
}

void arduinoData (String str) {

	String[] valueList = split(str, ':');

	if(valueList.length == 4) {
		float x = Float.parseFloat(valueList[0]);
		float y = Float.parseFloat(valueList[1]);
		float z = Float.parseFloat(valueList[2]);
		pressure = Float.parseFloat(valueList[3]);

println("Pressure"+pressure);
		
		// the accelerometer return values around the 512 values (for negative and positive orientation)
		x -= 512;
		y -= 512;
		z -= 512;

		// normalize the values, we just want the gravity orientation
		// we dont care about the "movement"
		float norme = sqrt(x * x + y * y + z * z);
		x /= norme;
		y /= norme;
		z /= norme;

		// correct the values measured with the integrated sensor position
		orientationVector = new PVector(x, y, z);
		orientationVector.add(deltaVector);

		//println("v: ("+x+","+y+","+z+")");

		// normalize the pressure value around 50 to 180 range
		pressure = max(0, min(1, (pressure - 50.0) / (180.0 - 50.0)));
		pressure = 1 - pressure;
	}
}