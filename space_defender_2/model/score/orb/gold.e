note
	description: "Summary description for {GOLD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GOLD

inherit
	ORB

create
	make

feature
	make
		do
			points := 3
		end
	get_score: INTEGER
		do
			result := points
		end

end
