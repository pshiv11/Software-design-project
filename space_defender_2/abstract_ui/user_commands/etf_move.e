note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MOVE
inherit
	ETF_MOVE_INTERFACE
create
	make
feature -- command
	move(row: INTEGER_32 ; column: INTEGER_32)
		require else
			move_precond(row, column)
		local
			correct_row : INTEGER
			vertical: INTEGER
			horizontal: INTEGER
			total_move: INTEGER
    	do
			-- perform some update on the model state
			if row = A then correct_row := 1
			elseif row = B then correct_row := 2
			elseif row = C then correct_row := 3
			elseif row = D then correct_row := 4
			elseif row = E then correct_row := 5
			elseif row = F then correct_row := 6
			elseif row = G then correct_row := 7
			elseif row = H then correct_row := 8
			elseif row = I then correct_row := 9
			else correct_row := 10
			end

			model.print_state.set_error_empty
			model.print_state.set_all_empty
			vertical := correct_row - model.starfighter.pos.row
			horizontal := column - model.starfighter.pos.column
			total_move := vertical.abs + horizontal.abs
			model.print_state.set_all_empty
			if model.in_setup_mode then
				model.states[model.get_setup_cursor].error.make_empty
				model.states[model.get_setup_cursor].set_display ("  Command can only be used in game.")
				model.game_state.set_state (model.states[model.get_setup_cursor].state_name, "error")
			elseif not model.in_game then
				
				model.print_state.set_error ("  Command can only be used in game.")
				model.game_state.set_state ("not started", "error")
			elseif correct_row > model.grid.height or column > model.grid.width then
				model.print_state.set_error ("  Cannot move outside of board.")
				model.game_state.increment_y
				model.game_state.set_state ("in game", "error")
			elseif model.starfighter.pos.row = correct_row and model.starfighter.pos.column = column then
				model.game_state.increment_y
				model.game_state.set_state ("in game", "error")
				model.print_state.set_error ("  Already there.")
			elseif  total_move > model.starfighter.total_move  then
				model.print_state.set_error ("  Out of movement range.")
				model.game_state.increment_y
				model.game_state.set_state ("in game", "error")
			elseif (total_move * model.starfighter.total_move_cost) > (model.starfighter.current_energy + model.starfighter.total_regen.energy) then
				model.game_state.increment_y
				model.game_state.set_state ("in game", "error")
				model.print_state.set_error ("  Not enough resources to move.")
			else
				model.game_state.increment_x
				model.game_state.set_state ("in game", "ok")
				model.move(correct_row, column)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
