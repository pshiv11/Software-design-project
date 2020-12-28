note
	description: "Summary description for {PRINT_STATE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PRINT_STATE

inherit
	ANY
redefine out end

create
	make

feature
	make
		do
			create options.make_empty
			create error.make_empty
			create welcome.make_empty
			create grid.make_empty
			create starfighter.make_empty
			create row_name.make_from_array (<<"A", "B", "C","D", "E", "F","G", "H", "I", "J">>)
			create game_over.make_empty
--------------------------------------Initialization of titles----------------------------------------------------
			create enemy_title.make_from_string ("%N  Enemy:")
			create projectile_title.make_from_string ("%N  Projectile:")
			create friendly_projectile_action_title.make_from_string ("%N  Friendly Projectile Action:")
			create enemy_projectile_action_title.make_from_string("%N  Enemy Projectile Action:")
			create starfighter_action_title.make_from_string ("%N  Starfighter Action:")
			create enemy_action_title.make_from_string ("%N  Enemy Action:")
			create natural_enemy_spawn_title.make_from_string ("%N  Natural Enemy Spawn:")
----------------------------------------Initialization of respection actions-----------------------------------------------

			create enemy.make_empty
			create projectile.make_empty
			create friendly_projectile_action.make_empty
			create enemy_projectile_action.make_empty
			create starfighter_action.make_empty
			create enemy_action.make_empty
			create natural_enemy_spawn.make_empty
		end

feature -- attributes

	starfighter: STRING
	row_name: ARRAY[STRING]

-- print sections attributes
	welcome: STRING
	error: STRING
	options: STRING
	game_over: STRING

-- debug mode attributes
	-- predefined titles
	enemy_title, projectile_title, friendly_projectile_action_title,enemy_projectile_action_title, starfighter_action_title, enemy_action_title, natural_enemy_spawn_title : STRING
--
	enemy, projectile, friendly_projectile_action, enemy_projectile_action, starfighter_action, enemy_action, natural_enemy_spawn: STRING
	grid: STRING





feature -- commands empty state options to display error

	set_options_empty
		do
			options.make_empty
		end
	set_error_empty
		do
			error.make_empty
		end
	set_welcome_empty
		do
			welcome.make_empty
		end
	set_starfighter_empty
		do
			starfighter.make_empty
		end


	set_all_empty
		do
			welcome.make_empty
			options.make_empty
			error.make_empty
			starfighter.make_empty
			grid.make_empty
			enemy.make_empty
			projectile.make_empty
			friendly_projectile_action.make_empty
			enemy_projectile_action.make_empty
			starfighter_action.make_empty
			enemy_action.make_empty
			natural_enemy_spawn.make_empty
			game_over.make_empty

		end

feature -- commands display state options		


	set_welcome(str: STRING)
		do

			welcome.make_empty
			welcome.append(str)
		end
	set_error(str: STRING)
		do
			error.append(str)
		end
	set_options(str: STRING)
		do

			options.append(str)
		end

	set_starfighter(str: STRING)
		do
			starfighter.make_empty
			starfighter.append (str)
		end

	set_message(str: STRING)
		do
			grid.make_empty
			grid.append (str)
		end

	set_game_over(str: STRING)
		do
			game_over.append (str)
		end

-------------------------------------printing 2D Array ------------------------------------------------------		

	set_grid(array: ARRAY2[STRING])
		local
			model :ETF_MODEL_ACCESS
		do
			grid.make_empty
			grid.append ("%N")
				if  model.m.in_debug_mode then
					grid.append ("    ")
								across 1 |..| array.width is col
									loop
										if col > 9 then
											grid.append(" ")
											grid.append (col.out)
										else
											grid.append("  ")
											grid.append (col.out)
										end

								end
								grid.append ("%N")

								across 1 |..| array.height is j
								loop
										grid.append ("    ")
										grid.append (row_name[j])
										grid.append (" ")
										across 1 |..| array.width is k
										loop
											grid.append (array.item (j, k))
											if k /= array.width then
												grid.append ("  ")
											end

										end
									if not (j = array.height) then
										grid.append ("%N")
									end
								end
				else

						grid.append ("    ")
								across 1 |..| array.width is col
									loop
										if col > 9 then
											grid.append(" ")
											grid.append (col.out)
										else
											grid.append("  ")
											grid.append (col.out)
										end

								end
								grid.append ("%N")

								across 1 |..| array.height is j
								loop
										grid.append ("    ")
										grid.append (row_name[j])
										grid.append (" ")
										across 1 |..| array.width is k
										loop

											if not model.m.starfighter.seen_by_starfighter (j, k) then
												grid.append ("?")
											else
												grid.append (array.item (j, k))
											end

											if k /= array.width then
												grid.append ("  ")
											end

										end
									if not (j = array.height) then
										grid.append ("%N")
									end
								end


				end

		end
-------------------------------------END printing 2D Array ------------------------------------------------------	


feature -- set debug mode sections
	set_enemy(str: STRING)
		do
			enemy.append (str)
		end

	set_enemy_empty
		do
			enemy.make_empty
		end
--------------------------------------------------------------
	set_projectile(str: STRING)
		do
			projectile.append (str)
		end

	set_projectile_empty
		do
			projectile.make_empty
		end
--------------------------------------------------------------

	set_friendly_projectile_action(str: STRING)
		do
			friendly_projectile_action.append (str)
		end

	prepend_friendly_projectile_action(str:STRING)
		do
			friendly_projectile_action.prepend (str)
		end

	set_friendly_projectile_action_empty
		do
			friendly_projectile_action.make_empty
		end
--------------------------------------------------------------

	set_enemy_projectile_action(str: STRING)
		do
			enemy_projectile_action.append (str)
		end

	prepend_enemy_projectile_action(str:STRING)
		do
			enemy_projectile_action.prepend (str)
		end

	set_enemy_projectile_action_empty
		do
			enemy_projectile_action.make_empty
		end


--------------------------------------------------------------
	set_starfighter_action(str: STRING)
		do
			starfighter_action.append (str)
		end
			-- no empty feature as there can only be one SF action at a time
	set_starfighter_action_empty
		do
			starfighter_action.make_empty
		end


--------------------------------------------------------------		
	set_enemy_action(str: STRING)
		do
			enemy_action.append (str)
		end


	set_enemy_action_empty
		do
			enemy_action.make_empty
		end


--------------------------------------------------------------		
	set_natural_enemy_spawn(str: STRING)
		do
			natural_enemy_spawn.append (str)
		end

	set_natural_enemy_spawn_empty
		do
			natural_enemy_spawn.make_empty
		end
--------------------------------------------------------------

feature -- queries

	get_options: STRING
		do
			create result.make_empty
			result.append (options)
		end

	get_error: STRING
		do
			create result.make_empty
			result.append(error)
		end

feature
	out: STRING

		local
			model: ETF_MODEL_ACCESS
		do
			create result.make_empty
			if not welcome.is_empty then
				result.append(welcome)
			end


			if  error.is_empty then

				if not starfighter.is_empty then
					result.append ("  ")
					result.append(starfighter)
				end
				if model.m.in_debug_mode and model.m.display_titles then
					result.append (enemy_title)
						result.append (enemy)
					result.append (projectile_title)
						result.append (projectile)
					result.append (current.friendly_projectile_action_title)
						result.append (current.friendly_projectile_action)
					result.append (current.enemy_projectile_action_title)
						result.append (current.enemy_projectile_action)
					result.append (current.starfighter_action_title)
						result.append (current.starfighter_action)
					result.append (current.enemy_action_title)
						result.append (current.enemy_action)
					result.append(natural_enemy_spawn_title)
						result.append (current.natural_enemy_spawn)
				end
				if not grid.is_empty then
					result.append(grid)
				end

			else
				result.append(error)
			end

			if not game_over.is_empty then
				result.append(game_over)
			end



		end


end
