# dmc-megaphone

One shared object that any part of a Solar2D (formerly Corona SDK) app can send messages to and listen on.

Every module that requires dmc-megaphone gets the same object, so a game screen can tell the app controller "game over" without either one holding a reference to the other. dmc-megaphone is [lua-megaphone](https://github.com/dmccuskey/lua-megaphone) packaged like the other DMC Solar2D libraries:

```lua
local Megaphone = require 'dmc_corona.dmc_megaphone'

Megaphone:listen( function( event ) print( event.type ) end )
Megaphone:say( 'game-over' )  --> game-over
```

Because every part of the app can hear every message, keep it for a few well-defined, app-wide messages.

## Features

- A single object, shared by every module that requires it
- `listen()`, `say()` and `ignore()`: listeners get the message name and your data
- A file of your own names and documents your app's messages (below)
- An object of your own, rather than Solar2D's global `Runtime`, which the app doesn't own
- Pure Lua, no plugins needed; MIT licensed

## Quick Start

The following code will get you up and running in about 10 minutes in the Solar2D Simulator on macOS or Windows. It names two messages in a file of your own, then makes a ball to tap and a scoreboard that hears about each tap without knowing the ball.

Prerequisites: the [Solar2D](https://solar2d.com/) Simulator and a copy of this repository (`git clone https://github.com/dmccuskey/dmc-megaphone.git`, or download the ZIP from GitHub).

### 1. Copy the Library into Your Project

Copy these from this repository into the root of your project folder:

```text
dmc_corona_boot.lua     loader for the DMC libraries
dmc_corona.cfg          configuration
dmc_corona/             dmc-megaphone and the modules it needs
```

**Going further:** keep the libraries in a subfolder, or combine several DMC libraries ([dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md)).

### 2. Name Your Messages

Create `service/megaphone.lua` in the project folder, the one place that lists and documents the app's messages:

```lua
local Megaphone = require 'dmc_corona.dmc_megaphone'

-- SCORE_CHANGED: sent by the game when the score changes
-- data: { score=<number> }
Megaphone.SCORE_CHANGED = 'score-changed'

-- GAME_OVER: sent by the game when it ends; no data
Megaphone.GAME_OVER = 'game-over'

return Megaphone
```

### 3. Send and Listen

Create `main.lua` in the project folder:

```lua
local Megaphone = require 'service.megaphone'

-- the scoreboard listens; it knows nothing of the game
local scoreboard = display.newText( "score 0", display.contentCenterX, 80, native.systemFont, 32 )

local function onMessage( event )
	if event.type == Megaphone.SCORE_CHANGED then
		scoreboard.text = "score " .. event.data.score
	elseif event.type == Megaphone.GAME_OVER then
		scoreboard.text = "game over"
		print( "game over" )
	end
end

Megaphone:listen( onMessage )

-- the game speaks; it knows nothing of the scoreboard
local score = 0
local ball = display.newCircle( display.contentCenterX, display.contentCenterY, 60 )

ball:addEventListener( 'tap', function()
	score = score + 1
	print( "score", score )
	Megaphone:say( Megaphone.SCORE_CHANGED, { score=score } )
	if score == 3 then
		Megaphone:say( Megaphone.GAME_OVER )
		Megaphone:ignore( onMessage )
	end
end )
```

Open the project in the Simulator and click the white ball four times. The scoreboard at the top counts the taps, shows `game over` on the third and then stays that way; the console shows:

```text
score	1
score	2
score	3
game over
score	4
```

If the console shows `module 'dmc_corona.dmc_megaphone' not found` instead, `dmc_corona/` is missing from the root of the project folder.

`say( message, data )` sends a message to every listener, which gets an event with the message as its `type` and your `data`. After `ignore( onMessage )` the scoreboard hears nothing more, so the fourth tap only prints. In an app, the ball and the scoreboard would be in different modules: each requires `service.megaphone` and gets the same object. (The original docs made it a global, `_G.gMegaphone = require 'service.megaphone'` in `main.lua`; requiring it where it's needed works as well.)

To update, copy `dmc_corona_boot.lua` and `dmc_corona/` again from the newer version. Keep your own `dmc_corona.cfg` if you have changed it.

## Documentation

`require 'dmc_corona.dmc_megaphone'` returns lua-megaphone's object, so its documentation applies as written:

- [Reference](https://github.com/dmccuskey/lua-megaphone#reference): `listen()`, `say()`, `ignore()`, and the event a listener gets
- [In Solar2D](https://github.com/dmccuskey/lua-megaphone#in-solar2d): one megaphone per module name, and why not `Runtime`
- [Known Issues](https://github.com/dmccuskey/lua-megaphone#known-issues) of the megaphone

## Configuration

dmc-megaphone has no settings: `dmc_corona.cfg` needs no section for it, only the `[DMC_CORONA]` section that tells the loader where the libraries are. See [dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md).

## Known Issues

The bugs of the megaphone itself are in lua-megaphone's [Known Issues](https://github.com/dmccuskey/lua-megaphone#known-issues); the one most likely to be met: `ignore()` raises an error when nothing is listening. The old README said `listen()` and `ignore()` take an object as well as a function; they take only a function. In `dmc_megaphone.lua`:

- It sets the global `_extend` (its copy of `Utils.extend()` declares the inner function without `local`).
- Its version (`0.1.0`) isn't available to code.

## Development

Only `dmc_corona/dmc_megaphone.lua` is written in this repository. It loads the DMC boot loader and returns lua-megaphone's object from `lib.dmc_lua.lua_megaphone`. Everything else is a generated copy; fix it in its own repository, then rebuild:

| file | owner |
|---|---|
| every file in `dmc_corona/lib/dmc_lua/` | [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library), which copies them from the `lua-*` repositories ([lua-megaphone](https://github.com/dmccuskey/lua-megaphone), [lua-objects](https://github.com/dmccuskey/lua-objects), ...) |
| `dmc_corona_boot.lua` | [dmc-corona-boot](https://github.com/dmccuskey/dmc-corona-boot) |

The copies are made by Snakemake from sibling checkouts of the repositories above (`../DMC-Lua-Library`, `../dmc-corona-boot`, `../DMC-Corona-Library` for the shared rules). From this repository's root folder:

```sh
snakemake --cores 1 build_all
```

dmc-megaphone has no tests of its own; lua-megaphone's are in its `spec/`. The Quick Start is the check that the package loads in Solar2D.

## License

dmc-megaphone is released under the [MIT License](LICENSE).
