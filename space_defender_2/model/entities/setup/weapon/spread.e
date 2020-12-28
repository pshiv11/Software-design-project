note
	description: "Summary description for {SPREAD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WEAPON_SPREAD
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
			name.make_from_string ("Spread")
			health  := 0
			energy := 60
			regen :=[0,2]
			armour := 1
			vision := 0
			move := 0
			move_cost := 2
			projectile_damage := 50
			projectile_cost := 10

		end


fire
		local
			projectile1, projectile2, projectile3: FRIENDLY_PROJECTILE

		do
			model.m.print_state.set_starfighter_action_empty


			-- subtracting the costing of firing
			model.m.starfighter.subtract_energy (model.m.starfighter.total_projectile_cost)

		-- creating all 3 projectiles
			create {FRIENDLY_PROJECTILE} projectile1.make (model.m.projectile_id, model.m.starfighter.total_projectile_damage,  1, model.m.starfighter.pos.row - 1, model.m.starfighter.pos.column + 1)
			model.m.add_friendly_projectile (projectile1)
			create {FRIENDLY_PROJECTILE} projectile2.make (model.m.projectile_id, model.m.starfighter.total_projectile_damage, 1, model.m.starfighter.pos.row, model.m.starfighter.pos.column + 1)
			model.m.add_friendly_projectile (projectile2)
			create {FRIENDLY_PROJECTILE} projectile3.make (model.m.projectile_id, model.m.starfighter.total_projectile_damage, 1, model.m.starfighter.pos.row + 1, model.m.starfighter.pos.column + 1)
			model.m.add_friendly_projectile (projectile3)
		-- fire string
		model.m.print_state.set_starfighter_action ("%N    The Starfighter(id:" + model.m.starfighter.id.id.out + ") fires at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out
				 		+ "].")

		-- top right of SF
				-- spawning outside the board
				if (projectile1.pos.row < 1) or (projectile1.pos.column  > model.m.grid.width) then
					model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile1.id.out + ") spawns at location out of board.")


				else
					model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile1.id.out + ") spawns at location ["+ model.m.row_name[projectile1.pos.row] + "," + projectile1.pos.column.out.out + "].")

					if model.m.enemy_projectile_presence (projectile1.pos.row, projectile1.pos.column) /= -9999 then
					--Spawing in a location that has enemy projectile

						if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (projectile1.pos.row, projectile1.pos.column)) as ep_obj then
						-- enemy projectile damage is higher than current projectile
							if ep_obj.damage > projectile1.damage then
								ep_obj.subtract_damage(projectile1.damage)
							--	model.m.grid.put ("_", projectile1.pos.row, projectile1.pos.column)
								model.m.print_state.set_starfighter_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
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
								 projectile1.set_on_board (false)

							end
						end
					elseif model.m.friendly_projectile_presence (projectile1.pos.row, projectile1.pos.column) /= -9999 then
						-- Spawning in a location that has friendly projectile
						-- combine the damage of both projectile and remove the exisiting projectile from board
						if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (projectile1.pos.row, projectile1.pos.column )) as fp_obj then
							projectile1.add_damage(fp_obj.damage)
							fp_obj.set_on_board(false)
							model.m.print_state.set_starfighter_action ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
							model.m.grid.put ("*", projectile1.pos.row, projectile1.pos.column)
							projectile1.set_on_board (true)
						end
					elseif model.m.enemy_presence (projectile1.pos.row, projectile1.pos.column) /= -9999 then
						-- spwawning in a location that has an enemy
						-- friendly projectile is removed from the board and enemy, depends on it health after collision may or may not be removed from the board
						if attached model.m.enemy_collection.item (model.m.enemy_presence (projectile1.pos.row, projectile1.pos.column)) as enemy_obj then
							enemy_obj.subtract_health(model.m.max((projectile1.damage - enemy_obj.armour), 0))
							model.m.print_state.set_starfighter_action ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((projectile1.damage - enemy_obj.armour), 0).out  + " damage.")
							if enemy_obj.current_health <= 0 then
								model.m.print_state.set_starfighter_action ("%N      The " + enemy_obj.name +  " at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed.")
								enemy_obj.set_on_board(false)
								model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
							--	model.m.grid.put ("*", projectile1.pos.row, projectile1.pos.column)
								projectile1.set_on_board (false)
								enemy_obj.add_to_focus
							end
						end


					else
						model.m.grid.put ("*", projectile1.pos.row, projectile1.pos.column)
						projectile1.set_on_board (true)

					end


				end

 		-- directly to the right of SF	

 			if (projectile2.pos.column) > model.m.grid.width  then
				model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile2.id.out + ") spawns at location out of board.")
			else
				model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile2.id.out + ") spawns at location ["+ model.m.row_name[projectile2.pos.row] + "," + projectile2.pos.column.out.out + "].")
				if model.m.enemy_projectile_presence (projectile2.pos.row, projectile2.pos.column) /= -9999 then
					--Spawing in a location that has enemy projectile
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
				elseif model.m.friendly_projectile_presence (projectile2.pos.row, projectile2.pos.column) /= -9999 then
					-- Spawning in a location that has friendly projectile
					-- combine the damage of both projectile and remove the exisiting projectile from board
					if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (projectile2.pos.row, projectile2.pos.column )) as fp_obj then
							projectile2.add_damage(fp_obj.damage)
							fp_obj.set_on_board(false)
							model.m.print_state.set_starfighter_action ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
							model.m.grid.put ("*", projectile2.pos.row, projectile2.pos.column)
							projectile2.set_on_board (true)
					end

				elseif model.m.enemy_presence (projectile2.pos.row, projectile2.pos.column) /= -9999 then
					-- spawning in a location that has an enemy
					-- friendly projectile is removed from the board and enemy, depends on it health after collision may or may not be removed from the board
					if attached model.m.enemy_collection.item (model.m.enemy_presence (projectile2.pos.row, projectile2.pos.column)) as enemy_obj then
							enemy_obj.subtract_health(model.m.max((projectile2.damage - enemy_obj.armour), 0))
							model.m.print_state.set_starfighter_action ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((projectile2.damage - enemy_obj.armour), 0).out  + " damage.")
							if enemy_obj.current_health <= 0 then
								model.m.print_state.set_starfighter_action ("%N      The " + enemy_obj.name +  " at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed.")
								enemy_obj.set_on_board(false)
								model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
							--	model.m.grid.put ("*", projectile2.pos.row, projectile2.pos.column)
								projectile2.set_on_board (false)
								enemy_obj.add_to_focus
							end
					end


				else
			--		model.m.add_friendly_projectile (projectile2)
					projectile2.set_on_board (true)
					model.m.grid.put ("*", projectile2.pos.row, projectile2.pos.column)


				end

			end

	-- botton right of SF

			-- check to see if spawing location is on board
				if (projectile3.pos.row > model.m.grid.height) or (projectile3.pos.column > model.m.grid.width) then
					model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile3.id.out + ") spawns at location out of board.")
				else
					model.m.print_state.set_starfighter_action ("%N      A friendly projectile(id:" + projectile3.id.out + ") spawns at location ["+ model.m.row_name[projectile3.pos.row] + "," + projectile3.pos.column.out.out + "].")
					if model.m.enemy_projectile_presence (projectile3.pos.row, projectile3.pos.column) /= -9999 then
						--Spawing in a location that has enemy projectile
						if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence (projectile3.pos.row, projectile3.pos.column)) as ep_obj then
						-- enemy projectile damage is higher than current projectile
							if ep_obj.damage > projectile3.damage then
								ep_obj.subtract_damage(projectile3.damage)
							--	model.m.grid.put ("_", projectile3.pos.row, projectile2.pos.column)
								model.m.print_state.set_starfighter_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
								 + "], negating damage.")
								 projectile3.set_on_board (false)

						-- current projectile damage is higher than enemy projectile	
							elseif projectile3.damage > ep_obj.damage then
								projectile3.subtract_damage(ep_obj.damage)
								model.m.grid.put ("*", projectile3.pos.row, projectile3.pos.column)
								ep_obj.set_on_board(false)
								model.m.print_state.set_starfighter_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
								 + "], negating damage.")
								projectile3.set_on_board (true)

						-- current and enemy projectile damage is equal	
							else
								model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
								ep_obj.set_on_board(false)
								model.m.print_state.set_starfighter_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
								 + "], negating damage.")
								 projectile3.set_on_board (false)

							end
					end

					elseif model.m.friendly_projectile_presence (projectile3.pos.row, projectile3.pos.column) /= -9999 then
						-- Spawning in a location that has friendly projectile
						-- combine the damage of both projectile and remove the exisiting projectile from board
						if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (projectile3.pos.row, projectile3.pos.column )) as fp_obj then
							projectile3.add_damage(fp_obj.damage)
							fp_obj.set_on_board(false)
							model.m.print_state.set_starfighter_action ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
							model.m.grid.put ("*", projectile3.pos.row, projectile3.pos.column)
							projectile3.set_on_board (true)
						end


					elseif model.m.enemy_presence (projectile3.pos.row, projectile3.pos.column) /= -9999 then
						-- spwawning in a location that has an enemy
						-- friendly projectile is removed from the board and enemy, depends on it health after collision may or may not be removed from the board
						if attached model.m.enemy_collection.item (model.m.enemy_presence (projectile3.pos.row, projectile3.pos.column)) as enemy_obj then
							enemy_obj.subtract_health(model.m.max((projectile3.damage - enemy_obj.armour), 0))
							model.m.print_state.set_starfighter_action ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((projectile3.damage - enemy_obj.armour), 0).out  + " damage.")
							if enemy_obj.current_health <= 0 then
								model.m.print_state.set_starfighter_action ("%N      The " + enemy_obj.name +  " at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed.")
								enemy_obj.set_on_board(false)
								model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
							--	model.m.grid.put ("*", projectile3.pos.row, projectile3.pos.column)
								projectile3.set_on_board (false)
								enemy_obj.add_to_focus
							end
						end

					else
						projectile3.set_on_board (true)
						model.m.grid.put ("*", projectile3.pos.row, projectile3.pos.column)

					end

				end


		end

	friendly_projectile_act
		local
			i: INTEGER
			output, output1, output2, output3, destination: STRING
			break: BOOLEAN
			keys: ARRAY[INTEGER]
		do
			model.m.print_state.set_friendly_projectile_action_empty
			create keys.make_from_array (model.m.friendly_projectiles.current_keys)
			create output.make_empty
			create output1.make_empty
			create output2.make_empty
			create output3.make_empty
			create destination.make_empty
			from
				i := 1
			until
				i > keys.count
			loop
				output.make_empty
				output1.make_empty
				output2.make_empty
				output3.make_empty
				destination.make_empty

				-- move top right
				if attached model.m.friendly_projectiles.item (keys[i]) as obj then

				--	destination.append ("%N    A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "] -> ")

					if obj.on_board and not break and model.m.in_game then

						if (obj.pos.row - 1 < 1) or (obj.pos.column + 1 > model.m.grid.width) then
							-- projectiles moves out of board
							model.m.grid.put ("_", obj.pos.row, obj.pos.column)
							model.m.print_state.set_friendly_projectile_action ("%N    A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "] -> out of board")
						--	destination.append ("out of board")
--							obj.set_old_pos(obj.pos.row, obj.pos.column)
--							obj.set_pos(obj.pos.row - 1, obj.pos.column + 1)
							obj.set_on_board(false)

						else
							model.m.print_state.set_friendly_projectile_action ("%N    A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column).out + "] -> [" + model.m.row_name[obj.pos.row - 1] + "," + (obj.pos.column + 1).out + "]")
							model.m.grid.put ("_",obj.pos.row, obj.pos.column)

							if model.m.friendly_projectile_presence (obj.pos.row - 1, obj.pos.column + 1) /= -9999 then
							-- collision with *
								if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (obj.pos.row - 1, obj.pos.column + 1)) as fp_obj then
									obj.add_damage(fp_obj.damage)
									model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
									fp_obj.set_on_board(false)
									model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
								end



							elseif model.m.enemy_projectile_presence (obj.pos.row - 1, obj.pos.column + 1) /= -9999 then
								-- collision with <
								if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence(obj.pos.row - 1, obj.pos.column + 1)) as ep_obj then
									-- enemy projectile damage is higher than current projectile
									if ep_obj.damage > obj.damage then
										ep_obj.subtract_damage(obj.damage)
										obj.set_on_board(false)

										model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")

									-- current projectile damage is higher than enemy projectile	
									elseif obj.damage > ep_obj.damage then
										obj.subtract_damage(ep_obj.damage)
										model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
										ep_obj.set_on_board(false)
										model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")

									-- current and enemy projectile damage is equal	
									else
										obj.set_on_board(false)
										model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
										ep_obj.set_on_board(false)
										model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")

									end
								end

							elseif model.m.enemy_presence (obj.pos.row - 1, obj.pos.column + 1) /= -9999 then
								-- collision with one of {G, F, C, I, P}
								if attached model.m.enemy_collection.item (model.m.enemy_presence (obj.pos.row - 1, obj.pos.column + 1)) as enemy_obj then
									obj.set_on_board(false)
									enemy_obj.subtract_health(model.m.max((obj.damage - enemy_obj.armour), 0))
									model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with " +  enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "], dealing " +  model.m.max((obj.damage - enemy_obj.armour), 0).out  + " damage.")
									if enemy_obj.current_health <= 0 then
										enemy_obj.set_current_health (0)
										model.m.print_state.set_friendly_projectile_action ("%N      The " + enemy_obj.name +  " at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed.")
										enemy_obj.set_on_board(false)
										model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
										enemy_obj.add_to_focus
									end
								end


							elseif model.m.starfighter.pos ~ [obj.pos.row - 1, obj.pos.column + 1] then
								-- collision with S
								model.m.starfighter.subtract_health(model.m.max((obj.damage - model.m.starfighter.current_armour), 0))
								model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with Starfighter(id:" + model.m.starfighter.id.id.out + ") at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], dealing " +  model.m.max((obj.damage - model.m.starfighter.current_armour), 0).out  + " damage.")
								obj.set_on_board(false)

								if model.m.starfighter.current_health <= 0 then
									-- game over
									model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
									model.m.starfighter.set_current_health (0)
									model.m.print_state.set_friendly_projectile_action ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
									model.m.toggle_in_game
									model.m.game_state.set_state ("not started", "ok")
									model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")
									break := true
								end

							else
								-- nothing

							end
							-- if still on board and not destroyed, move projectile to its final destination
							if obj.on_board then
								obj.set_old_pos(obj.pos.row, obj.pos.column)
								obj.set_pos(obj.pos.row - 1, obj.pos.column + 1)
								model.m.grid.put ("*",obj.pos.row, obj.pos.column)

							end

						end
					end
				end

				-- move to the right
				if attached  model.m.friendly_projectiles.item(keys[i+1]) as obj then
					if obj.on_board and not break and model.m.in_game then

						if obj.pos.column + 1 > model.m.grid.width then
							-- projectiles moves out of board
							model.m.print_state.set_friendly_projectile_action ("%N    A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "] -> out of board")
							model.m.grid.put ("_", obj.pos.row, obj.pos.column)
							obj.set_old_pos(obj.pos.row, obj.pos.column)
							obj.set_pos(obj.pos.row , obj.pos.column + 1)
							obj.set_on_board(false)

						else
							model.m.print_state.set_friendly_projectile_action ("%N    A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column).out + "] -> [" + model.m.row_name[obj.pos.row] + "," + (obj.pos.column + 1).out + "]")
							model.m.grid.put ("_",obj.pos.row, obj.pos.column)
							if model.m.friendly_projectile_presence (obj.pos.row , obj.pos.column + 1) /= -9999 then
								-- collision with *
								if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (obj.pos.row , obj.pos.column + 1)) as fp_obj then
									obj.add_damage(fp_obj.damage)
									model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
									fp_obj.set_on_board(false)
									model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
								end
							elseif model.m.enemy_projectile_presence (obj.pos.row , obj.pos.column + 1) /= -9999 then
								-- collision with <
								if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence(obj.pos.row , obj.pos.column + 1)) as ep_obj then
									-- enemy projectile damage is higher than current projectile
									if ep_obj.damage > obj.damage then
										ep_obj.subtract_damage(obj.damage)
										obj.set_on_board(false)
										model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")

									-- current projectile damage is higher than enemy projectile	
									elseif obj.damage > ep_obj.damage then
										obj.subtract_damage(ep_obj.damage)
										model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
										ep_obj.set_on_board(false)
										model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")

									-- current and enemy projectile damage is equal	
									else
										obj.set_on_board(false)
										model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
										ep_obj.set_on_board(false)
										model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")

									end
								end

							elseif model.m.enemy_presence (obj.pos.row , obj.pos.column + 1) /= -9999 then
								-- collision with one of {G, F, C, I, P}
								if attached model.m.enemy_collection.item (model.m.enemy_presence (obj.pos.row , obj.pos.column + 1)) as enemy_obj then
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


							elseif model.m.starfighter.pos ~ [obj.pos.row , obj.pos.column + 1] then
								-- collision with S
								model.m.starfighter.subtract_health(model.m.max((obj.damage - model.m.starfighter.current_armour), 0))
								model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with Starfighter(id:" + model.m.starfighter.id.id.out + ") at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], dealing " +  model.m.max((obj.damage - model.m.starfighter.current_armour), 0).out  + " damage.")
								obj.set_on_board(false)

								if model.m.starfighter.current_health <= 0 then
									-- game over
									model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
									model.m.starfighter.set_current_health (0)
									model.m.print_state.set_friendly_projectile_action ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
									model.m.toggle_in_game
									model.m.game_state.set_state ("not started", "ok")
									model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")
									break := true
								end

							else

							end

							-- if still on board and not destroyed, move projectile to its final destination
							if obj.on_board then
								obj.set_old_pos(obj.pos.row, obj.pos.column)
								obj.set_pos(obj.pos.row , obj.pos.column + 1)
								model.m.grid.put ("*",obj.pos.row, obj.pos.column)

							end
						end
					end
				end

			-- move bottom right
				if attached model.m.friendly_projectiles.item(keys[i + 2]) as obj then
					if obj.on_board and not break and model.m.in_game then

						if obj.pos.row + 1 > model.m.grid.height then
							-- projectiles moves out of board
							model.m.grid.put ("_", obj.pos.row, obj.pos.column)
							model.m.print_state.set_friendly_projectile_action ("%N    A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "] -> out of board")
							obj.set_old_pos(obj.pos.row, obj.pos.column)
							obj.set_pos(obj.pos.row + 1, obj.pos.column + 1)
							obj.set_on_board(false)

						else
							model.m.print_state.set_friendly_projectile_action ("%N    A friendly projectile(id:" + obj.id.out + ") moves: [" + model.m.row_name[obj.pos.row] + "," + obj.pos.column.out + "] -> [" + model.m.row_name[obj.pos.row + 1] + "," + (obj.pos.column + 1).out + "]")
							model.m.grid.put ("_",obj.pos.row, obj.pos.column)
							if model.m.friendly_projectile_presence (obj.pos.row + 1, obj.pos.column + 1) /= -9999 then
								-- collision with *
								if attached model.m.friendly_projectiles.item (model.m.friendly_projectile_presence (obj.pos.row + 1, obj.pos.column + 1)) as fp_obj then
									obj.add_damage(fp_obj.damage)
									model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
									fp_obj.set_on_board(false)
									model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with friendly projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "], combining damage.")
								end

							elseif model.m.enemy_projectile_presence (obj.pos.row + 1, obj.pos.column + 1) /= -9999 then
								-- collision with <
								if attached model.m.enemy_projectiles.item (model.m.enemy_projectile_presence(obj.pos.row + 1, obj.pos.column + 1)) as ep_obj then
									-- enemy projectile damage is higher than current projectile
									if ep_obj.damage > obj.damage then
										ep_obj.subtract_damage(obj.damage)
										obj.set_on_board(false)
										model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")

									-- current projectile damage is higher than enemy projectile	
									elseif obj.damage > ep_obj.damage then
										obj.subtract_damage(ep_obj.damage)
										model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
										ep_obj.set_on_board(false)
										model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")

									-- current and enemy projectile damage is equal	
									else
										obj.set_on_board(false)
										model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
										ep_obj.set_on_board(false)
										model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with enemy projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out
										 + "], negating damage.")

									end
								end

							elseif model.m.enemy_presence (obj.pos.row + 1, obj.pos.column + 1) /= -9999 then
								-- collision with one of {G, F, C, I, P}
								if attached model.m.enemy_collection.item (model.m.enemy_presence (obj.pos.row + 1, obj.pos.column + 1)) as enemy_obj then
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

							elseif model.m.starfighter.pos ~ [obj.pos.row + 1, obj.pos.column + 1] then
								-- collision with S
								model.m.starfighter.subtract_health(model.m.max((obj.damage - model.m.starfighter.current_armour), 0))
								model.m.print_state.set_friendly_projectile_action ("%N      The projectile collides with Starfighter(id:" + model.m.starfighter.id.id.out + ") at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "], dealing " +  model.m.max((obj.damage - model.m.starfighter.current_armour), 0).out  + " damage.")
								obj.set_on_board(false)

								if model.m.starfighter.current_health <= 0 then
									-- game over
									model.m.grid.put ("X", model.m.starfighter.pos.row, model.m.starfighter.pos.column)
									model.m.starfighter.set_current_health (0)
									model.m.print_state.set_friendly_projectile_action ("%N      The Starfighter at location [" + model.m.row_name[model.m.starfighter.pos.row] + "," + model.m.starfighter.pos.column.out + "] has been destroyed.")
									model.m.toggle_in_game
									model.m.game_state.set_state ("not started", "ok")
									model.m.print_state.set_game_over ("%N  The game is over. Better luck next time!")
									break := true
								end

							else

							end

							-- if still on board and not destroyed, move projectile to its final destination
							if obj.on_board then
								obj.set_old_pos(obj.pos.row, obj.pos.column)
								obj.set_pos(obj.pos.row + 1, obj.pos.column + 1)
								model.m.grid.put ("*",obj.pos.row, obj.pos.column)
							end

						end
					end
				end
			i := i + 3
			end

		end



end
