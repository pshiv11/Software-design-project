note
	description: "Summary description for {CARRIER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CARRIER

inherit
	ENEMY

create
	make

feature
	make (i: INTEGER)
		do
			create name.make_from_string ("Carrier")
			create symbol.make_from_string ("C")
			create pos.default_create
			create old_pos.default_create
			total_health := 200
			current_health := 200
		 	regen := 10
		 	armour := 15
		 	vision := 15
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

	apply_regen
		do
			if current_health + regen > total_health then
				current_health := total_health
			else
				current_health := current_health + regen
			end
		end


	subtract_health(h: INTEGER)
		do
			current_health := current_health - h
		end



	update_can_see_sf
		do
			current.set_can_see_sf ( can_see_starfighter(model.m.starfighter.pos.row, model.m.starfighter.pos.column))
		end

	update_seen_by_sf
		do
			current.set_seen_by_sf (model.m.starfighter.seen_by_starfighter(current.pos.row, current.pos.column))
		end



	add_to_focus
		local
			diamond: FOCUS
		do
			create {DIAMOND} diamond.make
			model.m.total_score.add (diamond)
		end


	preemptive_action(command: STRING)
		local
			break: BOOLEAN
			destination: STRING
		do
			create destination.make_empty
			output.make_empty
			if command ~ "special" then
				regen := regen + 10
				output.append ("%N    A Carrier(id:" + current.id.out + ") gains 10 regen.")


			elseif command ~ "pass" then
					current.set_turn (true)
					apply_regen
					destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") moves: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "] -> ")
					across 1 |..| 2 is index
					loop
						-- run a loop only if enemy is still on board
						if current.on_board and not break then
							-- next location is out of board
								if  (pos.column - index) < 1 then
								--	model.m.print_state.set_enemy_action ("%N    A " + current.name + "(id:" + current.id.out + ") moves: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "] -> out of board")
									destination.append ("out of board")
									model.m.grid.put ("_", pos.row, pos.column)
									pos := [pos.row, pos.column - index]
									on_board := false
								else

										if model.m.starfighter.pos ~ [pos.row, pos.column - index] then
											--perform some update based on collision with S
											destination.append ("[" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "]")

											output.append ("%N      The Carrier collides with Starfighter(id:0) at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], trading "  + current.current_health.out + " damage.")
											output.append ("%N      The Carrier at location [" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "] has been destroyed.")
											current.set_on_board (false)
											model.m.starfighter.subtract_health (current.current_health)
											model.m.grid.put ("_", current.pos.row, current.pos.column)
											current.add_to_focus
											if model.m.starfighter.current_health <= 0  then
												break := true
												model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
												model.m.starfighter.set_current_health (0)
												output.append ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
												model.m.toggle_in_game
												model.m.game_state.set_state ("not started", "ok")
												model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")


											end


										elseif model.m.friendly_projectile_presence (pos.row, pos.column - index) /= -9999 then
											-- friendly projectile (enemy projectile for an enemy) is located at next position
											if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (pos.row, pos.column - index)) as fp_obj then
												fp_obj.set_on_board(false)
												model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
												model.m.grid.put ("_", current.pos.row, current.pos.column)
												current.subtract_health (model.m.max (fp_obj.damage - current.armour, 0))

												output.append ("%N      The Carrier collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], taking " + model.m.max (fp_obj.damage - current.armour, 0).out + " damage.")

												if current.current_health <= 0 then
													current.set_on_board (false)
													model.m.grid.put ("_", current.pos.row, current.pos.column)
													destination.append ("[" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "]")
													output.append ("%N      The Carrier at location [" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "] has been destroyed.")
													current.add_to_focus
												end

											end


										elseif model.m.enemy_presence (pos.row, pos.column - index) /= -9999 then
											-- another enemy is located at next location
											-- no movement of `current` enemy since it has to stop one place before hitting the other enemy
											break := true
											if current.pos ~ [current.pos.row, current.pos.column - (index - 1)] then
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

											current.spawn_interceptor (pos.row - 1, pos.column)
											current.spawn_interceptor (pos.row + 1, pos.column)

										elseif model.m.enemy_projectile_presence (pos.row, pos.column - index) /= -9999 then
											-- enemy projectile (friendly projectile for an enemy) is located at next position
											if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (pos.row, pos.column - index)) as ep_obj then
												output.append ("%N      The Carrier collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out + "], healing " + ep_obj.damage.out + " damage.")
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
						end
					end

				-- if Enemy is still `on board` and not destroyed, spawn two interceptors				
				if on_board and not break then

					-- move carrier to final destination and update its position

						model.m.grid.put ("_", pos.row, pos.column)
						model.m.grid.put (current.symbol, pos.row, pos.column - 2)
						current.set_old_pos (pos.row, pos.column)
						current.set_pos (pos.row, pos.column - 2)
						destination.append ("[" + model.m.row_name[pos.row] + "," + pos.column.out + "]")

					-- spwan two INTERCEPTORS (one above and below the ENEMY)
						current.spawn_interceptor (pos.row - 1, pos.column)
						current.spawn_interceptor (pos.row + 1, pos.column)
				end

			end

			model.m.print_state.set_enemy_action (destination + output)
		end

	action
		local
			break: BOOLEAN
			destination: STRING
		do
			create destination.make_empty
			output.make_empty
			-- action when SF is not seen

			destination.append ("%N    A " + current.name + "(id:" + current.id.out + ") moves: [" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "] -> ")
			if  not can_see_starfighter(model.m.starfighter.pos.row, model.m.starfighter.pos.column) then
					apply_regen
					across 1 |..| 2 is index
					loop
						-- run a loop only if enemy is still on board
						if current.on_board and not break then
							-- next location is out of board
								if  (pos.column - index) < 1 then

									destination.append ("out of board")
									model.m.grid.put ("_", pos.row, pos.column)
									pos := [pos.row, pos.column - index]
									on_board := false
								else

										if model.m.starfighter.pos ~ [pos.row, pos.column - index] then
											--perform some update based on collision with S

											destination.append ("[" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "]")
											output.append ("%N      The Carrier collides with Starfighter(id:0) at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], trading "  + current.current_health.out + " damage.")
											output.append ("%N      The Carrier at location [" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "] has been destroyed.")
											current.set_on_board (false)
											model.m.starfighter.subtract_health (current.current_health)
											model.m.grid.put ("_", current.pos.row, current.pos.column)
											current.add_to_focus
											if model.m.starfighter.current_health <= 0  then
												break := true
												model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
												model.m.starfighter.set_current_health (0)
												output.append ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
												model.m.toggle_in_game
												model.m.game_state.set_state ("not started", "ok")
												model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")


											end


										elseif model.m.friendly_projectile_presence (pos.row, pos.column - index) /= -9999 then
											-- friendly projectile (enemy projectile for an enemy) is located at next position
											if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (pos.row, pos.column - index)) as fp_obj then
												fp_obj.set_on_board(false)
												model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
												model.m.grid.put ("_", current.pos.row, current.pos.column)
												current.subtract_health (model.m.max (fp_obj.damage - current.armour, 0))

												output.append ("%N      The Carrier collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], taking " + model.m.max (fp_obj.damage - current.armour, 0).out + " damage.")

												if current.current_health <= 0 then
													current.set_on_board (false)

													destination.append ("[" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "]")
													output.append ("%N      The Carrier at location [" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "] has been destroyed.")
													current.add_to_focus
												end

											end


										elseif model.m.enemy_presence (pos.row, pos.column - index) /= -9999 then
											-- another enemy is located at next location
											-- no movement of `current` enemy since it has to stop one place before hitting the other enemy
											break := true
											if current.pos ~ [current.pos.row, current.pos.column - (index - 1)] then
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
											-- enemy projectile (friendly projectile for an enemy) is located at next position
											if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (pos.row, pos.column - index)) as ep_obj then
												output.append ("%N      The Carrier collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out + "], healing " + ep_obj.damage.out + " damage.")
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
						end
					end

					if on_board and not break then

						-- move `Fighter` to final destination and update its position

						model.m.grid.put ("_", pos.row, pos.column)
						model.m.grid.put (current.symbol, pos.row, pos.column - 2)
						current.set_old_pos (pos.row, pos.column)
						current.set_pos (pos.row, pos.column - 2)
						destination.append ("[" + model.m.row_name[pos.row] + "," + pos.column.out + "]")

					end


				-- action when SF is seen
				else
					apply_regen
					across 1 |..| 1 is index
					loop
						-- run a loop only if enemy is still on board
						if current.on_board and not break then
							-- next location is out of board
								if  (pos.column - index) < 1 then

									destination.append ("out of board")
									model.m.grid.put ("_", pos.row, pos.column)
									pos := [pos.row, pos.column - index]
									on_board := false
								else

										if model.m.starfighter.pos ~ [pos.row, pos.column - index] then
											--perform some update based on collision with S

											break := true
											destination.append ("[" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "]")
											output.append ("%N      The Carrier collides with Starfighter(id:0) at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], trading "  + current.current_health.out + " damage.")
											output.append ("%N      The Carrier at location [" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "] has been destroyed.")
											current.set_on_board (false)
											model.m.starfighter.subtract_health (current.current_health)
											current.add_to_focus

											model.m.grid.put ("_", current.pos.row, current.pos.column)
											if model.m.starfighter.current_health <= 0  then
												model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
												model.m.starfighter.set_current_health (0)
												output.append ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
												model.m.toggle_in_game
												model.m.game_state.set_state ("not started", "ok")
												model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")

											end


										elseif model.m.friendly_projectile_presence (pos.row, pos.column - index) /= -9999 then
											-- friendly projectile (enemy projectile for an enemy) is located at next position
											if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (pos.row, pos.column - index)) as fp_obj then
												fp_obj.set_on_board(false)
												model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
												model.m.grid.put ("_", current.pos.row, current.pos.column)
												current.subtract_health (model.m.max (fp_obj.damage - current.armour, 0))

												output.append ("%N      The Carrier collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], taking " + model.m.max (fp_obj.damage - current.armour, 0).out + " damage.")

												if current.current_health <= 0 then
													current.set_on_board (false)
													destination.append ("[" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "]")
													output.append ("%N      The Carrier at location [" + model.m.row_name[current.pos.row] + "," + (current.pos.column - index).out + "] has been destroyed.")
													current.add_to_focus
												end

											end


										elseif model.m.enemy_presence (pos.row, pos.column - index) /= -9999 then
											-- another enemy is located at next location
											-- no movement of `current` enemy since it has to stop one place before hitting the other enemy
											break := true
											if current.pos ~ [current.pos.row, current.pos.column - (index - 1)] then
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
											-- enemy projectile (friendly projectile for an enemy) is located at next position
											if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (pos.row, pos.column - index)) as ep_obj then
												output.append ("%N      The Carrier collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out + "], healing " + ep_obj.damage.out + " damage.")
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
						end
					end

				-- if Enemy is still `on board` and not destroyed, spawn interceptor to the left of it				
				if on_board and not break then

					-- move carrier to final destination and update its position

						model.m.grid.put ("_", pos.row, pos.column)
						model.m.grid.put (current.symbol, pos.row, pos.column - 1)
						current.set_old_pos (pos.row, pos.column)
						current.set_pos (pos.row, pos.column - 1)

						destination.append ("[" + model.m.row_name[pos.row] + "," + pos.column.out + "]")
						current.spawn_interceptor (pos.row, pos.column - 1)

				end


			end

			model.m.print_state.set_enemy_action (destination + output)

		end


	spawn_interceptor(row: INTEGER; column: INTEGER)
		local
			interceptor: INTERCEPTOR
			destination: STRING
		do
			create destination.make_empty
			create interceptor.make (model.m.enemy_id)
			interceptor.set_turn (true)
			interceptor.set_old_pos (row, column)
			interceptor.set_pos (row, column)
			interceptor.set_can_see_sf (current.can_see_starfighter (model.m.starfighter.pos.row, model.m.starfighter.pos.column))
			interceptor.set_seen_by_sf (model.m.starfighter.seen_by_starfighter (row, column))


			if (row < 1) or (row > model.m.grid.height) or (column < 1) or (column > model.m.grid.width )then
				-- spawn outside the board, assign id but do not keep track of it
				-- print spawn statement
				model.m.add_enemy (interceptor)
				interceptor.set_on_board(false)
				destination.append ("%N      A Interceptor(id:" + interceptor.id.out + ") spawns at location out of board.")

			else

				destination.append ("%N      A Interceptor(id:" + interceptor.id.out + ") spawns at location [" + model.m.row_name[row] + "," + column.out + "].")
				interceptor.set_on_board (true)
				if model.m.friendly_projectile_presence (row, column) /= -9999 then
					-- spawning in a location occupied by a friendly projectile (enemy projectile for an enemy)
					if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (row, column)) as fp_obj then
						model.m.add_enemy (interceptor)
						fp_obj.set_on_board (false)
						interceptor.subtract_health (model.m.max (fp_obj.damage - interceptor.armour, 0))
						destination.append ("%N      The Interceptor collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[row] + "," + column.out + "], taking " + model.m.max (fp_obj.damage - interceptor.armour, 0).out + " damage.")
						if interceptor.current_health <= 0 then
							interceptor.set_current_health (0)
							interceptor.set_on_board (false)
							model.m.grid.put ("_", row, column)
							destination.append ("%N      The Interceptor at location [" + model.m.row_name[row] + "," + column.out + "] has been destroyed.")
							interceptor.add_to_focus
						else
							interceptor.update_can_see_sf
							interceptor.update_seen_by_sf
							model.m.grid.put (interceptor.get_symbol, row, column)
						end
					end

				elseif model.m.enemy_projectile_presence (row, column) /= -9999 then
					-- spawning in a location occupied by a enemy projectile (friendly projectile for an enemy)
					interceptor.set_on_board (true)
					if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (row, column)) as ep_obj then
						model.m.add_enemy (interceptor)
						ep_obj.set_on_board (false)
						interceptor.add_health (ep_obj.damage)
						destination.append ("%N      The Interceptor collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out + "], healing " + ep_obj.damage.out + " damage.")
						if current.current_health > current.total_health then
							current.set_current_health (current.total_health)
						end
						model.m.grid.put (interceptor.get_symbol, row, column)
						interceptor.update_can_see_sf
						interceptor.update_seen_by_sf
					end

				elseif model.m.enemy_presence (row, column) /= -9999 then
					-- another enemy is located at next location
					-- do not spawn an Interceptor	
						destination.make_empty
						interceptor.set_on_board (false)
				elseif model.m.starfighter.pos ~ [row , column] then
					-- spawning in a location occupied by a starfighter
					model.m.add_enemy (interceptor)
					destination.append ("%N      The Interceptor collides with Starfighter(id:0) at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], trading " + interceptor.current_health.out + " damage.")
					destination.append ("%N      The Interceptor at location [" + model.m.row_name[row] + "," + column.out + "] has been destroyed.")
					model.m.starfighter.subtract_health (interceptor.current_health)

					interceptor.set_on_board (false)
					interceptor.add_to_focus
					if model.m.starfighter.current_health <= 0 then

						model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
						model.m.starfighter.set_current_health (0)
						destination.append ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
						model.m.toggle_in_game
						model.m.game_state.set_state ("not started", "ok")
						model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")


					end

				else
					model.m.add_enemy (interceptor)
					model.m.grid.put (interceptor.symbol, row, column)
					interceptor.update_can_see_sf
					interceptor.update_seen_by_sf


				end
			end

			output.append (destination)

		end




		report_status: STRING
			do
				create result.make_empty
				Result.append ("%N    [" + current.id.out + "," + current.symbol + "]->health:" + current.current_health.out + "/" + current.total_health.out + ", Regen:" + current.regen.out + ", Armour:" + current.armour.out +
				               ", Vision:" + current.vision.out + ", seen_by_Starfighter:" + current.seen_by_sf.out.item (1).out + ", can_see_Starfighter:" + current.can_see_sf.out.item (1).out + ", location:[" + model.m.row_name[current.pos.row] + "," + current.pos.column.out + "]")
			end



end

