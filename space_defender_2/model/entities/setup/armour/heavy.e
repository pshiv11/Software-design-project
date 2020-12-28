note
	description: "Summary description for {HEAVY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARMOUR_HEAVY

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
			name.make_from_string ("Heavy")

			health  := 200
			energy := 0
			regen :=[4,0]
			armour := 10
			vision := 0
			move := -1
			move_cost := 5

		end
end
