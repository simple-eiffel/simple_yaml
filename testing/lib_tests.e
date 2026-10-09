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

feature -- Test: Round trip

	assert_string_round_trip (a_text: STRING_32)
			-- Emit a one-key mapping holding `a_text`, re-parse, and require the same string back.
		local
			yaml: SIMPLE_YAML
			l_map: YAML_MAPPING
			l_out: STRING_32
		do
			create yaml.make
			l_map := yaml.new_mapping
			l_map.put (yaml.new_string (a_text), "k")
			l_out := yaml.to_yaml (l_map)
			if attached yaml.parse (l_out) as l_root and then l_root.is_mapping and then attached l_root.as_mapping.item ("k") as l_v then
				assert_true ({STRING_32} "still a string: " + a_text + {STRING_32} " emitted as " + l_out, l_v.is_string)
				assert_true ({STRING_32} "same text: " + a_text, l_v.as_string.same_string (a_text))
			else
				assert_true ({STRING_32} "re-parse failed for " + a_text + {STRING_32} " emitted as " + l_out, False)
			end
		end

	test_round_trip_strings
			-- Strings that look like other types survive emit and re-parse as strings.
		note
			testing: "covers/{YAML_STRING}.to_yaml"
		do
			assert_string_round_trip ("80")
			assert_string_round_trip ("1.5")
			assert_string_round_trip ("-3")
			assert_string_round_trip ("1e5")
			assert_string_round_trip ("True")
			assert_string_round_trip ("null")
			assert_string_round_trip ("")
			assert_string_round_trip (" lead")
			assert_string_round_trip ("trail ")
			assert_string_round_trip ("Yes")
			assert_string_round_trip ("n")
			assert_string_round_trip (".5")
			assert_string_round_trip ("-.inf")
			assert_string_round_trip (".NaN")
			assert_string_round_trip ("0x1F")
			assert_string_round_trip ("plain text")
		end

	test_round_trip_empty_collections
			-- Empty child mapping and sequence come back as empty collections, not null.
		note
			testing: "covers/{YAML_MAPPING}.to_yaml_indented"
		local
			yaml: SIMPLE_YAML
			l_root, l_inner: YAML_MAPPING
			l_seq: YAML_SEQUENCE
			l_out: STRING_32
		do
			create yaml.make
			l_root := yaml.new_mapping
			l_root.put (yaml.new_mapping, "m")
			create l_seq.make
			l_root.put (l_seq, "s")
			l_out := yaml.to_yaml (l_root)
			if attached yaml.parse (l_out) as l_back and then l_back.is_mapping then
				if attached l_back.as_mapping.item ("m") as l_m then
					assert_true ({STRING_32} "m is mapping: " + l_out, l_m.is_mapping)
					assert_true ("m empty", l_m.as_mapping.is_empty)
				else
					assert_true ("m missing", False)
				end
				if attached l_back.as_mapping.item ("s") as l_s then
					assert_true ({STRING_32} "s is sequence: " + l_out, l_s.is_sequence)
					assert_true ("s empty", l_s.as_sequence.is_empty)
				else
					assert_true ("s missing", False)
				end
			else
				assert_true ("re-parse failed", False)
			end
			l_inner := yaml.new_mapping
			assert_true ("empty top mapping", yaml.to_yaml (l_inner).same_string ({STRING_32} "{}%N"))
			create l_seq.make
			assert_true ("empty top sequence", yaml.to_yaml (l_seq).same_string ({STRING_32} "[]%N"))
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
