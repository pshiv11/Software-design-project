note
	description: "Summary description for {FOCUS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	FOCUS

inherit
	ORBMENT

feature -- attributes
	array: ARRAY[ORBMENT]

feature -- deferred queries
	is_full: BOOLEAN deferred end

	add(o: ORBMENT) deferred end




end
