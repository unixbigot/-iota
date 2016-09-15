# Manfred - a rapid framework for Internet of Things build on the NodeMCU platform

Manfred exists to provide a common platform for IoT devices that brings the
three most important characteristics

   * Interoperability - standard protocols for cooperating with cloud services
   * Security - Confidentiality and Authentication built in
   * Maintainability - ability to manage, control and upgrade devices in the field
   
## Basic Concept

This framework consists of a number of standard files which you must download to the
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
    
## Getting started

   * Install the core files
   * Install a file named "config.json" which defines a JSON object
      * field application_name names the LUA file which will be loaded when the framework is ready
   * Install a file named "credentials.json" with your WiFi and MQTT credentials
   * See the projects in the examples/ subdirectory for more information

## Using MQTT

   * To subscribe, call the function mqtt_register(topic, qos, callback) to
     subscribe to a topic, for which the callback will be invoked
   * To publish, call the function mqtt_publish which is a wrapper around the standard NodeMCU
     publish method
   * If MQTT connection is lost the device will attempt to reconnect
   * If configuration defines heartbeat_topic then the device will reboot if it stops receiving
     messages on that topic.  This covers cases where reconnection has failed - for example
     NodeMCU appears to sometimes lose connectivity after reboot of access point.

## Using slack
   * If you define the configuration item 'slack_webhook_url', then you can use the 'slack' function
     to invoke the slack inbound webhook at that URL.
   * For using outbound hooks from slack, there is a webhook-to-MQTT router implemented in Node-RED
     see examples/traffic/traffic_flow.js and http://nodered.org/


