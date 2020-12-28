note
	description: "Summary description for {ENGINE_LIGHT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENGINE_LIGHT
inherit
	ENGINE
redefine make end
create
	make

feature
	make
		do
			create name.make_empty
			create error.make_empty
			create display.make_empty
			create choice_array.make_empty
			create state_name.make_empty
			create display.make_empty
			create name.make_from_string("Light")
			health  := 0
			energy := 30
			regen :=[0,1]
			armour := 0
			vision := 15
			move := 10
			move_cost := 1

		end
end
