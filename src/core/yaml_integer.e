note
	description: "YAML integer scalar value"
	date: "$Date$"
	revision: "$Revision$"

class
	YAML_INTEGER

inherit
	YAML_VALUE
		redefine
			is_integer,
			as_integer,
			to_yaml
		end

create
	make

feature {NONE} -- Initialization

	make (a_value: INTEGER_64)
			-- Create an integer value
		do
			value := a_value
		ensure
			value_set: value = a_value
		end

feature -- Access

	value: INTEGER_64
			-- The integer value

feature -- Type checking

	is_integer: BOOLEAN
			-- Is this value an integer?
		do
			Result := True
		end

feature -- Conversion

	as_integer: INTEGER_64
			-- Get integer value
		do
			Result := value
		end

feature -- Output

	to_yaml: STRING_32
			-- Convert to YAML representation
		do
			Result := value.out
		end

end
