note
	description: "Summary description for {POWER_ORBITAL_STRIKE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POWER_ORBITAL_STRIKE

inherit
	POWER
redefine make, special end
create
	make

feature
	make
		do
			create name.make_empty
			create error.make_empty
			create display.make_empty
			create choice_array.make_empty
			create state_name.make_empty
			name.make_from_string ("Orbital Strike (100 energy): Deal 100 damage to all enemies, affected by armour.")

		end

	special
		local
			output: STRING
		do
			model.m.starfighter.apply_regen
			model.m.starfighter.subtract_energy (100)
			create output.make_empty
			output.append ("%N    The Starfighter(id:0) uses special, unleashing a wave of energy.")

			across 1 |..| model.m.enemy_id is id
			loop
				if attached model.m.enemy_collection.item (id) as enemy_obj and then enemy_obj.on_board then
					enemy_obj.subtract_health(100 - enemy_obj.armour)
					output.append ("%N      A " + enemy_obj.name + "(id:" + enemy_obj.id.out + ") at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] takes " + (100 - enemy_obj.armour).out + " damage.")
					if enemy_obj.current_health <= 0 then
						enemy_obj.set_current_health(0)
						model.m.grid.put ("_", enemy_obj.pos.row, enemy_obj.pos.column)
						enemy_obj.set_on_board(false)
						output.append ("%N     The " + enemy_obj.name +  " at location [" + model.m.row_name[enemy_obj.pos.row] + "," + enemy_obj.pos.column.out + "] has been destroyed.")
						enemy_obj.add_to_focus
					end

				end
			end

			model.m.print_state.set_starfighter_action (output)
		end

end
