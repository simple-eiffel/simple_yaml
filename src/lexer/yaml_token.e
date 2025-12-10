note
	description: "YAML lexer token"
	date: "$Date$"
	revision: "$Revision$"

class
	YAML_TOKEN

create
	make

feature {NONE} -- Initialization

	make (a_type: INTEGER; a_value: STRING_32; a_line, a_column, a_indent: INTEGER)
			-- Create a token
		require
			value_not_void: a_value /= Void
			valid_line: a_line >= 1
			valid_column: a_column >= 1
			valid_indent: a_indent >= 0
		do
			type := a_type
			value := a_value
			line := a_line
			column := a_column
			indent := a_indent
		ensure
			type_set: type = a_type
			value_set: value = a_value
			line_set: line = a_line
			column_set: column = a_column
			indent_set: indent = a_indent
		end

feature -- Access

	type: INTEGER
			-- Token type

	value: STRING_32
			-- Token value

	line: INTEGER
			-- Source line number

	column: INTEGER
			-- Source column number

	indent: INTEGER
			-- Indentation level

feature -- Token types

	Token_eof: INTEGER = 0
	Token_newline: INTEGER = 1
	Token_indent: INTEGER = 2
	Token_dedent: INTEGER = 3
	Token_colon: INTEGER = 4
	Token_dash: INTEGER = 5
	Token_comma: INTEGER = 6
	Token_lbracket: INTEGER = 7
	Token_rbracket: INTEGER = 8
	Token_lbrace: INTEGER = 9
	Token_rbrace: INTEGER = 10
	Token_question: INTEGER = 11
	Token_pipe: INTEGER = 12
	Token_greater: INTEGER = 13
	Token_anchor: INTEGER = 14
	Token_alias: INTEGER = 15
	Token_tag: INTEGER = 16
	Token_directive: INTEGER = 17
	Token_doc_start: INTEGER = 18
	Token_doc_end: INTEGER = 19
	Token_scalar: INTEGER = 20
	Token_single_quoted: INTEGER = 21
	Token_double_quoted: INTEGER = 22
	Token_literal_block: INTEGER = 23
	Token_folded_block: INTEGER = 24
	Token_error: INTEGER = 99

feature -- Output

	debug_output: STRING_32
			-- Debug representation
		do
			create Result.make (50)
			Result.append (type_name)
			Result.append (": %"")
			Result.append (value)
			Result.append ("%" at ")
			Result.append_integer (line)
			Result.append_character (':')
			Result.append_integer (column)
			Result.append (" (indent=")
			Result.append_integer (indent)
			Result.append_character (')')
		end

	type_name: STRING_32
			-- Human-readable token type name
		do
			inspect type
			when Token_eof then Result := "EOF"
			when Token_newline then Result := "NEWLINE"
			when Token_indent then Result := "INDENT"
			when Token_dedent then Result := "DEDENT"
			when Token_colon then Result := "COLON"
			when Token_dash then Result := "DASH"
			when Token_comma then Result := "COMMA"
			when Token_lbracket then Result := "LBRACKET"
			when Token_rbracket then Result := "RBRACKET"
			when Token_lbrace then Result := "LBRACE"
			when Token_rbrace then Result := "RBRACE"
			when Token_question then Result := "QUESTION"
			when Token_pipe then Result := "PIPE"
			when Token_greater then Result := "GREATER"
			when Token_anchor then Result := "ANCHOR"
			when Token_alias then Result := "ALIAS"
			when Token_tag then Result := "TAG"
			when Token_directive then Result := "DIRECTIVE"
			when Token_doc_start then Result := "DOC_START"
			when Token_doc_end then Result := "DOC_END"
			when Token_scalar then Result := "SCALAR"
			when Token_single_quoted then Result := "SINGLE_QUOTED"
			when Token_double_quoted then Result := "DOUBLE_QUOTED"
			when Token_literal_block then Result := "LITERAL_BLOCK"
			when Token_folded_block then Result := "FOLDED_BLOCK"
			when Token_error then Result := "ERROR"
			else
				Result := "UNKNOWN"
			end
		end

end
