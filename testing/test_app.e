note
	description: "Test application for SIMPLE_YAML"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run the tests.
		do
			print ("Running SIMPLE_YAML tests...%N%N")
			passed := 0
			failed := 0

			run_lib_tests

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Runners

	run_lib_tests
		do
			create lib_tests
			run_test (agent lib_tests.test_parse_string, "test_parse_string")
			run_test (agent lib_tests.test_parse_integer, "test_parse_integer")
			run_test (agent lib_tests.test_parse_boolean, "test_parse_boolean")
			run_test (agent lib_tests.test_parse_sequence, "test_parse_sequence")
			run_test (agent lib_tests.test_parse_mapping, "test_parse_mapping")
			run_test (agent lib_tests.test_parse_null, "test_parse_null")
			run_test (agent lib_tests.test_to_yaml_string, "test_to_yaml_string")
			run_test (agent lib_tests.test_to_yaml_integer, "test_to_yaml_integer")
			run_test (agent lib_tests.test_to_yaml_boolean, "test_to_yaml_boolean")
			run_test (agent lib_tests.test_has_errors, "test_has_errors")
		end

feature {NONE} -- Implementation

	lib_tests: LIB_TESTS

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
