note
	description: "Summary description for {ENEMY_PROJECTILE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENEMY_PROJECTILE


create
	make

feature
	make(i: INTEGER; dmg: INTEGER; mv: INTEGER; row: INTEGER; column: INTEGER)
		do
			create pos.default_create
			pos := [row, column]
			pos.compare_objects
			id := i
			create old_pos.default_create
			old_pos := [row, column]
			move := mv
			damage := dmg
			on_board := false
		end

feature -- attributes
	id: INTEGER
	old_pos: TUPLE[row: INTEGER; column: INTEGER]
	pos: TUPLE[row: INTEGER; column: INTEGER]
	damage: INTEGER
	move: INTEGER
	on_board: BOOLEAN


feature -- commands
	set_pos(row: INTEGER; column: INTEGER)
		do
			pos := [row, column]
		end

	set_old_pos(row: INTEGER; column: INTEGER)
		do
			old_pos := [row, column]
		end

	add_damage(d: INTEGER)
		do
			damage := damage + d
		end

	subtract_damage(d: INTEGER)
		do
			damage := damage - d
		end
	set_on_board(b: BOOLEAN)
		do
			on_board := b
		end

feature -- queries
	report_status: STRING
		local
			model: ETF_MODEL_ACCESS
		do
			create result.make_empty
			result.append ("%N    [" + id.out + ",<]->damage:" + damage.out + ", move:" + move.out + ", location:[" + model.m.row_name[pos.row] + "," + pos.column.out + "]")
		end

end
