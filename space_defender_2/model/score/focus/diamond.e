note
	description: "Summary description for {DIAMOND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DIAMOND

inherit
	FOCUS

create
	make

feature-- Initialization

	make

			-- Initialization for `Current'.
		do
			create array.make_empty
			max_size := 4
			array.force(create {GOLD}.make, 1)


		end

feature	-- attributes
	max_size: INTEGER


feature -- queries


	is_full: BOOLEAN
		do
			if array.count = max_size then
				-- means we can safely iterate over the array to check if_full on each element
				result :=
					across 1 |..| max_size is index
					all
						array[index].is_full

					end
			else
				result := false
			end

		end


	add(o: ORBMENT)
		do

			if attached {FOCUS} array[array.count] as f_obj and then not f_obj.is_full then
				f_obj.add (o)
			elseif not attached {FOCUS} array[array.count] then
				array.force (o, array.count + 1)
			else
				array.force (o, array.count + 1)
			end

		end


	get_score: INTEGER

		do
			across 1 |..| array.count is index
			loop
				result := result + array[index].get_score
			end

			if array.count = max_size then
				result := result*3
			end
		end

end
