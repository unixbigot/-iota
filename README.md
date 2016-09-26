# Manfred - a simple framework for Internet of Things built on the NodeMCU platform

Manfred exists to provide a common platform for IoT devices that brings the
three most important characteristics missing from many IoT devices.

   * Interoperability - standard protocols for cooperating with cloud services
   * Security - Confidentiality and Authentication built in
   * Maintainability - ability to manage, control and upgrade devices in the field

## Basic Concept

NodeMCU is a Lua programming environment for the ESP8266 family of WiFi-enabled microcontrollers.

This framework consists of a number of standard files which you must upload to the
NodeMCU device.   A configuration file nominates the user application code to which control
is passed once the framework is ready.

The framework provides

* WiFi setup, network selection and event handling
* Basic I/O support for the built-in LED and Button on the NodeMCU
* MQTT client with a simple multiple-topic dispatcher
* Slack webhook client
* Support for "Neopixel" addressable-LEDs using the WS8212 chip
* Support for pushing configuration to devices over MQTT (forthcoming)
* Support for upgrading the framework and the application over MQTT (forthcoming)
* Support for serverless computing with AWS IoT platform (forthcoming)

## Getting started

* Upload all the core Lua files to your NodeMCU
* Upload a file named "config.json" which defines a JSON object defining configuration
  * the field `application_name` names the LUA file which will be loaded when the framework is ready
* Upload a file named "credentials.json" with your WiFi and MQTT credentials
* Upload your application code
  * If your `application_name` is "foo", then name your application code "foo.lua"
  * See the sample applications in the examples/ subdirectory for more information


## Advice on using Manfred

   * The design presumes your devices are probably on a firewalled WiFi network, and that they can connect out to the internet, but inbound connections are no permitted
   * If you want to deliver information to your devices, you are expected to use an MQTT message broker in the cloud.  You can host one on Amazon EC2, or use the free test server from mosquitto.org

## Using MQTT

MQTT is a lightweight publish-subscribe messaging system.

   * To subscribe to a topic, call the function mqtt_register(topic, qos, callback) to
     subscribe to a topic, for which the callback will be invoked
   * To publish, call the function mqtt_publish which is a wrapper around the standard NodeMCU
     publish method
   * If MQTT connection is lost the device will attempt to reconnect
   * If configuration defines heartbeat_topic then the device will reboot if it stops receiving
     messages on that topic.  This covers cases where reconnection has failed - for example
     NodeMCU appears to sometimes lose connectivity after reboot of access point.

## Using Slack

   * If you define the configuration item 'slack_webhook_url', then you can use the 'slack' function
     to invoke the slack inbound webhook at that URL.
   * For using outbound hooks from slack, there is a webhook-to-MQTT router implemented in Node-RED
     see examples/traffic/traffic_flow.js and http://nodered.org/
