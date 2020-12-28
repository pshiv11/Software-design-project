note
	description: "Summary description for {LIGHT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARMOUR_LIGHT


inherit
	ARMOUR
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
			name.make_from_string ("Light")

			health  := 75
			energy := 0
			regen :=[2,0]
			armour := 3
			vision := 0
			move := 0
			move_cost := 1

		end
end
