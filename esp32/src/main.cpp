#include <Arduino.h>
#include <iostream>
#include <string.h>
#include <math.h>

#include <wifi_connector.h>
#include <aws_iot.h>
#include "SPI.h"
#include "wifi_credentials.h"
#include "aws_credentials.h"
#include "coordinate.h"
#include "straight.h"

#include <Adafruit_ADS1X15.h>

#define ADS_I2C_ADDRBAT 0x48
#define ADS_I2C_ADDRSHUNT 0x4a
#define RELAISPIN 27

const float R1 = 33000;
const float R2 = 100000;
const float outputThresholdVoltageMillis = 0.2;
const float maxBatteryCapacity = 9435.0;

int batteryVoltageCounter = 0;
float batteryCapacity = 0;

AwsIot awsIot = AwsIot(aws_cert_ca, aws_cert_crt, aws_cert_private, aws_iot_endpoint, device_name, aws_max_reconnect_tries);
WifiConnector wifiConnector = WifiConnector(ssid, password);
Adafruit_ADS1115 adsshunt;
Adafruit_ADS1115 adsbattery;

void setupConnections()
{
  wifiConnector.connect();
  if (wifiConnector.isConnected())
  {
    awsIot.connect();
  }

  while (!adsshunt.begin(ADS_I2C_ADDRSHUNT))
  {
    Serial.println("Failed to initialize ADS.");
  }
  adsshunt.setGain(GAIN_EIGHT);

  while (!adsbattery.begin(ADS_I2C_ADDRBAT))
  {
    Serial.println("Failed to initialize ADS.");
  }
  adsbattery.setGain(GAIN_TWOTHIRDS);
}

float calculate_adc_voltage_gain_eight(int adc_value)
{
  return fabs(adc_value * 0.015625);
}

float calculate_adc_voltage_gain_two_thirds(int adc_value)
{
  return fabs((adc_value * 0.1875) / 1000);
}

float readInVoltage()
{
  int16_t adc_value = adsshunt.readADC_Differential_0_1();
  return calculate_adc_voltage_gain_eight(adc_value);
}

float readOutVoltage()
{
  int16_t adc_value = adsshunt.readADC_Differential_2_3();
  return calculate_adc_voltage_gain_eight(adc_value);
}

float readBatteryVoltage()
{
  int16_t adc_value = adsbattery.readADC_Differential_0_1();
  double resistorVoltage = calculate_adc_voltage_gain_two_thirds(adc_value);
  return (resistorVoltage * (R1 + R2)) / R2;
}

void setRelaisPins(bool high)
{
  if (high)
  {
    digitalWrite(RELAISPIN, HIGH);
  }
  else
  {
    digitalWrite(RELAISPIN, LOW);
  }
}

void publishMessageToAws(float powerIn, float powerOut, float batteryCapacity)
{
  StaticJsonDocument<512> json;
  JsonObject stateObj = json.createNestedObject("state");
  JsonObject reportedObj = stateObj.createNestedObject("reported");
  JsonObject generated = reportedObj.createNestedObject("generated");

  generated["powerIn"] = powerIn;
  generated["powerOut"] = powerOut;
  generated["batteryCapacity"] = batteryCapacity;

  char jsonBuffer[512];
  serializeJson(json, jsonBuffer);

  string published = awsIot.publish(json, aws_iot_topic);
}

float calculatePowermW(float batteryVoltage, float shuntVoltage)
{
  return (shuntVoltage / 0.1) * batteryVoltage;
}

float calculateCapacity(double voltage)
{

  if (voltage >= 4.2)
    return 100.0;
  if (voltage <= 3.00)
    return 0.0;

  Coordinate coordinates[12] = {Coordinate(0, 3.00), Coordinate(5, 3.45), Coordinate(10, 3.68), Coordinate(20, 3.74),
                                Coordinate(30, 3.77), Coordinate(40, 3.79), Coordinate(50, 3.82), Coordinate(60, 3.87), Coordinate(70, 3.92),
                                Coordinate(80, 3.98), Coordinate(90, 4.06), Coordinate(100, 4.20)};

  int i = 0;
  while (voltage > coordinates[i].y)
  {
    i++;
  }

  Straight straight = Straight(coordinates[i - 1], coordinates[i]);

  return ((voltage - straight.b) / straight.m);
}

void measureBatteryCapacityOpenCircuit()
{
  setRelaisPins(true);
  delay(100);
  float batteryOpenCircuitVoltage = readBatteryVoltage();
  batteryCapacity = calculateCapacity(batteryOpenCircuitVoltage);
  setRelaisPins(false);
}

void setup()
{
  Serial.begin(9600);
  pinMode(RELAISPIN, OUTPUT);
  setRelaisPins(false);
  setupConnections();
  measureBatteryCapacityOpenCircuit();
}

void loop()
{

  float inVoltage = readInVoltage();
  float outVoltage = readOutVoltage();
  float batteryVoltage = readBatteryVoltage();

  float powerIn = calculatePowermW(batteryVoltage, inVoltage);
  float powerOut = calculatePowermW(batteryVoltage, outVoltage);
  float capacityDiff = (((powerIn - powerOut) * (1 / 3600.0)) / maxBatteryCapacity) * 100;

  batteryCapacity += capacityDiff;

  if (outVoltage < outputThresholdVoltageMillis && batteryVoltageCounter == 10)
  {
    measureBatteryCapacityOpenCircuit();
  }

  publishMessageToAws(powerIn, powerOut, batteryCapacity);

  batteryVoltageCounter++;
  if (batteryVoltageCounter > 10)
    batteryVoltageCounter = 0;

  delay(1000);
}