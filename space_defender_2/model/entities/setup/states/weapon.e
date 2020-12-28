note
	description: "Summary description for {WEAPON}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WEAPON
inherit
	STATE

redefine out end

create
	make

feature  -- initialize weapon attributes to that of default `Standard` Weapon
	make
		do

			create name.make_empty
			create error.make_empty
			create choice_array.make_empty
			create regen.default_create
			choice_cursor := 1
			choice_array.force(create {WEAPON_STANDARD}.make, choice_array.count + 1)
			choice_array.force(create {WEAPON_SPREAD}.make, choice_array.count + 1)
			choice_array.force(create {WEAPON_SNIPE}.make, choice_array.count + 1)
			choice_array.force(create {WEAPON_ROCKET}.make, choice_array.count + 1)
			choice_array.force(create {WEAPON_SPLITTER}.make, choice_array.count + 1)
			create state_name.make_from_string("weapon setup")
			create display.make_empty





		end

feature -- common Weapon attributes


	health: INTEGER
	energy: INTEGER
	regen: TUPLE[health: INTEGER; energy: INTEGER]
	armour: INTEGER
	vision: INTEGER
	move: INTEGER
	move_cost: INTEGER
	projectile_damage: INTEGER
	projectile_cost: INTEGER
--	weapon_cursor: INTEGER

feature -- model_access
	model_access: ETF_MODEL_ACCESS





feature -- commands

	fire
		do
			current.choice_array[current.choice_cursor].fire
		end

	friendly_projectile_act
		do
			current.choice_array[choice_cursor].friendly_projectile_act
		end

	set_choice_cursor(cursor: INTEGER)
		do
			choice_cursor := cursor
		end

feature -- queries
	get_choice_cursor: INTEGER
		do
			result := choice_cursor
		end


	get_option: STRING
		do
			create result.make_empty
			result.append ("  Weapon Selected:" + choice_array[choice_cursor].name)
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
			display.append ("  1:Standard (A single projectile is fired in front)%N")
			display.append  ("    Health:10, Energy:10, Regen:0/1, Armour:0, Vision:1, Move:1, Move Cost:1,%N")
			display.append ("    Projectile Damage:70, Projectile Cost:5 (energy)%N")
			display.append  ("  2:Spread (Three projectiles are fired in front, two going diagonal)%N")
			display.append  ("    Health:0, Energy:60, Regen:0/2, Armour:1, Vision:0, Move:0, Move Cost:2,%N")
			display.append  ("    Projectile Damage:50, Projectile Cost:10 (energy)%N")
			display.append  ("  3:Snipe (Fast and high damage projectile, but only travels via teleporting)%N")
			display.append  ("    Health:0, Energy:100, Regen:0/5, Armour:0, Vision:10, Move:3, Move Cost:0,%N")
			display.append  ("    Projectile Damage:1000, Projectile Cost:20 (energy)%N")
			display.append  ("  4:Rocket (Two projectiles appear behind to the sides of the Starfighter and accelerates)%N")
			display.append  ("    Health:10, Energy:0, Regen:10/0, Armour:2, Vision:2, Move:0, Move Cost:3,%N")
			display.append  ("    Projectile Damage:100, Projectile Cost:10 (health)%N")
			display.append  ("  5:Splitter (A single mine projectile is placed in front of the Starfighter)%N")
			display.append ("    Health:0, Energy:100, Regen:0/10, Armour:0, Vision:0, Move:0, Move Cost:5,%N")
			display.append  ("    Projectile Damage:150, Projectile Cost:70 (energy)%N")
			display.append  ("  Weapon Selected:" + choice_array[choice_cursor].name)
		end

	set_display(str: STRING)
		do
			error.make_empty
			error.append (str)
		end

-- redefined out
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
