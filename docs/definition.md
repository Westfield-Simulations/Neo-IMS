---
sidebar_position: 4
---

# Workspace Definition

## Tagging
Once you have the device modules scripted, you still need to ensure that the Neo-IMS knows which models to treat as that device.

Doing this is also pretty simple.

Simply add a CollectionService tag to the device model named the exact same thing as the module scripts for the device.

Adding the `ComplexInteractable` tag to the parent of the device model will prefix the name of the device with that parent's name.

So for example, if we have a device named `L` and its parent was named `Light`, tagging the parent with ComplexInteractable would make the final name of the device `Light L`

Once you do this, Neo-IMS loads an instance of that device for each tagged model.

## Initial States
To define an initial state, simply add a value object to the root of your device model named `InitialState` (Case Sensitive) to define a **Basic State**.

Alternatively, add a folder to the root of your device model named `InitialState` to define a **Complex State**. This folder contains the value objects for the complex state.
:::note
Subfolders are currently not supported.
:::