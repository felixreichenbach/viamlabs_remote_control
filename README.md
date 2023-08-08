# Viamlabs - Remote Control

A demo application using the Viam Flutter SDK to connect to a robot and provide remote control capabilities such as moving the base while monitoring the environment through the camera.

![Flutter App Screenshot](./media/viamlabs-remote-control.jpeg)

This is an example with the intention to get an idea of how to use the SDK and therefore kept simple. This is no production ready code!

## Prerequisites

A robot using the Viam RDK with at least a base and a camera. The easiest way to get started is probably the [Viam Rover](https://www.viam.com/resources/rover) but any other should work as well.


## Getting Started

If you are new to Flutter, I recommend to run through this [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/install) excersise which gives a great intro and hands on exercises.

To be able to connect to your robot, you will need to provide the robot address and location secret to the app (either copy paste or use a .env. file). You can find information regarding retrieving the secret in the [Viam documentation](https://docs.viam.com/manage/fleet/robots/#code-sample)

The usage of the app is self explanatory.

Enjoy and please don't hesitate to reach out if there are questions or feedback to improve the app!
