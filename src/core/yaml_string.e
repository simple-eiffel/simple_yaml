note
	description: "YAML string scalar value"
	date: "$Date$"
	revision: "$Revision$"

class
	YAML_STRING

inherit
	YAML_VALUE
		redefine
			is_string,
			as_string,
			to_yaml
		end

create
	make,
	make_literal,
	make_folded

feature {NONE} -- Initialization

	make (a_value: STRING_32)
			-- Create a plain string value
		require
			value_not_void: a_value /= Void
		do
			value := a_value
			style := Style_plain
		ensure
			value_set: value = a_value
			plain_style: style = Style_plain
		end

	make_literal (a_value: STRING_32)
			-- Create a literal block string (|)
		require
			value_not_void: a_value /= Void
		do
			value := a_value
			style := Style_literal
		ensure
			value_set: value = a_value
			literal_style: style = Style_literal
		end

	make_folded (a_value: STRING_32)
			-- Create a folded block string (>)
		require
			value_not_void: a_value /= Void
		do
			value := a_value
			style := Style_folded
		ensure
			value_set: value = a_value
			folded_style: style = Style_folded
		end

feature -- Access

	value: STRING_32
			-- The string value

	style: INTEGER
			-- String style (plain, literal, folded, single-quoted, double-quoted)

feature -- Type checking

	is_string: BOOLEAN
			-- Is this value a string?
		do
			Result := True
		end

feature -- Conversion

	as_string: STRING_32
			-- Get string value
		do
			Result := value
		end

feature -- Output

	to_yaml: STRING_32
			-- Convert to YAML representation
		do
			if needs_quoting then
				Result := quote_string (value)
			else
				Result := value.twin
			end
		end

feature {NONE} -- Implementation

	needs_quoting: BOOLEAN
			-- Does this string need quoting?
		local
			i: INTEGER
			c: CHARACTER_32
		do
			if value.is_empty then
				Result := True
			else
				-- Check first character
				c := value [1]
				if c = '-' or c = ':' or c = '?' or c = '*' or c = '&' or
				   c = '!' or c = '|' or c = '>' or c = '%'' or c = '"' or
				   c = '@' or c = '`' or c = '#' or c = '{' or c = '[' then
					Result := True
				end

				-- Check for special values
				if not Result then
					if value.same_string ("true") or value.same_string ("false") or
					   value.same_string ("null") or value.same_string ("~") or
					   value.same_string ("yes") or value.same_string ("no") or
					   value.same_string ("on") or value.same_string ("off") then
						Result := True
					end
				end

				-- Check for special characters in content
				if not Result then
					from
						i := 1
					until
						i > value.count or Result
					loop
						c := value [i]
						if c = ':' or c = '#' or c = '%N' or c = '%R' then
							Result := True
						end
						i := i + 1
					end
				end
			end
		end

	quote_string (a_value: STRING_32): STRING_32
			-- Quote and escape string
		local
			i: INTEGER
			c: CHARACTER_32
		do
			create Result.make (a_value.count + 10)
			Result.append_character ('"')

			from
				i := 1
			until
				i > a_value.count
			loop
				c := a_value [i]
				inspect c
				when '"' then Result.append ("\%"")
				when '\' then Result.append ("\\")
				when '%N' then Result.append ("\n")
				when '%R' then Result.append ("\r")
				when '%T' then Result.append ("\t")
				else
					Result.append_character (c)
				end
				i := i + 1
			end

			Result.append_character ('"')
		end

feature -- Constants

	Style_plain: INTEGER = 0
	Style_single_quoted: INTEGER = 1
	Style_double_quoted: INTEGER = 2
	Style_literal: INTEGER = 3
	Style_folded: INTEGER = 4

end
