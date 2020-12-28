note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SETUP_BACK
inherit
	ETF_SETUP_BACK_INTERFACE
create
	make
feature -- command
	setup_back(state: INTEGER_32)
		require else
			setup_back_precond(state)
    	do
    		model.print_state.set_error_empty
			-- perform some update on the model state

			if model.in_setup_mode then
				if model.get_setup_cursor - state < 1  then
					  	model.states[model.get_setup_cursor].error.make_empty
						model.toggle_setup_mode
						model.print_state.set_all_empty
						model.game_state.set_empty
						model.initial_state
						model.set_setup_cursor (0)
						model.game_state.reset_x_y
						-- go back to initial state
				else
						model.states[model.get_setup_cursor].error.make_empty
						model.set_setup_cursor (model.get_setup_cursor - state)
						model.game_state.set_state (model.states[model.get_setup_cursor].get_state_name, "ok")
				end
			else

				if  not model.in_game then
					model.print_state.set_welcome_empty
					model.game_state.increment_y
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
