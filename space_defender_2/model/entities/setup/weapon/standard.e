note
	description: "Summary description for {STANDARD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WEAPON_STANDARD

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
			 name.make_from_string ("Standard")
			health  := 10
			energy := 10
			create regen.default_create
				regen :=[0,1]
			armour := 0
			vision := 1
			move := 1
			move_cost := 1
			projectile_damage := 70
			projectile_cost := 5

		end



	fire
		local
			projectile: FRIENDLY_PROJECTILE
		do



			model.m.starfighter.subtract_energy (model.m.starfighter.total_projectile_cost)
			model.m.print_state.set_starfighter_action_empty
			-- create a projectile
			create {FRIENDLY_PROJECTILE} projectile.make (model.m.projectile_id, model.m.starfighter.total_projectile_damage, 5, model.m.starfighter.pos.row, model.m.starfighter.pos.column + 1)
			model.m.add_friendly_projectile (projectile)
			-- fire statement (string)
			model.m.print_state.set_starfighter_action ("%N    The Starfighter(id:" + model.m.starfighter.id.id.out + ") fires at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out
				 		+ "].")


			-- check to see if spawing location is on board
			if (model.m.starfighter.pos.column) > model.m.grid.width then
					model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile.id.out + ") spawns at location out of board.")


			else
				model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile.id.out + ") spawns at location ["+ model.m.row_name[projectile.pos.row] + "," + projectile.pos.column.out.out + "].")
					if model.m.enemy_projectile_presence (model.m.starfighter.pos.row, model.m.starfighter.pos.column + 1) /= -9999 then
								--Spawning in a location that has enemy projectile

								if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (projectile.pos.row, projectile.pos.column)) as ep_obj then
											-- enemy projectile damage is higher than current projectile
												if ep_obj.damage > projectile.damage then
													ep_obj.subtract_damage(projectile.damage)
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
							model.m.grid.put ("*", projectile.pos.row, projectile.pos.column)
						end

					elseif model.m.enemy_presence (projectile.pos.row, projectile.pos.column ) /= -9999 then
						-- spawning in a location that has an enemy
						-- friendly projectile is removed from the board and enemy, depends on it health after collision may or may not be removed from the board

						if attached model.m.enemy_collection.item (model.m.enemy_presence (projectile.pos.row, projectile.pos.column)) as enemy_obj then
							enemy_obj.subtract_health(model.m.max((projectile.damage - enemy_obj.armour), 0))
							model.m.print_state.set_starfighter_action ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((projectile.damage - enemy_obj.armour), 0).out  + " damage.")
							if enemy_obj.current_health <= 0 then
								enemy_obj.set_current_health (0)
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
			output, destination: STRING
			break: BOOLEAN
		do
			create destination.make_empty
			create output.make_empty
			model.m.print_state.set_friendly_projectile_action_empty
			across 1 |..| -model.m.projectile_id is id
			loop
					output.make_empty
					destination.make_empty

					if model.m.friendly_projectiles.has (-id) and attached model.m.friendly_projectiles.item (-id) as obj and then obj.on_board then

					destination.append ("%N    A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "] -> ")
							model.m.grid.put ("_", obj.pos.row, obj.pos.column)
							across 1 |..| 5 is index
							loop
								if obj.on_board and not break and model.m.in_game then


								-- next position is out of board
									if obj.pos.column + index > model.m.grid.width  then
										-- to string
									model.m.grid.put ("_", obj.pos.row, obj.pos.column)
									destination.append ("out of board")
									obj.set_old_pos(obj.pos.row, obj.pos.column)
									obj.set_pos(obj.pos.row, obj.pos.column + index)
									obj.set_on_board(false)


									else
											-- enemy projectile exist next to current projectile
											if model.m.enemy_projectile_presence(obj.pos.row, obj.pos.column + index) /= -9999  then

												if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence(obj.pos.row, obj.pos.column + index)) as ep_obj then
													-- enemy projectile damage is higher than current projectile
													if ep_obj.damage > obj.damage then
														ep_obj.subtract_damage(obj.damage)
														model.m.grid.put ("_", obj.pos.row, obj.pos.column)
														obj.set_on_board(false)
														output.append ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
														 + "], negating damage.")

													--	output.prepend("%N      A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.old_pos.row] + "," + obj.old_pos.column.out + "] -> [" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")
														destination.append ("[" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")

													-- current projectile damage is higher than enemy projectile	
													elseif obj.damage > ep_obj.damage then
														obj.subtract_damage(ep_obj.damage)
														ep_obj.set_on_board(false)
														model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
														output.append ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
														 + "], negating damage.")

													-- current and enemy projectile damage is equal	
													else
														model.m.grid.put ("_", obj.pos.row, obj.pos.column)
														obj.set_on_board(false)
														model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
														ep_obj.set_on_board(false)
														output.append ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
														 + "], negating damage.")
														destination.append ("[" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")

													end
												end

											-- friendly projectile exists next to current projectile
											elseif model.m.friendly_projectile_presence (obj.pos.row, obj.pos.column + index) /= -9999  then

													if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (obj.pos.row, obj.pos.column + index)) as fp_obj then
														obj.add_damage(fp_obj.damage)
														fp_obj.set_on_board(false)
														output.append ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
													end

											-- enemy exist next to current projectile
											elseif model.m.enemy_presence (obj.pos.row, obj.pos.column + index) /= -9999 then
													if attached model.m.enemy_collection.item (model.m.enemy_presence (obj.pos.row, obj.pos.column + index)) as enemy_obj then
														obj.set_on_board(false)
														destination.append ("[" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")
														enemy_obj.subtract_health(model.m.max((obj.damage - enemy_obj.armour), 0))
														output.append ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((obj.damage - enemy_obj.armour), 0).out  + " damage.")
														if enemy_obj.current_health <= 0 then
															output.append ("%N      The " + enemy_obj.name +  " at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed.")
															enemy_obj.set_on_board(false)
															model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
															enemy_obj.add_to_focus

														end
													end

											-- starfighter exist next to projectile	
											elseif [obj.pos.row, obj.pos.column + index] ~ model.m.starfighter.pos then
												model.m.starfighter.subtract_health(model.m.max((obj.damage - model.m.starfighter.current_armour), 0))
												output.append ("%N      The projectile collides with Starfighter (id:" + model.m.starfighter.id.id.out + ") at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], dealing " +  model.m.max((obj.damage - model.m.starfighter.current_armour), 0).out  + " damage.")
												obj.set_on_board(false)
												destination.append ("[" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")

												model.m.grid.put ("_", obj.pos.row, obj.pos.column)
												if model.m.starfighter.current_health <= 0 then
													-- game over
													model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
													model.m.starfighter.set_current_health (0)
													output.append ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed")
													model.m.toggle_in_game
													model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")
													break := true
												end

											else
												-- do nothing and go for next iteration

											end

									end
							end
						end
						-- end of inner loop
						-- if we reach here and projectile is still `on_board` then we update its old_pos and current pos

						if obj.on_board then
							model.m.grid.put ("_",obj.pos.row, obj.pos.column)
							obj.set_old_pos(obj.pos.row, obj.pos.column)
							obj.set_pos(obj.pos.row, obj.pos.column + 5)
							model.m.grid.put ("*",obj.pos.row, obj.pos.column)

							-- to string

							destination.append ("[" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "]")
						end

					end
					model.m.print_state.set_friendly_projectile_action (destination + output)
			end
			-- end of outer loop


		end

end
