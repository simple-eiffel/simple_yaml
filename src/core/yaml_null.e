note
	description: "YAML null scalar value"
	date: "$Date$"
	revision: "$Revision$"

class
	YAML_NULL

inherit
	YAML_VALUE
		redefine
			is_null,
			to_yaml
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Create a null value
		do
		end

feature -- Type checking

	is_null: BOOLEAN
			-- Is this value null?
		do
			Result := True
		end

feature -- Output

	to_yaml: STRING_32
			-- Convert to YAML representation
		do
			Result := "null"
		end

end
