note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_PASS
inherit
	ETF_PASS_INTERFACE
create
	make
feature -- command
	pass
    	do
			-- perform some update on the model state
			model.print_state.set_error_empty
			model.print_state.set_all_empty
			if model.in_setup_mode then
				model.states[model.get_setup_cursor].error.make_empty
				model.game_state.set_state (model.states[model.get_setup_cursor].state_name, "error")
				model.states[model.get_setup_cursor].set_display ("  Command can only be used in game.")
			elseif not model.in_game then
				model.game_state.set_state ("not started", "error")
				model.print_state.set_error ("  Command can only be used in game.")
			else
				model.print_state.set_all_empty
				model.pass
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
