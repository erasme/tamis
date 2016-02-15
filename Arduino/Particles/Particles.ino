
float ax = 0;
float ay = 0;
float az = 0;

// pressure sensor
const int APin = 14;
// x-axis of the accelerometer
const int xpin = A3;
// y-axis
const int ypin = A2;
// z-axis (only on 3-axis models)
const int zpin = A1;

void setup(void) {
	//pinMode(APin, INPUT);
	//analogWrite(APin, 0);
	Serial.begin(9600);
}

void loop(void) {
	int val = analogRead(APin);

	ax = analogRead(xpin);
	ay = analogRead(ypin);
	az = analogRead(zpin);

	Serial.print(ax);
	Serial.print(":");
	Serial.print(ay);
	Serial.print(":");
	Serial.print(az);
	Serial.print(":");
	Serial.println(val);

	delay(100);
}




