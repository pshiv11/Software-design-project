note
	description: "Summary description for {MEDIUM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARMOUR_MEDIUM

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
			name.make_from_string ("Medium")
			health  := 100
			energy := 0
			regen :=[3,0]
			armour := 5
			vision := 0
			move := 0
			move_cost := 3

		end

end
