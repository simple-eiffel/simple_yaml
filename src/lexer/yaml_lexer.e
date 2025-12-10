note
	description: "[
		YAML lexer (tokenizer).
		Handles YAML 1.2 lexical analysis including indentation tracking.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	YAML_LEXER

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
			-- Create lexer with source
		require
			source_not_void: a_source /= Void
		do
			source := a_source
			position := 1
			line := 1
			column := 1
			current_indent := 0
			create indent_stack.make (10)
			indent_stack.extend (0)
			at_line_start := True
		ensure
			source_set: source = a_source
			position_initialized: position = 1
			line_initialized: line = 1
		end

feature -- Access

	source: STRING_32
			-- Source text

	position: INTEGER
			-- Current position in source

	line: INTEGER
			-- Current line number

	column: INTEGER
			-- Current column number

	current_indent: INTEGER
			-- Current indentation level

	indent_stack: ARRAYED_LIST [INTEGER]
			-- Stack of indentation levels

	at_line_start: BOOLEAN
			-- Are we at the start of a line?

feature -- Status

	is_at_end: BOOLEAN
			-- Are we at end of source?
		do
			Result := position > source.count
		end

feature -- Tokenization

	next_token: YAML_TOKEN
			-- Get next token
		local
			l_line, l_column: INTEGER
			c: CHARACTER_32
		do
			-- Skip whitespace (but track indentation at line start)
			if at_line_start then
				current_indent := 0
				from
				until
					is_at_end or else (current_char /= ' ' and current_char /= '%T')
				loop
					if current_char = ' ' then
						current_indent := current_indent + 1
					elseif current_char = '%T' then
						current_indent := current_indent + 2
					end
					advance
				end
				at_line_start := False
			else
				skip_inline_whitespace
			end

			l_line := line
			l_column := column

			if is_at_end then
				create Result.make ({YAML_TOKEN}.Token_eof, "", l_line, l_column, current_indent)
			else
				c := current_char

				if c = '%N' then
					advance
					line := line + 1
					column := 1
					at_line_start := True
					create Result.make ({YAML_TOKEN}.Token_newline, "%N", l_line, l_column, current_indent)
				elseif c = '%R' then
					advance
					if not is_at_end and current_char = '%N' then
						advance
					end
					line := line + 1
					column := 1
					at_line_start := True
					create Result.make ({YAML_TOKEN}.Token_newline, "%N", l_line, l_column, current_indent)
				elseif c = '#' then
					-- Comment - skip to end of line
					skip_to_end_of_line
					create Result.make ({YAML_TOKEN}.Token_newline, "", l_line, l_column, current_indent)
				elseif c = ':' then
					advance
					create Result.make ({YAML_TOKEN}.Token_colon, ":", l_line, l_column, current_indent)
				elseif c = '-' then
					if peek_char (1) = '-' and peek_char (2) = '-' then
						advance
						advance
						advance
						create Result.make ({YAML_TOKEN}.Token_doc_start, "---", l_line, l_column, current_indent)
					else
						advance
						create Result.make ({YAML_TOKEN}.Token_dash, "-", l_line, l_column, current_indent)
					end
				elseif c = '.' and peek_char (1) = '.' and peek_char (2) = '.' then
					advance
					advance
					advance
					create Result.make ({YAML_TOKEN}.Token_doc_end, "...", l_line, l_column, current_indent)
				elseif c = ',' then
					advance
					create Result.make ({YAML_TOKEN}.Token_comma, ",", l_line, l_column, current_indent)
				elseif c = '[' then
					advance
					create Result.make ({YAML_TOKEN}.Token_lbracket, "[", l_line, l_column, current_indent)
				elseif c = ']' then
					advance
					create Result.make ({YAML_TOKEN}.Token_rbracket, "]", l_line, l_column, current_indent)
				elseif c = '{' then
					advance
					create Result.make ({YAML_TOKEN}.Token_lbrace, "{", l_line, l_column, current_indent)
				elseif c = '}' then
					advance
					create Result.make ({YAML_TOKEN}.Token_rbrace, "}", l_line, l_column, current_indent)
				elseif c = '?' then
					advance
					create Result.make ({YAML_TOKEN}.Token_question, "?", l_line, l_column, current_indent)
				elseif c = '|' then
					Result := scan_literal_block (l_line, l_column)
				elseif c = '>' then
					Result := scan_folded_block (l_line, l_column)
				elseif c = '&' then
					Result := scan_anchor (l_line, l_column)
				elseif c = '*' then
					Result := scan_alias (l_line, l_column)
				elseif c = '!' then
					Result := scan_tag (l_line, l_column)
				elseif c = '%%' then
					Result := scan_directive (l_line, l_column)
				elseif c = '%'' then
					Result := scan_single_quoted (l_line, l_column)
				elseif c = '"' then
					Result := scan_double_quoted (l_line, l_column)
				else
					Result := scan_plain_scalar (l_line, l_column)
				end
			end
		end

	tokenize: ARRAYED_LIST [YAML_TOKEN]
			-- Tokenize entire source
		local
			l_token: YAML_TOKEN
		do
			create Result.make (50)
			from
				l_token := next_token
			until
				l_token.type = {YAML_TOKEN}.Token_eof
			loop
				Result.extend (l_token)
				l_token := next_token
			end
			Result.extend (l_token) -- Add EOF token
		end

feature {NONE} -- Scanning

	scan_plain_scalar (a_line, a_column: INTEGER): YAML_TOKEN
			-- Scan plain (unquoted) scalar
		local
			l_value: STRING_32
			c: CHARACTER_32
			l_done: BOOLEAN
		do
			create l_value.make (50)

			from
				l_done := False
			until
				l_done or is_at_end
			loop
				c := current_char

				if c = ':' and (peek_char (1) = ' ' or peek_char (1) = '%N' or peek_char (1) = '%R' or is_at_end_plus (1)) then
					l_done := True
				elseif c = '#' and position > 1 and source [position - 1] = ' ' then
					l_done := True
				elseif c = '%N' or c = '%R' or c = ',' or c = '[' or c = ']' or c = '{' or c = '}' then
					l_done := True
				else
					l_value.append_character (c)
					advance
				end
			end

			-- Trim trailing whitespace
			l_value.right_adjust

			create Result.make ({YAML_TOKEN}.Token_scalar, l_value, a_line, a_column, current_indent)
		end

	scan_single_quoted (a_line, a_column: INTEGER): YAML_TOKEN
			-- Scan single-quoted string
		local
			l_value: STRING_32
			c: CHARACTER_32
		do
			advance -- skip opening quote
			create l_value.make (50)

			from
			until
				is_at_end
			loop
				c := current_char
				if c = '%'' then
					if peek_char (1) = '%'' then
						-- Escaped single quote
						l_value.append_character ('%'')
						advance
						advance
					else
						advance -- skip closing quote
							-- Exit loop by checking is_at_end will be true or we've advanced past
						create Result.make ({YAML_TOKEN}.Token_single_quoted, l_value, a_line, a_column, current_indent)
						-- Force exit
						position := source.count + 1
					end
				else
					l_value.append_character (c)
					advance
				end
			end

			if Result = Void then
				create Result.make ({YAML_TOKEN}.Token_single_quoted, l_value, a_line, a_column, current_indent)
			end
		end

	scan_double_quoted (a_line, a_column: INTEGER): YAML_TOKEN
			-- Scan double-quoted string
		local
			l_value: STRING_32
			c: CHARACTER_32
			l_done: BOOLEAN
		do
			advance -- skip opening quote
			create l_value.make (50)

			from
				l_done := False
			until
				l_done or is_at_end
			loop
				c := current_char
				if c = '"' then
					advance -- skip closing quote
					l_done := True
				elseif c = '\' then
					l_value.append_character (scan_escape_sequence)
				else
					l_value.append_character (c)
					advance
				end
			end

			create Result.make ({YAML_TOKEN}.Token_double_quoted, l_value, a_line, a_column, current_indent)
		end

	scan_escape_sequence: CHARACTER_32
			-- Scan escape sequence
		local
			c: CHARACTER_32
		do
			advance -- skip backslash
			if is_at_end then
				Result := '\'
			else
				c := current_char
				advance
				inspect c
				when 'n' then Result := '%N'
				when 'r' then Result := '%R'
				when 't' then Result := '%T'
				when '\' then Result := '\'
				when '"' then Result := '"'
				when '0' then Result := '%U'
				when 'x' then Result := scan_hex_escape (2)
				when 'u' then Result := scan_hex_escape (4)
				when 'U' then Result := scan_hex_escape (8)
				else
					Result := c
				end
			end
		end

	scan_hex_escape (a_count: INTEGER): CHARACTER_32
			-- Scan hex escape of given length
		local
			l_hex: STRING_32
			l_code: INTEGER
			i: INTEGER
		do
			create l_hex.make (a_count)
			from
				i := 1
			until
				i > a_count or is_at_end
			loop
				if is_hex_digit (current_char) then
					l_hex.append_character (current_char)
					advance
				end
				i := i + 1
			end
			l_code := hex_to_integer (l_hex)
			Result := l_code.to_character_32
		end

	scan_literal_block (a_line, a_column: INTEGER): YAML_TOKEN
			-- Scan literal block scalar (|)
		local
			l_value: STRING_32
			l_block_indent: INTEGER
			l_first_line: BOOLEAN
		do
			advance -- skip |
			skip_to_end_of_line
			if not is_at_end and (current_char = '%N' or current_char = '%R') then
				advance_line
			end

			create l_value.make (200)
			l_first_line := True
			l_block_indent := -1

			from
			until
				is_at_end
			loop
				-- Get line indent
				current_indent := 0
				from
				until
					is_at_end or else (current_char /= ' ' and current_char /= '%T')
				loop
					if current_char = ' ' then
						current_indent := current_indent + 1
					else
						current_indent := current_indent + 2
					end
					advance
				end

				if is_at_end or (current_char = '%N' or current_char = '%R') then
					-- Blank line
					l_value.append_character ('%N')
					if not is_at_end then
						advance_line
					end
				elseif l_block_indent = -1 then
					-- First content line sets indent
					l_block_indent := current_indent
					l_value.append (scan_to_end_of_line)
					l_value.append_character ('%N')
					if not is_at_end then
						advance_line
					end
				elseif current_indent >= l_block_indent then
					-- Content line
					-- Add extra indent as spaces
					l_value.append_string (create {STRING_32}.make_filled (' ', current_indent - l_block_indent))
					l_value.append (scan_to_end_of_line)
					l_value.append_character ('%N')
					if not is_at_end then
						advance_line
					end
				else
					-- Dedent - end of block
						-- Exit loop
					position := source.count + 1
				end
			end

			-- Remove trailing newline
			if not l_value.is_empty and then l_value [l_value.count] = '%N' then
				l_value.remove_tail (1)
			end

			create Result.make ({YAML_TOKEN}.Token_literal_block, l_value, a_line, a_column, current_indent)
		end

	scan_folded_block (a_line, a_column: INTEGER): YAML_TOKEN
			-- Scan folded block scalar (>)
		local
			l_value: STRING_32
			l_block_indent: INTEGER
		do
			advance -- skip >
			skip_to_end_of_line
			if not is_at_end and (current_char = '%N' or current_char = '%R') then
				advance_line
			end

			create l_value.make (200)
			l_block_indent := -1

			from
			until
				is_at_end
			loop
				-- Get line indent
				current_indent := 0
				from
				until
					is_at_end or else (current_char /= ' ' and current_char /= '%T')
				loop
					if current_char = ' ' then
						current_indent := current_indent + 1
					else
						current_indent := current_indent + 2
					end
					advance
				end

				if is_at_end or (current_char = '%N' or current_char = '%R') then
					-- Blank line becomes newline
					l_value.append_character ('%N')
					if not is_at_end then
						advance_line
					end
				elseif l_block_indent = -1 then
					l_block_indent := current_indent
					l_value.append (scan_to_end_of_line)
					if not is_at_end then
						advance_line
					end
				elseif current_indent >= l_block_indent then
					-- Folded: add space instead of newline
					if not l_value.is_empty and l_value [l_value.count] /= '%N' then
						l_value.append_character (' ')
					end
					l_value.append (scan_to_end_of_line)
					if not is_at_end then
						advance_line
					end
				else
					-- Dedent - end of block
					position := source.count + 1
				end
			end

			create Result.make ({YAML_TOKEN}.Token_folded_block, l_value, a_line, a_column, current_indent)
		end

	scan_anchor (a_line, a_column: INTEGER): YAML_TOKEN
			-- Scan anchor (&name)
		local
			l_name: STRING_32
		do
			advance -- skip &
			l_name := scan_identifier
			create Result.make ({YAML_TOKEN}.Token_anchor, l_name, a_line, a_column, current_indent)
		end

	scan_alias (a_line, a_column: INTEGER): YAML_TOKEN
			-- Scan alias (*name)
		local
			l_name: STRING_32
		do
			advance -- skip *
			l_name := scan_identifier
			create Result.make ({YAML_TOKEN}.Token_alias, l_name, a_line, a_column, current_indent)
		end

	scan_tag (a_line, a_column: INTEGER): YAML_TOKEN
			-- Scan tag (!tag)
		local
			l_tag: STRING_32
		do
			create l_tag.make (20)
			from
			until
				is_at_end or else current_char = ' ' or else current_char = '%N' or else current_char = '%R'
			loop
				l_tag.append_character (current_char)
				advance
			end
			create Result.make ({YAML_TOKEN}.Token_tag, l_tag, a_line, a_column, current_indent)
		end

	scan_directive (a_line, a_column: INTEGER): YAML_TOKEN
			-- Scan directive (%YAML, %TAG)
		local
			l_directive: STRING_32
		do
			create l_directive.make (50)
			from
			until
				is_at_end or else current_char = '%N' or else current_char = '%R'
			loop
				l_directive.append_character (current_char)
				advance
			end
			create Result.make ({YAML_TOKEN}.Token_directive, l_directive, a_line, a_column, current_indent)
		end

	scan_identifier: STRING_32
			-- Scan identifier (for anchors/aliases)
		do
			create Result.make (20)
			from
			until
				is_at_end or else not is_identifier_char (current_char)
			loop
				Result.append_character (current_char)
				advance
			end
		end

	scan_to_end_of_line: STRING_32
			-- Scan to end of line (not including newline)
		do
			create Result.make (80)
			from
			until
				is_at_end or else current_char = '%N' or else current_char = '%R'
			loop
				Result.append_character (current_char)
				advance
			end
		end

feature {NONE} -- Character operations

	current_char: CHARACTER_32
			-- Current character
		require
			not_at_end: not is_at_end
		do
			Result := source [position]
		end

	peek_char (a_offset: INTEGER): CHARACTER_32
			-- Character at offset from current position
		do
			if position + a_offset <= source.count then
				Result := source [position + a_offset]
			else
				Result := '%U'
			end
		end

	is_at_end_plus (a_offset: INTEGER): BOOLEAN
			-- Is position + offset at end?
		do
			Result := position + a_offset > source.count
		end

	advance
			-- Move to next character
		require
			not_at_end: not is_at_end
		do
			position := position + 1
			column := column + 1
		end

	advance_line
			-- Advance past newline
		do
			if not is_at_end and current_char = '%R' then
				advance
			end
			if not is_at_end and current_char = '%N' then
				advance
			end
			line := line + 1
			column := 1
			at_line_start := True
		end

	skip_inline_whitespace
			-- Skip spaces and tabs (not newlines)
		do
			from
			until
				is_at_end or else (current_char /= ' ' and current_char /= '%T')
			loop
				advance
			end
		end

	skip_to_end_of_line
			-- Skip to end of line
		do
			from
			until
				is_at_end or else current_char = '%N' or else current_char = '%R'
			loop
				advance
			end
		end

feature {NONE} -- Character classification

	is_hex_digit (c: CHARACTER_32): BOOLEAN
			-- Is c a hexadecimal digit?
		do
			Result := (c >= '0' and c <= '9') or
			          (c >= 'a' and c <= 'f') or
			          (c >= 'A' and c <= 'F')
		end

	is_identifier_char (c: CHARACTER_32): BOOLEAN
			-- Is c valid in an identifier?
		do
			Result := (c >= 'A' and c <= 'Z') or
			          (c >= 'a' and c <= 'z') or
			          (c >= '0' and c <= '9') or
			          c = '_' or c = '-'
		end

	hex_to_integer (a_hex: STRING_32): INTEGER
			-- Convert hex string to integer
		local
			i: INTEGER
			c: CHARACTER_32
			l_digit: INTEGER
		do
			from
				i := 1
			until
				i > a_hex.count
			loop
				c := a_hex [i]
				if c >= '0' and c <= '9' then
					l_digit := c.code - ('0').code
				elseif c >= 'a' and c <= 'f' then
					l_digit := c.code - ('a').code + 10
				elseif c >= 'A' and c <= 'F' then
					l_digit := c.code - ('A').code + 10
				else
					l_digit := 0
				end
				Result := Result * 16 + l_digit
				i := i + 1
			end
		end

end
