note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MODEL

inherit
	ANY
		redefine
			out
		end

create {ETF_MODEL_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			create s.make_empty
			i := 0
		--	create output.make_empty
			create game_state.make
			create print_state.make
			create row_name.make_from_array (<<"A", "B", "C","D", "E", "F","G", "H", "I", "J">>)
			initial_state

			-- Initialization of setup stage attributes

			create states.make_empty
				states.force (create {WEAPON}.make, states.count + 1)
				states.force (create {ARMOUR}.make, states.count + 1)
				states.force (create {ENGINE}.make, states.count + 1)
				states.force (create{POWER}.make, states.count + 1)
				states.force (create{SUMMARY}.make, states.count + 1)

			-- Initialization of starfighter attributes	
				create starfighter.make
				create friendly_projectiles.make(100)
				friendly_projectiles.compare_objects
			-- Initialization of Enemy related attributes
				create enemy_collection.make (100)
				enemy_collection.compare_objects
				create enemy_projectiles.make(100)
				enemy_projectiles.compare_objects
				enemy_id := 1
				projectile_id := -1
				create enemy_entity.make_from_array (<<"G", "F", "C", "I", "P">>)
				enemy_entity.compare_objects


			-- Initialization of `GRID`
				create grid.make_filled ("_", 0, 0)


			-- Initialization of score
				create total_score.make
		end

feature -- setup stage attributes
	states: ARRAY[STATE]


feature -- model attributes
	s : STRING
	i : INTEGER
	setup_cursor: INTEGER
	in_setup_mode: BOOLEAN
	in_game: BOOLEAN
	in_debug_mode: BOOLEAN
	display_titles: BOOLEAN
--	output: STRING
	game_state: GAME_STATE
	print_state: PRINT_STATE
	grid: ARRAY2[STRING]
	row_name: ARRAY[STRING]

	-- ids
	enemy_id: INTEGER
	projectile_id: INTEGER


feature -- in game attributes
	score: INTEGER assign set_score
	random: RANDOM_GENERATOR_ACCESS

feature -- initial play attributes
	board_row, board_column, grunt_threshold, fighter_threshold, carrier_threshold, interceptor_threshold, pylon_threshold: INTEGER_32

feature -- starfighter related attribute
	starfighter: STAR_FIGHTER
	friendly_projectiles: HASH_TABLE[FRIENDLY_PROJECTILE, INTEGER]

feature -- enemy related attributes
	enemy_collection: HASH_TABLE[ENEMY, INTEGER]
	enemy_projectiles: HASH_TABLE[ENEMY_PROJECTILE, INTEGER]
	enemy_entity: ARRAY[STRING]

feature -- scoring component
	total_score: SCORE


feature -- model operations
	default_update
			-- Perform update to the model state.
		do
			i := i + 1
		end

--	reset
--			-- Reset model state.
--		do
--			make
--		end


	initial_state
		do

			print_state.set_welcome ("state:not started, normal, ok%N  Welcome to Space Defender Version 2.")

		end

	-- set setup mode
	toggle_setup_mode
		do
			if in_setup_mode = true then
				in_setup_mode := false
			else
				in_setup_mode := true
			end
		end

	toggle_debug_mode
		do
			if in_debug_mode = true then
				in_debug_mode := false
			else
				in_debug_mode := true
			end
		end


	-- set in game
	toggle_in_game
		do
			if in_game = true then
				in_game := false
			else
				in_game := true
			end
		end

	-- set setup cursor
	set_setup_cursor(cursor: INTEGER)
		do
			setup_cursor := cursor
		end

	increment_enemy_id
		do
			enemy_id := enemy_id + 1
		end

feature -- play

	play(row: INTEGER_32 ; column: INTEGER_32 ; g_threshold: INTEGER_32 ; f_threshold: INTEGER_32 ; c_threshold: INTEGER_32 ; i_threshold: INTEGER_32 ; p_threshold: INTEGER_32)
		do
				grid.make_empty
				board_row := row
				board_column := column
				grunt_threshold := g_threshold
				fighter_threshold := f_threshold
				carrier_threshold := c_threshold
				interceptor_threshold := i_threshold
				pylon_threshold := p_threshold

		end

	play_game
		do

			grid.make_empty

			grid.make_filled ("_", board_row, board_column)
			grid.initialize ("_")
			starfighter.set_old_pos(((grid.height/2).ceiling_real_64.truncated_to_integer), 1)
			starfighter.set_pos (((grid.height/2).ceiling_real_64.truncated_to_integer), 1)
			starfighter.set_initial_pos (((grid.height/2).ceiling_real_64.truncated_to_integer), 1)
			starfighter.set_id (0)
			starfighter.setup
			grid.put ("S", starfighter.pos.row, starfighter.pos.column)
			print_state.set_grid (grid)
			current.set_score (0)
			update_starfighter

		end


	pass
		do
			print_state.set_starfighter_action_empty

			if in_game then
				check attached {WEAPON} current.states[1] as weapon  then weapon.friendly_projectile_act end
			end

			if in_game then
				enemy_projectile_act
			end

			if in_game then
				starfighter.apply_regen
				starfighter.apply_regen
				game_state.increment_x
				game_state.set_state ("in game", "ok")
				print_state.set_starfighter_action ("%N    The Starfighter(id:" + starfighter.id.id.out + ") passes at location [" + row_name[starfighter.pos.row] + "," + starfighter.pos.column.out + "], doubling regen rate.")

			end

			if in_game then
				enemy_vision_update
			end

			-- preemptive_action followed by action
			print_state.set_enemy_action_empty
			if in_game then
				preemptive_action("pass")
			end


			if in_game	 then
				action
			end

			if in_game then
				enemy_vision_update
			end

			if in_game	 then
				enemy_setup
			end

			current.set_score (total_score.get_score)
			update_starfighter
			-- all projectiles on board with the updated location (to string)
			report_projectiles
			-- report all enemies that are still on board with its current status
			report_enemies
			print_state.set_grid (grid)
		end


	fire
		do
			print_state.set_starfighter_action_empty
			if in_game then
				check attached {WEAPON} current.states[1] as weapon  then weapon.friendly_projectile_act end
			end

			if in_game then
				enemy_projectile_act
			end

			if in_game then
				starfighter.apply_regen
				check attached {WEAPON} current.states[1] as weapon  then weapon.fire end
			end


			if in_game then
				enemy_vision_update
			end

			print_state.set_enemy_action_empty
			if in_game then
				current.preemptive_action ("fire")

			end

			if in_game then
				action

			end

			if in_game then
				enemy_vision_update
			end

			if in_game then
				enemy_setup
			end
			current.set_score (total_score.get_score)
			update_starfighter
			current.report_projectiles
			current.report_enemies
			print_state.set_grid (grid)
		end

	special_test
		do

		end
	special
		do
			current.print_state.set_starfighter_action_empty


			if in_game then
				check attached {WEAPON} current.states[1] as weapon  then weapon.friendly_projectile_act end
			end

			if in_game then
				current.enemy_projectile_act
			end

			if in_game then
				check attached {POWER} current.states[4] as power  then power.special end
			end



			if in_game then
				enemy_vision_update
			end

			print_state.set_enemy_action_empty
			if in_game then
				current.preemptive_action ("special")

			end

			if in_game then
				action

			end

			if in_game then
				current.enemy_setup
			end

			if in_game then
				enemy_vision_update
			end

			current.set_score (total_score.get_score)
			update_starfighter
			report_projectiles
			report_enemies

			print_state.set_grid (grid)



		end


	subtract_move_cost
		local
			total_move: INTEGER
		do
			total_move:= (starfighter.old_pos.row - starfighter.pos.row).abs + (starfighter.old_pos.column - starfighter.pos.column).abs
			starfighter.subtract_energy (starfighter.total_move_cost * total_move)
		end

	move(row: INTEGER_32 ; column: INTEGER_32)

		local
			j, k: INTEGER
			output, destination: STRING

		do
					create output.make_empty
					create destination.make_empty
					print_state.set_starfighter_action_empty
						if current.in_game then
							check attached {WEAPON} current.states[1] as weapon  then weapon.friendly_projectile_act end
						end


						if current.in_game then
							enemy_projectile_act
						end



						if in_game then



								--Applying regen
									starfighter.apply_regen

									-- assign old_pos before SF moves
										starfighter.set_old_pos (starfighter.pos.row, starfighter.pos.column)
									-- set the SF action string empty
									print_state.set_starfighter_action_empty

									destination.append ("%N    The Starfighter(id:" + starfighter.id.id.out + ") moves: [" + row_name[starfighter.old_pos.row]
																				+ "," + starfighter.old_pos.column.out + "] -> ")
									if in_game then

											-- move down in same column  ********************************************************
											if starfighter.pos.row < row then
												across
													starfighter.pos.row |..| (row - 1)  is index
												loop
													if in_game then
														if current.friendly_projectile_presence (index + 1 , starfighter.pos.column) /= -9999 then
															-- collision with *
															if attached current.friendly_projectiles.item (current.friendly_projectile_presence (index + 1 , starfighter.pos.column)) as fp_obj then
																current.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
																fp_obj.set_on_board(false)
																starfighter.subtract_health (current.max (fp_obj.damage - starfighter.current_armour, 0))

																output.append ("%N      The Starfighter collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + row_name[fp_obj.pos.row] + ","
																											+ fp_obj.pos.column.out + "], taking " + max (fp_obj.damage - starfighter.current_armour, 0).out + " damage.")

																if starfighter.current_health <= 0 then
																	-- game over
																	starfighter.set_current_health (0)
																	current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)
																	current.grid.put ("X", index + 1 , starfighter.pos.column)
																	starfighter.set_pos (index + 1 , starfighter.pos.column)
																	current.subtract_move_cost

																	current.toggle_in_game
																	current.game_state.set_state ("not started", "ok")
																	destination.append ("[" + row_name[index + 1] + "," + starfighter.pos.column.out + "]")

																	output.append ("%N      The Starfighter at location [" + row_name[index + 1] + "," + starfighter.pos.column.out + "] has been destroyed.")
																	current.print_state.set_game_over ("%N  The game is over. Better luck next time!")
																end
															end
														elseif current.enemy_presence (index + 1, starfighter.pos.column) /= -9999 then
															-- collision with one of {G, F, C, I, P}
															if attached current.enemy_collection.item (current.enemy_presence (index + 1, starfighter.pos.column)) as enemy_obj then
																starfighter.subtract_health (enemy_obj.current_health)
																current.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
																enemy_obj.set_on_board(false)

																output.append ("%N      The Starfighter collides with " + enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + row_name[index + 1] + "," + starfighter.pos.column.out +
																													"], trading " + enemy_obj.current_health.out +  " damage.")

																output.append ("%N      The "  + enemy_obj.name + " at location [" + row_name[enemy_obj.pos.row]+ "," + enemy_obj.pos.column.out + "] has been destroyed.")
																enemy_obj.add_to_focus

																if starfighter.current_health <= 0 then
																	-- game over
																	starfighter.set_current_health (0)
																	current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)
																	current.grid.put ("X", index + 1 , starfighter.pos.column)
																	starfighter.set_pos (index + 1 , starfighter.pos.column)
																	current.subtract_move_cost

																	current.toggle_in_game
																	current.game_state.set_state ("not started", "ok")
																	current.print_state.set_game_over ("%N  The game is over. Better luck next time!")

			--													
																	destination.append ("[" + row_name[index + 1] + "," + starfighter.pos.column.out + "]")

																	output.append ("%N      The Starfighter at location [" + row_name[index + 1] + "," + starfighter.pos.column.out + "] has been destroyed.")

																end
															end


														elseif current.enemy_projectile_presence (index + 1, starfighter.pos.column) /= -9999 then
															-- collision with <	
															if attached current.enemy_projectiles.item (current.enemy_projectile_presence  (index + 1, starfighter.pos.column)) as ep_obj then
																current.grid.put ("_", index + 1, starfighter.pos.column)
																ep_obj.set_on_board(false)
																starfighter.subtract_health (current.max (ep_obj.damage - starfighter.current_armour, 0))
			--												
																output.append("%N      The Starfighter collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + row_name[ep_obj.pos.row] + ","
																											+ ep_obj.pos.column.out + "], taking " + max (ep_obj.damage - starfighter.current_armour, 0).out + " damage.")

																if starfighter.current_health <= 0 then
																	-- game over
																	starfighter.set_current_health (0)
																	current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)

																	starfighter.set_pos (index + 1 , starfighter.pos.column)
																	current.grid.put ("X", starfighter.pos.row, starfighter.pos.column)
																	current.subtract_move_cost

																	current.toggle_in_game
																	current.game_state.set_state ("not started", "ok")
																	current.print_state.set_game_over ("%N  The game is over. Better luck next time!")
																	destination.append ("[" + row_name[index + 1] + "," + starfighter.pos.column.out + "]")

																	output.append ("%N      The Starfighter at location [" + row_name[index + 1] + "," + starfighter.pos.column.out + "] has been destroyed.")

																end
															end

														else

															-- do nothing ang go for next iteration

														end
													end
												end
											end

									end


									if in_game then


									-- move up in same column **********************************************************************
										if starfighter.pos.row > row then
											from
												j := starfighter.pos.row
											until
												j < row + 1
											loop
												if in_game then

													if current.friendly_projectile_presence (j - 1 , starfighter.pos.column) /= -9999 then
														-- collision with *
														if attached current.friendly_projectiles.item (current.friendly_projectile_presence (j - 1 , starfighter.pos.column)) as fp_obj then
																current.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
																fp_obj.set_on_board(false)
																starfighter.subtract_health (current.max (fp_obj.damage - starfighter.current_armour, 0))
																current.print_state.set_starfighter_action ("%N      The Starfighter collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + row_name[fp_obj.pos.row] + ","
																											+ fp_obj.pos.column.out + "], taking " + max (fp_obj.damage - starfighter.current_armour, 0).out + " damage.")

																if starfighter.current_health <= 0 then
																	-- game over
																	starfighter.set_current_health (0)
																	current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)

																	starfighter.set_pos (j - 1 , starfighter.pos.column)
																	current.grid.put ("_X", starfighter.pos.row, starfighter.pos.column)
																	current.subtract_move_cost

																	current.toggle_in_game
																	current.game_state.set_state ("not started", "ok")


																	output.append("%N      The Starfighter at location [" + row_name[j - 1] + "," + starfighter.pos.column.out + "] has been destroyed.")
																	destination.append ("[" + row_name[j - 1] + "," + starfighter.pos.column.out + "]")

																end
														end


													elseif current.enemy_presence (j - 1 , starfighter.pos.column) /= -9999 then
														-- collision with one of {G, F, C, I, P}	
														if attached current.enemy_collection.item (current.enemy_presence (j - 1 , starfighter.pos.column)) as enemy_obj then
																starfighter.subtract_health (enemy_obj.current_health)
																current.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
																enemy_obj.set_on_board(false)

																output.append ("%N      The Starfighter collides with " + enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + row_name[j - 1] + "," + starfighter.pos.column.out +
																													"], trading " + enemy_obj.current_health.out +  " damage.")
																output.append ("%N      The "  + enemy_obj.name + " at location [" + row_name[enemy_obj.pos.row]+ "," + enemy_obj.pos.column.out + "] has been destroyed.")
																enemy_obj.add_to_focus
																if starfighter.current_health <= 0 then
																	-- game over
																	starfighter.set_current_health (0)
																	current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)

																	starfighter.set_pos (j - 1 , starfighter.pos.column)
																	current.grid.put ("X", starfighter.pos.row, starfighter.pos.column)
																	current.subtract_move_cost

																	current.toggle_in_game
																	current.game_state.set_state ("not started", "ok")
																	current.print_state.set_game_over ("%N  The game is over. Better luck next time!")

																	output.append ("%N      The Starfighter at location [" + row_name[j - 1] + "," + starfighter.pos.column.out + "] has been destroyed.")
																	destination.append ("[" + row_name[j - 1] + "," + starfighter.pos.column.out + "]")

																end
														end



													elseif current.enemy_projectile_presence (j - 1 , starfighter.pos.column) /= -9999 then
														-- collision with <

															if attached current.enemy_projectiles.item (current.enemy_projectile_presence  (j - 1, starfighter.pos.column)) as ep_obj then
																	current.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
																	ep_obj.set_on_board(false)
																	starfighter.subtract_health (current.max (ep_obj.damage - starfighter.current_armour, 0))
																	output.append ("%N      The Starfighter collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + row_name[ep_obj.pos.row] + ","
																												+ ep_obj.pos.column.out + "], taking " + max (ep_obj.damage - starfighter.current_armour, 0).out + " damage.")

																	if starfighter.current_health <= 0 then
																		-- game over
																		starfighter.set_current_health (0)
																		current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)
																		current.grid.put ("X", j - 1 , starfighter.pos.column)
																		starfighter.set_pos (j - 1 , starfighter.pos.column)
																		current.subtract_move_cost

																		current.toggle_in_game
																		current.game_state.set_state ("not started", "ok")

																		output.append ("%N      The Starfighter at location [" + row_name[j - 1] + "," + starfighter.pos.column.out + "] has been destroyed.")
																		destination.append ("[" + row_name[j -1] + "," + starfighter.pos.column.out + "]")
																		current.print_state.set_game_over ("%N  The game is over. Better luck next time!")
																	end
															end


													else
														-- do nothing ang go for next iteration

													end
												end
												j := j - 1

											end
										end
									end

									if in_game then


										-- move right in same row   **********************************************************************
										if starfighter.pos.column < column then
											across
												starfighter.pos.column |..| (column - 1)  is index
											loop
												if in_game then


													if current.friendly_projectile_presence (row , index + 1) /= -9999 then

														-- collision with *
														if attached current.friendly_projectiles.item (current.friendly_projectile_presence (row , index + 1)) as fp_obj then
																current.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
																fp_obj.set_on_board(false)
																starfighter.subtract_health (current.max (fp_obj.damage - starfighter.current_armour, 0))
																output.append ("%N      The Starfighter collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + row_name[fp_obj.pos.row] + ","
																											+ fp_obj.pos.column.out + "], taking " + max (fp_obj.damage - starfighter.current_armour, 0).out + " damage.")

																if starfighter.current_health <= 0 then
																	-- game over
																	starfighter.set_current_health (0)
																	current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)
																	current.grid.put ("X", row , index + 1)
																	starfighter.set_pos (row , index + 1)
																	current.subtract_move_cost
																	current.toggle_in_game
																	current.game_state.set_state ("not started", "ok")
																	current.print_state.set_game_over ("%N  The game is over. Better luck next time!")
																	output.append("%N      The Starfighter at location [" + row_name[row] + "," + (index + 1).out + "] has been destroyed.")
																	destination.append ("[" + row_name[row] + "," + (index + 1).out + "]")

																end
														end

													elseif current.enemy_presence (row , index + 1) /= -9999 then
														-- collision with one of {G, F, C, I, P}
														if attached current.enemy_collection.item (current.enemy_presence (row , index + 1)) as enemy_obj then
																starfighter.subtract_health (enemy_obj.current_health)
																current.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
																enemy_obj.set_on_board(false)
																output.append ("%N      The Starfighter collides with " + enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + row_name[row] + "," + (index + 1).out +
																													"], trading " + enemy_obj.current_health.out +  " damage.")
																output.append ("%N      The "  + enemy_obj.name + " at location [" + row_name[enemy_obj.pos.row]+ "," + enemy_obj.pos.column.out + "] has been destroyed.")
																enemy_obj.add_to_focus
																if starfighter.current_health <= 0 then
																	-- game over
																	starfighter.set_current_health (0)
																	current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)
																	current.grid.put ("X", row , index + 1)
																	starfighter.set_pos (row , index + 1)
																	current.subtract_move_cost

																	current.toggle_in_game
																	current.game_state.set_state ("not started", "ok")
																	output.append ("%N      The Starfighter at location [" + row_name[row] + "," + (index + 1).out + "] has been destroyed.")
																	destination.append ("[" + row_name[row] + "," + (index + 1).out + "]")
																	current.print_state.set_game_over ("%N  The game is over. Better luck next time!")
																end
														end

													elseif current.enemy_projectile_presence (row , index + 1) /= -9999 then
														-- collision with <
														if attached current.enemy_projectiles.item (current.enemy_projectile_presence  (row , index + 1)) as ep_obj then
																	current.grid.put ("_", row, index + 1)
																	ep_obj.set_on_board(false)
																	starfighter.subtract_health (current.max (ep_obj.damage - starfighter.current_armour, 0))
																	output.append ("%N      The Starfighter collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + row_name[ep_obj.pos.row] + ","
																												+ ep_obj.pos.column.out + "], taking " + max (ep_obj.damage - starfighter.current_armour, 0).out + " damage.")


																	if starfighter.current_health <= 0 then
																		-- game over
																		starfighter.set_current_health (0)
																		current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)
																		current.grid.put ("X", row , index + 1)
																		starfighter.set_pos (row , index + 1)
																		current.subtract_move_cost
																		toggle_in_game
																		current.game_state.set_state ("not started", "ok")
																		output.append ("%N      The Starfighter at location [" + row_name[row] + "," + (index + 1).out + "] has been destroyed.")
																		destination.append ("[" + row_name[row] + "," + (index + 1).out + "]")
																		current.print_state.set_game_over ("%N  The game is over. Better luck next time!")

																	end
														end





													else
														-- do nothing ang go for next iteration
													end
												end
											end
										end
									end

									if in_game then

										-- move left in same row    **********************************************************************
										if starfighter.pos.column >  column then
											from
												k := starfighter.pos.column
											until
												k < (column + 1)
											loop
												if in_game then

													if current.friendly_projectile_presence (row , k - 1) /= -9999 then
														-- collision with *
														if attached current.friendly_projectiles.item (current.friendly_projectile_presence (row , k - 1)) as fp_obj then
																current.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
																fp_obj.set_on_board(false)
																starfighter.subtract_health (current.max (fp_obj.damage - starfighter.current_armour, 0))
																output.append ("%N      The Starfighter collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + row_name[fp_obj.pos.row] + ","
																																							+ fp_obj.pos.column.out + "], taking " + max (fp_obj.damage - starfighter.current_armour, 0).out + " damage.")

																if starfighter.current_health <= 0 then
																	-- game over
																	starfighter.set_current_health (0)
																	current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)
																	current.grid.put ("X", row , k - 1)
																	starfighter.set_pos (row , k - 1)
																	current.subtract_move_cost

																	current.toggle_in_game
																	current.game_state.set_state ("not started", "ok")
																	output.append ("%N      The Starfighter at location [" + row_name[row] + "," + (k - 1).out + "] has been destroyed.")
																	destination.append ("[" + row_name[row] + "," + (k - 1).out + "]")
																	current.print_state.set_game_over ("%N  The game is over. Better luck next time!")
																end
														end


													elseif current.enemy_presence (row , k - 1) /= -9999 then
														-- collision with one of {G, C, F, I, P}
														if attached current.enemy_collection.item (current.enemy_presence (row , k - 1)) as enemy_obj then
																starfighter.subtract_health (enemy_obj.current_health)
																current.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
																enemy_obj.set_on_board(false)
																output.append ("%N      The Starfighter collides with " + enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + row_name[row] + "," + (k - 1).out +
																													"], trading " + enemy_obj.current_health.out +  " damage.")
																output.append ("%N      The "  + enemy_obj.name + " at location [" + row_name[enemy_obj.pos.row]+ "," + enemy_obj.pos.column.out + "] has been destroyed.")
																enemy_obj.add_to_focus
																if starfighter.current_health <= 0 then
																	-- game over
																	starfighter.set_current_health (0)
																	current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)
																	current.grid.put ("X", row , k - 1)
																	starfighter.set_pos (row , k - 1)
																	current.subtract_move_cost

																	current.toggle_in_game
																	current.game_state.set_state ("not started", "ok")
																	output.append ("%N      The Starfighter at location [" + row_name[row] + "," + (k - 1).out + "] has been destroyed.")
																	destination.append ("[" + row_name[row] + "," + (k - 1).out + "]")
																	current.print_state.set_game_over ("%N  The game is over. Better luck next time!")

																end
														end
													elseif current.enemy_projectile_presence (row , k - 1) /= -9999 then
														-- collision with <
														if attached current.enemy_projectiles.item (current.enemy_projectile_presence  (row , k - 1)) as ep_obj then
																	current.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
																	ep_obj.set_on_board(false)
																	starfighter.subtract_health (current.max (ep_obj.damage - starfighter.current_armour, 0))
																	output.append ("%N      The Starfighter collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + row_name[ep_obj.pos.row] + ","
																												+ ep_obj.pos.column.out + "], taking " + max (ep_obj.damage - starfighter.current_armour, 0).out + " damage.")
																	if starfighter.current_health <= 0 then
																		-- game over
																		starfighter.set_current_health (0)
																		current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)
																		current.grid.put ("X", row , k - 1)
																		starfighter.set_pos (row , k - 1)
																		current.subtract_move_cost
																		current.toggle_in_game
																		current.game_state.set_state ("not started", "ok")
																		output.append ("%N      The Starfighter at location [" + row_name[row] + "," + (k - 1).out + "] has been destroyed.")
																		destination.append ("[" + row_name[row] + "," + (k - 1).out + "]")
																		current.game_state.set_state ("not started", "ok")
																		current.print_state.set_game_over ("%N  The game is over. Better luck next time!")
																	end
														end

													else
														-- do nothing ang go for next iteration


													end

												end
												k := k - 1
											end
										end

									end


								-- if still in game then move SF to its final destination and updates it old and current pos
								if in_game then

									current.grid.put ("_", starfighter.pos.row, starfighter.pos.column)
									starfighter.set_pos (row, column)
									current.grid.put ("S", starfighter.pos.row, starfighter.pos.column)
									current.subtract_move_cost
									destination.append ("[" + row_name[starfighter.pos.row] + "," + starfighter.pos.column.out + "]")

								end


								current.print_state.set_starfighter_action (destination + output)

								-- all projectiles on board with the updated location (to string)

					end

					if in_game then
						enemy_vision_update
					end

					print_state.set_enemy_action_empty
					if current.in_game then
						current.action

					end

					if in_game then
						enemy_vision_update
					end

					if current.in_game then
						enemy_setup
					end

					current.set_score (total_score.get_score)
					update_starfighter
					report_projectiles
					report_enemies
					print_state.set_grid (grid)


end

	abort
		do
				print_state.set_all_empty
				game_state.reset_x_y
				current.reset_ids
				current.reset_collection
				starfighter.reset

				toggle_in_game
				game_state.set_state ("not started", "ok")
				print_state.set_all_empty
--				current.enemy_collection.wipe_out
--				current.enemy_projectiles.wipe_out
--				current.friendly_projectiles.wipe_out
				print_state.set_message ("  Exited from game.")
				current.toggle_disply_titles
				states[setup_cursor].error.make_empty
				print_state.game_over.make_empty



		end

	reset
		do
			current.starfighter.reset
			current.game_state.reset_x_y
			current.reset_collection
			current.reset_ids
			create total_score.make
			current.set_score (0)
		end

feature -- update starfighter state
	update_starfighter
		local
			str: STRING
		do


			create str.make_empty
			if current.states[1].choice_cursor = 4 then
				str.append ("health")
			else
				str.append ("energy")
			end


			print_state.set_starfighter ("Starfighter:%N    [" + starfighter.id.id.out + "," + starfighter.id.symbol + "]->health:" + starfighter.current_health.out + "/" +
			 starfighter.total_health.out + ", energy:" + starfighter.current_energy.out + "/" + starfighter.total_energy.out + ", Regen:" + starfighter.total_regen.health.out + "/" +
			 starfighter.total_regen.energy.out + ", Armour:" + starfighter.current_armour.out + ", Vision:" + starfighter.total_vision.out +
			 ", Move:" + starfighter.total_move.out + ", Move Cost:" + starfighter.total_move_cost.out + ", location:[" + row_name[starfighter.pos.row] + "," + starfighter.pos.column.out + "]%N      Projectile Pattern:" +
			  starfighter.projectile_pattern + ", Projectile Damage:" + starfighter.total_projectile_damage.out + ", Projectile Cost:" + starfighter.total_projectile_cost.out +
			  " (" + str + ")%N      Power:" + starfighter.power + "%N      score:" + score.out)


		end


	enemy_projectile_act
		local
			output, destination: STRING
			break: BOOLEAN
		do
			create output.make_empty
			create destination.make_empty
			print_state.set_enemy_projectile_action_empty
			across 1 |..| -current.projectile_id is id
			loop
					output.make_empty
					destination.make_empty
					if attached current.enemy_projectiles.item (-id) as obj and then obj.on_board and in_game then
						destination.append ("%N    A enemy projectile(id:" + obj.id.out + ") moves: [" + row_name[obj.pos.row] + "," + obj.pos.column.out + "] -> ")
						across 1 |..| obj.move is index
							loop
								if obj.on_board and not break then

									if obj.pos.column - index < 1  then
										-- next position is out of board
										-- to string
										current.grid.put ("_",obj.pos.row, obj.pos.column)
										destination.append ("out of board")
										obj.set_on_board(false)

									else

										if current.enemy_projectile_presence(obj.pos.row, obj.pos.column - index) /= -9999  then
											-- enemy projectile (friendly projectile for an enemy) exist next to current projectile
											if attached current.enemy_projectiles.item (current.enemy_projectile_presence(obj.pos.row, obj.pos.column - index)) as ep_obj then
												obj.add_damage(ep_obj.damage)
												ep_obj.set_on_board(false)
												output.append ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out + "], combining damage.")
												current.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
											end

										elseif current.friendly_projectile_presence (obj.pos.row, obj.pos.column - index) /= -9999  then
											-- friendly projectile (enemy projectile for an enemy) exists next to current projectile
											if attached friendly_projectiles.item (friendly_projectile_presence(obj.pos.row, obj.pos.column - index)) as fp_obj then
													-- enemy projectile damage is higher than current projectile
													if fp_obj.damage > obj.damage then
														fp_obj.subtract_damage(obj.damage)
														grid.put ("_", obj.pos.row, obj.pos.column)
														obj.set_on_board(false)
														output.append ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out
														 + "], negating damage.")
														destination.append ("[" + row_name[obj.pos.row] + "," + (obj.pos.column - index).out + "]")
													-- current projectile damage is higher than enemy projectile	
													elseif obj.damage > fp_obj.damage then
														obj.subtract_damage(fp_obj.damage)
														grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
														fp_obj.set_on_board(false)
														output.append ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out
														 + "], negating damage.")



													-- current and enemy projectile damage is equal	
													else
														grid.put ("_", obj.pos.row, obj.pos.column)
														obj.set_on_board(false)
														grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
														fp_obj.set_on_board(false)
														output.append ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out
														 + "], negating damage.")
														destination.append ("[" + row_name[obj.pos.row] + "," + (obj.pos.column - index).out + "]")
													end
											end


										elseif current.enemy_presence (obj.pos.row, obj.pos.column - index) /= -9999 then
											-- enemy exist next to current projectile
											if attached enemy_collection.item (enemy_presence (obj.pos.row, obj.pos.column - index)) as enemy_obj then
												obj.set_on_board(false)
												current.grid.put ("_", obj.pos.row, obj.pos.column)
												destination.append ("[" + row_name[obj.pos.row] + "," + (obj.pos.column - index).out + "]")
												enemy_obj.add_health(obj.damage)
													if enemy_obj.current_health > enemy_obj.total_health then
														enemy_obj.set_current_health(enemy_obj.total_health)
													end

												output.append ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], healing " +  obj.damage.out  + " damage.")
											end

										elseif [obj.pos.row, obj.pos.column - index] ~ starfighter.pos then
											-- starfighter exist next to projectile	
											starfighter.subtract_health(max((obj.damage - starfighter.current_armour), 0))
											output.append("%N      The projectile collides with Starfighter(id:" + starfighter.id.id.out + ") at location [" + row_name[starfighter.pos.row] + "," + starfighter.pos.column.out + "], dealing " +  max((obj.damage - starfighter.current_armour), 0).out  + " damage.")

											obj.set_on_board(false)
											destination.append ("[" + row_name[obj.pos.row] + "," + (obj.pos.column - index).out + "]")
											grid.put ("_", obj.pos.row, obj.pos.column)

											if starfighter.current_health <= 0 then
												-- game over
												break := true
												grid.put ("X", starfighter.pos.row, starfighter.pos.column)
												starfighter.set_current_health (0)
												output.append("%N      The Starfighter at location [" + row_name[starfighter.pos.row] + "," + starfighter.pos.column.out + "] has been destroyed.")

												toggle_in_game
												current.game_state.set_state ("not started", "ok")
												current.print_state.set_game_over ("%N  The game is over. Better luck next time!")
											end

										else
											-- do nothing and go for next iteration

										end

									end
								end
							end
							-- end of inner loop
							-- if we reach here and projectile is still `on_board` then we update its old_pos and current pos

							if obj.on_board and not break then
								current.grid.put ("_",obj.pos.row, obj.pos.column)
								obj.set_old_pos(obj.pos.row, obj.pos.column)
								obj.set_pos(obj.pos.row, obj.pos.column - obj.move)
								current.grid.put ("<",obj.pos.row, obj.pos.column)

								-- to string
								destination.append ("[" + row_name[obj.pos.row] + "," + obj.pos.column.out + "]")
							end
					end

					current.print_state.set_enemy_projectile_action (destination + output)


			end
		end





	report_projectiles
		local
		length: INTEGER
		do
			print_state.set_projectile_empty
			across 1 |..| -current.projectile_id is id
			loop
				if current.friendly_projectiles.has (-id) and attached current.friendly_projectiles.item (-id) as obj and then obj.on_board then
					print_state.set_projectile (obj.report_status)
				else
					if attached current.enemy_projectiles.item (-id) as obj and then obj.on_board then
						print_state.set_projectile (obj.report_status)
					end
				end


			end



		end


	report_enemies
		do
			print_state.set_enemy_empty
			across 1 |..| current.enemy_collection.count is id
			loop
				if attached current.enemy_collection.item (id) as obj and then obj.on_board then
					print_state.set_enemy (obj.report_status)
					obj.set_turn(false)

				end


			end
		end


	spawn_enemy(enemy_obj: ENEMY; row: INTEGER; column: INTEGER)
		local
			output: STRING
			destination: STRING
		do
			create output.make_empty
			create destination.make_empty
			enemy_obj.set_old_pos (row, column)
			enemy_obj.set_pos (row,column)
			enemy_obj.set_seen_by_sf (starfighter.seen_by_starfighter(row,column ))
			enemy_obj.set_can_see_sf (enemy_obj.can_see_starfighter (starfighter.pos.row, starfighter.pos.column))
			enemy_obj.set_on_board (true)


			if current.friendly_projectile_presence (row, column) /= -9999 then
				-- spawning in a location occupied by a friendly projectile (in this case it is enemy projectile for an enemy)
					if attached friendly_projectiles.item (friendly_projectile_presence (row, column)) as fp_obj then
							destination.append ("%N    A " + enemy_obj.name + "(id:" + enemy_id.out + ") spawns at location [" + row_name[row] + "," + column.out + "].")
							add_enemy (enemy_obj)
							fp_obj.set_on_board (false)
							enemy_obj.subtract_health (max (fp_obj.damage - enemy_obj.armour, 0))
							output.append ("%N      The " + enemy_obj.name +   " collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + row_name[row] + "," + column.out + "], taking " + max (fp_obj.damage - enemy_obj.armour, 0).out + " damage.")
							if enemy_obj.current_health <= 0 then
								enemy_obj.set_current_health (0)
								enemy_obj.set_on_board (false)
								grid.put ("_", row, column)
								output.append ("%N      The " + enemy_obj.name + " at location [" + row_name[row] + "," + column.out + "] has been destroyed.")
								enemy_obj.add_to_focus
							else
								grid.put (enemy_obj.get_symbol, row, column)
							end
					end


			elseif current.enemy_projectile_presence (row, column) /= -9999 then
				-- spwaning in a location occupied by enemy projectile (in this case it is friendly projectile for an enemy)
					if attached enemy_projectiles.item (enemy_projectile_presence (row, column)) as ep_obj then
						destination.append ("%N    A " + enemy_obj.name + "(id:" + enemy_id.out + ") spawns at location [" + row_name[row] + "," + column.out + "].")
						add_enemy (enemy_obj)
						ep_obj.set_on_board (false)
						enemy_obj.add_health (ep_obj.damage)
						output.append ("N      The " + enemy_obj.name + " collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out + "], healing " + ep_obj.damage.out + " damage.")
						if enemy_obj.current_health > enemy_obj.total_health then
							enemy_obj.set_current_health (enemy_obj.total_health)
						end
						grid.put (enemy_obj.get_symbol, row, column)
					end

			elseif current.enemy_presence (row, column) /= -9999 then

				-- no enemy is spawned spawn

			elseif starfighter.pos ~ [row, column] then
				-- spawning in a location occupied by starfighter
					destination.append ("%N    A " + enemy_obj.name + "(id:" + enemy_id.out + ") spawns at location [" + row_name[row] + "," + column.out + "].")
					add_enemy (enemy_obj)
					enemy_obj.set_on_board (false)
					output.append ("%N      The " + enemy_obj.name + " collides with Starfighter(id:0) at location [" + row_name[starfighter.pos.row] + "," + starfighter.pos.column.out + "], trading " + enemy_obj.current_health.out + " damage.")
					starfighter.subtract_health (enemy_obj.current_health)
					enemy_obj.add_to_focus
					if starfighter.current_health <= 0 then
						toggle_in_game
						grid.put ("X", starfighter.pos.row, starfighter.pos.column)
						starfighter.set_current_health (0)

						output.append ("%N      The Starfighter at location [" + row_name[starfighter.pos.row] + "," + starfighter.pos.column.out + "] has been destroyed.")
					end
			else
				destination.append ("%N    A " + enemy_obj.name + "(id:" + enemy_id.out + ") spawns at location [" + row_name[row] + "," + column.out + "].")
				add_enemy(enemy_obj)
				grid.put (enemy_obj.get_symbol, row, column)

			end
			print_state.set_natural_enemy_spawn_empty
			print_state.set_natural_enemy_spawn (destination + output)

		end

	enemy_setup
		local
			enemy_obj: ENEMY
			random_i: INTEGER
			random_j: INTEGER
		do
			random_i := random.rchoose (1, board_row)
			random_j := random.rchoose (1, 100)
			current.print_state.set_natural_enemy_spawn_empty
	--		if not current.enemy_entity.has (grid.item (random_i, grid.width)) then

				if 1 <= random_j and random_j < grunt_threshold then
						create {GRUNT} enemy_obj.make(enemy_id)
						spawn_enemy(enemy_obj, random_i, grid.width)

				elseif grunt_threshold <= random_j and random_j < fighter_threshold then
					create {FIGHTER} enemy_obj.make(enemy_id)
					spawn_enemy(enemy_obj, random_i, grid.width)

				elseif fighter_threshold <= random_j and random_j < carrier_threshold then
					create {CARRIER} enemy_obj.make(enemy_id)
					spawn_enemy(enemy_obj, random_i, grid.width)

				elseif carrier_threshold <= random_j and random_j < interceptor_threshold then
					create {INTERCEPTOR} enemy_obj.make(enemy_id)
					spawn_enemy(enemy_obj, random_i, grid.width)

				elseif interceptor_threshold <= random_j and random_j < pylon_threshold  then
					create {PYLON} enemy_obj.make(enemy_id)
					spawn_enemy(enemy_obj, random_i, grid.width)

				else
					-- no enemy is spawn
					print_state.set_natural_enemy_spawn_empty

				end
--			end

		end


	enemy_vision_update
		do
			across 1 |..| current.enemy_id is id
			loop
				if attached current.enemy_collection.item (id) as e_obj and then e_obj.on_board then
					e_obj.update_can_see_sf
					e_obj.update_seen_by_sf
				end

			end
		end

	preemptive_action(str: STRING)
		do

			across 1 |..| current.enemy_collection.count is id
			loop
				if attached current.enemy_collection.item (id) as obj and then in_game then
					if attached {ENEMY} obj as e_obj then
						if e_obj.on_board then
							e_obj.preemptive_action(str)
						end

					end

				end

			end
		end

	action
		do
			across 1 |..| current.enemy_collection.count is id
			loop
				if attached current.enemy_collection.item (id) as e_obj and then in_game then

					if e_obj.on_board and (not e_obj.end_turn) then
						e_obj.action
					end

				end

			end
		end

	add_enemy(e: ENEMY)
		do
			enemy_collection.extend (e, enemy_id)
			increment_enemy_id
		end

	add_enemy_projectile(ep: ENEMY_PROJECTILE)
		do
			enemy_projectiles.extend (ep, projectile_id)
			projectile_id := projectile_id - 1

		end

	add_friendly_projectile(fp: FRIENDLY_PROJECTILE)
		do
			friendly_projectiles.extend (fp, projectile_id)
			projectile_id := projectile_id - 1
		end

	toggle_disply_titles
		do
			if current.display_titles = true then
				display_titles := false
			else
				display_titles := true
			end
		end

feature -- Below features looks for collision

	enemy_presence(row: INTEGER; column: INTEGER): INTEGER
		do
			result := -9999
			across 1 |..| current.enemy_id is id
			loop
				if current.enemy_collection.has_key (id) then
					if attached current.enemy_collection.item (id) as obj and then obj.on_board then

							if obj.pos.row = row and obj.pos.column = column then
								result :=  obj.id
							end


					end
				end

			end


		end

	enemy_projectile_presence(row: INTEGER; column: INTEGER): INTEGER
		do
			result := -9999
			across 1 |..| (current.friendly_projectiles.count + current.enemy_projectiles.count) is id
			loop
				if current.enemy_projectiles.has_key (-id) then
					if attached current.enemy_projectiles.item (-id) as obj then
						if attached {ENEMY_PROJECTILE} obj as ep_obj and then ep_obj.on_board then
							if ep_obj.pos.row = row and ep_obj.pos.column = column then
								result := ep_obj.id
							end
						end

					end
				end

			end

		end

	friendly_projectile_presence(row: INTEGER; column: INTEGER): INTEGER
		do
			result := -9999
			across 1 |..| (current.friendly_projectiles.count + current.enemy_projectiles.count) is id
			loop

				if current.friendly_projectiles.has_key (-id)  then
					if attached current.friendly_projectiles.item (-id) as obj and then obj.on_board then
						if attached {FRIENDLY_PROJECTILE} obj as fp_obj and then fp_obj.on_board then
							if fp_obj.pos.row = row and fp_obj.pos.column = column then
								result := fp_obj.id
							end
						end

					end

				end

			end

		end

	reset_collection
		do
			create enemy_collection.make (100)
			create friendly_projectiles.make (100)
			create enemy_projectiles.make (100)
		end

	reset_ids
		do
			projectile_id := -1
			enemy_id := 1

		end

	set_score(sc: INTEGER)
		do
			score := sc
		end

	--------------------- TEST SCORE -------------------
		test_score
			local
				bronze1, bronze2, silver, gold: ORB
				diamond, platinum: FOCUS
				total: SCORE
			do
--				create total.make

--				create {SILVER} silver.make
--				total.add (silver)

--				create {DIAMOND} diamond.make
--				total.add (diamond)

--				create {GOLD} gold.make
--				total.add (gold)

--				create {BRONZE} bronze1.make
--				total.add (bronze1)

--				create {PLATINUM} platinum.make
--				total.add (platinum)

--				create {BRONZE} bronze2.make
--				total.add (bronze2)

--			--	current.set_score (total.get_score)
--				current.print_state.set_natural_enemy_spawn (total.get_score.out)


			end




	-----------------------------------------------------	


feature -- queries
	get_setup_cursor : INTEGER
		do
			result := setup_cursor
		end

	max(x: INTEGER; y: INTEGER): INTEGER
		do
			if x > y then
				result := x
			else
				result := y
			end
		end



feature -- queries
	out : STRING
		do
			create Result.make_empty
			result.append (game_state.out)
			if not in_setup_mode then
				result.append (print_state.out)
			end

			if in_setup_mode then
				result.append(states[setup_cursor].out)
			end

		end



invariant
	contradiction:
		(in_game and in_setup_mode) = false

end




