note
	description: "Summary description for {STAR_FIGHTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STAR_FIGHTER
inherit
	ANY

create
	make

feature
	make
		do
			total_health := 0
			total_energy := 0
			total_armour := 0
			create total_regen.default_create
			create current_regen.default_create
			total_vision := 0
			total_move := 0
			total_move_cost := 0
			create projectile_pattern.make_empty
			create power.make_empty
			create pos.default_create
			pos.compare_objects
			create old_pos.default_create
			create id.default_create
			create initial_pos.default_create

			-- unique attributes of weapon setup

		end

	reset
		do
			total_health := 0
			total_energy := 0
			total_armour := 0
			create total_regen.default_create
			create current_regen.default_create
			total_vision := 0
			total_move := 0
			total_move_cost := 0
			create projectile_pattern.make_empty
			create power.make_empty
			create pos.default_create
			pos.compare_objects
			create old_pos.default_create
			create id.default_create
			create initial_pos.default_create
			total_projectile_cost := 0
			total_projectile_damage := 0
			current_health := 0
			current_energy := 0
			current_armour := 0



		end

feature -- starfighter attributes
	-- total attribute value in the beginning of the game
	total_health: INTEGER
	total_energy: INTEGER
	total_armour: INTEGER
	total_regen: TUPLE[health: INTEGER; energy: INTEGER]
	total_vision: INTEGER
	total_move: INTEGER
	total_move_cost: INTEGER
	projectile_pattern: STRING
	power: STRING




	-- Power choice
	power_choice: INTEGER

	-- unique attributes of weapon setup
	total_projectile_cost: INTEGER
	total_projectile_damage: INTEGER

	-- current attribute value during the game

		current_health: INTEGER
		current_energy: INTEGER
		current_armour: INTEGER
		current_regen: TUPLE[health: INTEGER; energy: INTEGER]

	--starfighter identity attributes
	initial_pos: TUPLE[row: INTEGER; column: INTEGER]
	pos: TUPLE[row: INTEGER; column: INTEGER]
	old_pos: TUPLE[row: INTEGER; column: INTEGER]
	id: TUPLE[id: INTEGER; symbol: STRING]

	-- model access
	model: ETF_MODEL_ACCESS



feature --commands to set `total` attributes values
	set_health(h: INTEGER)
		do
			total_health := total_health + h
		end
	set_energy(e: INTEGER)
		do
			total_energy := total_energy + e
		end

	set_regen(h: INTEGER; e: INTEGER)
		do
			total_regen.health := total_regen.health + h
			total_regen.energy := total_regen.energy + e
		end

	set_armour(a: INTEGER)
		do
			total_armour := total_armour + a
		end
	set_vision(v: INTEGER)
		do
			total_vision := total_vision + v
		end
	set_move(m: INTEGER)
		do
			total_move := total_move + m
		end
	set_move_cost(mc: INTEGER)
		do
			total_move_cost := total_move_cost + mc
		end
	set_projectile_cost(pc: INTEGER)
		do
			total_projectile_cost := total_projectile_cost + pc
		end
	set_projectile_damage(pd: INTEGER)
		do
			total_projectile_damage := total_projectile_damage + pd
		end

	seen_by_starfighter(row: INTEGER; column: INTEGER): BOOLEAN

		do
			 if ((pos.row - row).abs  + (pos.column - column).abs) <=  total_vision then
			 	result := true
			 else
			 	result := false
			 end

		end


	set_initial_pos(row: INTEGER; column: INTEGER)
		do
			initial_pos := [row, column]
		end


	set_pos(row: INTEGER; column: INTEGER)
		do
			pos := [row, column]
		end

	set_old_pos(row: INTEGER; column: INTEGER)
		do
			old_pos := [row, column]
		end
	set_id(i: INTEGER)
		do
			id := [i, "S"]
		end

	setup
		do
			across 1 |..| 4 is index
			loop
				inspect index
					when 1  then
						check attached {WEAPON} model.m.states[index] as weapon then
							set_projectile_cost (weapon.choice_array[weapon.choice_cursor].projectile_cost)
							set_projectile_damage (weapon.choice_array[weapon.choice_cursor].projectile_damage)
							set_health (weapon.choice_array[weapon.choice_cursor].health)
							set_energy (weapon.choice_array[weapon.choice_cursor].energy)
							set_armour(weapon.choice_array[weapon.choice_cursor].armour)
							set_move (weapon.choice_array[weapon.choice_cursor].move)
							set_move_cost (weapon.choice_array[weapon.choice_cursor].move_cost)
							set_regen (weapon.choice_array[weapon.choice_cursor].regen.health, weapon.choice_array[weapon.choice_cursor].regen.energy)
							set_vision (weapon.choice_array[weapon.choice_cursor].vision)
							projectile_pattern := weapon.choice_array[weapon.choice_cursor].name
						end
					when 2 then
						check attached {ARMOUR} model.m.states[index] as armour then
							set_health (armour.choice_array[armour.choice_cursor].health)
							set_energy (armour.choice_array[armour.choice_cursor].energy)
							set_armour(armour.choice_array[armour.choice_cursor].armour)
							set_move (armour.choice_array[armour.choice_cursor].move)
							set_move_cost (armour.choice_array[armour.choice_cursor].move_cost)
							set_regen (armour.choice_array[armour.choice_cursor].regen.health, armour.choice_array[armour.choice_cursor].regen.energy)
							set_vision (armour.choice_array[armour.choice_cursor].vision)
						end
					when 3 then

						check attached {ENGINE} model.m.states[index] as engine then
							set_health (engine.choice_array[engine.choice_cursor].health)
							set_energy (engine.choice_array[engine.choice_cursor].energy)
							set_armour(engine.choice_array[engine.choice_cursor].armour)
							set_move (engine.choice_array[engine.choice_cursor].move)
							set_move_cost (engine.choice_array[engine.choice_cursor].move_cost)
							set_regen (engine.choice_array[engine.choice_cursor].regen.health, engine.choice_array[engine.choice_cursor].regen.energy)
							set_vision (engine.choice_array[engine.choice_cursor].vision)
						end
					when 4 then
							check attached {POWER} model.m.states[index] as pwr then
								power := pwr.choice_array[pwr.choice_cursor].name
							--	power_choice := pwr.choice

							end
					else
						-- else nothing
					end
			end
			current_health := total_health
			current_energy := total_energy
			current_regen.health := total_regen.health
			current_regen.energy := total_regen.energy
			current_armour := total_armour
		end

feature --commands to set `current` attributes values during `in game` state
	set_current_health(h: INTEGER)
		do
			current_health := h
		end
	set_current_energy(e: INTEGER)
		do
			current_energy := e
		end

	set_current_armour(a: INTEGER)
		do
			current_armour := a
		end


feature -- commands for manipulating current attributes

	add_health(h: INTEGER)
		do
			current_health := current_health + h
		end

	subtract_health(h: INTEGER)
		do
			current_health := current_health - h
		end

	add_energy(e: INTEGER)
		do
			current_energy := current_energy + e
		end

	subtract_energy(e: INTEGER)
		do
			current_energy := current_energy - e
		end

	add_armour(a: INTEGER)
		do
			current_armour := current_armour + a
		end

	subtract_armour(a: INTEGER)
		do
			current_armour := current_armour - a
		end



	apply_regen
		do
			-- Applying health regeneration
			if not (current_health > total_health) then
				if current_health + total_regen.health > total_health then
					set_current_health (total_health)
				else
					add_health (total_regen.health)
				end
			end

		-- Applying energy regeneration

			if not (current_energy > total_energy) then
				if current_energy + total_regen.energy > total_energy then
					set_current_energy(total_energy)
				else
					add_energy (total_regen.energy)
				end
			end
		end

	apply_health_regen
		do
			if not (current_health > total_health) then
				if current_health + total_regen.health > total_health then
					set_current_health (total_health)
				else
					add_health (total_regen.health)
				end
			end
		end
	apply_energy_regen
		do
			if not (current_energy > total_energy) then
				if current_energy + total_regen.energy > total_energy then
					set_current_energy(total_energy)
				else
					add_energy (total_regen.energy)
				end
			end
		end


end
