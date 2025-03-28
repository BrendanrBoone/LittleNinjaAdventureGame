# Little Ninja Adventure Game
A little project. * Finishing project at this point. Release is only made for Windows.

## With Release
### Usage
1. extract ```LNAG_distributable.zip```
2. run ```LNAG_distributable/LittleNinjaAdventureGame.exe```

## Without Release
### Requirements
* Love2D
### Usage
```./run.bat```
* run the program normally with Love2D or edit ```run.bat``` for your device

## Controls
* ```w```, ```a```, ```s```, ```d``` -> move
* ```space``` -> jump
* ```lshift``` -> sprint
* ```e``` -> interact
* ```1```, ```2```, ```3``` -> select seal
* ```r``` -> activate seal sequence
* ```q``` -> charge
* ```escape``` -> pause

### Seal Sequences
* ```火``` -> red release (functions as a key to a locked door)
* ```水``` -> blue release (functions as a key to a locked door)
* ```風``` -> green release (functions as a key to a locked door)

## Things I fixed from the original platformer
* sounds.lua: update()
* player.lua: setNewFrame()
* nicoRobin.lua -> npc.lua: NPC.new()
* characterData.lua
* backgroundObject.lua -> animated

## Things to do
* make program more easily runable for increase accessability
* etherial message function
* fireball jutsu: ```火``` -> ```火```
* rasengan: ```風``` -> ```風```
* fireball rasengan: ```風``` -> ```風``` -> ```火```
