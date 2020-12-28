note
	description: "Summary description for {SPLITTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WEAPON_SPLITTER

inherit
	WEAPON
redefine make, fire, friendly_projectile_act end
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
			name.make_from_string ("Splitter")
			health  := 0
			energy := 100
			regen :=[0,10]
			armour := 0
			vision := 0
			move := 0
			move_cost := 5
			projectile_damage := 150
			projectile_cost := 70

		end

	fire

		local
				projectile: FRIENDLY_PROJECTILE
		do

			model.m.print_state.set_starfighter_action_empty

			-- subtracting the costing of firing
			model.m.starfighter.subtract_energy (model.m.starfighter.total_projectile_cost)

			-- creating projectile
				create {FRIENDLY_PROJECTILE} projectile.make (model.m.projectile_id,  model.m.starfighter.total_projectile_damage, 0, model.m.starfighter.pos.row, model.m.starfighter.pos.column + 1)
				model.m.add_friendly_projectile (projectile)
			-- fire to string
				model.m.print_state.set_starfighter_action ("%N    The Starfighter(id:" + model.m.starfighter.id.id.out + ") fires at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out
				 		+ "].")

			-- check to see if spawing location is on board
			if (model.m.starfighter.pos.column + 1) > model.m.grid.width then
				model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile.id.out + ") spawns at location out of board.")

			else
				model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile.id.out + ") spawns at location ["+ model.m.row_name[projectile.pos.row] + "," + projectile.pos.column.out.out + "].")
					if model.m.enemy_projectile_presence (model.m.starfighter.pos.row, model.m.starfighter.pos.column + 1) /= -9999 then
						--Spawing in a location that has enemy projectile
						if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (projectile.pos.row, projectile.pos.column)) as ep_obj then
							-- enemy projectile damage is higher than current projectile
								if ep_obj.damage > projectile.damage then
									ep_obj.subtract_damage(projectile.damage)
									model.m.grid.put ("_", projectile.pos.row, projectile.pos.column)
									projectile.set_on_board(false)
									model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
									 + "], negating damage.")

							-- current projectile damage is higher than enemy projectile	
								elseif projectile.damage > ep_obj.damage then
									projectile.subtract_damage(ep_obj.damage)
									model.m.grid.put ("*", projectile.pos.row, projectile.pos.column)
									ep_obj.set_on_board(false)
									model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
									 + "], negating damage.")
									projectile.set_on_board (true)


							-- current and enemy projectile damage is equal	
								else
									model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
									ep_obj.set_on_board(false)
									model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
									 + "], negating damage.")

								end
						end




					elseif model.m.friendly_projectile_presence (model.m.starfighter.pos.row, model.m.starfighter.pos.column + 1) /= -9999 then
						-- Spawning in a location that has friendly projectile
						-- combine the damage of both projectile and remove the exisiting projectile from board
						if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (projectile.pos.row, projectile.pos.column )) as fp_obj then
							projectile.add_damage(fp_obj.damage)
							fp_obj.set_on_board(false)
							model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
							projectile.set_on_board (true)
						end


					elseif model.m.enemy_presence (model.m.starfighter.pos.row, model.m.starfighter.pos.column + 1) /= -9999 then
						-- spwawning in a location that has an enemy
						-- friendly projectile is removed from the board and enemy, depends on it health after collision may or may not be removed from the board
						if attached model.m.enemy_collection.item (model.m.enemy_presence (projectile.pos.row, projectile.pos.column)) as enemy_obj then
							enemy_obj.subtract_health(model.m.max((projectile.damage - enemy_obj.armour), 0))
							model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with" +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((projectile.damage - enemy_obj.armour), 0).out  + " damage.")
							if enemy_obj.current_health <= 0 then
								model.m.print_state.set_friendly_projectile_action ("%N      The " + enemy_obj.name +  "at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed")
								enemy_obj.set_on_board(false)
								model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
								enemy_obj.add_to_focus
							end
						end


					else
						projectile.set_on_board (true)
						model.m.grid.put ("*", projectile.pos.row, projectile.pos.column)
					end
			end

		end


	friendly_projectile_act
		do
			model.m.print_state.set_friendly_projectile_action_empty
			across 1 |..| model.m.friendly_projectiles.count is id
			loop
				if attached model.m.friendly_projectiles.item (-id) as obj then
					if obj.on_board and model.m.in_game then

						model.m.print_state.set_friendly_projectile_action ("%N    A friendly projectile(id:" + obj.id.out + ") stays at: [" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "]")

					end
				end

			end
		end


end
