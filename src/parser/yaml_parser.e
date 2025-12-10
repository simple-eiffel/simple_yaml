note
	description: "[
		YAML parser.
		Builds YAML value tree from tokens.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	YAML_PARSER

inherit
	ANY
		redefine
			default_create
		end

create
	make,
	default_create

feature {NONE} -- Initialization

	default_create
			-- Create with empty source
		do
			make ("")
		end

	make (a_source: STRING_32)
			-- Create parser with source
		require
			source_not_void: a_source /= Void
		do
			create lexer.make (a_source)
			create tokens.make (50)
			create last_errors.make (5)
			create anchors.make (10)
			token_index := 0
		ensure
			no_errors: last_errors.is_empty
		end

feature -- Access

	last_errors: ARRAYED_LIST [STRING_32]
			-- Parser errors

	has_errors: BOOLEAN
			-- Were there parsing errors?
		do
			Result := not last_errors.is_empty
		end

feature -- Parsing

	parse: detachable YAML_VALUE
			-- Parse source and return root value
		do
			last_errors.wipe_out
			tokens := lexer.tokenize
			token_index := 1

			-- Skip document start if present
			if current_token.type = {YAML_TOKEN}.Token_doc_start then
				advance_token
			end
			skip_newlines

			if current_token.type = {YAML_TOKEN}.Token_eof then
				-- Empty document
				Result := Void
			else
				Result := parse_value (0)
			end
		end

feature {NONE} -- Parsing implementation

	parse_value (a_min_indent: INTEGER): detachable YAML_VALUE
			-- Parse a value at given minimum indentation
		local
			l_token: YAML_TOKEN
		do
			skip_newlines
			l_token := current_token

			inspect l_token.type
			when {YAML_TOKEN}.Token_lbrace then
				Result := parse_flow_mapping
			when {YAML_TOKEN}.Token_lbracket then
				Result := parse_flow_sequence
			when {YAML_TOKEN}.Token_dash then
				Result := parse_block_sequence (l_token.indent)
			when {YAML_TOKEN}.Token_scalar, {YAML_TOKEN}.Token_single_quoted, {YAML_TOKEN}.Token_double_quoted then
				-- Could be a mapping key or a scalar value
				if peek_token.type = {YAML_TOKEN}.Token_colon then
					Result := parse_block_mapping (l_token.indent)
				else
					Result := parse_scalar (l_token)
					advance_token
				end
			when {YAML_TOKEN}.Token_literal_block then
				create {YAML_STRING} Result.make_literal (l_token.value)
				advance_token
			when {YAML_TOKEN}.Token_folded_block then
				create {YAML_STRING} Result.make_folded (l_token.value)
				advance_token
			when {YAML_TOKEN}.Token_anchor then
				advance_token
				Result := parse_value (a_min_indent)
				if attached Result as l_val then
					anchors.force (l_val, l_token.value)
				end
			when {YAML_TOKEN}.Token_alias then
				Result := anchors.item (l_token.value)
				advance_token
			when {YAML_TOKEN}.Token_tag then
				advance_token
				skip_inline_whitespace
				Result := parse_value (a_min_indent)
			when {YAML_TOKEN}.Token_eof, {YAML_TOKEN}.Token_doc_end then
				Result := Void
			else
				add_error ("Unexpected token: " + l_token.debug_output)
				Result := Void
			end
		end

	parse_scalar (a_token: YAML_TOKEN): YAML_VALUE
			-- Parse scalar value from token
		local
			l_value: STRING_32
			l_lower: STRING_32
		do
			l_value := a_token.value

			if a_token.type = {YAML_TOKEN}.Token_single_quoted then
				create {YAML_STRING} Result.make (l_value)
			elseif a_token.type = {YAML_TOKEN}.Token_double_quoted then
				create {YAML_STRING} Result.make (l_value)
			else
				-- Plain scalar - determine type
				l_lower := l_value.as_lower

				if l_lower.same_string ("null") or l_lower.same_string ("~") or l_value.is_empty then
					create {YAML_NULL} Result.make
				elseif l_lower.same_string ("true") or l_lower.same_string ("yes") or l_lower.same_string ("on") then
					create {YAML_BOOLEAN} Result.make (True)
				elseif l_lower.same_string ("false") or l_lower.same_string ("no") or l_lower.same_string ("off") then
					create {YAML_BOOLEAN} Result.make (False)
				elseif l_lower.same_string (".inf") or l_lower.same_string ("inf") then
					create {YAML_FLOAT} Result.make_infinity (False)
				elseif l_lower.same_string ("-.inf") then
					create {YAML_FLOAT} Result.make_infinity (True)
				elseif l_lower.same_string (".nan") or l_lower.same_string ("nan") then
					create {YAML_FLOAT} Result.make_nan
				elseif is_integer (l_value) then
					create {YAML_INTEGER} Result.make (l_value.to_integer_64)
				elseif is_float (l_value) then
					create {YAML_FLOAT} Result.make (l_value.to_real_64)
				else
					create {YAML_STRING} Result.make (l_value)
				end
			end
		end

	parse_flow_mapping: YAML_MAPPING
			-- Parse flow-style mapping { key: value, ... }
		local
			l_key: STRING_32
			l_value: detachable YAML_VALUE
		do
			create Result.make
			advance_token -- skip {
			skip_whitespace_tokens

			from
			until
				current_token.type = {YAML_TOKEN}.Token_rbrace or
				current_token.type = {YAML_TOKEN}.Token_eof
			loop
				-- Parse key
				if current_token.type = {YAML_TOKEN}.Token_scalar or
				   current_token.type = {YAML_TOKEN}.Token_single_quoted or
				   current_token.type = {YAML_TOKEN}.Token_double_quoted then
					l_key := current_token.value
					advance_token
					skip_whitespace_tokens

					-- Expect colon
					if current_token.type = {YAML_TOKEN}.Token_colon then
						advance_token
						skip_whitespace_tokens
						l_value := parse_value (0)
						if attached l_value as lv then
							Result.put (lv, l_key)
						end
					end

					skip_whitespace_tokens
					if current_token.type = {YAML_TOKEN}.Token_comma then
						advance_token
						skip_whitespace_tokens
					end
				else
					advance_token -- skip unexpected token
				end
			end

			if current_token.type = {YAML_TOKEN}.Token_rbrace then
				advance_token
			end
		end

	parse_flow_sequence: YAML_SEQUENCE
			-- Parse flow-style sequence [ value, ... ]
		local
			l_value: detachable YAML_VALUE
		do
			create Result.make
			advance_token -- skip [
			skip_whitespace_tokens

			from
			until
				current_token.type = {YAML_TOKEN}.Token_rbracket or
				current_token.type = {YAML_TOKEN}.Token_eof
			loop
				l_value := parse_value (0)
				if attached l_value as lv then
					Result.extend (lv)
				end

				skip_whitespace_tokens
				if current_token.type = {YAML_TOKEN}.Token_comma then
					advance_token
					skip_whitespace_tokens
				end
			end

			if current_token.type = {YAML_TOKEN}.Token_rbracket then
				advance_token
			end
		end

	parse_block_mapping (a_indent: INTEGER): YAML_MAPPING
			-- Parse block-style mapping
		local
			l_key: STRING_32
			l_value: detachable YAML_VALUE
			l_done: BOOLEAN
		do
			create Result.make

			from
				l_done := False
			until
				l_done or current_token.type = {YAML_TOKEN}.Token_eof
			loop
				skip_newlines

				if current_token.indent < a_indent then
					l_done := True
				elseif current_token.type = {YAML_TOKEN}.Token_scalar or
				       current_token.type = {YAML_TOKEN}.Token_single_quoted or
				       current_token.type = {YAML_TOKEN}.Token_double_quoted then
					l_key := current_token.value
					advance_token

					if current_token.type = {YAML_TOKEN}.Token_colon then
						advance_token
						skip_inline_whitespace

						if current_token.type = {YAML_TOKEN}.Token_newline then
							skip_newlines
							l_value := parse_value (current_token.indent)
						else
							l_value := parse_value (a_indent)
						end

						if attached l_value as lv then
							Result.put (lv, l_key)
						else
							Result.put (create {YAML_NULL}.make, l_key)
						end
					else
						l_done := True
					end
				else
					l_done := True
				end
			end
		end

	parse_block_sequence (a_indent: INTEGER): YAML_SEQUENCE
			-- Parse block-style sequence
		local
			l_value: detachable YAML_VALUE
			l_done: BOOLEAN
		do
			create Result.make

			from
				l_done := False
			until
				l_done or current_token.type = {YAML_TOKEN}.Token_eof
			loop
				skip_newlines

				if current_token.indent < a_indent then
					l_done := True
				elseif current_token.type = {YAML_TOKEN}.Token_dash then
					advance_token
					skip_inline_whitespace

					if current_token.type = {YAML_TOKEN}.Token_newline then
						skip_newlines
						l_value := parse_value (current_token.indent)
					else
						l_value := parse_value (a_indent + 2)
					end

					if attached l_value as lv then
						Result.extend (lv)
					else
						Result.extend (create {YAML_NULL}.make)
					end
				else
					l_done := True
				end
			end
		end

feature {NONE} -- Token operations

	lexer: YAML_LEXER
			-- Lexer

	tokens: ARRAYED_LIST [YAML_TOKEN]
			-- Token list

	token_index: INTEGER
			-- Current token index

	anchors: HASH_TABLE [YAML_VALUE, STRING_32]
			-- Anchor definitions

	current_token: YAML_TOKEN
			-- Current token
		do
			if token_index >= 1 and token_index <= tokens.count then
				Result := tokens [token_index]
			else
				create Result.make ({YAML_TOKEN}.Token_eof, "", 1, 1, 0)
			end
		end

	peek_token: YAML_TOKEN
			-- Next token (without advancing)
		do
			if token_index + 1 <= tokens.count then
				Result := tokens [token_index + 1]
			else
				create Result.make ({YAML_TOKEN}.Token_eof, "", 1, 1, 0)
			end
		end

	advance_token
			-- Advance to next token
		do
			token_index := token_index + 1
		end

	skip_newlines
			-- Skip newline tokens
		do
			from
			until
				current_token.type /= {YAML_TOKEN}.Token_newline
			loop
				advance_token
			end
		end

	skip_whitespace_tokens
			-- Skip newlines in flow context
		do
			from
			until
				current_token.type /= {YAML_TOKEN}.Token_newline
			loop
				advance_token
			end
		end

	skip_inline_whitespace
			-- Handled by lexer already, just a placeholder
		do
		end

feature {NONE} -- Type detection

	is_integer (a_value: STRING_32): BOOLEAN
			-- Is value an integer?
		local
			i: INTEGER
			c: CHARACTER_32
			l_start: INTEGER
		do
			if a_value.is_empty then
				Result := False
			else
				l_start := 1
				if a_value [1] = '+' or a_value [1] = '-' then
					l_start := 2
				end

				if l_start > a_value.count then
					Result := False
				else
					Result := True
					from
						i := l_start
					until
						i > a_value.count or not Result
					loop
						c := a_value [i]
						if not (c >= '0' and c <= '9') then
							Result := False
						end
						i := i + 1
					end
				end
			end
		end

	is_float (a_value: STRING_32): BOOLEAN
			-- Is value a float?
		local
			i: INTEGER
			c: CHARACTER_32
			l_has_decimal, l_has_exp: BOOLEAN
			l_start: INTEGER
		do
			if a_value.is_empty then
				Result := False
			else
				l_start := 1
				if a_value [1] = '+' or a_value [1] = '-' then
					l_start := 2
				end

				if l_start > a_value.count then
					Result := False
				else
					Result := True
					from
						i := l_start
					until
						i > a_value.count or not Result
					loop
						c := a_value [i]
						if c >= '0' and c <= '9' then
							-- ok
						elseif c = '.' and not l_has_decimal then
							l_has_decimal := True
						elseif (c = 'e' or c = 'E') and not l_has_exp then
							l_has_exp := True
							if i + 1 <= a_value.count and (a_value [i + 1] = '+' or a_value [i + 1] = '-') then
								i := i + 1
							end
						else
							Result := False
						end
						i := i + 1
					end
					Result := Result and (l_has_decimal or l_has_exp)
				end
			end
		end

feature {NONE} -- Error handling

	add_error (a_message: STRING_32)
			-- Add error message
		do
			last_errors.extend (a_message)
		end

end
