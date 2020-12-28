note
	description: "Summary description for {SILVER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SILVER

inherit
	ORB

create
	make

feature  -- Initialization

	make
			-- Initialization for `Current'.
		do
			points := 2
		end

	get_score: INTEGER
		do
			result := points
		end
end
