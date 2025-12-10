note
	description: "[
		YAML sequence (array/list) value.
		Sequences are ordered collections of values.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	YAML_SEQUENCE

inherit
	YAML_VALUE
		redefine
			is_sequence,
			as_sequence,
			to_yaml,
			to_yaml_indented
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Create an empty sequence
		do
			create items.make (10)
		ensure
			empty: is_empty
		end

feature -- Access

	items: ARRAYED_LIST [YAML_VALUE]
			-- Sequence elements

	count: INTEGER
			-- Number of elements
		do
			Result := items.count
		ensure
			definition: Result = items.count
		end

	item (a_index: INTEGER): YAML_VALUE
			-- Element at index (1-based)
		require
			valid_index: valid_index (a_index)
		do
			Result := items [a_index]
		end

	first: YAML_VALUE
			-- First element
		require
			not_empty: not is_empty
		do
			Result := items.first
		end

	last: YAML_VALUE
			-- Last element
		require
			not_empty: not is_empty
		do
			Result := items.last
		end

feature -- Status report

	is_empty: BOOLEAN
			-- Is the sequence empty?
		do
			Result := items.is_empty
		end

	valid_index (a_index: INTEGER): BOOLEAN
			-- Is `a_index` a valid index?
		do
			Result := a_index >= 1 and a_index <= count
		end

feature -- Type checking

	is_sequence: BOOLEAN
			-- Is this value a sequence?
		do
			Result := True
		end

feature -- Conversion

	as_sequence: YAML_SEQUENCE
			-- Get sequence value
		do
			Result := Current
		end

feature -- Element change

	extend (a_value: YAML_VALUE)
			-- Add element to end of sequence
		require
			value_not_void: a_value /= Void
		do
			items.extend (a_value)
		ensure
			one_more: count = old count + 1
			last_is_value: last = a_value
		end

	put (a_value: YAML_VALUE; a_index: INTEGER)
			-- Replace element at index
		require
			value_not_void: a_value /= Void
			valid_index: valid_index (a_index)
		do
			items [a_index] := a_value
		ensure
			replaced: item (a_index) = a_value
			same_count: count = old count
		end

	wipe_out
			-- Remove all elements
		do
			items.wipe_out
		ensure
			empty: is_empty
		end

feature -- Convenience accessors

	string_item (a_index: INTEGER): STRING_32
			-- Get string at index
		require
			valid_index: valid_index (a_index)
			is_string: item (a_index).is_string
		do
			Result := item (a_index).as_string
		end

	integer_item (a_index: INTEGER): INTEGER_64
			-- Get integer at index
		require
			valid_index: valid_index (a_index)
			is_integer: item (a_index).is_integer
		do
			Result := item (a_index).as_integer
		end

	float_item (a_index: INTEGER): REAL_64
			-- Get float at index
		require
			valid_index: valid_index (a_index)
			is_float: item (a_index).is_float
		do
			Result := item (a_index).as_float
		end

	boolean_item (a_index: INTEGER): BOOLEAN
			-- Get boolean at index
		require
			valid_index: valid_index (a_index)
			is_boolean: item (a_index).is_boolean
		do
			Result := item (a_index).as_boolean
		end

	mapping_item (a_index: INTEGER): YAML_MAPPING
			-- Get mapping at index
		require
			valid_index: valid_index (a_index)
			is_mapping: item (a_index).is_mapping
		do
			Result := item (a_index).as_mapping
		end

	sequence_item (a_index: INTEGER): YAML_SEQUENCE
			-- Get sequence at index
		require
			valid_index: valid_index (a_index)
			is_sequence: item (a_index).is_sequence
		do
			Result := item (a_index).as_sequence
		end

feature -- Output

	to_yaml: STRING_32
			-- Convert to YAML representation (flow style)
		local
			i: INTEGER
		do
			create Result.make (100)
			Result.append_character ('[')

			from
				i := 1
			until
				i > count
			loop
				if i > 1 then
					Result.append (", ")
				end
				Result.append (item (i).to_yaml)
				i := i + 1
			end

			Result.append_character (']')
		end

	to_yaml_indented (a_indent: INTEGER): STRING_32
			-- Convert to YAML with indentation (block style)
		local
			i: INTEGER
			l_indent_str: STRING_32
		do
			create Result.make (200)
			create l_indent_str.make_filled (' ', a_indent)

			from
				i := 1
			until
				i > count
			loop
				Result.append (l_indent_str)
				Result.append ("- ")
				if item (i).is_mapping or item (i).is_sequence then
					Result.append_character ('%N')
					Result.append (item (i).to_yaml_indented (a_indent + 2))
				else
					Result.append (item (i).to_yaml)
					Result.append_character ('%N')
				end
				i := i + 1
			end
		end

invariant
	items_not_void: items /= Void

end
