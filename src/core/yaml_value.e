note
	description: "[
		Base class for all YAML values.
		YAML supports scalars, sequences, and mappings.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	YAML_VALUE

feature -- Type checking

	is_string: BOOLEAN
			-- Is this value a string?
		do
			Result := False
		end

	is_integer: BOOLEAN
			-- Is this value an integer?
		do
			Result := False
		end

	is_float: BOOLEAN
			-- Is this value a float?
		do
			Result := False
		end

	is_boolean: BOOLEAN
			-- Is this value a boolean?
		do
			Result := False
		end

	is_null: BOOLEAN
			-- Is this value null?
		do
			Result := False
		end

	is_sequence: BOOLEAN
			-- Is this value a sequence (array)?
		do
			Result := False
		end

	is_mapping: BOOLEAN
			-- Is this value a mapping (object)?
		do
			Result := False
		end

	is_datetime: BOOLEAN
			-- Is this value a datetime?
		do
			Result := False
		end

feature -- Conversion

	as_string: STRING_32
			-- Get string value
		require
			is_string: is_string
		do
			create Result.make_empty
		end

	as_integer: INTEGER_64
			-- Get integer value
		require
			is_integer: is_integer
		do
			Result := 0
		end

	as_float: REAL_64
			-- Get float value
		require
			is_float: is_float
		do
			Result := 0.0
		end

	as_boolean: BOOLEAN
			-- Get boolean value
		require
			is_boolean: is_boolean
		do
			Result := False
		end

	as_sequence: YAML_SEQUENCE
			-- Get sequence value
		require
			is_sequence: is_sequence
		do
			check wrong_type: False then end
			create Result.make
		end

	as_mapping: YAML_MAPPING
			-- Get mapping value
		require
			is_mapping: is_mapping
		do
			check wrong_type: False then end
			create Result.make
		end

feature -- Output

	to_yaml: STRING_32
			-- Convert to YAML representation
		do
			create Result.make_empty
		end

	to_yaml_indented (a_indent: INTEGER): STRING_32
			-- Convert to YAML with indentation
		do
			Result := to_yaml
		end

end
