note
	description: "Summary description for {POWER_RECALL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POWER_RECALL
inherit
	POWER

redefine make, special end
create
	make

feature
	make
		do
			create name.make_empty
			create error.make_empty
			create display.make_empty
			create choice_array.make_empty
			create state_name.make_empty
			name.make_from_string ("Recall (50 energy): Teleport back to spawn.")

		end


	special
		local
			output: STRING
		do
			model.m.starfighter.apply_regen
			model.m.starfighter.subtract_energy (50)
			create output.make_empty
			model.m.starfighter.set_old_pos (model.m.starfighter.pos.row, model.m.starfighter.pos.column)
			model.m.starfighter.set_pos (model.m.starfighter.initial_pos.row, model.m.starfighter.initial_pos.column)
			model.m.grid.put ("_", model.m.starfighter.old_pos.row, model.m.starfighter.old_pos.column)
			output.append ("%N    The Starfighter(id:0) uses special, teleporting to: [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "]")

			if model.m.enemy_presence (model.m.starfighter.initial_pos.row, model.m.starfighter.initial_pos.column) /= -9999 then
				-- collision with enemy
				if attached model.m.enemy_collection.item (model.m.enemy_presence (model.m.starfighter.initial_pos.row, model.m.starfighter.initial_pos.column)) as enemy_obj then
					model.m.starfighter.subtract_health (enemy_obj.current_health)
					model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
					enemy_obj.set_on_board(false)
					output.append ("%N    The Starfighter collides with " + enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out +
																		"], trading " + enemy_obj.current_health.out +  " damage.")
					enemy_obj.add_to_focus
					model.m.grid.put ("S", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
					if model.m.starfighter.current_health <= 0 then
						-- game over
						model.m.starfighter.set_current_health (0)
						model.m.grid.put ("X", model.m.starfighter.pos.row , model.m.starfighter.pos.column)
						model.m.toggle_in_game
						output.append ("%N    The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
					end
				end


			elseif model.m.enemy_projectile_presence (model.m.starfighter.initial_pos.row, model.m.starfighter.initial_pos.column) /= -9999 then
				-- collision with <
				if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence  (model.m.starfighter.initial_pos.row, model.m.starfighter.initial_pos.column)) as ep_obj then
					model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
					ep_obj.set_on_board(false)
					model.m.starfighter.subtract_health (model.m.max (ep_obj.damage - model.m.starfighter.current_armour, 0))
					output.append ("%N    The Starfighter collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + ","
																+ ep_obj.pos.column.out + "], taking " + model.m.max (ep_obj.damage - model.m.starfighter.current_armour, 0).out + " damage.")
					model.m.grid.put ("S", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
					if model.m.starfighter.current_health <= 0 then
						-- game over
						model.m.starfighter.set_current_health (0)
						model.m.grid.put ("X", model.m.starfighter.pos.row , model.m.starfighter.pos.column)
						model.m.toggle_in_game
						model.m.game_state.set_state ("not started", "ok")
						model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")
						output.append ("%N    The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")

					end
				end

			elseif model.m.friendly_projectile_presence(model.m.starfighter.initial_pos.row, model.m.starfighter.initial_pos.column) /= -9999 then
				-- collision with *
				if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (model.m.starfighter.initial_pos.row, model.m.starfighter.initial_pos.column)) as fp_obj then
					fp_obj.set_on_board(false)
					model.m.starfighter.subtract_health (model.m.max (fp_obj.damage - model.m.starfighter.current_armour, 0))

					output.append ("%N    The Starfighter collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + ","
																+ fp_obj.pos.column.out + "], taking " + model.m.max (fp_obj.damage - model.m.starfighter.current_armour, 0).out + " damage.")
					model.m.grid.put ("S", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
					if model.m.starfighter.current_health <= 0 then
						-- game over
						model.m.starfighter.set_current_health (0)
						model.m.grid.put ("X", model.m.starfighter.pos.row , model.m.starfighter.pos.column)
						model.m.toggle_in_game
						output.append ("%N    The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
					end
				end

			else
				-- teleport back to spawn	
				model.m.grid.put ("S", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
			end

			model.m.print_state.set_starfighter_action (output)
		end
end
