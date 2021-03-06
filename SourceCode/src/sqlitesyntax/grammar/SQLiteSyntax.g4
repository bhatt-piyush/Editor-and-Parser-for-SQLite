/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

grammar SQLiteSyntax;
/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 by Bart Kiers
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Project      : sqlite-parser; an ANTLR4 grammar for SQLite
 *                https://github.com/bkiers/sqlite-parser
 * Developed by : Bart Kiers, bart@big-o.nl
 */

parse
 : ( sql_stmt_list | error )* EOF
 ;

error
 : UNEXPECTED_CHAR 
   { 
     throw new RuntimeException("UNEXPECTED_CHAR=" + $UNEXPECTED_CHAR.text); 
   }
 ;

sql_stmt_list
 : ';'* sql_stmt ( ';'+ sql_stmt )* ';'*
 ;

sql_stmt
 : ( EXPLAIN ( QUERY PLAN )? )? ( alter_table_stmt
                                      | analyze_stmt
                                      | attach_stmt
                                      | begin_stmt
                                      | commit_stmt
                                      | compound_select_stmt
                                      | create_index_stmt
                                      | create_table_stmt
                                      | create_trigger_stmt
                                      | create_view_stmt
                                      | create_virtual_table_stmt
                                      | delete_stmt
                                      | delete_stmt_limited
                                      | detach_stmt
                                      | drop_index_stmt
                                      | drop_table_stmt
                                      | drop_trigger_stmt
                                      | drop_view_stmt
                                      | factored_select_stmt
                                      | insert_stmt
                                      | pragma_stmt
                                      | reindex_stmt
                                      | release_stmt
                                      | rollback_stmt
                                      | savepoint_stmt
                                      | simple_select_stmt
                                      | select_stmt
                                      | update_stmt
                                      | update_stmt_limited
                                      | vacuum_stmt )
 ;

alter_table_stmt
 : ALTER TABLE ( database_name '.' )? table_name
   ( RENAME TO new_table_name
   | ADD COLUMN? column_def
   )
 ;

analyze_stmt
 : ANALYZE ( database_name | table_or_index_name | database_name '.' table_or_index_name )?
 ;

attach_stmt
 : ATTACH DATABASE? expr AS database_name
 ;

begin_stmt
 : BEGIN ( DEFERRED | IMMEDIATE | EXCLUSIVE )? ( TRANSACTION transaction_name? )?
 ;

commit_stmt
 : ( COMMIT | END ) ( TRANSACTION transaction_name? )?
 ;

compound_select_stmt
 : ( WITH RECURSIVE? common_table_expression ( ',' common_table_expression )* )?
   select_core ( ( UNION ALL? | INTERSECT | EXCEPT ) select_core )+
   ( ORDER BY ordering_term ( ',' ordering_term )* )?
   ( LIMIT expr ( ( OFFSET | ',' ) expr )? )?
 ;

create_index_stmt
 : CREATE UNIQUE? INDEX ( IF NOT EXISTS )?
   ( database_name '.' )? index_name ON table_name '(' indexed_column ( ',' indexed_column )* ')'
   ( WHERE expr )?
 ;

create_table_stmt
 : CREATE ( TEMP | TEMPORARY )? TABLE ( IF NOT EXISTS )?
   ( database_name '.' )? table_name
   ( '(' column_def ( ',' column_def )* ( ',' table_constraint )* ')' ( WITHOUT IDENTIFIER )?
   | AS select_stmt 
   )
 ;

create_trigger_stmt
 : CREATE ( TEMP | TEMPORARY )? TRIGGER ( IF NOT EXISTS )?
   ( database_name '.' )? trigger_name ( BEFORE  | AFTER | INSTEAD OF )? 
   ( DELETE | INSERT | UPDATE ( OF column_name ( ',' column_name )* )? ) ON ( database_name '.' )? table_name
   ( FOR EACH ROW )? ( WHEN expr )?
   BEGIN ( ( update_stmt | insert_stmt | delete_stmt | select_stmt ) ';' )+ END
 ;

create_view_stmt
 : CREATE ( TEMP | TEMPORARY )? VIEW ( IF NOT EXISTS )?
   ( database_name '.' )? view_name AS select_stmt
 ;

create_virtual_table_stmt
 : CREATE VIRTUAL TABLE ( IF NOT EXISTS )?
   ( database_name '.' )? table_name
   USING module_name ( '(' module_argument ( ',' module_argument )* ')' )?
 ;

delete_stmt
 : with_clause? DELETE FROM qualified_table_name 
   ( WHERE expr )?
 ;

delete_stmt_limited
 : with_clause? DELETE FROM qualified_table_name 
   ( WHERE expr )?
   ( ( ORDER BY ordering_term ( ',' ordering_term )* )?
     LIMIT expr ( ( OFFSET | ',' ) expr )?
   )?
 ;

detach_stmt
 : DETACH DATABASE? database_name
 ;

drop_index_stmt
 : DROP INDEX ( IF EXISTS )? ( database_name '.' )? index_name
 ;

drop_table_stmt
 : DROP TABLE ( IF EXISTS )? ( database_name '.' )? table_name
 ;

drop_trigger_stmt
 : DROP TRIGGER ( IF EXISTS )? ( database_name '.' )? trigger_name
 ;

drop_view_stmt
 : DROP VIEW ( IF EXISTS )? ( database_name '.' )? view_name
 ;

factored_select_stmt
 : ( WITH RECURSIVE? common_table_expression ( ',' common_table_expression )* )?
   select_core ( compound_operator select_core )*
   ( ORDER BY ordering_term ( ',' ordering_term )* )?
   ( LIMIT expr ( ( OFFSET | ',' ) expr )? )?
 ;

insert_stmt
 : with_clause? ( INSERT 
                | REPLACE
                | INSERT OR REPLACE
                | INSERT OR ROLLBACK
                | INSERT OR ABORT
                | INSERT OR FAIL
                | INSERT OR IGNORE ) INTO
   ( database_name '.' )? table_name ( '(' column_name ( ',' column_name )* ')' )?
   ( VALUES '(' expr ( ',' expr )* ')' ( ',' '(' expr ( ',' expr )* ')' )*
   | select_stmt
   | DEFAULT VALUES
   )
 ;

pragma_stmt
 : PRAGMA ( database_name '.' )? pragma_name ( '=' pragma_value
                                               | '(' pragma_value ')' )?
 ;

reindex_stmt
 : REINDEX ( collation_name
             | ( database_name '.' )? ( table_name | index_name )
             )?
 ;

release_stmt
 : RELEASE SAVEPOINT? savepoint_name
 ;

rollback_stmt
 : ROLLBACK ( TRANSACTION transaction_name? )? ( TO SAVEPOINT? savepoint_name )?
 ;

savepoint_stmt
 : SAVEPOINT savepoint_name
 ;

simple_select_stmt
 : ( WITH RECURSIVE? common_table_expression ( ',' common_table_expression )* )?
   select_core ( ORDER BY ordering_term ( ',' ordering_term )* )?
   ( LIMIT expr ( ( OFFSET | ',' ) expr )? )?
 ;

select_stmt
 : ( WITH RECURSIVE? common_table_expression ( ',' common_table_expression )* )?
   select_or_values ( compound_operator select_or_values )*
   ( ORDER BY ordering_term ( ',' ordering_term )* )?
   ( LIMIT expr ( ( OFFSET | ',' ) expr )? )?
 ;

select_or_values
 : SELECT ( DISTINCT | ALL )? result_column ( ',' result_column )*
   ( FROM ( table_or_subquery ( ',' table_or_subquery )* | join_clause ) )?
   ( WHERE expr )?
   ( GROUP BY expr ( ',' expr )* ( HAVING expr )? )?
 | VALUES '(' expr ( ',' expr )* ')' ( ',' '(' expr ( ',' expr )* ')' )*
 ;

update_stmt
 : with_clause? UPDATE ( OR ROLLBACK
                         | OR ABORT
                         | OR REPLACE
                         | OR FAIL
                         | OR IGNORE )? qualified_table_name
   SET column_name '=' expr ( ',' column_name '=' expr )* ( WHERE expr )?
 ;

update_stmt_limited
 : with_clause? UPDATE ( OR ROLLBACK
                         | OR ABORT
                         | OR REPLACE
                         | OR FAIL
                         | OR IGNORE )? qualified_table_name
   SET column_name '=' expr ( ',' column_name '=' expr )* ( WHERE expr )?
   ( ( ORDER BY ordering_term ( ',' ordering_term )* )?
     LIMIT expr ( ( OFFSET | ',' ) expr )? 
   )?
 ;

vacuum_stmt
 : VACUUM
 ;

column_def
 : column_name type_name? column_constraint*
 ;

type_name
 : name+ ( '(' signed_number ')'
         | '(' signed_number ',' signed_number ')' )?
 ;

column_constraint
 : ( CONSTRAINT name )?
   ( PRIMARY KEY ( ASC | DESC )? conflict_clause AUTOINCREMENT?
   | NOT? NULL conflict_clause
   | UNIQUE conflict_clause
   | CHECK '(' expr ')'
   | DEFAULT (signed_number | literal_value | '(' expr ')')
   | COLLATE collation_name
   | foreign_key_clause
   )
 ;

conflict_clause
 : ( ON CONFLICT ( ROLLBACK
                     | ABORT
                     | FAIL
                     | IGNORE
                     | REPLACE
                     )
   )?
 ;

/*
    SQLite understands the following binary operators, in order from highest to
    lowest precedence:

    ||
    *    /    %
    +    -
    <<   >>   &    |
    <    <=   >    >=
    =    ==   !=   <>   IS   IS NOT   IN   LIKE   GLOB   MATCH   REGEXP
    AND
    OR
*/
expr
 : literal_value
 | BIND_PARAMETER
 | ( ( database_name '.' )? table_name '.' )? column_name
 | unary_operator expr
 | expr '||' expr
 | expr ( '*' | '/' | '%' ) expr
 | expr ( '+' | '-' ) expr
 | expr ( '<<' | '>>' | '&' | '|' ) expr
 | expr ( '<' | '<=' | '>' | '>=' ) expr
 | expr ( '=' | '==' | '!=' | '<>' | IS | IS NOT | IN | LIKE | GLOB | MATCH | REGEXP ) expr
 | expr AND expr
 | expr OR expr
 | function_name '(' ( DISTINCT? expr ( ',' expr )* | '*' )? ')'
 | '(' expr ')'
 | CAST '(' expr AS type_name ')'
 | expr COLLATE collation_name
 | expr NOT? ( LIKE | GLOB | REGEXP | MATCH ) expr ( ESCAPE expr )?
 | expr ( ISNULL | NOTNULL | NOT NULL )
 | expr IS NOT? expr
 | expr NOT? BETWEEN expr AND expr
 | expr NOT? IN ( '(' ( select_stmt
                          | expr ( ',' expr )*
                          )? 
                      ')'
                    | ( database_name '.' )? table_name )
 | ( ( NOT )? EXISTS )? '(' select_stmt ')'
 | CASE expr? ( WHEN expr THEN expr )+ ( ELSE expr )? END
 | raise_function
 ;

foreign_key_clause
 : REFERENCES foreign_table ( '(' column_name ( ',' column_name )* ')' )?
   ( ( ON ( DELETE | UPDATE ) ( SET NULL
                                    | SET DEFAULT
                                    | CASCADE
                                    | RESTRICT
                                    | NO ACTION )
     | MATCH name
     ) 
   )*
   ( NOT? DEFERRABLE ( INITIALLY DEFERRED | INITIALLY IMMEDIATE )? )?
 ;

raise_function
 : RAISE '(' ( IGNORE 
               | ( ROLLBACK | ABORT | FAIL ) ',' error_message )
           ')'
 ;

indexed_column
 : column_name ( COLLATE collation_name )? ( ASC | DESC )?
 ;

table_constraint
 : ( CONSTRAINT name )?
   ( ( PRIMARY KEY | UNIQUE ) '(' indexed_column ( ',' indexed_column )* ')' conflict_clause
   | CHECK '(' expr ')'
   | FOREIGN KEY '(' column_name ( ',' column_name )* ')' foreign_key_clause
   )
 ;

with_clause
 : WITH RECURSIVE? cte_table_name AS '(' select_stmt ')' ( ',' cte_table_name AS '(' select_stmt ')' )*
 ;

qualified_table_name
 : ( database_name '.' )? table_name ( INDEXED BY index_name
                                     | NOT INDEXED )?
 ;

ordering_term
 : expr ( COLLATE collation_name )? ( ASC | DESC )?
 ;

pragma_value
 : signed_number
 | name
 | STRING_LITERAL
 ;

common_table_expression
 : table_name ( '(' column_name ( ',' column_name )* ')' )? AS '(' select_stmt ')'
 ;

result_column
 : '*'
 | table_name '.' '*'
 | expr ( AS? column_alias )?
 ;

table_or_subquery
 : ( database_name '.' )? table_name ( AS? table_alias )?
   ( INDEXED BY index_name
   | NOT INDEXED )?
 | '(' ( table_or_subquery ( ',' table_or_subquery )*
       | join_clause )
   ')' ( AS? table_alias )?
 | '(' select_stmt ')' ( AS? table_alias )?
 ;

join_clause
 : table_or_subquery ( join_operator table_or_subquery join_constraint )*
 ;

join_operator
 : ','
 | NATURAL? ( LEFT OUTER? | INNER | CROSS )? JOIN
 ;

join_constraint
 : ( ON expr
   | USING '(' column_name ( ',' column_name )* ')' )?
 ;

select_core
 : SELECT ( DISTINCT | ALL )? result_column ( ',' result_column )*
   ( FROM ( table_or_subquery ( ',' table_or_subquery )* | join_clause ) )?
   ( WHERE expr )?
   ( GROUP BY expr ( ',' expr )* ( HAVING expr )? )?
 | VALUES '(' expr ( ',' expr )* ')' ( ',' '(' expr ( ',' expr )* ')' )*
 ;

compound_operator
 : UNION
 | UNION ALL
 | INTERSECT
 | EXCEPT
 ;

cte_table_name
 : table_name ( '(' column_name ( ',' column_name )* ')' )?
 ;

signed_number
 : ( '+' | '-' )? NUMERIC_LITERAL
 ;

literal_value
 : NUMERIC_LITERAL
 | STRING_LITERAL
 | BLOB_LITERAL
 | NULL
 | CURRENT_TIME
 | CURRENT_DATE
 | CURRENT_TIMESTAMP
 ;

unary_operator
 : '-'
 | '+'
 | '~'
 | NOT
 ;

error_message
 : STRING_LITERAL
 ;

module_argument // TODO check what exactly is permitted here
 : expr
 | column_def
 ;

column_alias
 : IDENTIFIER
 | STRING_LITERAL
 ;

keyword
 : ABORT
 | ACTION
 | ADD
 | AFTER
 | ALL
 | ALTER
 | ANALYZE
 | AND
 | AS
 | ASC
 | ATTACH
 | AUTOINCREMENT
 | BEFORE
 | BEGIN
 | BETWEEN
 | BY
 | CASCADE
 | CASE
 | CAST
 | CHECK
 | COLLATE
 | COLUMN
 | COMMIT
 | CONFLICT
 | CONSTRAINT
 | CREATE
 | CROSS
 | CURRENT_DATE
 | CURRENT_TIME
 | CURRENT_TIMESTAMP
 | DATABASE
 | DEFAULT
 | DEFERRABLE
 | DEFERRED
 | DELETE
 | DESC
 | DETACH
 | DISTINCT
 | DROP
 | EACH
 | ELSE
 | END
 | ESCAPE
 | EXCEPT
 | EXCLUSIVE
 | EXISTS
 | EXPLAIN
 | FAIL
 | FOR
 | FOREIGN
 | FROM
 | FULL
 | GLOB
 | GROUP
 | HAVING
 | IF
 | IGNORE
 | IMMEDIATE
 | IN
 | INDEX
 | INDEXED
 | INITIALLY
 | INNER
 | INSERT
 | INSTEAD
 | INTERSECT
 | INTO
 | IS
 | ISNULL
 | JOIN
 | KEY
 | LEFT
 | LIKE
 | LIMIT
 | MATCH
 | NATURAL
 | NO
 | NOT
 | NOTNULL
 | NULL
 | OF
 | OFFSET
 | ON
 | OR
 | ORDER
 | OUTER
 | PLAN
 | PRAGMA
 | PRIMARY
 | QUERY
 | RAISE
 | RECURSIVE
 | REFERENCES
 | REGEXP
 | REINDEX
 | RELEASE
 | RENAME
 | REPLACE
 | RESTRICT
 | RIGHT
 | ROLLBACK
 | ROW
 | SAVEPOINT
 | SELECT
 | SET
 | TABLE
 | TEMP
 | TEMPORARY
 | THEN
 | TO
 | TRANSACTION
 | TRIGGER
 | UNION
 | UNIQUE
 | UPDATE
 | USING
 | VACUUM
 | VALUES
 | VIEW
 | VIRTUAL
 | WHEN
 | WHERE
 | WITH
 | WITHOUT
 ;

// TODO check all names below

name
 : any_name
 ;

function_name
 : any_name
 ;

database_name
 : any_name
 ;

table_name 
 : any_name
 ;

table_or_index_name 
 : any_name
 ;

new_table_name 
 : any_name
 ;

column_name 
 : any_name
 ;

collation_name 
 : any_name
 ;

foreign_table 
 : any_name
 ;

index_name 
 : any_name
 ;

trigger_name
 : any_name
 ;

view_name 
 : any_name
 ;

module_name 
 : any_name
 ;

pragma_name 
 : any_name
 ;

savepoint_name 
 : any_name
 ;

table_alias 
 : any_name
 ;

transaction_name
 : any_name
 ;

any_name
 : IDENTIFIER 
 | keyword
 | STRING_LITERAL
 | '(' any_name ')'
 ;

SCOL : ';';
DOT : '.';
OPEN_PAR : '(';
CLOSE_PAR : ')';
COMMA : ',';
ASSIGN : '=';
STAR : '*';
PLUS : '+';
MINUS : '-';
TILDE : '~';
PIPE2 : '||';
DIV : '/';
MOD : '%';
LT2 : '<<';
GT2 : '>>';
AMP : '&';
PIPE : '|';
LT : '<';
LT_EQ : '<=';
GT : '>';
GT_EQ : '>=';
EQ : '==';
NOT_EQ1 : '!=';
NOT_EQ2 : '<>';

// http://www.sqlite.org/lang_keywords.html
ABORT : A B O R T;
ACTION : A C T I O N;
ADD : A D D;
AFTER : A F T E R;
ALL : A L L;
ALTER : A L T E R;
ANALYZE : A N A L Y Z E;
AND : A N D;
AS : A S;
ASC : A S C;
ATTACH : A T T A C H;
AUTOINCREMENT : A U T O I N C R E M E N T;
BEFORE : B E F O R E;
BEGIN : B E G I N;
BETWEEN : B E T W E E N;
BY : B Y;
CASCADE : C A S C A D E;
CASE : C A S E;
CAST : C A S T;
CHECK : C H E C K;
COLLATE : C O L L A T E;
COLUMN : C O L U M N;
COMMIT : C O M M I T;
CONFLICT : C O N F L I C T;
CONSTRAINT : C O N S T R A I N T;
CREATE : C R E A T E;
CROSS : C R O S S;
CURRENT_DATE : C U R R E N T '_' D A T E;
CURRENT_TIME : C U R R E N T '_' T I M E;
CURRENT_TIMESTAMP : C U R R E N T '_' T I M E S T A M P;
DATABASE : D A T A B A S E;
DEFAULT : D E F A U L T;
DEFERRABLE : D E F E R R A B L E;
DEFERRED : D E F E R R E D;
DELETE : D E L E T E;
DESC : D E S C;
DETACH : D E T A C H;
DISTINCT : D I S T I N C T;
DROP : D R O P;
EACH : E A C H;
ELSE : E L S E;
END : E N D;
ESCAPE : E S C A P E;
EXCEPT : E X C E P T;
EXCLUSIVE : E X C L U S I V E;
EXISTS : E X I S T S;
EXPLAIN : E X P L A I N;
FAIL : F A I L;
FOR : F O R;
FOREIGN : F O R E I G N;
FROM : F R O M;
FULL : F U L L;
GLOB : G L O B;
GROUP : G R O U P;
HAVING : H A V I N G;
IF : I F;
IGNORE : I G N O R E;
IMMEDIATE : I M M E D I A T E;
IN : I N;
INDEX : I N D E X;
INDEXED : I N D E X E D;
INITIALLY : I N I T I A L L Y;
INNER : I N N E R;
INSERT : I N S E R T;
INSTEAD : I N S T E A D;
INTERSECT : I N T E R S E C T;
INTO : I N T O;
IS : I S;
ISNULL : I S N U L L;
JOIN : J O I N;
KEY : K E Y;
LEFT : L E F T;
LIKE : L I K E;
LIMIT : L I M I T;
MATCH : M A T C H;
NATURAL : N A T U R A L;
NO : N O;
NOT : N O T;
NOTNULL : N O T N U L L;
NULL : N U L L;
OF : O F;
OFFSET : O F F S E T;
ON : O N;
OR : O R;
ORDER : O R D E R;
OUTER : O U T E R;
PLAN : P L A N;
PRAGMA : P R A G M A;
PRIMARY : P R I M A R Y;
QUERY : Q U E R Y;
RAISE : R A I S E;
RECURSIVE : R E C U R S I V E;
REFERENCES : R E F E R E N C E S;
REGEXP : R E G E X P;
REINDEX : R E I N D E X;
RELEASE : R E L E A S E;
RENAME : R E N A M E;
REPLACE : R E P L A C E;
RESTRICT : R E S T R I C T;
RIGHT : R I G H T;
ROLLBACK : R O L L B A C K;
ROW : R O W;
SAVEPOINT : S A V E P O I N T;
SELECT : S E L E C T;
SET : S E T;
TABLE : T A B L E;
TEMP : T E M P;
TEMPORARY : T E M P O R A R Y;
THEN : T H E N;
TO : T O;
TRANSACTION : T R A N S A C T I O N;
TRIGGER : T R I G G E R;
UNION : U N I O N;
UNIQUE : U N I Q U E;
UPDATE : U P D A T E;
USING : U S I N G;
VACUUM : V A C U U M;
VALUES : V A L U E S;
VIEW : V I E W;
VIRTUAL : V I R T U A L;
WHEN : W H E N;
WHERE : W H E R E;
WITH : W I T H;
WITHOUT : W I T H O U T;

IDENTIFIER
 : '"' (~'"' | '""')* '"'
 | '`' (~'`' | '``')* '`'
 | '[' ~']'* ']'
 | [a-zA-Z_] [a-zA-Z_0-9]* // TODO check: needs more chars in set
 ;

NUMERIC_LITERAL
 : DIGIT+ ( '.' DIGIT* )? ( E [-+]? DIGIT+ )?
 | '.' DIGIT+ ( E [-+]? DIGIT+ )?
 ;

BIND_PARAMETER
 : '?' DIGIT*
 | [:@$] IDENTIFIER
 ;

STRING_LITERAL
 : '\'' ( ~'\'' | '\'\'' )* '\''
 ;

BLOB_LITERAL
 : X STRING_LITERAL
 ;

SINGLE_LINE_COMMENT
 : '--' ~[\r\n]* -> channel(HIDDEN)
 ;

MULTILINE_COMMENT
 : '/*' .*? ( '*/' | EOF ) -> channel(HIDDEN)
 ;

SPACES
 : [ \u000B\t\r\n] -> channel(HIDDEN)
 ;

UNEXPECTED_CHAR
 : .
 ;

fragment DIGIT : [0-9];

fragment A : [aA];
fragment B : [bB];
fragment C : [cC];
fragment D : [dD];
fragment E : [eE];
fragment F : [fF];
fragment G : [gG];
fragment H : [hH];
fragment I : [iI];
fragment J : [jJ];
fragment K : [kK];
fragment L : [lL];
fragment M : [mM];
fragment N : [nN];
fragment O : [oO];
fragment P : [pP];
fragment Q : [qQ];
fragment R : [rR];
fragment S : [sS];
fragment T : [tT];
fragment U : [uU];
fragment V : [vV];
fragment W : [wW];
fragment X : [xX];
fragment Y : [yY];
fragment Z : [zZ];
