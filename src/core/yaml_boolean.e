note
	description: "YAML boolean scalar value"
	date: "$Date$"
	revision: "$Revision$"

class
	YAML_BOOLEAN

inherit
	YAML_VALUE
		redefine
			is_boolean,
			as_boolean,
			to_yaml
		end

create
	make

feature {NONE} -- Initialization

	make (a_value: BOOLEAN)
			-- Create a boolean value
		do
			value := a_value
		ensure
			value_set: value = a_value
		end

feature -- Access

	value: BOOLEAN
			-- The boolean value

feature -- Type checking

	is_boolean: BOOLEAN
			-- Is this value a boolean?
		do
			Result := True
		end

feature -- Conversion

	as_boolean: BOOLEAN
			-- Get boolean value
		do
			Result := value
		end

feature -- Output

	to_yaml: STRING_32
			-- Convert to YAML representation
		do
			if value then
				Result := "true"
			else
				Result := "false"
			end
		end

end
