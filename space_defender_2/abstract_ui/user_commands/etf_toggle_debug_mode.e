note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_TOGGLE_DEBUG_MODE
inherit
	ETF_TOGGLE_DEBUG_MODE_INTERFACE
create
	make
feature -- command
	toggle_debug_mode
    	do
			-- perform some update on the model state
			model.print_state.set_error_empty
			model.print_state.set_all_empty


			if model.in_setup_mode and model.in_debug_mode then
				model.states[model.get_setup_cursor].error.make_empty
				model.toggle_debug_mode

				model.game_state.set_state (model.states[model.get_setup_cursor].get_state_name, "ok")
				model.states[model.setup_cursor].set_display ("  Not in debug mode.")
			elseif model.in_setup_mode and not model.in_debug_mode  then
				model.states[model.get_setup_cursor].error.make_empty
				model.toggle_debug_mode
				model.game_state.set_state (model.states[model.get_setup_cursor].get_state_name, "ok")
				model.states[model.setup_cursor].set_display ("  In debug mode.")
				if not model.display_titles then
					model.toggle_disply_titles
				end
			elseif model.in_game and model.in_debug_mode then
				model.toggle_debug_mode
				model.print_state.set_all_empty
				model.game_state.increment_y
				model.game_state.set_state ("in game", "ok")
				model.print_state.set_error ("  Not in debug mode.")
			elseif model.in_game and not model.in_debug_mode then
				model.toggle_debug_mode
				model.print_state.set_all_empty
				model.game_state.increment_y
				model.game_state.set_state ("in game", "ok")
				model.print_state.set_error ("  In debug mode.")

				if not model.display_titles then
					model.toggle_disply_titles
				end

			else
					if model.in_debug_mode then
						model.toggle_debug_mode
						model.print_state.set_welcome_empty
						model.game_state.set_state ("not started", "ok")
						model.print_state.set_error ("  Not in debug mode.")
					else
						model.toggle_debug_mode
						model.print_state.set_welcome_empty
						model.game_state.set_state ("not started", "ok")
						model.print_state.set_error ("  In debug mode.")
						if not model.display_titles then
							model.toggle_disply_titles
						end
					end
					-- command can only be used after play	


			end


			etf_cmd_container.on_change.notify ([Current])
    	end

end
