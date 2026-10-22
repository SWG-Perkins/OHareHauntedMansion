# John O'Hare's **Adventure 1.5: Haunted Mansion** (Free Pascal port)

A Free Pascal console conversion of John O'Hare's **Adventure 1.5** (1980), originally written for Commodore BASIC.

## Intent

This port was created to keep the **spirit and function of the original game** intact.  
The room layout, object table, command parser, scoring, random encounters, and system messages have been faithfully translated from `OHARES3.BAS` into modern Free Pascal. It plays like the 1980 original: a text-driven exploration of a haunted mansion, with treasures to recover, monsters to avoid, and a flashlight whose batteries run down over time.

## History

John O'Hare's Adventure 1.5 was the first text adventure game I ever played. In the summer of 1985 I attended a computer camp at a local high school, where we were to learn the basics of computer operation on Commodore PETs, and an introduction to BASIC programming.
What ended up happening is that the entire class became addicted to this game. We shared tips and made maps of the game, and eventually completed it.

The game remains a formative part of my early days in computing.

I chose Free Pascal as the development language because Pascal was the first language in which I became proficient.

I made heavy use of the **nvidia/nemotron-3.5-super-v1** local LLM in this conversion.

## Features

* Classic two-word parser (verb + noun)
* 58 rooms to explore, including the haunted forest, manor house, caverns, and the infamous torture chamber
* 78 objects with keywords, weights, and carry limits
* Random ghost, goblin, troll, and vampire encounters
* Score-based ranking system (from "rank amateur" to "Adventurer Grand Master")
* Save and load game support
* Original system messages and flavor text preserved

## Requirements

* [Free Pascal Compiler (FPC)](https://freepascal.org/) — tested with recent 3.x versions
* A terminal/console that supports standard input/output

## Build & Run

```bash
# Compile
fpc hauntedmansion.pas

# Run
./hauntedmansion        # Linux/macOS
hauntedmansion.exe      # Windows
