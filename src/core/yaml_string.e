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

				-- Check for special values (case-insensitive) and number look-alikes
				if not Result then
					Result := is_reserved_word or looks_like_number
				end

				-- Leading or trailing space would be lost by a plain scalar
				if not Result then
					Result := value [1] = ' ' or value [value.count] = ' '
				end

				-- Check for special characters in content
				if not Result then
					from
						i := 1
					until
						i > value.count or Result
					loop
						c := value [i]
						if c = ':' or c = '#' or c = '%N' or c = '%R' or c = '%T' then
							Result := True
						end
						i := i + 1
					end
				end
			end
		end

	is_reserved_word: BOOLEAN
			-- Would a plain `value` re-read as boolean or null?
		local
			l_lower: STRING_32
		do
			l_lower := value.as_lower
			Result := l_lower.same_string ("true") or l_lower.same_string ("false") or
				l_lower.same_string ("null") or l_lower.same_string ("~") or
				l_lower.same_string ("yes") or l_lower.same_string ("no") or
				l_lower.same_string ("on") or l_lower.same_string ("off") or
				l_lower.same_string ("y") or l_lower.same_string ("n")
		end

	looks_like_number: BOOLEAN
			-- Would a plain `value` re-read as a number (int, float, 0x/0o, inf, nan)?
		local
			l_lower: STRING_32
			i, l_digits, l_start: INTEGER
			l_seen_dot, l_seen_exp, l_ok: BOOLEAN
			c: CHARACTER_32
		do
			l_lower := value.as_lower
			if l_lower.same_string (".inf") or l_lower.same_string ("-.inf") or
				l_lower.same_string ("+.inf") or l_lower.same_string (".nan") or
				l_lower.same_string ("inf") or l_lower.same_string ("nan") then
				Result := True
			elseif l_lower.count > 2 and then l_lower [1] = '0' and then (l_lower [2] = 'x' or l_lower [2] = 'o') then
				Result := True
			else
				l_start := 1
				if l_lower [1] = '+' or l_lower [1] = '-' then
					l_start := 2
				end
				l_ok := l_start <= l_lower.count
				from
					i := l_start
				until
					i > l_lower.count or not l_ok
				loop
					c := l_lower [i]
					if c >= '0' and c <= '9' then
						l_digits := l_digits + 1
					elseif c = '.' and not l_seen_dot and not l_seen_exp then
						l_seen_dot := True
					elseif c = 'e' and not l_seen_exp and l_digits > 0 then
						l_seen_exp := True
						if i < l_lower.count and then (l_lower [i + 1] = '+' or l_lower [i + 1] = '-') then
							i := i + 1
						end
						if i = l_lower.count then
							l_ok := False
						end
					else
						l_ok := False
					end
					i := i + 1
				end
				Result := l_ok and l_digits > 0
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
