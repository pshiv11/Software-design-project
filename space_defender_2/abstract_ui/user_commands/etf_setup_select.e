note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SETUP_SELECT
inherit
	ETF_SETUP_SELECT_INTERFACE
create
	make
feature -- command
	setup_select(value: INTEGER_32)
		require else
			setup_select_precond(value)
    	do
			-- perform some update on the model state
			model.print_state.set_error_empty



			if model.in_setup_mode then
				if model.get_setup_cursor = 2 and value = 5 then
					model.game_state.set_state (model.states[model.get_setup_cursor].state_name, "error")
					model.states[model.get_setup_cursor].set_display ("  Menu option selected out of range.")
				elseif model.get_setup_cursor = 3 and (value = 4 or value = 5) then
					model.game_state.set_state (model.states[model.get_setup_cursor].state_name, "error")
					model.states[model.get_setup_cursor].set_display ("  Menu option selected out of range.")
				elseif model.get_setup_cursor = 5 and (value >=1 and value <= 5) then
					model.game_state.set_state (model.states[model.get_setup_cursor].state_name, "error")
					model.states[model.get_setup_cursor].set_display ("  Command can only be used in setup mode (excluding summary in setup).")
				else
					model.states[model.get_setup_cursor].set_choice_cursor (value)
					model.states[model.get_setup_cursor].set_output
				end
			else
				if not model.in_game then
					model.print_state.set_welcome_empty
					model.game_state.set_state ("not started", "error")
					model.print_state.set_error ("  Command can only be used in setup mode (excluding summary in setup).")

				else
					model.game_state.increment_y
					model.game_state.set_state ("in game", "error")
					model.print_state.set_error ("  Command can only be used in setup mode (excluding summary in setup).")
				end

			end


			etf_cmd_container.on_change.notify ([Current])
    	end

end
