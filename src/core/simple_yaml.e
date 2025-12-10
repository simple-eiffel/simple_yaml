note
	description: "[
		SIMPLE_YAML - Main facade for YAML parsing and generation.
		Provides high-level API for working with YAML documents.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_YAML

create
	make

feature {NONE} -- Initialization

	make
			-- Create YAML processor
		do
			create last_errors.make (5)
		end

feature -- Access

	last_errors: ARRAYED_LIST [STRING_32]
			-- Errors from last operation

	has_errors: BOOLEAN
			-- Were there errors?
		do
			Result := not last_errors.is_empty
		end

	errors_as_string: STRING_32
			-- All errors as single string
		do
			create Result.make (100)
			across last_errors as ic loop
				if not Result.is_empty then
					Result.append ("; ")
				end
				Result.append (ic)
			end
		end

feature -- Parsing

	parse (a_source: STRING_32): detachable YAML_VALUE
			-- Parse YAML string and return root value
		require
			source_not_void: a_source /= Void
		local
			l_parser: YAML_PARSER
		do
			last_errors.wipe_out
			create l_parser.make (a_source)
			Result := l_parser.parse
			if l_parser.has_errors then
				across l_parser.last_errors as ic loop
					last_errors.extend (ic)
				end
			end
		end

	parse_file (a_file_path: STRING_32): detachable YAML_VALUE
			-- Parse YAML file and return root value
		require
			path_not_void: a_file_path /= Void
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING_32
		do
			last_errors.wipe_out
			create l_file.make_with_name (a_file_path)
			if l_file.exists and l_file.is_readable then
				l_file.open_read
				l_file.read_stream (l_file.count)
				create l_content.make_from_string (l_file.last_string)
				l_file.close
				Result := parse (l_content)
			else
				last_errors.extend ("Cannot read file: " + a_file_path)
			end
		end

feature -- Generation

	to_yaml (a_value: YAML_VALUE): STRING_32
			-- Convert value to YAML string (block style)
		require
			value_not_void: a_value /= Void
		do
			Result := a_value.to_yaml_indented (0)
		end

	to_yaml_flow (a_value: YAML_VALUE): STRING_32
			-- Convert value to YAML string (flow style)
		require
			value_not_void: a_value /= Void
		do
			Result := a_value.to_yaml
		end

	to_file (a_value: YAML_VALUE; a_file_path: STRING_32): BOOLEAN
			-- Write YAML to file, return True on success
		require
			value_not_void: a_value /= Void
			path_not_void: a_file_path /= Void
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING_32
		do
			last_errors.wipe_out
			create l_file.make_with_name (a_file_path)
			l_file.open_write
			l_content := to_yaml (a_value)
			l_file.put_string (l_content.to_string_8)
			l_file.close
			Result := True
		rescue
			last_errors.extend ("Failed to write file: " + a_file_path)
			Result := False
		end

feature -- Factory

	new_mapping: YAML_MAPPING
			-- Create new empty mapping
		do
			create Result.make
		end

	new_sequence: YAML_SEQUENCE
			-- Create new empty sequence
		do
			create Result.make
		end

	new_string (a_value: STRING_32): YAML_STRING
			-- Create string value
		require
			value_not_void: a_value /= Void
		do
			create Result.make (a_value)
		end

	new_integer (a_value: INTEGER_64): YAML_INTEGER
			-- Create integer value
		do
			create Result.make (a_value)
		end

	new_float (a_value: REAL_64): YAML_FLOAT
			-- Create float value
		do
			create Result.make (a_value)
		end

	new_boolean (a_value: BOOLEAN): YAML_BOOLEAN
			-- Create boolean value
		do
			create Result.make (a_value)
		end

	new_null: YAML_NULL
			-- Create null value
		do
			create Result.make
		end

feature -- Path queries

	value_at (a_root: YAML_VALUE; a_path: STRING_32): detachable YAML_VALUE
			-- Get value at dotted path (e.g., "server.host")
		require
			root_not_void: a_root /= Void
			path_not_void: a_path /= Void
		local
			l_parts: LIST [STRING_32]
			l_current: detachable YAML_VALUE
			l_key: STRING_32
		do
			l_parts := a_path.split ('.')
			l_current := a_root

			across l_parts as ic loop
				l_key := ic
				if attached l_current as lc and then lc.is_mapping then
					l_current := lc.as_mapping.item (l_key)
				else
					l_current := Void
				end
			end

			Result := l_current
		end

	string_at (a_root: YAML_VALUE; a_path: STRING_32): detachable STRING_32
			-- Get string at path
		do
			if attached value_at (a_root, a_path) as l_val and then l_val.is_string then
				Result := l_val.as_string
			end
		end

	integer_at (a_root: YAML_VALUE; a_path: STRING_32): INTEGER_64
			-- Get integer at path (0 if not found)
		do
			if attached value_at (a_root, a_path) as l_val and then l_val.is_integer then
				Result := l_val.as_integer
			end
		end

	boolean_at (a_root: YAML_VALUE; a_path: STRING_32): BOOLEAN
			-- Get boolean at path (False if not found)
		do
			if attached value_at (a_root, a_path) as l_val and then l_val.is_boolean then
				Result := l_val.as_boolean
			end
		end

	mapping_at (a_root: YAML_VALUE; a_path: STRING_32): detachable YAML_MAPPING
			-- Get mapping at path
		do
			if attached value_at (a_root, a_path) as l_val and then l_val.is_mapping then
				Result := l_val.as_mapping
			end
		end

	sequence_at (a_root: YAML_VALUE; a_path: STRING_32): detachable YAML_SEQUENCE
			-- Get sequence at path
		do
			if attached value_at (a_root, a_path) as l_val and then l_val.is_sequence then
				Result := l_val.as_sequence
			end
		end

end
