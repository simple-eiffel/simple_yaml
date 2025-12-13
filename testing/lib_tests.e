note
	description: "Tests for SIMPLE_YAML"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "covers"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Test: Parsing

	test_parse_string
			-- Test parsing YAML string.
		note
			testing: "covers/{SIMPLE_YAML}.parse"
		local
			yaml: SIMPLE_YAML
		do
			create yaml.make
			if attached yaml.parse ("name: Alice") as v then
				assert_true ("is mapping", v.is_mapping)
			else
				assert_false ("has errors", yaml.has_errors)
			end
		end

	test_parse_integer
			-- Test parsing YAML integer.
		note
			testing: "covers/{SIMPLE_YAML}.parse"
		local
			yaml: SIMPLE_YAML
		do
			create yaml.make
			if attached yaml.parse ("42") as v then
				assert_true ("is integer", v.is_integer)
				assert_integers_equal ("value", 42, v.as_integer.as_integer_32)
			else
				assert_false ("has errors", yaml.has_errors)
			end
		end

	test_parse_boolean
			-- Test parsing YAML boolean.
		note
			testing: "covers/{SIMPLE_YAML}.parse"
		local
			yaml: SIMPLE_YAML
		do
			create yaml.make
			if attached yaml.parse ("true") as v then
				assert_true ("is boolean", v.is_boolean)
				assert_true ("value is true", v.as_boolean)
			else
				assert_false ("has errors", yaml.has_errors)
			end
		end

	test_parse_sequence
			-- Test parsing YAML sequence.
		note
			testing: "covers/{SIMPLE_YAML}.parse"
		local
			yaml: SIMPLE_YAML
		do
			create yaml.make
			if attached yaml.parse ("- a%N- b%N- c") as v then
				assert_true ("is sequence", v.is_sequence)
				assert_integers_equal ("count", 3, v.as_sequence.count)
			else
				assert_false ("has errors", yaml.has_errors)
			end
		end

	test_parse_mapping
			-- Test parsing YAML mapping.
		note
			testing: "covers/{SIMPLE_YAML}.parse"
		local
			yaml: SIMPLE_YAML
		do
			create yaml.make
			if attached yaml.parse ("name: Bob%Nage: 30") as v then
				assert_true ("is mapping", v.is_mapping)
				assert_integers_equal ("count", 2, v.as_mapping.count)
			else
				assert_false ("has errors", yaml.has_errors)
			end
		end

	test_parse_null
			-- Test parsing YAML null.
		note
			testing: "covers/{SIMPLE_YAML}.parse"
		local
			yaml: SIMPLE_YAML
		do
			create yaml.make
			if attached yaml.parse ("null") as v then
				assert_true ("is null", v.is_null)
			else
				assert_false ("has errors", yaml.has_errors)
			end
		end

feature -- Test: Generation

	test_to_yaml_string
			-- Test generating YAML from string.
		note
			testing: "covers/{YAML_STRING}.to_yaml"
		local
			str: YAML_STRING
		do
			create str.make ("hello")
			assert_string_contains ("has value", str.to_yaml, "hello")
		end

	test_to_yaml_integer
			-- Test generating YAML from integer.
		note
			testing: "covers/{YAML_INTEGER}.to_yaml"
		local
			int: YAML_INTEGER
		do
			create int.make (42)
			assert_strings_equal ("integer yaml", "42", int.to_yaml)
		end

	test_to_yaml_boolean
			-- Test generating YAML from boolean.
		note
			testing: "covers/{YAML_BOOLEAN}.to_yaml"
		local
			bool: YAML_BOOLEAN
		do
			create bool.make (True)
			assert_strings_equal ("true yaml", "true", bool.to_yaml)
		end

feature -- Test: Error Handling

	test_has_errors
			-- Test error detection.
		note
			testing: "covers/{SIMPLE_YAML}.has_errors"
		local
			yaml: SIMPLE_YAML
		do
			create yaml.make
			assert_false ("no initial errors", yaml.has_errors)
		end

end
