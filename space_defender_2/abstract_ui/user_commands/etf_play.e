note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_PLAY
inherit
	ETF_PLAY_INTERFACE
create
	make
feature -- command
	play(row: INTEGER_32 ; column: INTEGER_32 ; g_threshold: INTEGER_32 ; f_threshold: INTEGER_32 ; c_threshold: INTEGER_32 ; i_threshold: INTEGER_32 ; p_threshold: INTEGER_32)
		require else
			play_precond(row, column, g_threshold, f_threshold, c_threshold, i_threshold, p_threshold)
    	do
			-- perform some update on the model state
			model.print_state.set_all_empty
			model.print_state.set_error_empty

			if model.in_setup_mode then
				model.game_state.set_state (model.states[model.get_setup_cursor].get_state_name, "error")
				model.states[model.get_setup_cursor].set_display ("  Already in setup mode.")
			elseif model.in_game then
				model.game_state.increment_y
				model.game_state.set_state ("in game", "error")
				model.print_state.set_error ("  Already in a game. Please abort to start a new one.")
			elseif not ((g_threshold <= f_threshold) and (f_threshold <= c_threshold) and (c_threshold <= i_threshold) and (i_threshold <= p_threshold) and (p_threshold <= 102))then
				model.game_state.set_state ("not started", "error")
				model.print_state.set_error ("  Threshold values are non-decreasing.")

			else
				model.toggle_setup_mode
				model.print_state.set_all_empty
				model.set_setup_cursor(1)
				model.play(row, column, g_threshold, f_threshold, c_threshold, i_threshold, p_threshold)
				model.reset
				model.game_state.set_state (model.states[model.get_setup_cursor].state_name, "ok")
				model.states[model.get_setup_cursor].error.make_empty

				if model.in_debug_mode and not model.display_titles then
					model.toggle_disply_titles
				end
			end

			etf_cmd_container.on_change.notify ([Current])
    	end

end
