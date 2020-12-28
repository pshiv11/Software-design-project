note
	description: "Summary description for {SNIPE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WEAPON_SNIPE

inherit
	WEAPON
redefine make, fire, friendly_projectile_act end
create
	make

feature
	make
		do
			create name.make_empty
			create display.make_empty
			create error.make_empty
			create choice_array.make_empty
			create state_name.make_empty
			name.make_from_string ("Snipe")
			health  := 0
			energy := 100
			regen :=[0,5]
			armour := 0
			vision := 10
			move := 3
			move_cost := 0
			projectile_damage := 1000
			projectile_cost := 20

		end



fire

		local
				projectile: FRIENDLY_PROJECTILE
		do

				model.m.print_state.set_starfighter_action_empty


				-- subtracting the costing of firing
				model.m.starfighter.subtract_energy (model.m.starfighter.total_projectile_cost)

				-- creating a projectile
				create {FRIENDLY_PROJECTILE} projectile.make (model.m.projectile_id, model.m.starfighter.total_projectile_damage, 8, model.m.starfighter.pos.row, model.m.starfighter.pos.column + 1)
				model.m.add_friendly_projectile (projectile)
				-- fire statement
				model.m.print_state.set_starfighter_action ("%N    The Starfighter(id:" + model.m.starfighter.id.id.out + ") fires at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out
					 		+ "].")

				-- check to see if spawing location is on board
				if (model.m.starfighter.pos.column + 1) > model.m.grid.width then
						model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile.id.out + ") spawns at location out of board.")

				else

					model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile.id.out + ") spawns at location ["+ model.m.row_name[projectile.pos.row] + "," + projectile.pos.column.out.out + "].")
						if model.m.enemy_projectile_presence (projectile.pos.row, projectile.pos.column) /= -9999 then
							--Spawing in a location that has enemy projectile
							if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (projectile.pos.row, projectile.pos.column)) as ep_obj then
								-- enemy projectile damage is higher than current projectile
									if ep_obj.damage > projectile.damage then
										ep_obj.subtract_damage(projectile.damage)
										projectile.set_on_board(false)
										model.m.print_state.set_starfighter_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")


								-- current projectile damage is higher than enemy projectile	
									elseif projectile.damage > ep_obj.damage then
										projectile.subtract_damage(ep_obj.damage)
										model.m.grid.put ("*", projectile.pos.row, projectile.pos.column)
										ep_obj.set_on_board(false)
										model.m.print_state.set_starfighter_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")
										projectile.set_on_board (true)


								-- current and enemy projectile damage is equal	
									else
										model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
										ep_obj.set_on_board(false)
										model.m.print_state.set_starfighter_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")
										 projectile.set_on_board (false)

									end
							end
						elseif model.m.friendly_projectile_presence (projectile.pos.row, projectile.pos.column) /= -9999 then
							-- Spawning in a location that has friendly projectile
							-- combine the damage of both projectile and remove the exisiting projectile from board
							if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (projectile.pos.row, projectile.pos.column )) as fp_obj then
								projectile.add_damage(fp_obj.damage)
								fp_obj.set_on_board(false)
								model.m.print_state.set_starfighter_action ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
								projectile.set_on_board (true)
							end

						elseif model.m.enemy_presence (projectile.pos.row, projectile.pos.column) /= -9999 then
							-- spwawning in a location that has an enemy
							-- friendly projectile is removed from the board and enemy, depends on it health after collision may or may not be removed from the board
							if attached model.m.enemy_collection.item (model.m.enemy_presence (projectile.pos.row, projectile.pos.column)) as enemy_obj then
								enemy_obj.subtract_health(model.m.max((projectile.damage - enemy_obj.armour), 0))
								projectile.set_on_board (false)
								model.m.print_state.set_starfighter_action ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((projectile.damage - enemy_obj.armour), 0).out  + " damage.")
								if enemy_obj.current_health <= 0 then
									model.m.print_state.set_starfighter_action ("%N      The " + enemy_obj.name +  " at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed.")
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
		local
			break: BOOLEAN
		do

			model.m.print_state.set_friendly_projectile_action_empty

			across 1 |..| -model.m.projectile_id is id
			loop
					if model.m.friendly_projectiles.has (-id) and attached model.m.friendly_projectiles.item (-id) as obj and then obj.on_board then

								if obj.on_board and not break and model.m.in_game then


								-- destination is out of board
										if obj.pos.column + 8 > model.m.grid.width  then
											-- to string
										model.m.grid.put ("_", obj.pos.row, obj.pos.column)
										model.m.print_state.set_friendly_projectile_action ("%N    A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "] -> out of board")
										obj.set_old_pos(obj.pos.row, obj.pos.column)
										obj.set_pos(obj.pos.row, obj.pos.column + 8)
										obj.set_on_board(false)

										else
											model.m.print_state.set_friendly_projectile_action ("%N    A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "] -> [" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + 8).out + "]")
											model.m.grid.put ("_",obj.pos.row, obj.pos.column)
											if model.m.enemy_projectile_presence(obj.pos.row, obj.pos.column + 8) /= -9999  then
												-- collision with <
												if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence(obj.pos.row, obj.pos.column + 8)) as ep_obj then
													-- enemy projectile damage is higher than current projectile
													if ep_obj.damage > obj.damage then
														ep_obj.subtract_damage(obj.damage)

														obj.set_on_board(false)
														model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
														 + "], negating damage.")

													-- current projectile damage is higher than enemy projectile	
													elseif obj.damage > ep_obj.damage then
														obj.subtract_damage(ep_obj.damage)
														model.m.grid.put ("*", obj.pos.row, obj.pos.column + 8)
														ep_obj.set_on_board(false)
														model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
														 + "], negating damage.")
														 obj.set_old_pos(obj.pos.row, obj.pos.column)
															obj.set_pos(obj.pos.row, obj.pos.column + 8)

													-- current and enemy projectile damage is equal	
													else
														obj.set_on_board(false)
														model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
														ep_obj.set_on_board(false)
														model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
														 + "], negating damage.")

													end
												end


											elseif model.m.friendly_projectile_presence (obj.pos.row, obj.pos.column + 8) /= -9999  then
												-- collision with *
												if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (obj.pos.row, obj.pos.column + 8)) as fp_obj then
													obj.add_damage(fp_obj.damage)
													fp_obj.set_on_board(false)
													model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
												end


											elseif model.m.enemy_presence (obj.pos.row, obj.pos.column + 8) /= -9999 then
												-- collision with one of {G, F, C, I, P}

												if attached model.m.enemy_collection.item (model.m.enemy_presence (obj.pos.row, obj.pos.column + 8)) as enemy_obj then
													obj.set_on_board(false)
													enemy_obj.subtract_health(model.m.max((obj.damage - enemy_obj.armour), 0))
													model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((obj.damage - enemy_obj.armour), 0).out  + " damage.")
													if enemy_obj.current_health <= 0 then
														model.m.print_state.set_friendly_projectile_action ("%N      The " + enemy_obj.name +  " at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed.")
														enemy_obj.set_on_board(false)
														model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
														enemy_obj.add_to_focus
													end
												end


											elseif [obj.pos.row, obj.pos.column + 8] ~ model.m.starfighter.pos then
												-- collision with S
												model.m.starfighter.subtract_health(model.m.max((obj.damage - model.m.starfighter.current_armour), 0))
												model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with Starfighter (id:" + model.m.starfighter.id.id.out + ") at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], dealing " +  model.m.max((obj.damage - model.m.starfighter.current_armour), 0).out  + " damage.")
												obj.set_on_board(false)

												if model.m.starfighter.current_health <= 0 then
													-- game over
													model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
													model.m.starfighter.set_current_health (0)
													model.m.print_state.set_friendly_projectile_action ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed")
													model.m.toggle_in_game
													model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")
													break := true
												end
											else
												-- update its old_pos and current pos
												obj.set_old_pos(obj.pos.row, obj.pos.column)
												obj.set_pos(obj.pos.row, obj.pos.column + 8)
												model.m.grid.put ("*",obj.pos.row, obj.pos.column)
											end

										end
								end

					end

			end


		end




end
