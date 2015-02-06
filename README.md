## dmc-megaphone ##


### Overview ###

The Megaphone is to be used for inter-app communication. It's simple to use:

```lua
gMegaphone:listen( <obj / func> )
gMegaphone:say( <message> )
gMegaphone:ignore( <obj / func> )
```

This is a singleton by nature and is global. Because it is global, any other component, view, etc can gain access to it to send and receive messages.

As any global object it should be used for only _well-defined events_!

**Why?**

Global communication can be easily setup in Corona SDK. Sometimes developers will use the global Runtime object. I don't use this myself because I feel you should only overload objects which are under your control (What if Corona decided to change the Runtime and your code steps on a method, etc.)

This can simply be avoided by creating a display group and setting it global – I initially did this. However, what was missing was a place to document/organize information about the messages in an app. (like a class file)

So I use this structure because:
* it's risky to use another object for which you don't have control
* Your megaphone file serves to document/organize the messages, new methods, and support functions in your app.
* It's a little simpler to use

### Usage ###

Import the object in a file for your app, then add messages, etc to it. 

```lua
-- in a file in your app, say 'service/megaphone.lua'

-- import main dmc_megaphone
local Megaphone = require 'dmc_corona.dmc_megaphone'

--[[
now you add message information to this object
you can also add methods or support functions in this file
as well as documentation for the message itself.

for example:
--]]


--=======================--
--== Game Over Message ==--

Megaphone.GAME_OVER_EVENT = 'game-over-event'

--[[

this message is to be used when an instantiated game object 
wishes to tell the app controller that it has finished and now can be removed
an example of this is the RaceEnvy Controller notifying
the app controller the game has completed

Sequence
Game Object/Controller >> App Controller

Request: the request always comes from a game object
Handler: the app controller always processes the request

Data

There is no data for this message

--]]



-- then return

return Megaphone
```

```lua
-- in your core app file (eg, app controller, main, etc)
-- import your version of Megaphone and make global

_G.gMegaphone = require 'service.megaphone'

```

#### Event Listen ####

Use method `listen` to receive global messages ( ie, like addEventListener() ). This can be done when your objects are instantiated.

`gMegaphone:listen( <obj or func> )`

( the actual listener can be either an object or function )


```lua
-- in one of your files/classes wanting to receive messages

local f = function(event)
  if event.type == gMegaphone.GAME_OVER_EVENT then 
    -- do game over stuff
  end
end
gMegaphone:listen( f )
```

#### Sending Messages ####

Send global messages by using method `say`. The first arg is the message type, the second optional arg is any data.

`gMegaphone:say( <message type>, <data> )`

```lua
-- in one of your files/classes dispatch a message
gMegaphone:say( gMegaphone.GAME_OVER_EVENT )
```

#### Event Ignore ####

Use method `ignore` to stop receiving global messages ( ie, like removeEventListener() ). This can be done when your objects are destroyed.

`gMegaphone:ignore( <obj or func> )`

( as usual, the actual listener should be same reference given in `listen` )

```lua
local f = function(event)
  if event.type == gMegaphone.GAME_OVER_EVENT then 
    -- do game over stuff
  end
end
gMegaphone:listen( f )

-- later in app
gMegaphone:ignore( f )
```

