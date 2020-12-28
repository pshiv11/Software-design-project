note
	description: "Summary description for {ENEMY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENEMY

feature -- identity attributes
	id: INTEGER
	name: STRING
	symbol: STRING


feature -- common attributes
	total_health: INTEGER
	current_health: INTEGER
	regen: INTEGER
	armour: INTEGER
	vision: INTEGER
	seen_by_sf: BOOLEAN
	can_see_sf:	BOOLEAN


-- extra attributes
	old_pos: TUPLE[row: INTEGER; column: INTEGER]
	pos: TUPLE[row: INTEGER; column: INTEGER]
	on_board: BOOLEAN assign set_on_board
	end_turn: BOOLEAN
	model: ETF_MODEL_ACCESS
	output: STRING


feature -- deferred queries

	get_name: STRING deferred end
	get_symbol: STRING deferred end
	can_see_starfighter(row: INTEGER; column: INTEGER) : BOOLEAN deferred end
	report_status: STRING deferred end



feature -- deferred commands	

	set_seen_by_sf(b: BOOLEAN) deferred end
	set_can_see_sf(b: BOOLEAN) deferred end
	set_pos(row: INTEGER; column: INTEGER) deferred end
	set_old_pos(row: INTEGER; column: INTEGER) deferred end
	set_on_board(b: BOOLEAN) deferred end
	update_can_see_sf deferred end
	update_seen_by_sf deferred end
	subtract_health(h: INTEGER) deferred end
	add_health(h: INTEGER) deferred end
	set_current_health(h: INTEGER) deferred end

	preemptive_action(command: STRING) deferred end
	action deferred end

	set_turn(b: BOOLEAN) deferred end

	add_to_focus deferred end






end
