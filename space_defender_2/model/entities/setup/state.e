note
	description: "Summary description for {STATE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
		STATE

inherit
	ANY

feature -- common atributes

	state_name: STRING
	name: STRING
	display: STRING
	model: ETF_MODEL_ACCESS
	error: STRING

-- selection	
	choice_cursor: INTEGER
	choice_array: ARRAY[like current]



feature -- deferred features
	set_choice_cursor(cursor: INTEGER) deferred end

feature -- deferred queries
	get_choice_cursor: INTEGER deferred end




-- one deferred end
-- two deferred end
-- three deferred end
-- four deferred end
-- five deferred end
 get_option: STRING
 	deferred end
 get_state_name: STRING
 	deferred end
 set_output deferred end
 set_display(str: STRING)
 	deferred end


end
