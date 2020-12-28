note
	description: "Summary description for {POWER_REPAIR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POWER_REPAIR

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
			name.make_from_string ("Repair (50 energy): Gain 50 health, can go over max health. Health regen will not be in effect if over cap.")

		end


	special
		local
			output: STRING
		do
			create output.make_empty
			model.m.starfighter.apply_regen
			output.append ("%N    The Starfighter(id:0) uses special, gaining 50 health.")
			model.m.starfighter.subtract_energy (50)
			model.m.starfighter.add_health (50)
			model.m.print_state.set_starfighter_action (output)

		end

end
