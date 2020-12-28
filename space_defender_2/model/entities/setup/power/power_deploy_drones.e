note
	description: "Summary description for {POWER_DEPLOY_DRONES}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POWER_DEPLOY_DRONES

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
			name.make_from_string ("Deploy Drones (100 energy): Clear all projectiles.")

		end


	special
		local
			output: STRING
		do
			create output.make_empty
			model.m.starfighter.apply_regen
			model.m.starfighter.subtract_energy (100)
			output.append ("%N    The Starfighter(id:0) uses special, clearing projectiles with drones.")
			across 1 |..| -model.m.projectile_id is id
			loop
				if model.m.friendly_projectiles.has (-id) then

					if attached model.m.friendly_projectiles.item (-id) as fp_obj and then fp_obj.on_board then
						fp_obj.set_on_board(false)
						model.m.grid.put ("_", fp_obj.pos.row, fp_obj.pos.column)
						output.append ("%N      A projectile(id:" + fp_obj.id.out + ") at location [" + model.m.row_name[fp_obj.pos.row] + "," + fp_obj.pos.column.out + "] has been neutralized.")
					end
				else
					if attached model.m.enemy_projectiles.item (-id) as ep_obj and then ep_obj.on_board then
						ep_obj.set_on_board(false)
						model.m.grid.put ("_", ep_obj.pos.row, ep_obj.pos.column)
						output.append ("%N      A projectile(id:" + ep_obj.id.out + ") at location [" + model.m.row_name[ep_obj.pos.row] + "," + ep_obj.pos.column.out + "] has been neutralized.")
					end

				end

			end


			model.m.print_state.set_starfighter_action (output)
		end

end
