note
	description: "Summary description for {ENGINE_ARMOURED}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENGINE_ARMOURED
inherit
	ENGINE
redefine make end

create
	make

feature
	make
		do
			create name.make_empty
			create display.make_empty
			create error.make_empty
			create choice_array.make_empty
			create state_name.make_empty
			name.make_from_string("Armoured")

			health  := 50
			energy := 100
			create regen.default_create
			regen :=[0,3]
			armour := 3
			vision := 6
			move := 4
			move_cost := 5

		end

end
