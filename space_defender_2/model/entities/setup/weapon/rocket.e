note
	description: "Summary description for {ROCKET}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WEAPON_ROCKET

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
			name.make_from_string ("Rocket")
			health  := 10
			energy := 0
			regen :=[10,0]
			armour := 2
			vision := 2
			move := 0
			move_cost := 3
			projectile_damage := 100
			projectile_cost := 10

		end


	fire
		local
			projectile1, projectile2: FRIENDLY_PROJECTILE
		do

				model.m.print_state.set_starfighter_action_empty
			-- subtracting the costing of firing
				model.m.starfighter.subtract_health (model.m.starfighter.total_projectile_cost)

			-- creating projectiles
				create {FRIENDLY_PROJECTILE} projectile1.make (model.m.projectile_id, model.m.starfighter.total_projectile_damage, 1, model.m.starfighter.pos.row - 1, model.m.starfighter.pos.column - 1)
				model.m.add_friendly_projectile (projectile1)
				create {FRIENDLY_PROJECTILE} projectile2.make (model.m.projectile_id, model.m.starfighter.total_projectile_damage, 1, model.m.starfighter.pos.row + 1, model.m.starfighter.pos.column - 1)
				model.m.add_friendly_projectile (projectile2)

			-- fire to string
				model.m.print_state.set_starfighter_action ("%N    The Starfighter(id:" + model.m.starfighter.id.id.out + ") fires at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out
				 		+ "].")


			-- top left of SF
				-- spawning outside the board
				if ((projectile1.pos.row) < 1) or ((projectile1.pos.column) < 1) then
					model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile1.id.out + ") spawns at location out of board.")

				else
					-- subtract cost

					model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile1.id.out + ") spawns at location ["+ model.m.row_name[projectile1.pos.row] + "," + projectile1.pos.column.out.out + "].")

					if model.m.enemy_projectile_presence (projectile1.pos.row, projectile1.pos.column) /= -9999 then
						-- Spawing in a location that has <
							if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (projectile1.pos.row, projectile1.pos.column)) as ep_obj then
								-- enemy projectile damage is higher than current projectile
									if ep_obj.damage > projectile1.damage then
										ep_obj.subtract_damage(projectile1.damage)
									--	model.m.grid.put ("_", projectile1.pos.row, projectile1.pos.column)
										model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")
										 projectile1.set_on_board (false)

								-- current projectile damage is higher than enemy projectile	
									elseif projectile1.damage > ep_obj.damage then
										projectile1.subtract_damage(ep_obj.damage)
										model.m.grid.put ("*", projectile1.pos.row, projectile1.pos.column)
										ep_obj.set_on_board(false)
										model.m.print_state.set_starfighter_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")
										projectile1.set_on_board (true)


								-- current and enemy projectile damage is equal	
									else
										model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
										ep_obj.set_on_board(false)
										model.m.print_state.set_starfighter_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")

									end
							end


					elseif model.m.friendly_projectile_presence (model.m.starfighter.pos.row - 1, model.m.starfighter.pos.column - 1) /= -9999 then
						-- Spawning in a location that has *

						if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (projectile1.pos.row, projectile1.pos.column )) as fp_obj then
								projectile1.add_damage(fp_obj.damage)
								fp_obj.set_on_board(false)
								model.m.print_state.set_starfighter_action ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
								model.m.grid.put ("*", projectile1.pos.row, projectile1.pos.column)
								projectile1.set_on_board (true)
						end


					elseif model.m.enemy_presence (model.m.starfighter.pos.row - 1, model.m.starfighter.pos.column - 1) /= -9999 then
						-- spwawning in a location that has one of {G, F, C, I, P}

						if attached model.m.enemy_collection.item (model.m.enemy_presence (projectile1.pos.row, projectile1.pos.column)) as enemy_obj then
								enemy_obj.subtract_health(model.m.max((projectile1.damage - enemy_obj.armour), 0))
								model.m.print_state.set_starfighter_action ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((projectile1.damage - enemy_obj.armour), 0).out  + " damage.")
								if enemy_obj.current_health <= 0 then
									model.m.print_state.set_starfighter_action ("%N      The " + enemy_obj.name +  " at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed.")
									enemy_obj.set_on_board(false)
									model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
									enemy_obj.add_to_focus
								end
						end

					else
						model.m.grid.put ("*", projectile1.pos.row, projectile1.pos.column)
						projectile1.set_on_board (true)

					end

				end


			-- Bottom left of SF
				-- spawning outside the board
				if ((projectile2.pos.row) > model.m.grid.height) or ((projectile2.pos.column) < 1) then

					model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile2.id.out + ") spawns at location out of board.")

				else
					model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile2.id.out + ") spawns at location ["+ model.m.row_name[projectile2.pos.row] + "," + projectile2.pos.column.out + "].")
					if model.m.enemy_projectile_presence (model.m.starfighter.pos.row + 1, model.m.starfighter.pos.column - 1) /= -9999 then
						-- Spawing in a location that has <
						if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (projectile2.pos.row, projectile2.pos.column)) as ep_obj then
								-- enemy projectile damage is higher than current projectile
									if ep_obj.damage > projectile2.damage then
										ep_obj.subtract_damage(projectile2.damage)
									--	model.m.grid.put ("_", projectile2.pos.row, projectile2.pos.column)
										model.m.print_state.set_starfighter_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")
										 projectile2.set_on_board (false)

								-- current projectile damage is higher than enemy projectile	
									elseif projectile2.damage > ep_obj.damage then
										projectile2.subtract_damage(ep_obj.damage)
										model.m.grid.put ("*", projectile2.pos.row, projectile2.pos.column)
										ep_obj.set_on_board(false)
										model.m.print_state.set_starfighter_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")
										projectile2.set_on_board (true)


								-- current and enemy projectile damage is equal	
									else
										model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
										ep_obj.set_on_board(false)
										model.m.print_state.set_starfighter_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")
										 projectile2.set_on_board (false)

									end
						end


					elseif model.m.friendly_projectile_presence (model.m.starfighter.pos.row + 1, model.m.starfighter.pos.column - 1) /= -9999 then
						-- Spawning in a location that has friendly *

						if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (projectile2.pos.row, projectile2.pos.column )) as fp_obj then
								projectile1.add_damage(fp_obj.damage)
								fp_obj.set_on_board(false)
								model.m.print_state.set_starfighter_action ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
								model.m.grid.put ("*", projectile2.pos.row, projectile2.pos.column)
								projectile2.set_on_board (true)
						end

					elseif model.m.enemy_presence (model.m.starfighter.pos.row + 1, model.m.starfighter.pos.column - 1) /= -9999 then
						-- spawning in a location that has one of {G, F, C, I, P}
						if attached model.m.enemy_collection.item (model.m.enemy_presence (projectile2.pos.row, projectile2.pos.column)) as enemy_obj then
								enemy_obj.subtract_health(model.m.max((projectile2.damage - enemy_obj.armour), 0))
								model.m.print_state.set_starfighter_action ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((projectile2.damage - enemy_obj.armour), 0).out  + " damage.")
								if enemy_obj.current_health <= 0 then
									model.m.print_state.set_starfighter_action ("%N      The " + enemy_obj.name +  " at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed.")
									enemy_obj.set_on_board(false)
									model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
									enemy_obj.add_to_focus
								end
						end

					else
						model.m.grid.put ("*", projectile2.pos.row, projectile2.pos.column)
						projectile2.set_on_board (true)
					end

				end

		end

	friendly_projectile_act
		local
			i: INTEGER
			output, output1, output2, destination1, destination2: STRING
			break: BOOLEAN
			keys: ARRAY[INTEGER]
		do
			model.m.print_state.set_friendly_projectile_action_empty
			create keys.make_from_array (model.m.friendly_projectiles.current_keys)
			create output.make_empty
			create output1.make_empty
			create output2.make_empty
			create destination1.make_empty
			create destination2.make_empty

			from
				i := 1
			until
				i > keys.count
			loop
				output.make_empty
				output1.make_empty
				output2.make_empty
				destination1.make_empty
				destination2.make_empty
				-- move top left
						if attached model.m.friendly_projectiles.item (keys[i]) as obj then

									if obj.on_board and not break and model.m.in_game then
													destination1.append ("%N    A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "] -> ")
													across 1 |..| obj.move is index
													loop
														-- loop only if the previous move did not result in out of board movement
																if obj.on_board and not break then
																				if obj.pos.column + index > model.m.grid.width then
																					-- projectiles moves out of board
																					model.m.grid.put ("_", obj.pos.row, obj.pos.column)
																					destination1.append ("out of board")
																					obj.set_old_pos(obj.pos.row, obj.pos.column)
																					obj.set_pos(obj.pos.row , obj.pos.column + index)
																					obj.set_on_board(false)

																				else


																					if model.m.friendly_projectile_presence (obj.pos.row , obj.pos.column + index) /= -9999 then
																						-- collison with *
																						if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (obj.pos.row , obj.pos.column + index)) as fp_obj then
																							obj.add_damage(fp_obj.damage)
																							model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
																							fp_obj.set_on_board(false)

																							output1.append ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
																						end


																					elseif model.m.enemy_projectile_presence (obj.pos.row , obj.pos.column + index) /= -9999  then
																						-- collision with <
																						if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence(obj.pos.row, obj.pos.column + index)) as ep_obj then
																								-- enemy projectile damage is higher than current projectile
																								if ep_obj.damage > obj.damage then
																									ep_obj.subtract_damage(obj.damage)
																									model.m.grid.put ("_", obj.pos.row, obj.pos.column)
																									obj.set_on_board(false)
																									output1.append ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
																									 + "], negating damage.")
																									destination1.append ("[" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")


																								-- current projectile damage is higher than enemy projectile	
																								elseif obj.damage > ep_obj.damage then
																									obj.subtract_damage(ep_obj.damage)
																									model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
																									ep_obj.set_on_board(false)
																									output1.append ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
																									 + "], negating damage.")

																								-- current and enemy projectile damage is equal	
																								else
																									model.m.grid.put ("_", obj.pos.row, obj.pos.column)
																									obj.set_on_board(false)
																									model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
																									ep_obj.set_on_board(false)
																									output1.append ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
																									 + "], negating damage.")
																									destination1.append ("[" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")

																								end
																							end



																					elseif model.m.enemy_presence (obj.pos.row , obj.pos.column + index) /= -9999  then
																						-- collision with one of {G, F, C, I, P}
																						if attached model.m.enemy_collection.item (model.m.enemy_presence (obj.pos.row, obj.pos.column + index)) as enemy_obj then
																							model.m.grid.put ("_", obj.pos.row, obj.pos.column)
																							obj.set_on_board(false)
																							destination1.append ("[" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")

																							enemy_obj.subtract_health(model.m.max((obj.damage - enemy_obj.armour), 0))
																							output1.append ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((obj.damage - enemy_obj.armour), 0).out  + " damage.")

																							if enemy_obj.current_health <= 0 then
																								output1.append ("%N      The " + enemy_obj.name +  " at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed.")
																								enemy_obj.set_on_board(false)
																								model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
																								enemy_obj.add_to_focus

																							end
																						end


																					elseif model.m.starfighter.pos ~ [obj.pos.row , obj.pos.column + index] then
																						-- collision with S
																						model.m.starfighter.subtract_health(model.m.max((obj.damage - model.m.starfighter.current_armour), 0))
																						output1.append ("%N      The projectile collides with Starfighter(id:" + model.m.starfighter.id.id.out + ") at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], dealing " +  model.m.max((obj.damage - model.m.starfighter.current_armour), 0).out  + " damage.")
																						obj.set_on_board(false)
																						destination1.append ("[" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")


																						model.m.grid.put ("_", obj.pos.row, obj.pos.column)
																						if model.m.starfighter.current_health <= 0 then
																							-- game over
																							model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
																							model.m.starfighter.set_current_health (0)
																							output1.append ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")

																							model.m.toggle_in_game
																							model.m.game_state.set_state ("not started", "ok")
																							model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")
																							break := true
																						end



																					else
																						-- do nothing and go for next iteration	

																					end

																				end
																end

													end

													-- if still on board and not destroyed then move projectile to its final destination
													if obj.on_board and not break then
														model.m.grid.put ("_",obj.pos.row, obj.pos.column)
														obj.set_old_pos(obj.pos.row, obj.pos.column)
														obj.set_pos(obj.pos.row , obj.pos.column + obj.move)
														model.m.grid.put ("*",obj.pos.row, obj.pos.column)

														-- to string
														destination1.append ("[" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "]")
														-- doubling its move for next turn
														obj.update_move (2 * obj.move)

													end

									end

						end

			-- move bottom left
				-- move top left
				if attached model.m.friendly_projectiles.item (keys[i + 1]) as obj then
					if obj.on_board then
							destination2.append ("%N    A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "] -> ")
							across 1 |..| obj.move is index
							loop
								-- loop only if the previous move did not result in out of board movement
								if obj.on_board then
									if obj.pos.column + index > model.m.grid.width then
										-- projectiles moves out of board
										model.m.grid.put ("_", obj.pos.row, obj.pos.column)
										destination2.append ("out of board")
										obj.set_old_pos(obj.pos.row, obj.pos.column)
										obj.set_pos(obj.pos.row , obj.pos.column + index)
										obj.set_on_board(false)

									else


										if model.m.friendly_projectile_presence (obj.pos.row , obj.pos.column + index) /= -9999 then
											-- collison with *
											if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (obj.pos.row , obj.pos.column + index)) as fp_obj then
												obj.add_damage(fp_obj.damage)
												model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
												fp_obj.set_on_board(false)
												output2.append ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
											end


										elseif model.m.enemy_projectile_presence (obj.pos.row , obj.pos.column + index) /= -9999  then
											-- collision with <
											if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence(obj.pos.row, obj.pos.column + index)) as ep_obj then
													-- enemy projectile damage is higher than current projectile
													if ep_obj.damage > obj.damage then
														ep_obj.subtract_damage(obj.damage)
														model.m.grid.put ("_", obj.pos.row, obj.pos.column)
														obj.set_on_board(false)
														output2.append ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
														 + "], negating damage.")
														destination2.append ("[" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")


													-- current projectile damage is higher than enemy projectile	
													elseif obj.damage > ep_obj.damage then
														obj.subtract_damage(ep_obj.damage)
														model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
														ep_obj.set_on_board(false)
														output2.append ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
														 + "], negating damage.")



													-- current and enemy projectile damage is equal	
													else
														model.m.grid.put ("_", obj.pos.row, obj.pos.column)
														obj.set_on_board(false)
														model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
														ep_obj.set_on_board(false)
														output2.append ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
														 + "], negating damage.")
														destination2.append ("[" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")
													end
												end



										elseif model.m.enemy_presence (obj.pos.row , obj.pos.column + index) /= -9999  then
											-- collision with one of {G, F, C, I, P}
											if attached model.m.enemy_collection.item (model.m.enemy_presence (obj.pos.row, obj.pos.column + index)) as enemy_obj then
												obj.set_on_board(false)
												model.m.grid.put ("_", obj.pos.row, obj.pos.column)
												destination2.append ("[" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")
												enemy_obj.subtract_health(model.m.max((obj.damage - enemy_obj.armour), 0))

												output2.append("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((obj.damage - enemy_obj.armour), 0).out  + " damage.")
												if enemy_obj.current_health <= 0 then

													output2.append ("%N      The " + enemy_obj.name +  " at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed.")
													enemy_obj.set_on_board(false)
													model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
													enemy_obj.add_to_focus

												end
											end


										elseif model.m.starfighter.pos ~ [obj.pos.row , obj.pos.column + index] then
											-- collision with S
											model.m.starfighter.subtract_health(model.m.max((obj.damage - model.m.starfighter.current_armour), 0))
											output2.append ("%N      The projectile collides with Starfighter(id:" + model.m.starfighter.id.id.out + ") at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], dealing " +  model.m.max((obj.damage - model.m.starfighter.current_armour), 0).out  + " damage.")

											obj.set_on_board(false)
											destination2.append ("[" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + index).out + "]")
											model.m.grid.put ("_", obj.pos.row, obj.pos.column)
											if model.m.starfighter.current_health <= 0 then
												-- game over
												obj.set_on_board (false)
												model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
												model.m.starfighter.set_current_health (0)
												output2.append ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
												model.m.toggle_in_game
												model.m.game_state.set_state ("not started", "ok")
												model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")
												break := true
											end



										else
											-- do nothing and go for next iteration	

										end

									end
								end

							end

							-- if still on board and not destroyed then move projectile to its final destination
							if obj.on_board then
								model.m.grid.put ("_",obj.pos.row, obj.pos.column)
								obj.set_old_pos(obj.pos.row, obj.pos.column)
								obj.set_pos(obj.pos.row , obj.pos.column + obj.move)
								model.m.grid.put ("*",obj.pos.row, obj.pos.column)

								destination2.append ("[" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "]")

								-- doubling its move for next turn
								obj.update_move (2 * obj.move)

							end
					end
				end
			i := i + 2

			model.m.print_state.set_friendly_projectile_action (destination1 + output1 + destination2 +  output2)
			end

		--	output.append (destination1 + output1 + destination2 +  output2

		end



end
