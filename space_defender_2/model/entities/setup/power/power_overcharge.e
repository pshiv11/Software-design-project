note
	description: "Summary description for {POWER_OVERCHARGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POWER_OVERCHARGE

inherit
	POWER
redefine make, special end
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
			name.make_from_string ("Overcharge (up to 50 health): Gain 2*health spent energy, can go over max energy. Energy regen will not be in effect if over cap.")

		end


	special
		local
			output: STRING
		do
			create output.make_empty
			if not (model.m.starfighter.current_energy >= model.m.starfighter.total_energy) then
				model.m.starfighter.apply_energy_regen
			end
			if not (model.m.starfighter.current_health >= model.m.starfighter.total_health) then
				model.m.starfighter.apply_health_regen
			end


			if model.m.starfighter.current_health > 50 then
				model.m.starfighter.subtract_health (50)
				model.m.starfighter.add_energy (100)

				output.append ("%N    The Starfighter(id:0) uses special, gaining 100 energy at the expense of 50 health.")
			else
				if model.m.starfighter.current_health > 1 then
					output.append ("%N    The Starfighter(id:0) uses special, gaining " + ((model.m.starfighter.current_health - 1)*2).out + " energy at the expense of " + (model.m.starfighter.current_health - 1).out + " health.")
					model.m.starfighter.add_energy ((model.m.starfighter.current_health - 1)*2)
					model.m.starfighter.subtract_health (model.m.starfighter.current_health - 1)
				end


			end

			model.m.print_state.set_starfighter_action (output)
		end

end
