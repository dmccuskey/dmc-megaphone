--====================================================================--
-- tests/dmc_megaphone_spec.lua
--
-- Unit tests for dmc-megaphone, using Luna Test.
-- Run with tests/run_unit.sh
--
-- lua-megaphone has the full specs; these check the wrapper, and
-- that lua-megaphone's fixes come through it
--====================================================================--


module(..., package.seeall)



--====================================================================--
--== Setup


local Megaphone, LuaMegaphone

function suite_setup()
	Megaphone = require 'dmc_corona.dmc_megaphone'
	LuaMegaphone = require 'lib.dmc_lua.lua_megaphone'
end



--====================================================================--
--== Tests


function test_module()
	assert_equal( 'table', type( Megaphone ) )
	assert_equal( '0.2.0', Megaphone.VERSION )
	assert_equal( '1.3.0', Megaphone.__version )
end

-- one megaphone, whichever name it's required by
function test_shared_object()
	assert_equal( LuaMegaphone, Megaphone )
	assert_equal( Megaphone, require 'dmc_corona.dmc_megaphone' )
end

function test_no_global_extend()
	assert_nil( rawget( _G, '_extend' ) )
end

-- the Quick Start: a function listener, then ignore()
function test_function_listener()
	local got = {}
	local function onMessage( event )
		got[ #got+1 ] = event
	end
	Megaphone:listen( onMessage )
	Megaphone:say( 'score-changed', { score=1 } )
	Megaphone:ignore( onMessage )
	Megaphone:say( 'score-changed', { score=2 } )
	assert_equal( 1, #got )
	assert_equal( 'score-changed', got[1].type )
	assert_equal( 1, got[1].data.score )
end

-- lua-megaphone 1.3.0: an object listener's megaphone_event() is called
function test_object_listener()
	local scoreboard = { count=0 }
	function scoreboard:megaphone_event( event )
		self.count = self.count + 1
	end
	Megaphone:listen( scoreboard )
	Megaphone:say( 'game-over' )
	Megaphone:ignore( scoreboard )
	Megaphone:say( 'game-over' )
	assert_equal( 1, scoreboard.count )
end

-- lua-megaphone 1.3.0: it raised an error before
function test_ignore_with_no_listeners()
	Megaphone:ignore( function() end )
end
