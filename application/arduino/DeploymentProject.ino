
#if defined(ESP32)
  #include <WiFiMulti.h>
  WiFiMulti wifiMulti;
  #define DEVICE "ESP32"
  //Change Number in Quotations to adjust Zone area
  #define Zone "1"
  /*#elif defined(ESP8266)
  #include <ESP8266WiFiMulti.h>
  ESP8266WiFiMulti wifiMulti;
  #define DEVICE "ESP8266"*/
  #endif

  #include <InfluxDbClient.h>
  #include <InfluxDbCloud.h>
  #include <DHT.h>

//Bluetooth Code
  //#include "BluetoothSerial.h"  

  // WiFi AP SSID
  #define WIFI_SSID  "main" //"1819_Guest" //"Anthony's iPhone" //"UC_Secure" //"iPhone" //"TeneComp"
  // WiFi password
  #define WIFI_PASSWORD "5139191357" //"NULL" //"EKkJ-Txsy-3LNB-NqiN" //"Priv0naut~" //"tzrkh9gzw16ku" //"~!IWantOut!~"
  
  #define INFLUXDB_URL "https://us-east-1-1.aws.cloud2.influxdata.com"
  #define INFLUXDB_TOKEN "04Jp10DtN5eThatcNnnUAxdqnEmCRKPjX0t0RudEcw9GnC5CJo-gEaMO4YxJmZYV-dQstd6_BCvA3lBHWoTL3w=="
  #define INFLUXDB_ORG "11188411442f6b61"
  #define INFLUXDB_BUCKET "Presentation_Day"
  
  // Time zone info
  #define TZ_INFO "UTC-5"
  
#include <DHT.h>;
#define LIGHTSENSORPIN 32
#define RAINSENSORPIN 33
#define FROSTSENSORPIN 34
#define VIN 4095
#define SOILPIN 35
#define DHTPIN 26     // what pin we're connected to
#define DHTTYPE DHT22   // DHT 22  (AM2302)
DHT dht(DHTPIN, DHTTYPE); //// Initialize DHT sensor for normal 16mhz Arduino

#define uS_TO_S_FACTOR 1000000  /* Conversion factor for micro seconds to seconds */
#define TIME_TO_SLEEP  3        /* Time ESP32 will go to sleep (in seconds) */

  Point sensor("Site 1");
  InfluxDBClient InfluxClient(INFLUXDB_URL, INFLUXDB_ORG, INFLUXDB_BUCKET, INFLUXDB_TOKEN, InfluxDbCloud2CACert);
 


//Bluetooth Code
//BluetoothSerial SerialBT;


void setup() {
  Serial.begin(9600);

    //Bluetooth Code
    Serial.println("BLE OFF");
    //btStop(); 



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



float square_ratio;

  float reading = analogRead(LIGHTSENSORPIN);
  square_ratio = reading / 1023.0; //Get percent of maximum value (1023)
  square_ratio = pow(square_ratio, 2.0);
  Serial.print("Lux: ");
  Serial.print(square_ratio);
  Serial.print(" ");

  delay(500);



float Precipitation;
float num;
  
  num = analogRead(RAINSENSORPIN);
  Precipitation = (num/4095)*100;
  Serial.print("Rain Fall Sensor:");
  
  Serial.print(Precipitation);
  Serial.print(" ");
  delay(500);


  float h = dht.readHumidity();
  // Read temperature as Celsius (the default)
  float t = dht.readTemperature();
  // Read temperature as Fahrenheit (isFahrenheit = true)
  float f = dht.readTemperature(true);


  // Check if any reads failed and exit early (to try again).
 /* if (isnan(h) || isnan(t) || isnan(f)) {
    Serial.println(F("Failed to read from DHT sensor!"));
    return;
  }*/

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



  float frost_reading_fahrenheit;

  float frost_reading_analog = analogRead(FROSTSENSORPIN);
  float frost_reading = 24900*((VIN / frost_reading_analog) - 1);
  float frost_reading_kelvin = 1 / ((1.129241 * pow(10,-3)) + (2.341077* pow(10, -4) * log(frost_reading)) + (8.775468* pow(10, -8) * pow(log(frost_reading), 3)));
  frost_reading_fahrenheit = (frost_reading_kelvin - 273) * 9/5 + 32;

  Serial.print("Frost Reading Analog: ");
  Serial.println(frost_reading_analog);
  Serial.print("Frost Reading Temp Kelvin: ");
  Serial.println(frost_reading_kelvin);
  Serial.print("Frost Reading Temp Fahrenheit: ");
  Serial.println(frost_reading_fahrenheit);
  delay(1000);


 float math; 
 float val;

  	math = analogRead(35);	// Read the analog value form sensor
    val = 100-((math/4095)*100);
    Serial.println(math);




    sensor.clearFields();

    //sensor.addField("rssi", Wifi.RSSI());
    sensor.addField("Fahrenheit", t);
    sensor.addField("Humidity", h);
    sensor.addField("Lux", square_ratio);
    sensor.addField("Dryness Intensity", Precipitation);
    sensor.addField("Radiation Fahrenheit", frost_reading_fahrenheit );
    sensor.addField("Soil Moisture", val);

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

  esp_sleep_enable_timer_wakeup(TIME_TO_SLEEP * uS_TO_S_FACTOR);
  esp_deep_sleep_start();

}