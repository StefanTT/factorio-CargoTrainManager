# Overview

This mod allows to create train networks like those of the logistic bots with providers and
requesters. The images in the doc folder should give you some hints how the mod works.

# Provider Station

A provider station consists of two stops: an ordinary train stop where the train is loaded and
a cargo train manager stop where the goods are provided. Set the train to fully load on the
loading stop and to an empty circuit condition on the cargo train manager stop.

# Requester Station

A requester station has a cargo train manager stop, and one or more requester lamps.
The requester lamps needs to be connected to the constant combinator that is part of the
cargo train manager stop.

# Train Networks

Per default all provider and requester are in the network "1". It might be useful to create
different networks for different tasks.

# Refuel

Trains are automatically sent to refuel stations when they run out of fuel. The refuel
stop's name has to be "Refuel-2" to refuel trains that have 2 locomotives. The name and
refuel limit is configurable in the mod settings.

# Known Problems

* When a requester stop is removed while a train is inbound then the affected train
  behaves somewhat strange for a short period of time.

* Copy/paste of stops and requester lamps does not copy the resource/network IDs. I am
  still unsure if I like this or not.

# Credits

The mod is heavily inspired by the Train Supply Manager mod by LordKTor. The idea of the
indicator lamp comes from the Logistic Train Network mod by Optera. 

