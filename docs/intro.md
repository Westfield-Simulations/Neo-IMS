---
sidebar_position: 1
---

# Introduction

:::warning
This documentation is highly work in progress!
:::

## Design
The Neo-IMS (Formerly RP-IMS) is a system designed to handle control and instrumentation systems in an easy to work with but efficient manner.

The Neo-IMS gives different types of devices (gauges, switches, indicators, etc.) functionality while ensuring that all scripts are kept in a centralized location and only a minimum of 2 scripts are required per device type.

Devices defined in the system can both receive input from players and display an output on a device model.

To achieve this, the Neo-IMS is divided into two sections. The **Server Side** and the **Client Side**.

The use of the **Server Side** include:
- Storing Data about the current state of a device (i.e. position of a switch, on/off on an indicator light)
- Recieve and validate state change requests from the client
- Change the current state when suitable and send an update to all clients

The **Server Side** should **NOT** be used for anything that the client side is responsible for.

The use of the **Client Side** include:
- Recieving state change updates from the server
- Providing visual feedback (animation) for the current state on the device model within the game world
- Recieve input from the player and send them to the server for further processing

The **Client Side** should **NOT** be used for anything that the Server Side is responsible for.

## Structure

### Server Side

The scripts for the **Server Side** are located within *ServerScriptService.IMSServer* and contains the following children:
- **Interface**: This script is responsible for the following tasks:
    - Initializing all devices
    - Passing references to devices to other scripts
    - Routing messages and signals from the client to devices
    - Sending messages and signals from devices to the client
- **Types**: This script contains all type definitions for the different devices.
- **Devices**: This folder contains all Server Side scripts for the different devices. The ModuleScripts contained in this folder are automatically loaded by the **Interface** on initialization.

### Client Side

The scripts for the **Client Side** are located within *StarterPlayer.StarterPlayerScripts.IMSClient* and contains the following children:
- **Loader**: This script is responsible for the following tasks:
    - Initializing all devices
    - Deciding whether or not to load the VR version of Client Side scripts
    - Routing messages and signals from the server to devices
    - Sending messages and signals from devices to the server
- **Devices**: This folder contains all Client Side scripts for the different devices. The ModuleScripts contained in this folder are automatically loaded by the **Loader** script on initialization.
    - This folder also contains the subfolder “VR” for devices which require a different implementation in VR (i.e. switches and buttons)
      :::info
      VR Functionality is WIP!