note
	description: "Summary description for {ENGINE_STANDARD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENGINE_STANDARD

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
			name.make_from_string ("Standard")
			health  := 10
			energy := 60
			create regen.default_create
				regen :=[0,2]
			armour := 1
			vision := 12
			move := 8
			move_cost := 2

		end

end
