
grammar S11Versioning::Grammar {
	rule TOP       { ^ <name> <from>? <auth>? <ver>? $ }
	rule namespace { <[\w]>+                           }
	rule name      { <namespace>+ % [ '::' ]           }
	rule from      { 'from'                            }

	token version {
		'v'?
		[ 0 | <[1..9]> <[0..9]>* ]
		[ \. <[0..9]>+ ]*
		[ \. \* ]?
	}

	proto token ver { <...> };

	token ver:sym<angle> {
		':'
		'ver'?
		'<' ~ '>' [
			\*
			| <version>
		]
	};

	token ver:sym<braces> {
		':'
		'ver'?
		'(' ~ ')' [
			'Any'
			| $<version_from> = <version>          '..' $<version_to> = [ \* | <version> ]
			| $<version_from> = [ \* | <version> ] '..' $<version_to> = [ '^'? <version> ]
			| [ <ws>? <version> <ws>? ]+ % [ '|' ]
		]
	};

	proto token auth { <...> };

	token auth:sym<angle> {
		':auth<' $<name> = .+? '>'
	};

	token auth:sym<braces> {
		':auth(' ~ ')' [
			'Any'
			| <url>
		]
	};

	token auth:sym<block> {
		':auth(' [
			  '{' $<code>  = .+? '}'
			| '/' $<regex> = .+? '/'
		] ')'
	};

	token user      { <[ \. \w ]>+ };
	token domain    { <-[ '/' ')' ]>+  };
	proto token url { <...>        };

	token url:sym<home> {
		\w+ '://' <domain> '/~' <user>
	};

	token url:sym<mail> {
		'mailto:' <user> '@' <domain>
	};
}
