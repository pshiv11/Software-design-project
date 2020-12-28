note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SPECIAL
inherit
	ETF_SPECIAL_INTERFACE
create
	make
feature -- command
	special
    	do
    		model.print_state.set_error_empty
			model.print_state.set_all_empty

			if not model.in_game then

				if model.in_setup_mode then
					model.states[model.get_setup_cursor].error.make_empty
					model.game_state.set_state (model.states[model.get_setup_cursor].state_name, "error")
					model.states[model.get_setup_cursor].set_display ("  Command can only be used in game.")
				else
					model.game_state.set_state ("not started", "error")
					model.print_state.set_error ("  Command can only be used in game.")
				end

			elseif model.states[4].choice_cursor = 1 or model.states[4].choice_cursor = 2 then

					if ((model.starfighter.current_energy + model.starfighter.total_regen.energy) - 50) < 0 then
						model.game_state.increment_y
						model.game_state.set_state ("in game", "error")
						model.print_state.set_error ("  Not enough resources to use special.")
					else
						model.game_state.increment_x
						model.game_state.set_state ("in game", "ok")
						model.special


					end

			elseif model.states[4].choice_cursor = 4 or model.states[4].choice_cursor = 5 then

					if ((model.starfighter.current_energy + model.starfighter.total_regen.energy) - 100) < 0 then
						model.game_state.increment_y
						model.game_state.set_state ("in game", "error")
						model.print_state.set_error ("  Not enough resources to use special.")
					else
						model.game_state.increment_x
						model.game_state.set_state ("in game", "ok")
						model.special

					end
			else
				model.game_state.increment_x
				model.game_state.set_state ("in game", "ok")
				model.special


			end



			etf_cmd_container.on_change.notify ([Current])
    	end

end
