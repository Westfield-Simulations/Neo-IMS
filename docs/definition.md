---
sidebar_position: 4
---

# Workspace Definition

## Tagging
Once you have the device modules scripted, you still need to ensure that the Neo-IMS knows which models to treat as that device.

Doing this is also pretty simple.

Simply add a CollectionService tag to the device model named the exact same thing as the module scripts for the device.

Once you do this, Neo-IMS loads an instance of that device for each tagged model.

## Initial States
To define an initial state, simply add a value object to the root of your device model named `InitialState` (Case Sensitive) to define a **Basic State**.

Alternatively, add a folder to the root of your device model named `InitialState` to define a **Complex State**. This folder contains the value objects for the complex state.
:::note
Subfolders are currently not supported.
:::