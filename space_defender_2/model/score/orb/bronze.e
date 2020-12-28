note
	description: "Summary description for {BRONZE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BRONZE

inherit
	ORB

create
	make

feature  -- Initialization

	make
			-- Initialization for `Current'.
		do
			points := 1
		end

	get_score: INTEGER
		do
			result := points
		end
end
