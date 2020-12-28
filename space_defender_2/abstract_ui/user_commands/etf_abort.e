note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ABORT
inherit
	ETF_ABORT_INTERFACE
create
	make
feature -- command
	abort
    	do
			-- perform some update on the model state
			model.print_state.set_all_empty
			if not model.in_game and not model.in_setup_mode then

				model.game_state.set_state ("not started", "error")
				model.print_state.set_message ("  Command can only be used in setup mode or in game.")
				if model.display_titles then
					model.toggle_disply_titles
				end

			elseif model.in_setup_mode then
				model.print_state.set_all_empty
				model.states[model.get_setup_cursor].error.make_empty
				model.game_state.set_state ("not started", "ok")
				model.print_state.set_message ("  Exited from setup mode.")
				model.toggle_setup_mode
				if model.display_titles then
					model.toggle_disply_titles
				end
			else
				model.states[model.get_setup_cursor].error.make_empty
				model.game_state.set_state ("not in game", "ok")
				model.abort
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
