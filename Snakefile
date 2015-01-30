# dmc-megaphone

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "dmc-states-mixin"
	include: "../DMC-Corona-Library/snakemake/Snakefile"

module_config = {
	"name": "dmc-megaphone",
	"module": {
		"dir": "dmc_corona",
		"files": [
			"dmc_megaphone.lua"
		],
		"requires": [
			"dmc-corona-boot",
			"DMC-Lua-Library"
		]
	},
	"tests": {
		"files": [],
		"requires": []
	}
}

register( "dmc-megaphone", module_config )

