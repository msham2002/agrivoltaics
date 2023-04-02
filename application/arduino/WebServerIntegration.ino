
#if defined(ESP32)
  #include <WiFiMulti.h>
  WiFiMulti wifiMulti;
  #define DEVICE "ESP32"
  //Change Number in Quotations to adjust Zone area
  #define Zone "1"
  #elif defined(ESP8266)
  #include <ESP8266WiFiMulti.h>
  ESP8266WiFiMulti wifiMulti;
  #define DEVICE "ESP8266"
  #endif

  #include <InfluxDbClient.h>
  #include <InfluxDbCloud.h>
  #include <DHT.h>

  // WiFi AP SSID
  #define WIFI_SSID  "TeneComp" //"1819_Guest" //"Anthony's iPhone" //"UC_Secure" //"iPhone" //"TeneComp"
  // WiFi password
  #define WIFI_PASSWORD "~!IWantOut!~" //"NULL" //"EKkJ-Txsy-3LNB-NqiN" //"Priv0naut~" //"tzrkh9gzw16ku" //"~!IWantOut!~"
  
 

  #define INFLUXDB_URL "https://us-east-1-1.aws.cloud2.influxdata.com"
  #define INFLUXDB_TOKEN "jO3-s9kOJEPzRv80hkOs0d4rAGbB_XMfTXCaqJmHAEEaFJ0ilyJ4qNLifjNwfJnBgMpWep3S_xC1QfjTIyhFkw=="
  #define INFLUXDB_ORG "11188411442f6b61"
  #define INFLUXDB_BUCKET "Vitisvoltaics"
  
  // Time zone info
  #define TZ_INFO "UTC-5"
  

#include <WiFi.h>
#include <DHT.h>;
#define LIGHTSENSORPIN 32
#define RAINSENSORPIN 33
#define DHTPIN 26     // what pin we're connected to
#define DHTTYPE DHT22   // DHT 22  (AM2302)
DHT dht(DHTPIN, DHTTYPE); //// Initialize DHT sensor for normal 16mhz Arduino

  // Declare Data point
  //Point sensor("wifi_status");
  //Change Number in Quotations to adjust upload to site area
  Point sensor("Site 2");
  // Declare InfluxDB client instance with preconfigured InfluxCloud certificate
  InfluxDBClient InfluxClient(INFLUXDB_URL, INFLUXDB_ORG, INFLUXDB_BUCKET, INFLUXDB_TOKEN, InfluxDbCloud2CACert);
 

// Replace with your network credentials

// Set web server port number to 80
WiFiServer server(80);

// Variable to store the HTTP request
String header;

// Auxiliar variables to store the current output state
String output26State = "off";
String output32State = "off";
String output33State = "off";

// Assign output variables to GPIO pins
const int output26 = 26;
const int output32 = 32;
const int output33 = 33;

// Current time
unsigned long currentTime = millis();
// Previous time
unsigned long previousTime = 0; 
// Define timeout time in milliseconds (example: 2000ms = 2s)
const long timeoutTime = 2000;

void setup() {
  Serial.begin(9600);
  // Initialize the output variables as outputs
  pinMode(output26, INPUT);
  pinMode(output32, OUTPUT);
  pinMode(output33, OUTPUT);
  // Set outputs to LOW
  digitalWrite(output26, LOW);
  digitalWrite(output32, LOW);
  digitalWrite(output33, LOW);

  dht.begin();
  Serial.println(F("DHTxx test!"));

  // Connect to Wi-Fi network with SSID and password

  // Print local IP address and start web server

    // Setup wifi
    WiFi.mode(WIFI_STA);
    wifiMulti.addAP(WIFI_SSID, WIFI_PASSWORD); //WIFI_PASSWORD MUST BE ADDED, DON'T FORGET. IF THERE IS ON WIFI_PASSWORD GET RID OF THE VALUE AND WRITE NULL FOR THE PASSWORD INITIALIZATION
    Serial.print("Connecting to wifi");
    while (wifiMulti.run() != WL_CONNECTED) {
      Serial.print(".");
      delay(100);
    }

  // Print local IP address and start web server
  Serial.println("");
  Serial.println("WiFi connected.");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
  server.begin();
  Serial.println();
  
    // Accurate time is necessary for certificate validation and writing in batches
    // We use the NTP servers in your area as provided by: https://www.pool.ntp.org/zone/
    // Syncing progress and the time will be printed to Serial.
    timeSync(TZ_INFO, "pool.ntp.org", "time.nis.gov");

    // Check server connection
    if (InfluxClient.validateConnection()) {
      Serial.print("Connected to InfluxDB: ");
      Serial.println(InfluxClient.getServerUrl());
    } else {
      Serial.print("InfluxDB connection failed: ");
      Serial.println(InfluxClient.getLastErrorMessage());
    }
    // ... code in setup() from Initialize Client
   
    // Add tags to the data point
    //sensor.addTag("device", DEVICE);
    //sensor.addTag("SSID", WiFi.SSID());
    sensor.addTag("Zone", Zone);


}

void loop(){

  WiFiClient client = server.available();   // Listen for incoming clients
    delay(1000);
  if (client) {                             // If a new client connects,
    currentTime = millis();
    previousTime = currentTime;
    Serial.println("New Client.");          // print a message out in the serial port
    String currentLine = "";                // make a String to hold incoming data from the client
    while (client.connected() && currentTime - previousTime <= timeoutTime) {  // loop while the client's connected
      currentTime = millis();
      if (client.available()) {             // if there's bytes to read from the client,
        char c = client.read();             // read a byte, then
        Serial.write(c);                    // print it out the serial monitor
        header += c;
        if (c == '\n') {                    // if the byte is a newline character
          // if the current line is blank, you got two newline characters in a row.
          // that's the end of the client HTTP request, so send a response:
          if (currentLine.length() == 0) {
            // HTTP headers always start with a response code (e.g. HTTP/1.1 200 OK)
            // and a content-type so the client knows what's coming, then a blank line:
            client.println("HTTP/1.1 200 OK");
            client.println("Content-type:text/html");
            client.println("Connection: close");
            client.println();
            
            // turns the GPIOs on and off
            if (header.indexOf("GET /26/on") >= 0) {
              Serial.println("GPIO 26 on");
              output26State = "on";
            } else if (header.indexOf("GET /26/off") >= 0) {
              Serial.println("GPIO 26 off");
              output26State = "off";    

            } else if (header.indexOf("GET /32/on") >= 0) {
              Serial.println("GPIO 32 on");
              output32State = "on";            
            } else if (header.indexOf("GET /32/off") >= 0) {
              Serial.println("GPIO 32 off");
              output32State = "off";

    
            } else if (header.indexOf("GET /33/off") >= 0) {
              Serial.println("GPIO 33 off");
              output33State = "off";
            } else if (header.indexOf("GET /33/on") >= 0) {
              Serial.println("GPIO 33 on");
              output33State = "on";
            }
            
            // Display the HTML web page
            client.println("<!DOCTYPE html><html>");
            client.println("<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
            client.println("<link rel=\"icon\" href=\"data:,\">");
            // CSS to style the on/off buttons 
            // Feel free to change the background-color and font-size attributes to fit your preferences
            client.println("<style>html { font-family: Helvetica; display: inline-block; margin: 0px auto; text-align: center;}");
            client.println(".button { background-color: #4CAF50; border: none; color: white; padding: 16px 40px;");
            client.println("text-decoration: none; font-size: 30px; margin: 2px; cursor: pointer;}");
            client.println(".button2 {background-color: #555555;}</style></head>");
            
            // Web Page Heading
            client.println("<body><h1>ESP32 Web Server Zone 1 Site 1</h1>");
            
            // Display current state, and ON/OFF buttons for GPIO 26  
            client.println("<p>GPIO 26 - State " + output26State + "</p>");
            // If the output26State is off, it displays the ON button       
            if (output26State=="off") {
              client.println("<p><a href=\"/26/on\"><button class=\"button\">ON</button></a></p>");
            } else {
              client.println("<p><a href=\"/26/off\"><button class=\"button button2\">OFF</button></a></p>");
            } 
               
            // Display current state, and ON/OFF buttons for GPIO 27  
            client.println("<p>GPIO 32 - State " + output32State + "</p>");
            // If the output27State is off, it displays the ON button       
            if (output32State=="off") {
              client.println("<p><a href=\"/32/on\"><button class=\"button\">ON</button></a></p>");
            } else {
              client.println("<p><a href=\"/32/off\"><button class=\"button button2\">OFF</button></a></p>");
            }

            client.println("<p>GPIO 33 - State " + output33State + "</p>");
            // If the output26State is off, it displays the ON button       
            if (output33State=="off") {
              client.println("<p><a href=\"/33/on\"><button class=\"button\">ON</button></a></p>");
            } else {
              client.println("<p><a href=\"/33/off\"><button class=\"button button2\">OFF</button></a></p>");
            } 
            client.println("</body></html>");
            

            // The HTTP response ends with another blank line
            client.println();
            // Break out of the while loop
            break;
          } else { // if you got a newline, then clear currentLine
            currentLine = "";
          }
        } else if (c != '\r') {  // if you got anything else but a carriage return character,
          currentLine += c;      // add it to the end of the currentLine
        }
      }
    }
    // Clear the header variable
    header = "";
    // Close the connection
    client.stop();
    Serial.println("Client disconnected.");
    Serial.println("");
  }

float square_ratio;

if(output32State == "off"){
  float reading = analogRead(LIGHTSENSORPIN);
  square_ratio = reading / 1023.0; //Get percent of maximum value (1023)
  square_ratio = pow(square_ratio, 2.0);
  Serial.print("Lux: ");
  Serial.print(square_ratio);
  Serial.print(" ");

  delay(500);
}
else{
  square_ratio = 0;
}


int Precipitation;

if(output33State == "off"){
  Precipitation = analogRead(RAINSENSORPIN);
  Serial.print("Rain Fall Sensor:");
  Serial.print(Precipitation);
  Serial.print(" ");
  delay(500);
}
else{
  Precipitation = 0;
}

  float h = dht.readHumidity();
  // Read temperature as Celsius (the default)
  float t = dht.readTemperature();
  // Read temperature as Fahrenheit (isFahrenheit = true)
  float f = dht.readTemperature(true);

if(output26State == "off"){

  // Check if any reads failed and exit early (to try again).
  if (isnan(h) || isnan(t) || isnan(f)) {
    Serial.println(F("Failed to read from DHT sensor!"));
    return;
  } 

  // Compute heat index in Fahrenheit (the default)
  float hif = dht.computeHeatIndex(f, h);
  // Compute heat index in Celsius (isFahreheit = false)
  float hic = dht.computeHeatIndex(t, h, false);

  Serial.print(F("Humidity: "));
  Serial.print(h);
  Serial.print(F("%  Temperature: "));
  Serial.print(t);
  Serial.print(F("°C "));
  Serial.print(f);
  Serial.print(F("°F  Heat index: "));
  Serial.print(hic);
  Serial.print(F("°C "));
  Serial.print(hif);
  Serial.println(F("°F"));
}
  else{
    h = 0;
    t = 0;
    f = 0;
  }

    sensor.clearFields();

    //sensor.addField("rssi", Wifi.RSSI());
    sensor.addField("Farenheit", t);
    sensor.addField("Humidity", h);
    sensor.addField("Lux", square_ratio);
    sensor.addField("Rain Intensity", Precipitation);

    // Print what are we exactly writing
    Serial.print("Writing: ");
    Serial.println(sensor.toLineProtocol());

    // Check WiFi connection and reconnect if needed
    if (wifiMulti.run() != WL_CONNECTED) {
      Serial.println("Wifi connection lost");
    }
   

    // Write point
    if (!InfluxClient.writePoint(sensor)) {
      Serial.print("InfluxDB write failed: ");
      Serial.println(InfluxClient.getLastErrorMessage());
    }
    InfluxClient.writePoint(sensor);

  
    Serial.println("Waiting 1 second");
    delay(1000);

}