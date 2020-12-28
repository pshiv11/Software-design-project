note
	description: "Summary description for {SUMMARY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SUMMARY

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
			create state_name.make_from_string ("setup summary")
			create display.make_empty
			create choice_array.make_empty


		end

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


	get_option: STRING
		do
			create result.make_empty
		end

	get_state_name: STRING
		do
			create result.make_empty
			result.append (state_name)
		end


	set_output
		do
			display.make_empty
			across 1 |..| (model.m.states.count - 1) is index
			loop
				display.append(model.m.states[index].get_option)
				if index /= (model.m.states.count - 1)  then
					display.append ("%N")
				end
			end
		end

	set_display(str: STRING)
		do
			error.make_empty
			error.append (str)
		end

feature
	out: STRING
		do
			create result.make_empty
			if not error.is_empty then
				result.append(error)
			else
				set_output
				result.append (display)
			end

		end


end



