note
	description: "Summary description for {PYLON}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PYLON

inherit
	ENEMY

create
	make

feature
	make (i: INTEGER)
		do
			create name.make_from_string ("Pylon")
			create symbol.make_from_string ("P")
			create pos.default_create
			pos.compare_objects
			create old_pos.default_create
			total_health := 300
			current_health := 300
		 	regen := 0
		 	armour := 0
		 	vision := 5
		 	id := i
		 	create output.make_empty

		end


feature -- queries	

	get_name: STRING
		do
		 	create result.make_empty
		 	result.append(name)

		end


	get_symbol: STRING
		do
			create result.make_empty
			result.append(symbol)
		end
	can_see_starfighter(row: INTEGER; column: INTEGER) : BOOLEAN
		do
			if ((pos.row - row).abs  + (pos.column - column).abs) <=  vision then
			 	result := true
			 else
			 	result := false
			 end

		end


feature -- 	commands

	set_turn(b: BOOLEAN)
		do
			end_turn := b
		end

	add_health(h: INTEGER)
		do
			current_health := current_health + h
			if current_health >= total_health then
				current_health := total_health
			end
		end


	set_current_health(h: INTEGER)
		do
			current_health := h
		end

	set_on_board(b: BOOLEAN)
		do
			on_board := b
		end

	set_seen_by_sf(b: BOOLEAN)
		do
			seen_by_sf := b
		end

	set_can_see_sf(b: BOOLEAN)
		do
			can_see_sf := b
		end

	set_pos(row: INTEGER; column: INTEGER)
		do
			pos := [row, column]
		end
	set_old_pos(row: INTEGER; column: INTEGER)
		do
			old_pos := [row, column]
		end

	update_can_see_sf
		do
			current.set_can_see_sf ( can_see_starfighter(model.m.starfighter.pos.row, model.m.starfighter.pos.column))
		end

	update_seen_by_sf
		do
			current.set_seen_by_sf (model.m.starfighter.seen_by_starfighter(current.pos.row, current.pos.column))
		end


	subtract_health(h: INTEGER)
		do
			current_health := current_health - h
		end

	add_to_focus
		local
			platinum: FOCUS
		do
			create {PLATINUM} platinum.make
			model.m.total_score.add (platinum)
		end


	preemptive_action(command: STRING)
		do
			-- no preemptive action
			output.make_empty
		end

	action
		local
			projectile: ENEMY_PROJECTILE
			break: BOOLEAN
			destination : STRING
		do
			output.make_empty
			create destination.make_empty
			-- when SF is not seen
			if (not can_see_starfighter(model.m.starfighter.pos.row, model.m.starfighter.pos.column)) then
					destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") moves: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "] -> ")
								model.m.grid.put ("_", pos.row, pos.column)
								across 1 |..| 2  is index
								loop
									-- loop only if the enemy is still on board

											if current.on_board and not break then

													if  (pos.column - index) < 1 then

															destination.append ("out of board")
															model.m.grid.put ("_", pos.row, pos.column)
															on_board := false
													else

															if model.m.starfighter.pos ~ [pos.row, pos.column - index] then
																--perform some update based on collision with S

																destination.append ("[" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "]")
																output.append ("%N      The " + current.name + " collides with Starfighter(id:0) at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], trading "  + current.current_health.out + " damage.")
																output.append ("%N      The " + current.name + " at location [" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "] has been destroyed.")
																current.set_on_board (false)
																model.m.starfighter.subtract_health (current.current_health)
																model.m.grid.put ("_", current.pos.row, current.pos.column)
																current.add_to_focus
																if model.m.starfighter.current_health <= 0  then
																	model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
																	model.m.starfighter.set_current_health (0)
																	output.append ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
																	model.m.toggle_in_game
																	break := true
																	model.m.game_state.set_state ("not started", "ok")
																	model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")
																end


															elseif model.m.friendly_projectile_presence (pos.row, pos.column - index) /= -9999 then
																-- loop over `friendly` projectile array and perform some update based on collision with *
																if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (pos.row, pos.column - index)) as fp_obj then
																	fp_obj.set_on_board(false)
																	model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
																	current.subtract_health (model.m.max (fp_obj.damage - current.armour, 0))

																	output.append ("%N      The " + current.name + " collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], taking " + model.m.max (fp_obj.damage - current.armour, 0).out + " damage.")

																	if current.current_health <= 0 then
																		current.set_on_board (false)
																		current.add_to_focus
																		destination.append ("[" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "]")
																		output.append ("%N      The " + current.name + " at location [" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "] has been destroyed.")

																	end

																end



															elseif model.m.enemy_presence (pos.row, pos.column - index) /= -9999 then
																-- no movement of `current` enemy since it has to stop one place before hitting the other enemy
																break := true
																if current.pos ~ [pos.row, pos.column - (index - 1)] then
																	model.m.grid.put (current.symbol, current.pos.row, current.pos.column)
																	destination.make_empty
																	destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") stays at: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")

																else
																	model.m.grid.put ("_", pos.row, pos.column)
																	current.set_old_pos (pos.row, pos.column)
																	current.set_pos (pos.row, pos.column - (index - 1))
																	model.m.grid.put (current.symbol, pos.row, pos.column )
																	destination.append ("[" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")

																end

																-- heal all enemies within the vision
																current.heal (current)


															elseif model.m.enemy_projectile_presence (pos.row, pos.column - index) /= -9999 then
																-- loop over the `enemy projectiles` array and perform some update based on collision with enemy projectile
																if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (pos.row, pos.column - index)) as ep_obj then
																	output.append ("%N      The " + current.name + " collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out + "], healing " + ep_obj.damage.out + " damage.")
																	ep_obj.set_on_board(false)
																	model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
																	current.add_health (ep_obj.damage)

																	if current.current_health > current.total_health then
																		current.set_current_health (current.total_health)
																	end
																end

															else

															end

													end

											end

								end  -- end of loop

								-- if still on board and not destroyed, heal all the enemies within the vision
								if on_board and not break then
									-- loop over the `enemies array` and heal those who are in your vision

									model.m.grid.put ("_", pos.row, pos.column)
									current.set_old_pos (pos.row, pos.column)
									current.set_pos (pos.row, pos.column - 2)
									model.m.grid.put (current.symbol, pos.row, pos.column)
									destination.append ("[" + model.m.row_name[current.pos.row] + "," + current.pos.column .out + "]")

									current.heal (current)

								end

			-- when SF is seen
			else
				destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") moves: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "] -> ")
					model.m.grid.put ("_", pos.row, pos.column)
							across 1 |..| 1  is index
							loop
								-- loop only if enemy is still on board
									if current.on_board and not break then
											if  (pos.column - index) < 1 then
												destination.append ("out of board")
												model.m.grid.put ("_", pos.row, pos.column)
												on_board := false
											else

													if model.m.starfighter.pos ~ [pos.row, pos.column - index] then
														--perform some update based on collision with S

														destination.append ("[" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "]")
														output.append ("%N      The " + current.name + " collides with Starfighter(id:0) at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], trading "  + current.current_health.out + " damage.")
														output.append ("%N      The " + current.name + " at location [" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "] has been destroyed.")
														current.set_on_board (false)
														model.m.starfighter.subtract_health (current.current_health)
														model.m.grid.put ("_", current.pos.row, current.pos.column)
														current.add_to_focus
														if model.m.starfighter.current_health <= 0  then
															model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
															model.m.starfighter.set_current_health (0)
															output.append ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
															model.m.toggle_in_game
															break := true
															model.m.game_state.set_state ("not started", "ok")
															model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")
														end

													elseif model.m.friendly_projectile_presence (pos.row, pos.column - index) /= -9999 then
														-- loop over `friendly` projectile array and perform some update based on collision with *
														if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (pos.row, pos.column - index)) as fp_obj then
															fp_obj.set_on_board(false)
															model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
															current.subtract_health (model.m.max (fp_obj.damage - current.armour, 0))

															output.append ("%N      The " + current.name + " collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], taking " + model.m.max (fp_obj.damage - current.armour, 0).out + " damage.")

															if current.current_health <= 0 then
																current.set_on_board (false)
																current.add_to_focus
																destination.append ("[" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "]")
																output.append ("%N      The " + current.name + " at location [" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "] has been destroyed.")

															end

														end


													elseif model.m.enemy_presence (pos.row, pos.column - index) /= -9999 then
														-- no movement of `current` enemy since it has to stop one place before hitting the other enemy
														break := true
														if current.pos ~ [pos.row, pos.column - (index - 1)] then
															destination.make_empty
															destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") stays at: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")
															model.m.grid.put(current.symbol, current.pos.row, current.pos.column)

														else
															model.m.grid.put ("_", pos.row, pos.column)
															current.set_old_pos (pos.row, pos.column)
															current.set_pos (pos.row, pos.column - (index - 1))
															model.m.grid.put (current.symbol, pos.row, pos.column )
															destination.append ("[" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")
														end

														-- spawn a projectile
														create projectile.make (model.m.projectile_id, 70, 2, pos.row, pos.column - 1)
														model.m.add_enemy_projectile (projectile)
														current.spawn_projectile(projectile)


													elseif model.m.enemy_projectile_presence (pos.row, pos.column - index) /= -9999 then
														-- loop over the `enemy projectiles` array and perform some update based on collision with enemy projectile
														if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (pos.row, pos.column - index)) as ep_obj then
															output.append ("%N      The " + current.name + " collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out + "], healing " + ep_obj.damage.out + " damage.")
															ep_obj.set_on_board(false)
															model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
															current.add_health (ep_obj.damage)
															if current.current_health > current.total_health then
																current.set_current_health (current.total_health)
															end
														end

													else
														-- do nothing and go for next iteration
													end


											end

									end

							end  -- end of loop

							if on_board and not break then
								model.m.grid.put ("_", pos.row, pos.column)
								model.m.grid.put (current.symbol, pos.row, pos.column - 1)
								current.set_old_pos (pos.row, pos.column)
								current.set_pos (pos.row, pos.column - 1)

								destination.append ("[" + model.m.row_name[pos.row] + "," + pos.column.out + "]")

								-- spawn a projectile
								create projectile.make (model.m.projectile_id, 70, 2, pos.row, pos.column - 1)
								model.m.add_enemy_projectile (projectile)
								current.spawn_projectile(projectile)

							end





			end  -- end of first if
			model.m.print_state.set_enemy_action (destination + output)

	end -- end of do



	spawn_projectile(projectile: ENEMY_PROJECTILE)
			do
				if  projectile.pos.column < 1 then
					--	model.m.print_state.set_enemy_action("%N      A enemy projectile(id:" + projectile.id.out + ") spawns at location out of board.")
					output.append("%N      A enemy projectile(id:" + projectile.id.out + ") spawns at location out of board.")
				else
				 	--	model.m.print_state.set_enemy_action("%N      A enemy projectile(id:" + model.m.projectile_id.out + ") spawns at location [" + model.m.row_name[pos.row] + "," + (pos.column - 1).out + "].")
					output.append("%N      A enemy projectile(id:" + projectile.id.out + ") spawns at location [" + model.m.row_name[projectile.pos.row] + "," + projectile.pos.column.out + "].")

					if model.m.enemy_projectile_presence (pos.row, pos.column - 1) /= -9999 then
						-- spawn location contains enemy projectile (friendly projectile for an enemy)
						if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (pos.row, pos.column - 1)) as ep_obj then
							ep_obj.set_on_board (false)
							projectile.add_damage (ep_obj.damage)
							projectile.set_on_board (true)
							output.append ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out + "], combining damage.")
						end

					elseif model.m.friendly_projectile_presence (pos.row, pos.column - 1) /= -9999 then
						-- spawn location contains friendly projectile (enemy projectile for an enemy)

						if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence(pos.row, pos.column - 1)) as fp_obj then
							-- friendly projectile damage is higher than current projectile
							if fp_obj.damage > projectile.damage then
								fp_obj.subtract_damage(projectile.damage)
--										print_state.set_enemy_projectile_action ("%N    The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out
--										 + "], negating damage.")
								output.append ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out
								 + "], negating damage.")

							-- current projectile damage is higher than friendly projectile	
							elseif projectile.damage > fp_obj.damage then
								projectile.subtract_damage(fp_obj.damage)
								fp_obj.set_on_board(false)
								projectile.set_on_board (true)
								model.m.grid.put ("<", projectile.pos.row, projectile.pos.column)
--										print_state.set_enemy_projectile_action ("%N    The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out
--										 + "], negating damage.")

								output.append("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out
								 + "], negating damage.")


							-- current and friendly projectile damage is equal	
							else
								model.m.grid.put ("_",fp_obj.pos.row, fp_obj.pos.column)
								fp_obj.set_on_board(false)
--										print_state.set_enemy_projectile_action ("%N    The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out
--										 + "], negating damage.")

								output.append ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out
								 + "], negating damage.")

							end
						end

					elseif model.m.enemy_presence (pos.row, pos.column - 1) /= -9999 then
						-- another enemy is located at next location
						if attached model.m.enemy_collection.item (model.m.enemy_presence (pos.row, pos.column - 1)) as enemy_obj then
							enemy_obj.add_health (projectile.damage)
							if enemy_obj.current_health > enemy_obj.total_health then
								enemy_obj.set_current_health (enemy_obj.total_health)
							end
							output.append ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], healing " +  projectile.damage.out  + " damage.")
						end

					elseif model.m.starfighter.pos ~ [pos.row, pos.column - 1]  then
						-- spwan location contains a Starfighter
						model.m.starfighter.subtract_health (model.m.max (projectile.damage - model.m.starfighter.current_armour, 0))
						output.append ("%N      The projectile collides with Starfighter(id:0) at location [" + model.m.row_name[model.m.starfighter.pos.row] + ","  + model.m.starfighter.pos.column.out + "], dealing " + model.m.max (projectile.damage - model.m.starfighter.current_armour, 0).out + " damage.")
							if model.m.starfighter.current_health <= 0 then
								model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
								model.m.starfighter.set_current_health (0)
								output.append ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
								model.m.toggle_in_game
								model.m.game_state.set_state ("not started", "ok")
								model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")
							end

					else
						model.m.grid.put ("<", pos.row, pos.column - 1)
						projectile.set_on_board (true)
					end
				end



			end



	heal(pylon: PYLON)
		do
			across 1 |..| model.m.enemy_id is i
			loop
				if attached model.m.enemy_collection.item (i) as enemy_obj and then enemy_obj.on_board then
					if pylon.can_see_starfighter (enemy_obj.pos.row, enemy_obj.pos.column) then
						enemy_obj.add_health(10)
						if enemy_obj.current_health >= enemy_obj.total_health then
							enemy_obj.set_current_health(enemy_obj.total_health)
						end
						output.append ("%N      The Pylon heals " + enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] for 10 damage.")
					end
				end

			end
		end


	report_status: STRING
		do
			create result.make_empty
			Result.append ("%N    [" + current.id.out + "," + current.symbol + "]->health:" + current.current_health.out + "/" + current.total_health.out + ", Regen:" + current.regen.out + ", Armour:" + current.armour.out +
			               ", Vision:" + current.vision.out + ", seen_by_Starfighter:" + current.seen_by_sf.out.item (1).out + ", can_see_Starfighter:" + current.can_see_sf.out.item (1).out + ", location:[" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")
		end


end
