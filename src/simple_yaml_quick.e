note
	description: "[
		Zero-configuration YAML facade for beginners.

		One-liner YAML operations for config files.
		For full control, use SIMPLE_YAML directly.

		Quick Start Examples:
			create yaml.make

			-- Load config file
			config := yaml.load ("config.yml")

			-- Get values with dot-path
			host := yaml.get_string (config, "database.host")
			port := yaml.get_integer (config, "database.port")

			-- Parse YAML string
			config := yaml.parse (yaml_string)
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_YAML_QUICK

create
	make

feature {NONE} -- Initialization

	make
			-- Create quick YAML facade.
		do
			create yaml.make
			
			last_error := ""
		ensure
			yaml_exists: yaml /= Void
		end

feature -- Loading

	load (a_path: STRING): detachable YAML_VALUE
			-- Load YAML from file.
		require
			path_not_empty: not a_path.is_empty
		do
			last_error := ""
			Result := yaml.parse_file (a_path)
			if Result = Void and then yaml.has_errors then
				last_error := yaml.errors_as_string.to_string_8
			end
		end

	parse (a_yaml: STRING): detachable YAML_VALUE
			-- Parse YAML string.
		require
			yaml_not_empty: not a_yaml.is_empty
		do
			last_error := ""
			Result := yaml.parse (a_yaml.to_string_32)
			if Result = Void and then yaml.has_errors then
				last_error := yaml.errors_as_string.to_string_8
			end
		end

feature -- Dot-Path Getters (config file style)

	get_string (a_value: YAML_VALUE; a_path: STRING): detachable STRING
			-- Get string at dot-separated path.
			-- Example: yaml.get_string (config, "database.host")
		require
			value_not_void: a_value /= Void
			path_not_empty: not a_path.is_empty
		local
			l_current: detachable YAML_VALUE
			l_parts: LIST [STRING]
		do
			l_current := a_value
			l_parts := a_path.split ('.')
			across l_parts as p until l_current = Void loop
				if attached {YAML_MAPPING} l_current as obj then
					l_current := obj.item (p)
				else
					l_current := Void
				end
			end
			if attached {YAML_STRING} l_current as vs then
				Result := vs.value.to_string_8
			end
		end

	get_integer (a_value: YAML_VALUE; a_path: STRING): INTEGER
			-- Get integer at dot-separated path.
		require
			value_not_void: a_value /= Void
			path_not_empty: not a_path.is_empty
		local
			l_current: detachable YAML_VALUE
			l_parts: LIST [STRING]
		do
			l_current := a_value
			l_parts := a_path.split ('.')
			across l_parts as p until l_current = Void loop
				if attached {YAML_MAPPING} l_current as obj then
					l_current := obj.item (p)
				else
					l_current := Void
				end
			end
			if attached {YAML_INTEGER} l_current as vi then
				Result := vi.value.to_integer_32
			end
		end

	get_real (a_value: YAML_VALUE; a_path: STRING): REAL_64
			-- Get real number at dot-separated path.
		require
			value_not_void: a_value /= Void
			path_not_empty: not a_path.is_empty
		local
			l_current: detachable YAML_VALUE
			l_parts: LIST [STRING]
		do
			l_current := a_value
			l_parts := a_path.split ('.')
			across l_parts as p until l_current = Void loop
				if attached {YAML_MAPPING} l_current as obj then
					l_current := obj.item (p)
				else
					l_current := Void
				end
			end
			if attached {YAML_FLOAT} l_current as vf then
				Result := vf.value
			end
		end

	get_boolean (a_value: YAML_VALUE; a_path: STRING): BOOLEAN
			-- Get boolean at dot-separated path.
		require
			value_not_void: a_value /= Void
			path_not_empty: not a_path.is_empty
		local
			l_current: detachable YAML_VALUE
			l_parts: LIST [STRING]
		do
			l_current := a_value
			l_parts := a_path.split ('.')
			across l_parts as p until l_current = Void loop
				if attached {YAML_MAPPING} l_current as obj then
					l_current := obj.item (p)
				else
					l_current := Void
				end
			end
			if attached {YAML_BOOLEAN} l_current as vb then
				Result := vb.value
			end
		end

	get_list (a_value: YAML_VALUE; a_path: STRING): ARRAYED_LIST [STRING]
			-- Get string list at dot-separated path.
		require
			value_not_void: a_value /= Void
			path_not_empty: not a_path.is_empty
		local
			l_current: detachable YAML_VALUE
			l_parts: LIST [STRING]
		do
			create Result.make (10)
			l_current := a_value
			l_parts := a_path.split ('.')
			across l_parts as p until l_current = Void loop
				if attached {YAML_MAPPING} l_current as obj then
					l_current := obj.item (p)
				else
					l_current := Void
				end
			end
			if attached {YAML_SEQUENCE} l_current as seq then
				across seq.items as item loop
					if attached {YAML_STRING} item as vs then
						Result.extend (vs.value.to_string_8)
					end
				end
			end
		ensure
			result_exists: Result /= Void
		end

feature -- One-liner File Getters

	string_from_file (a_path: STRING; a_key_path: STRING): detachable STRING
			-- Load file and get string in one call.
		require
			path_not_empty: not a_path.is_empty
			key_not_empty: not a_key_path.is_empty
		do
			if attached load (a_path) as config then
				Result := get_string (config, a_key_path)
			end
		end

	integer_from_file (a_path: STRING; a_key_path: STRING): INTEGER
			-- Load file and get integer in one call.
		require
			path_not_empty: not a_path.is_empty
			key_not_empty: not a_key_path.is_empty
		do
			if attached load (a_path) as config then
				Result := get_integer (config, a_key_path)
			end
		end

	boolean_from_file (a_path: STRING; a_key_path: STRING): BOOLEAN
			-- Load file and get boolean in one call.
		require
			path_not_empty: not a_path.is_empty
			key_not_empty: not a_key_path.is_empty
		do
			if attached load (a_path) as config then
				Result := get_boolean (config, a_key_path)
			end
		end

feature -- Existence Checks

	has_key (a_value: YAML_VALUE; a_path: STRING): BOOLEAN
			-- Does path exist in YAML?
		require
			value_not_void: a_value /= Void
			path_not_empty: not a_path.is_empty
		local
			l_current: detachable YAML_VALUE
			l_parts: LIST [STRING]
		do
			l_current := a_value
			l_parts := a_path.split ('.')
			across l_parts as p until l_current = Void loop
				if attached {YAML_MAPPING} l_current as obj then
					l_current := obj.item (p)
				else
					l_current := Void
				end
			end
			Result := l_current /= Void
		end

feature -- Validation

	is_valid (a_yaml: STRING): BOOLEAN
			-- Is string valid YAML?
		require
			yaml_not_void: a_yaml /= Void
		do
			Result := attached yaml.parse (a_yaml.to_string_32)
			if not Result and then yaml.has_errors then
				last_error := yaml.errors_as_string.to_string_8
			else
				last_error := ""
			end
		end

feature -- Status

	last_error: STRING
			-- Last error message.

	has_error: BOOLEAN
			-- Did last operation fail?
		do
			Result := not last_error.is_empty
		end

feature -- Advanced Access

	yaml: SIMPLE_YAML
			-- Access underlying YAML handler for advanced operations.

feature {NONE} -- Implementation


invariant
	yaml_exists: yaml /= Void
	last_error_exists: last_error /= Void

end
