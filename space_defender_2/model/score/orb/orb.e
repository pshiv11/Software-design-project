note
	description: "Summary description for {ORB}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ORB

inherit
	ORBMENT

feature	-- attributes

	points: INTEGER

feature --  queries

	is_full: BOOLEAN
		do
			result := true
		end


end
