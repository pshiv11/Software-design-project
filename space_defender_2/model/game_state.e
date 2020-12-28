note
	description: "Summary description for {GAME_STATE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GAME_STATE
inherit
	ANY

redefine out end

create
	make

feature
	make
		do
			create message.make_empty
		end
feature -- attributes
	message: STRING
	x,y : INTEGER


feature

	increment_x
		do
			x := x + 1
			y := 0
		end

	increment_y
		do
			y := y + 1
		end
	reset_x_y
		do
			x := 0
			y := 0
		end

	set_empty
		do
			message.make_empty
		end

	set_state(state: STRING ; status: STRING )

		local
			model: ETF_MODEL_ACCESS
		do
			message.make_empty
			if model.m.in_setup_mode then
				if model.m.in_debug_mode then
					message.append("state:" + state + ", " + "debug, "+ status + "%N")
				else
					message.append("state:" + state + ", " + "normal, "+ status + "%N")
				end
			elseif model.m.in_game then

				if model.m.in_debug_mode then
					message.append("state:" + state + "(" + x.out + "." + y.out + "), debug, " + status + "%N")
				else
					message.append("state:" + state + "(" + x.out + "." + y.out + "), normal, " + status + "%N")
				end
			else
				if model.m.in_debug_mode then
						message.append("state:" + state + ", " + "debug, "+ status + "%N")
					else
						message.append("state:" + state + ", " + "normal, "+ status + "%N")
					end
			end

		end

feature
	out: STRING
		do
			create result.make_empty
			Result.append ("  ")
			result.append (message)
		end

end
