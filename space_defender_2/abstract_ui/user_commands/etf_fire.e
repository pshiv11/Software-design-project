note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_FIRE
inherit
	ETF_FIRE_INTERFACE
create
	make
feature -- command
	fire
    	do
			-- perform some update on the model state
--			model.print_state.set_error_empty
--			model.print_state.set_all_empty
--			if model.in_setup_mode then
--				model.states[model.get_setup_cursor].error.make_empty
--				model.game_state.set_state (model.states[model.get_setup_cursor].state_name, "error")
--				model.states[model.get_setup_cursor].set_display ("  Command can only be used in game.")
--			elseif not model.in_game then
--				model.game_state.set_state ("not started", "error")
--				model.print_state.set_error("  Command can only be used in game.")
--			elseif (model.starfighter.current_energy + model.starfighter.total_regen.energy) <  model.starfighter.total_projectile_cost then
--				model.game_state.increment_y
--				model.game_state.set_state ("in game", "error")
--				model.print_state.set_error_empty
--				model.print_state.set_error ("  Not enough resources to fire.")
--			else
--				model.game_state.increment_x
--				model.game_state.set_state ("in game", "ok")
--				model.fire
--			end
			model.print_state.set_error_empty
			model.print_state.set_all_empty
			if model.in_setup_mode then
				model.states[model.get_setup_cursor].error.make_empty
				model.game_state.set_state (model.states[model.get_setup_cursor].state_name, "error")
				model.states[model.get_setup_cursor].set_display ("  Command can only be used in game.")
			elseif not model.in_game then
				model.game_state.set_state ("not started", "error")
				model.print_state.set_error("  Command can only be used in game.")
			else
				if not (model.states[1].choice_cursor = 4) then
					if (model.starfighter.current_energy + model.starfighter.total_regen.energy) <  model.starfighter.total_projectile_cost then
							model.game_state.increment_y
							model.game_state.set_state ("in game", "error")
							model.print_state.set_error_empty
							model.print_state.set_error ("  Not enough resources to fire.")
					else
							model.game_state.increment_x
							model.game_state.set_state ("in game", "ok")
							model.fire
					end

				else
					if (model.starfighter.current_health + model.starfighter.total_regen.health) <  model.starfighter.total_projectile_cost then
							model.game_state.increment_y
							model.game_state.set_state ("in game", "error")
							model.print_state.set_error_empty
							model.print_state.set_error ("  Not enough resources to fire.")
					else
						model.game_state.increment_x
						model.game_state.set_state ("in game", "ok")
						model.fire
					end


				end


			end




			etf_cmd_container.on_change.notify ([Current])
    	end

end
