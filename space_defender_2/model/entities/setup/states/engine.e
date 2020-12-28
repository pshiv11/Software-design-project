note
	description: "Summary description for {ENGINE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENGINE
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
			create state_name.make_from_string ("engine setup")
			create display.make_empty
			create regen.default_create
			create choice_array.make_empty
			choice_cursor := 1
			choice_array.force(create {ENGINE_STANDARD}.make, choice_array.count + 1)
			choice_array.force(create {ENGINE_LIGHT}.make, choice_array.count + 1)
			choice_array.force(create {ENGINE_ARMOURED}.make, choice_array.count + 1)

		end

feature -- engine attributes
--	engine_selected: STRING
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



--feature -- commands (select options)	
--	one
--		do
--			name.make_empty
--			model.m.print_state.set_error_empty
--			name.make_from_string("Standard")
--			health  := 10
--			energy := 60
--			regen :=[0,2]
--			armour := 1
--			vision := 12
--			move := 8
--			move_cost := 2
--			set_output

--		end

--	two
--		do
--			name.make_empty
--			model.m.print_state.set_error_empty
--			name.make_from_string("Light")
--			health  := 0
--			energy := 30
--			regen :=[0,1]
--			armour := 0
--			vision := 15
--			move := 10
--			move_cost := 1
--			set_output


--		end

--	three
--		do
--			name.make_empty
--			model.m.print_state.set_error_empty
--			name.make_from_string("Armoured")
--			health  := 50
--			energy := 100
--			regen :=[0,3]
--			armour := 3
--			vision := 6
--			move := 4
--			move_cost := 5
--			set_output

--		end

--	four
--		do

--			set_display("  Menu option selected out of range.")
--			model.m.game_state.set_state (model.m.states[model.m.get_setup_cursor].get_state_name, "error")
--		end

--	five
--		do

--			set_display("  Menu option selected out of range.")
--			model.m.game_state.set_state (model.m.states[model.m.get_setup_cursor].get_state_name, "error")
--		end

	get_option: STRING
		do
			create result.make_empty
			result.append ("  Engine Selected:" + choice_array[choice_cursor].name)
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
			display.append  ("  1:Standard%N")
			display.append  ("    Health:10, Energy:60, Regen:0/2, Armour:1, Vision:12, Move:8, Move Cost:2%N")
			display.append ("  2:Light%N")
			display.append  ("    Health:0, Energy:30, Regen:0/1, Armour:0, Vision:15, Move:10, Move Cost:1%N")
			display.append ("  3:Armoured%N")
			display.append  ("    Health:50, Energy:100, Regen:0/3, Armour:3, Vision:6, Move:4, Move Cost:5%N")
			display.append  ("  Engine Selected:" + choice_array[choice_cursor].name)
		end

	set_display(str: STRING)
		do
			error.make_empty
			error.append (str)
		end


feature  -- out
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
