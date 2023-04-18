# User Documentation

## Introduction

## Getting Started

## User Interface
### Site Selection
### Date Range Selection
### Time Interval Selection
### Filter Selection
### Settings

## Frequently Asked Questions


# Developer Documentation

## Introduction
There are multiple steps that need to be taken as a developer to fully deploy this codebase as a working application. The steps below target deployment as a web application, but this same codebase can be built and published as a mobile or desktop application with few changes.

## Environment
This application was developed using Flutter. We recommend using Visual Studio Code as your IDE and installing the recommended Dart and Flutter extensions: https://docs.flutter.dev/get-started

## Building and Debugging
Set [this](../../../application/agrivoltaics_flutter_app/) as the root directory in Visual Studio Code to enable debugging.

In order to build and debug:
* Ensure all Flutter packages are downloaded by running ```flutter pub get```
* Populate all necessary values in [launch.json](../../../application/agrivoltaics_flutter_app/.vscode/launch.json) (see [configuration](#configuration))
* Select your target platform in the bottom right of VSCode:

![platform](./images/select-platform-flutter.png)

* Open the Run and Debug panel, select your desired launch configuration, and Run -> Start Debugging (F5)

![run-and-debug](./images/run-and-debug-flutter.png)

![run-and-debug](./images/run-and-debug-flutter-2.png)

Flutter will automatically build and run the application on the selected platform, outputting any build or runtime errors to the debug console.

## Deployment
### GitHub Actions
### GitHub Variables & Secrets
### Google Cloud Platform

## Configuration

# Sensor Documentation