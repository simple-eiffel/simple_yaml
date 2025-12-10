note
	description: "YAML floating-point scalar value"
	date: "$Date$"
	revision: "$Revision$"

class
	YAML_FLOAT

inherit
	YAML_VALUE
		redefine
			is_float,
			as_float,
			to_yaml
		end

create
	make,
	make_infinity,
	make_nan

feature {NONE} -- Initialization

	make (a_value: REAL_64)
			-- Create a float value
		do
			value := a_value
			is_infinity_value := False
			is_nan_value := False
			is_negative := False
		ensure
			value_set: value = a_value
		end

	make_infinity (a_negative: BOOLEAN)
			-- Create infinity value
		do
			value := 0.0
			is_infinity_value := True
			is_nan_value := False
			is_negative := a_negative
		ensure
			is_inf: is_infinity_value
		end

	make_nan
			-- Create NaN value
		do
			value := 0.0
			is_infinity_value := False
			is_nan_value := True
			is_negative := False
		ensure
			is_nan: is_nan_value
		end

feature -- Access

	value: REAL_64
			-- The float value

	is_infinity_value: BOOLEAN
			-- Is this infinity?

	is_nan_value: BOOLEAN
			-- Is this NaN?

	is_negative: BOOLEAN
			-- Is this negative (for infinity)?

feature -- Type checking

	is_float: BOOLEAN
			-- Is this value a float?
		do
			Result := True
		end

feature -- Conversion

	as_float: REAL_64
			-- Get float value
		do
			Result := value
		end

feature -- Output

	to_yaml: STRING_32
			-- Convert to YAML representation
		do
			if is_nan_value then
				Result := ".nan"
			elseif is_infinity_value then
				if is_negative then
					Result := "-.inf"
				else
					Result := ".inf"
				end
			else
				Result := value.out
				-- Ensure decimal point
				if not Result.has ('.') and not Result.has ('e') and not Result.has ('E') then
					Result.append (".0")
				end
			end
		end

end
