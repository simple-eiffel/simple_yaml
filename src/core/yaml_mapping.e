note
	description: "[
		YAML mapping (object/dictionary) value.
		Mappings are unordered collections of key-value pairs.
		Keys are typically strings but can be any scalar.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	YAML_MAPPING

inherit
	YAML_VALUE
		redefine
			is_mapping,
			as_mapping,
			to_yaml,
			to_yaml_indented
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Create an empty mapping
		do
			create entries.make (10)
			create key_order.make (10)
		ensure
			empty: is_empty
		end

feature -- Access

	entries: HASH_TABLE [YAML_VALUE, STRING_32]
			-- Mapping entries

	key_order: ARRAYED_LIST [STRING_32]
			-- Keys in insertion order

	count: INTEGER
			-- Number of entries
		do
			Result := entries.count
		ensure
			definition: Result = entries.count
		end

	item (a_key: STRING_32): detachable YAML_VALUE
			-- Value for key, or Void if not found
		require
			key_not_void: a_key /= Void
		do
			Result := entries.item (a_key)
		end

	keys: ARRAYED_LIST [STRING_32]
			-- All keys in insertion order
		do
			Result := key_order.twin
		ensure
			result_not_void: Result /= Void
		end

feature -- Status report

	is_empty: BOOLEAN
			-- Is the mapping empty?
		do
			Result := entries.is_empty
		end

	has (a_key: STRING_32): BOOLEAN
			-- Does mapping have key?
		require
			key_not_void: a_key /= Void
		do
			Result := entries.has (a_key)
		end

feature -- Type checking

	is_mapping: BOOLEAN
			-- Is this value a mapping?
		do
			Result := True
		end

feature -- Conversion

	as_mapping: YAML_MAPPING
			-- Get mapping value
		do
			Result := Current
		end

feature -- Element change

	put (a_value: YAML_VALUE; a_key: STRING_32)
			-- Add or replace entry
		require
			value_not_void: a_value /= Void
			key_not_void: a_key /= Void
			key_not_empty: not a_key.is_empty
		do
			if not entries.has (a_key) then
				key_order.extend (a_key)
			end
			entries.force (a_value, a_key)
		ensure
			has_key: has (a_key)
			value_set: item (a_key) = a_value
		end

	remove (a_key: STRING_32)
			-- Remove entry
		require
			key_not_void: a_key /= Void
			has_key: has (a_key)
		do
			entries.remove (a_key)
			key_order.prune_all (a_key)
		ensure
			removed: not has (a_key)
		end

	wipe_out
			-- Remove all entries
		do
			entries.wipe_out
			key_order.wipe_out
		ensure
			empty: is_empty
		end

feature -- Convenience accessors

	string_item (a_key: STRING_32): detachable STRING_32
			-- Get string value for key
		require
			key_not_void: a_key /= Void
		do
			if attached item (a_key) as l_val and then l_val.is_string then
				Result := l_val.as_string
			end
		end

	integer_item (a_key: STRING_32): INTEGER_64
			-- Get integer value for key (0 if not found or not integer)
		require
			key_not_void: a_key /= Void
		do
			if attached item (a_key) as l_val and then l_val.is_integer then
				Result := l_val.as_integer
			end
		end

	float_item (a_key: STRING_32): REAL_64
			-- Get float value for key (0.0 if not found or not float)
		require
			key_not_void: a_key /= Void
		do
			if attached item (a_key) as l_val and then l_val.is_float then
				Result := l_val.as_float
			end
		end

	boolean_item (a_key: STRING_32): BOOLEAN
			-- Get boolean value for key (False if not found or not boolean)
		require
			key_not_void: a_key /= Void
		do
			if attached item (a_key) as l_val and then l_val.is_boolean then
				Result := l_val.as_boolean
			end
		end

	mapping_item (a_key: STRING_32): detachable YAML_MAPPING
			-- Get mapping value for key
		require
			key_not_void: a_key /= Void
		do
			if attached item (a_key) as l_val and then l_val.is_mapping then
				Result := l_val.as_mapping
			end
		end

	sequence_item (a_key: STRING_32): detachable YAML_SEQUENCE
			-- Get sequence value for key
		require
			key_not_void: a_key /= Void
		do
			if attached item (a_key) as l_val and then l_val.is_sequence then
				Result := l_val.as_sequence
			end
		end

feature -- Fluent API

	with_string (a_key: STRING_32; a_value: STRING_32): like Current
			-- Add string entry and return self
		require
			key_not_void: a_key /= Void
			value_not_void: a_value /= Void
		do
			put (create {YAML_STRING}.make (a_value), a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

	with_integer (a_key: STRING_32; a_value: INTEGER_64): like Current
			-- Add integer entry and return self
		require
			key_not_void: a_key /= Void
		do
			put (create {YAML_INTEGER}.make (a_value), a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

	with_float (a_key: STRING_32; a_value: REAL_64): like Current
			-- Add float entry and return self
		require
			key_not_void: a_key /= Void
		do
			put (create {YAML_FLOAT}.make (a_value), a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

	with_boolean (a_key: STRING_32; a_value: BOOLEAN): like Current
			-- Add boolean entry and return self
		require
			key_not_void: a_key /= Void
		do
			put (create {YAML_BOOLEAN}.make (a_value), a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

	with_mapping (a_key: STRING_32; a_value: YAML_MAPPING): like Current
			-- Add mapping entry and return self
		require
			key_not_void: a_key /= Void
			value_not_void: a_value /= Void
		do
			put (a_value, a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

	with_sequence (a_key: STRING_32; a_value: YAML_SEQUENCE): like Current
			-- Add sequence entry and return self
		require
			key_not_void: a_key /= Void
			value_not_void: a_value /= Void
		do
			put (a_value, a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

	with_null (a_key: STRING_32): like Current
			-- Add null entry and return self
		require
			key_not_void: a_key /= Void
		do
			put (create {YAML_NULL}.make, a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

feature -- Output

	to_yaml: STRING_32
			-- Convert to YAML representation (flow style)
		local
			l_key: STRING_32
			l_first: BOOLEAN
		do
			create Result.make (100)
			Result.append_character ('{')
			l_first := True

			across key_order as ic loop
				l_key := ic
				if not l_first then
					Result.append (", ")
				end
				l_first := False

				Result.append (quote_key_if_needed (l_key))
				Result.append (": ")
				if attached item (l_key) as l_val then
					Result.append (l_val.to_yaml)
				end
			end

			Result.append_character ('}')
		end

	to_yaml_indented (a_indent: INTEGER): STRING_32
			-- Convert to YAML with indentation (block style)
		local
			l_key: STRING_32
			l_indent_str: STRING_32
		do
			create Result.make (500)
			create l_indent_str.make_filled (' ', a_indent)

			across key_order as ic loop
				l_key := ic
				Result.append (l_indent_str)
				Result.append (quote_key_if_needed (l_key))
				Result.append (": ")

				if attached item (l_key) as l_val then
					if l_val.is_mapping or l_val.is_sequence then
						Result.append_character ('%N')
						Result.append (l_val.to_yaml_indented (a_indent + 2))
					else
						Result.append (l_val.to_yaml)
						Result.append_character ('%N')
					end
				else
					Result.append ("null%N")
				end
			end
		end

feature {NONE} -- Implementation

	quote_key_if_needed (a_key: STRING_32): STRING_32
			-- Quote key if it contains special characters
		require
			key_not_void: a_key /= Void
		local
			l_needs_quoting: BOOLEAN
			i: INTEGER
			c: CHARACTER_32
		do
			-- Check if key needs quoting
			from
				i := 1
			until
				i > a_key.count or l_needs_quoting
			loop
				c := a_key [i]
				if not ((c >= 'A' and c <= 'Z') or
				        (c >= 'a' and c <= 'z') or
				        (c >= '0' and c <= '9') or
				        c = '_' or c = '-') then
					l_needs_quoting := True
				end
				i := i + 1
			end

			if l_needs_quoting then
				Result := "%"" + a_key + "%""
			else
				Result := a_key
			end
		ensure
			result_not_void: Result /= Void
		end

invariant
	entries_not_void: entries /= Void
	key_order_not_void: key_order /= Void
	consistent_count: entries.count = key_order.count

end
