note
	description: "Summary description for {ARMOUR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARMOUR
inherit
	STATE
redefine out end
create
	make

feature
	make
		do
			create name.make_empty
			create error.make_empty
			create state_name.make_from_string ("armour setup")
			create display.make_empty
			create regen.default_create
			create choice_array.make_empty
			choice_cursor := 1
			choice_array.force(create {ARMOUR_NONE}.make, choice_array.count + 1)
			choice_array.force(create {ARMOUR_LIGHT}.make, choice_array.count + 1)
			choice_array.force(create {ARMOUR_MEDIUM}.make, choice_array.count + 1)
			choice_array.force(create {ARMOUR_HEAVY}.make, choice_array.count + 1)


		end


feature -- common Weapon attributes

	health: INTEGER
	energy: INTEGER
	regen: TUPLE[health: INTEGER; energy: INTEGER]
	armour: INTEGER
	vision: INTEGER
	move: INTEGER
	move_cost: INTEGER




feature -- commands

	set_choice_cursor(cursor: INTEGER)
		do
			choice_cursor := cursor
		end

feature -- queries
	get_choice_cursor: INTEGER
		do
			result := choice_cursor
		end


--	one
--		do
--			name.make_empty
--			model.m.print_state.set_error_empty
--			name.make_from_string ("None")
--			health  := 50
--			energy := 0
--			regen :=[1,0]
--			armour := 0
--			vision := 0
--			move := 1
--			move_cost := 0
--			set_output

--		end

--	two
--		do
--			name.make_empty
--			model.m.print_state.set_error_empty
--			name.make_from_string ("Light")

--			health  := 75
--			energy := 0
--			regen :=[2,0]
--			armour := 3
--			vision := 0
--			move := 0
--			move_cost := 1
--			set_output


--		end

--	three
--		do
--			name.make_empty
--			model.m.print_state.set_error_empty
--			name.make_from_string ("Medium")

--			health  := 100
--			energy := 0
--			regen :=[3,0]
--			armour := 5
--			vision := 0
--			move := 0
--			move_cost := 3
--			set_output

--		end

--	four
--		do
--			name.make_empty
--			model.m.print_state.set_error_empty
--			name.make_from_string ("Heavy")

--			health  := 200
--			energy := 0
--			regen :=[4,0]
--			armour := 10
--			vision := 0
--			move := -1
--			move_cost := 5
--			set_output


--		end

	five
		do

			set_display ("  Menu option selected out of range.")
			model.m.game_state.set_state (model.m.states[model.m.get_setup_cursor].get_state_name, "error")
		end

	get_option: STRING
		do
			create result.make_empty
			result.append ("  Armour Selected:" + choice_array[choice_cursor].name)
		end

	get_state_name: STRING
		do
			create result.make_empty
			result.append (state_name)
		end

	set_output
		do
			error.make_empty
			display.make_empty
			display.append 	("  1:None%N")
			display.append  ("    Health:50, Energy:0, Regen:1/0, Armour:0, Vision:0, Move:1, Move Cost:0%N")
			display.append  ("  2:Light%N")
			display.append  ("    Health:75, Energy:0, Regen:2/0, Armour:3, Vision:0, Move:0, Move Cost:1%N")
			display.append  ("  3:Medium%N")
			display.append ("    Health:100, Energy:0, Regen:3/0, Armour:5, Vision:0, Move:0, Move Cost:3%N")
			display.append  ("  4:Heavy%N")
			display.append  ("    Health:200, Energy:0, Regen:4/0, Armour:10, Vision:0, Move:-1, Move Cost:5%N")
			display.append  ("  Armour Selected:" + choice_array[choice_cursor].name)
		end

	set_display(str: STRING)
		do
			error.make_empty
			error.append (str)
		end


-- redefined out
feature
	out: STRING
		do
			create result.make_empty

			if not error.is_empty then
				result.append(error)
			else
				current.set_output
				result.append (display)
			end

		end

end


