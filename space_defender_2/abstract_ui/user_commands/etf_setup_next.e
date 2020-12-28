note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SETUP_NEXT
inherit
	ETF_SETUP_NEXT_INTERFACE
create
	make
feature -- command
	setup_next(state: INTEGER_32)
		require else
			setup_next_precond(state)
    	do
			-- perform some update on the model state
			model.print_state.set_error_empty
			model.print_state.set_all_empty



			if model.in_setup_mode then
				model.states[model.get_setup_cursor].error.make_empty
				if model.get_setup_cursor + state > 5  then
				--	model.states[model.get_setup_cursor].error.make_empty
					model.toggle_setup_mode
					model.toggle_in_game
					model.game_state.set_state ("in game", "ok")
					model.play_game
				--	model.test_score
				else
				--	model.states[model.get_setup_cursor].error.make_empty
					model.set_setup_cursor (model.get_setup_cursor + state)
					model.game_state.set_state (model.states[model.get_setup_cursor].get_state_name, "ok")
				end
			else
				model.states[model.get_setup_cursor].error.make_empty
				if not model.in_game then
					model.print_state.set_welcome_empty

					model.game_state.set_state ("not started", "error")
					model.print_state.set_error ("  Command can only be used in setup mode.")
				else
					model.print_state.set_welcome_empty
					model.game_state.increment_y
					model.game_state.set_state ("in game", "error")
					model.print_state.set_error ("  Command can only be used in setup mode.")
				end

			end


			etf_cmd_container.on_change.notify ([Current])
    	end

end
