note
	description: "Summary description for {SCORE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SCORE


create
	make

feature
	make
		do
			create s_focus.make_empty
		end

feature -- attributes

	score: INTEGER
	s_focus: ARRAY[ORBMENT]

feature -- commands


--	reset_score
--		do
--			score := 0
--			s_focus.make_empty
--		end



	add(orbment : ORBMENT)
	do
			if s_focus.is_empty then
				s_focus.force (orbment, s_focus.count + 1)

			elseif attached {FOCUS} s_focus[s_focus.count] as f_obj and then not(f_obj.is_full)  then -- and then f_obj not full

 				f_obj.add (orbment)
 			else

				s_focus.force (orbment, s_focus.count + 1)
			end
	end





--	add(o: ORBMENT)
--		do
--			if s_focus.is_empty then
--				s_focus.force(o, s_focus.count + 1)
--				
--			elseif attached {FOCUS} s_focus[s_focus.count] as f_obj and then not f_obj.is_full then
--				f_obj.add (o)

--			else
--				s_focus.force (o, s_focus.count + 1)
--			end
--		end



	calculate: INTEGER
		do
			across 1 |..| s_focus.count is index
			loop
				Result := result + s_focus[index].get_score
			end
		end

	get_score: INTEGER
		do
			score := calculate
			result := score

		end

end
