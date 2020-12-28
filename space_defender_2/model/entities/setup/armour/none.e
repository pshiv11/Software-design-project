note
	description: "Summary description for {NONE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARMOUR_NONE

inherit
	ARMOUR
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
			name.make_from_string ("None")
			health  := 50
			energy := 0
			create regen.default_create
				regen :=[1,0]
			armour := 0
			vision := 0
			move := 1
			move_cost := 0

		end

end
