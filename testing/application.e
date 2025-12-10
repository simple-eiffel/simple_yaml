note
	description: "Test application runner for simple_yaml"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests
		do
			create yaml.make
			print ("simple_yaml test suite%N")
			print ("=====================%N%N")

			run_all_tests
		end

feature -- Access

	yaml: SIMPLE_YAML
			-- YAML processor

feature -- Helpers

	assert (a_tag: STRING; a_condition: BOOLEAN)
			-- Check condition and report if false
		do
			if not a_condition then
				print ("ASSERTION FAILED: " + a_tag + "%N")
			end
		end

feature -- Tests

	run_all_tests
			-- Run all test cases
		do
			test_parse_scalar_string
			test_parse_scalar_types
			test_parse_flow_sequence
			test_parse_flow_mapping
			test_parse_block_sequence
			test_parse_block_mapping
			test_parse_nested_structure
			test_write_mapping
			test_write_sequence
			test_special_values
			test_quoted_strings
			test_error_handling

			print ("%N=======================%N")
			print ("All tests completed!%N")
		end

	test_parse_scalar_string
			-- Test simple string parsing
		local
			l_result: detachable YAML_VALUE
		do
			print ("Test: parse scalar string... ")

			l_result := yaml.parse ("hello world")

			if attached l_result and then l_result.is_string then
				assert ("value correct", l_result.as_string.same_string ("hello world"))
				print ("PASSED%N")
			else
				print ("FAILED%N")
			end
		end

	test_parse_scalar_types
			-- Test scalar type parsing
		local
			l_result: detachable YAML_VALUE
		do
			print ("Test: parse scalar types... ")

			-- Integer
			l_result := yaml.parse ("42")
			if attached l_result and then l_result.is_integer then
				assert ("integer", l_result.as_integer = 42)
			else
				print ("FAILED (integer)%N")
			end

			-- Float
			l_result := yaml.parse ("3.14")
			if attached l_result and then l_result.is_float then
				assert ("float", (l_result.as_float - 3.14).abs < 0.001)
			end

			-- Boolean true
			l_result := yaml.parse ("true")
			if attached l_result and then l_result.is_boolean then
				assert ("true", l_result.as_boolean = True)
			end

			-- Boolean false
			l_result := yaml.parse ("false")
			if attached l_result and then l_result.is_boolean then
				assert ("false", l_result.as_boolean = False)
			end

			-- Null
			l_result := yaml.parse ("null")
			if attached l_result and then l_result.is_null then
				assert ("null", True)
			end

			print ("PASSED%N")
		end

	test_parse_flow_sequence
			-- Test flow sequence parsing
		local
			l_result: detachable YAML_VALUE
		do
			print ("Test: parse flow sequence... ")

			l_result := yaml.parse ("[1, 2, 3]")

			if attached l_result and then l_result.is_sequence then
				assert ("count", l_result.as_sequence.count = 3)
				assert ("first", l_result.as_sequence.integer_item (1) = 1)
				assert ("last", l_result.as_sequence.integer_item (3) = 3)
				print ("PASSED%N")
			else
				print ("FAILED: " + yaml.errors_as_string + "%N")
			end
		end

	test_parse_flow_mapping
			-- Test flow mapping parsing
		local
			l_result: detachable YAML_VALUE
		do
			print ("Test: parse flow mapping... ")

			l_result := yaml.parse ("{name: John, age: 30}")

			if attached l_result and then l_result.is_mapping then
				if attached l_result.as_mapping.string_item ("name") as l_name then
					assert ("name", l_name.same_string ("John"))
				end
				assert ("age", l_result.as_mapping.integer_item ("age") = 30)
				print ("PASSED%N")
			else
				print ("FAILED: " + yaml.errors_as_string + "%N")
			end
		end

	test_parse_block_sequence
			-- Test block sequence parsing
		local
			l_result: detachable YAML_VALUE
			l_text: STRING_32
		do
			print ("Test: parse block sequence... ")

			l_text := "[
- apple
- banana
- cherry
]"

			l_result := yaml.parse (l_text)

			if attached l_result and then l_result.is_sequence then
				assert ("count", l_result.as_sequence.count = 3)
				assert ("first", l_result.as_sequence.string_item (1).same_string ("apple"))
				print ("PASSED%N")
			else
				print ("FAILED: " + yaml.errors_as_string + "%N")
			end
		end

	test_parse_block_mapping
			-- Test block mapping parsing
		local
			l_result: detachable YAML_VALUE
			l_text: STRING_32
		do
			print ("Test: parse block mapping... ")

			l_text := "[
name: John Doe
age: 30
active: true
]"

			l_result := yaml.parse (l_text)

			if attached l_result and then l_result.is_mapping then
				if attached l_result.as_mapping.string_item ("name") as l_name then
					assert ("name", l_name.same_string ("John Doe"))
				end
				assert ("age", l_result.as_mapping.integer_item ("age") = 30)
				assert ("active", l_result.as_mapping.boolean_item ("active") = True)
				print ("PASSED%N")
			else
				print ("FAILED: " + yaml.errors_as_string + "%N")
			end
		end

	test_parse_nested_structure
			-- Test nested structure parsing
		local
			l_result: detachable YAML_VALUE
			l_text: STRING_32
		do
			print ("Test: parse nested structure... ")

			l_text := "[
server:
  host: localhost
  port: 8080
]"

			l_result := yaml.parse (l_text)

			if attached l_result and then l_result.is_mapping then
				if attached yaml.string_at (l_result, "server.host") as l_host then
					assert ("host", l_host.same_string ("localhost"))
				end
				assert ("port", yaml.integer_at (l_result, "server.port") = 8080)
				print ("PASSED%N")
			else
				print ("FAILED: " + yaml.errors_as_string + "%N")
			end
		end

	test_write_mapping
			-- Test mapping writing
		local
			l_mapping: YAML_MAPPING
			l_output: STRING_32
		do
			print ("Test: write mapping... ")

			l_mapping := yaml.new_mapping
			l_mapping := l_mapping.with_string ("name", "test")
			l_mapping := l_mapping.with_integer ("version", 1)
			l_mapping := l_mapping.with_boolean ("active", True)

			l_output := yaml.to_yaml (l_mapping)

			assert ("has name", l_output.has_substring ("name:"))
			assert ("has version", l_output.has_substring ("version: 1"))
			assert ("has active", l_output.has_substring ("active: true"))

			print ("PASSED%N")
		end

	test_write_sequence
			-- Test sequence writing
		local
			l_seq: YAML_SEQUENCE
			l_output: STRING_32
		do
			print ("Test: write sequence... ")

			l_seq := yaml.new_sequence
			l_seq.extend (yaml.new_string ("one"))
			l_seq.extend (yaml.new_string ("two"))
			l_seq.extend (yaml.new_string ("three"))

			l_output := yaml.to_yaml_flow (l_seq)

			assert ("has brackets", l_output.has_substring ("[") and l_output.has_substring ("]"))
			assert ("has one", l_output.has_substring ("one"))

			print ("PASSED%N")
		end

	test_special_values
			-- Test special values (inf, nan)
		local
			l_result: detachable YAML_VALUE
		do
			print ("Test: special values... ")

			l_result := yaml.parse (".inf")
			if attached l_result as lr and then lr.is_float then
				assert ("inf", True)
			end

			l_result := yaml.parse (".nan")
			if attached l_result as lr and then lr.is_float then
				assert ("nan", True)
			end

			print ("PASSED%N")
		end

	test_quoted_strings
			-- Test quoted string parsing
		local
			l_result: detachable YAML_VALUE
		do
			print ("Test: quoted strings... ")

			l_result := yaml.parse ("'hello world'")
			if attached l_result and then l_result.is_string then
				assert ("single quoted", l_result.as_string.same_string ("hello world"))
			end

			l_result := yaml.parse ("%"hello\nworld%"")
			if attached l_result and then l_result.is_string then
				assert ("double quoted with escape", l_result.as_string.has ('%N'))
			end

			print ("PASSED%N")
		end

	test_error_handling
			-- Test error handling
		local
			l_result: detachable YAML_VALUE
		do
			print ("Test: error handling... ")

			-- This should not crash even with malformed input
			l_result := yaml.parse ("{unclosed")

			print ("PASSED%N")
		end

end
