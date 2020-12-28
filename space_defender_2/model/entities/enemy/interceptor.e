note
	description: "Summary description for {INTERCEPTOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	INTERCEPTOR

inherit
	ENEMY

create
	make

feature
	make (i: INTEGER)
		do
			create name.make_from_string ("Interceptor")
			create symbol.make_from_string ("I")
			create pos.default_create
			pos.compare_objects
			create old_pos.default_create
			total_health := 50
			current_health := 50
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
			bronze: ORB
		do
			create {BRONZE} bronze.make
			model.m.total_score.add (bronze)
		end



	preemptive_action(command: STRING)
		local
			i,j: INTEGER
			break: BOOLEAN
			destination: STRING
		do
			output.make_empty
			create destination.make_empty

			if command ~ "fire" then

							current.set_turn (true)
							model.m.grid.put ("_", pos.row, pos.column)
							-- moving INTERCEPTOR upwards (SF row < Interceptor row)
							if model.m.starfighter.pos.row < pos.row then
								destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") moves: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "] -> ")
								from
									i := pos.row
								until
									i <= model.m.starfighter.pos.row
								loop

										if on_board and not break and model.m.in_game then

												if model.m.friendly_projectile_presence (i - 1, pos.column) /= -9999 then
													-- collision with *
													if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (i - 1, pos.column)) as fp_obj then
														fp_obj.set_on_board(false)
														model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
														current.subtract_health (model.m.max (fp_obj.damage - current.armour, 0))

														output.append ("%N      The " + current.name + " collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], taking " + model.m.max (fp_obj.damage - current.armour, 0).out + " damage.")

														if current.current_health <= 0 then
															current.set_on_board (false)
															destination.append ("[" + model.m.row_name[i - 1] + "," + current.pos.column.out + "]")
															output.append ("%N      The " + current.name + " at location [" + model.m.row_name[i - 1] + "," + current.pos.column.out + "] has been destroyed.")
															current.add_to_focus
														end
													end

												elseif model.m.enemy_projectile_presence (i - 1, pos.column) /= -9999 then
													-- collision with <
													if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (i - 1, pos.column)) as ep_obj then
														output.append ("%N      The " + current.name + " collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out + "], healing " + ep_obj.damage.out + " damage.")
														ep_obj.set_on_board(false)
														model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
														current.add_health (ep_obj.damage)
														if current.current_health > current.total_health then
															current.set_current_health (current.total_health)

														end
													end

												elseif model.m.enemy_presence (i - 1, pos.column) /= -9999 then
													-- collision with {G, F, C, I, P}
													break := true
													if current.pos ~ [i, pos.column] then
															destination.make_empty
															destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") stays at: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")
															model.m.grid.put (current.symbol, pos.row, pos.column )
													else
														model.m.grid.put ("_", pos.row, pos.column)
														current.set_old_pos (pos.row, pos.column)
														current.set_pos (i, pos.column)
														model.m.grid.put (current.symbol, pos.row, pos.column )
														destination.append ("[" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")

													end

												elseif model.m.starfighter.pos ~ [i - 1, pos.column] then
													-- collision with S	
													destination.append ("[" + model.m.row_name[i - 1] + "," + current.pos.column.out + "]")
													output.append ("%N      The " + current.name + " collides with Starfighter(id:0) at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], trading "  + current.current_health.out + " damage.")
													output.append ("%N      The " + current.name + " at location [" + model.m.row_name[i - 1] + "," + current.pos.column.out + "] has been destroyed.")
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

												else
													-- do nothing and go for next iteration

												end

										end
									i := i - 1
								end

								if on_board and not break then
									model.m.grid.put ("_",pos.row , pos.column)
									current.set_old_pos (pos.row, pos.column)
									current.set_pos (model.m.starfighter.pos.row, pos.column)
									model.m.grid.put (current.symbol,pos.row , pos.column)

									destination.append ("[" + model.m.row_name[pos.row] + "," + current.pos.column.out + "]")

								end


						-- 	moving INTERCEPTOR downwards (SF row > Interceptor row)
						elseif  model.m.starfighter.pos.row > pos.row then
							destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") moves: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "] -> ")
							from
								j := pos.row
							until
								j >= model.m.starfighter.pos.row
							loop
										if on_board and not break and model.m.in_game then


														if model.m.friendly_projectile_presence (j + 1, pos.column) /= -9999 then
															-- collision with *
															if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (j + 1, pos.column)) as fp_obj then
																	fp_obj.set_on_board(false)
																	model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
																	current.subtract_health (model.m.max (fp_obj.damage - current.armour, 0))

																	output.append ("%N      The " + current.name + " collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], taking " + model.m.max (fp_obj.damage - current.armour, 0).out + " damage.")

																	if current.current_health <= 0 then
																		current.set_on_board (false)
																		destination.append ("[" + model.m.row_name[j + 1] + "," + current.pos.column.out + "]")
																		output.append ("%N      The " + current.name + " at location [" + model.m.row_name[j + 1] + "," + current.pos.column.out + "] has been destroyed.")
																		current.add_to_focus
																	end
															end

														elseif model.m.enemy_projectile_presence (j + 1, pos.column) /= -9999 then
																--  collision with <
																if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (j + 1, pos.column)) as ep_obj then
																	output.append ("%N      The " + current.name + " collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out + "], healing " + ep_obj.damage.out + " damage.")
																	ep_obj.set_on_board(false)
																	model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
																	current.add_health (ep_obj.damage)
																	if current.current_health > current.total_health then
																		current.set_current_health (current.total_health)
																	end
																end

														elseif model.m.enemy_presence (j + 1, pos.column) /= -9999 then
															-- collision with {G, F, C, I, P}
															break := true
															if current.pos ~ [j, pos.column] then
																destination.make_empty
																destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") stays at: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")
																model.m.grid.put (current.symbol, pos.row, pos.column )
															else
																model.m.grid.put ("_", pos.row, pos.column)
																current.set_old_pos (pos.row, pos.column)
																current.set_pos (j, pos.column)
																model.m.grid.put (current.symbol, pos.row, pos.column )
																destination.append ("[" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")

															end


														elseif model.m.starfighter.pos ~ [j + 1, pos.column] then
															-- collision with S

															destination.append ("[" + model.m.row_name[j + 1] + "," + current.pos.column.out + "]")
															output.append ("%N      The " + current.name + " collides with Starfighter(id:0) at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], trading "  + current.current_health.out + " damage.")
															output.append ("%N      The " + current.name + " at location [" + model.m.row_name[j + 1] + "," + current.pos.column.out + "] has been destroyed.")
															current.set_on_board (false)
															model.m.starfighter.subtract_health (current.current_health)
															model.m.grid.put ("_", current.pos.row, current.pos.column)
															break := true
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

														else
															-- do nothing and go for next iteration

														end


										end
										j := j + 1
							end
							if on_board and not break then
								model.m.grid.put ("_",pos.row , pos.column)
								current.set_old_pos (pos.row, pos.column)
								current.set_pos (model.m.starfighter.pos.row, pos.column)
								model.m.grid.put (current.symbol,pos.row , pos.column)
								destination.append ("[" + model.m.row_name[pos.row] + "," + current.pos.column.out + "]")

							end


						else
							-- do nothing since the I and SF are in same row
							destination.make_empty
							destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") stays at: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")
							model.m.grid.put (current.symbol, current.pos.row, current.pos.column)
						end


			end
				model.m.print_state.set_enemy_action (destination + output)

		end

	action
		local
			break: BOOLEAN
			destination: STRING
		do
				output.make_empty
				create destination.make_empty
				model.m.grid.put ("_", pos.row, pos.column)
				-- move 3 spaces left when SF is seen and when SF is not seen
				destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") moves: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "] -> ")
				across 1 |..| 3  is index
				loop
					-- loop only if the enemy is still on board
						if current.on_board and not break then

									if  (pos.column - index) < 1 then
										destination.append ("out of board")
										model.m.grid.put ("_", pos.row, pos.column)
										current.set_on_board (false)
									else
										if model.m.starfighter.pos ~ [pos.row, pos.column - index] then
											--perform some update based on collision with S

											destination.append ("[" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "]")
											output.append ("%N      The " + current.name + " collides with Starfighter(id:0) at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], trading "  + current.current_health.out + " damage.")
											output.append ("%N      The " + current.name + " at location [" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "] has been destroyed.")
											current.set_on_board (false)
											model.m.starfighter.subtract_health (current.current_health)
											model.m.grid.put ("_", current.pos.row, current.pos.column)
											break := true
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
														destination.append ("[" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "]")
														output.append ("%N      The " + current.name + " at location [" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "] has been destroyed.")
														current.add_to_focus
													end

												end

										elseif model.m.enemy_presence (pos.row, pos.column - index) /= -9999 then
											-- no movement of `current` enemy since it has to stop one place before hitting the other enemy
												break := true
												if current.pos ~ [pos.row, pos.column - (index - 1)] then
													destination.make_empty
													destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") stays at: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")
													model.m.grid.put (current.symbol, pos.row, pos.column )
												else
													model.m.grid.put ("_", pos.row, pos.column)
													current.set_old_pos (pos.row, pos.column)
													current.set_pos (pos.row, pos.column - (index - 1))
													model.m.grid.put (current.symbol, pos.row, pos.column )
													destination.append ("[" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")

												end


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
											-- do nothing and check for next location
										end

									end
						end -- end of first if

				end  -- end of loop

				if on_board and not break then
					model.m.grid.put ("_", pos.row, pos.column)
					current.set_old_pos (pos.row, pos.column)
					current.set_pos (pos.row, pos.column - 3)
					model.m.grid.put (current.symbol, pos.row, pos.column)
				--	output.prepend ("%N    A " + current.name + "(id:" + current.id.out + ") moves: [" + model.m.row_name[current.old_pos.row] + "," + current.old_pos.column.out + "] -> [" + model.m.row_name[pos.row] + "," + pos.column.out + "]")
					destination.append ("[" + model.m.row_name[pos.row] + "," + pos.column.out + "]")

				end


				model.m.print_state.set_enemy_action (destination + output)
		end


		report_status: STRING
			do
				create result.make_empty
				Result.append ("%N    [" + current.id.out + "," + current.symbol + "]->health:" + current.current_health.out + "/" + current.total_health.out + ", Regen:" + current.regen.out + ", Armour:" + current.armour.out +
				               ", Vision:" + current.vision.out + ", seen_by_Starfighter:" + current.seen_by_sf.out.item (1).out + ", can_see_Starfighter:" + current.can_see_sf.out.item (1).out + ", location:[" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")
			end

end
