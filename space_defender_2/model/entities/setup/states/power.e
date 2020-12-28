note
	description: "Summary description for {POWER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POWER
inherit
	STATE
redefine out end

create
	make

feature
	make
		do
			create name.make_empty
			create error.make_empty
			create state_name.make_from_string ("power setup")
			create display.make_empty
			create choice_array.make_empty
			choice_cursor := 1
			choice_array.force(create {POWER_RECALL}.make, choice_array.count + 1)
			choice_array.force(create {POWER_REPAIR}.make, choice_array.count + 1)
			choice_array.force(create {POWER_OVERCHARGE}.make, choice_array.count + 1)
			choice_array.force(create {POWER_DEPLOY_DRONES}.make, choice_array.count + 1)
			choice_array.force(create {POWER_ORBITAL_STRIKE}.make, choice_array.count + 1)
		end


feature -- commands	


	set_choice_cursor(cursor: INTEGER)
		do
			choice_cursor := cursor
		end

	special
		do
			current.choice_array[current.choice_cursor].special
		end

feature -- queries
	get_choice_cursor: INTEGER
		do
			result := choice_cursor
		end


--	one
--		do

--			name.make_empty
--			name.make_from_string ("Recall (50 energy): Teleport back to spawn.")
--			set_output
--		end
--	two
--		do
--			name.make_empty
--			name.make_from_string ("Repair (50 energy): Gain 50 health, can go over max health. Health regen will not be in effect if over cap.")
--			set_output
--		end
--	three
--		do

--			name.make_empty
--			name.make_from_string ("Overcharge (up to 50 health): Gain 2*health spent energy, can go over max energy. Energy regen will not be in effect if over cap.")
--			set_output
--		end
--	four
--		do

--			name.make_empty
--			name.make_from_string ("Deploy Drones (100 energy): Clear all projectiles.")
--			set_output
--		end
--	five
--		do

--			name.make_empty
--			name.make_from_string ("Orbital Strike (100 energy): Deal 100 damage to all enemies, affected by armour.")
--			set_output
--		end

	get_option: STRING
 		do
 			create result.make_empty
 			result.append("  Power Selected:" + choice_array[choice_cursor].name)

 		end

 	get_state_name: STRING
		do
			create result.make_empty
			result.append (state_name)

		end

	set_output
		do
			error.make_empty
			display.make_empty
			display.append	("  1:Recall (50 energy): Teleport back to spawn.%N")
			display.append  ("  2:Repair (50 energy): Gain 50 health, can go over max health. Health regen will not be in effect if over cap.%N")
			display.append  ("  3:Overcharge (up to 50 health): Gain 2*health spent energy, can go over max energy. Energy regen will not be in effect if over cap.%N")
			display.append  ("  4:Deploy Drones (100 energy): Clear all projectiles.%N")
			display.append  ("  5:Orbital Strike (100 energy): Deal 100 damage to all enemies, affected by armour.%N")
			display.append  ("  Power Selected:" + choice_array[choice_cursor].name)
		end

	set_display(str: STRING)
		do
			error.make_empty
			error.append (str)
		end



feature
	out: STRING
		do
			create result.make_empty
			if not error.is_empty then
				result.append(error)
			else
				current.set_output
				result.append (display)
			end


		end

end
