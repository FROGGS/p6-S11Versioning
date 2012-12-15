
module S11Versioning;

use S11Versioning::Grammar;

use JSON::Tiny;

my @dists = ();
@dists.push: from-json( slurp "{%*CUSTOM_LIB{$_}}/MANIFEST" ).flat if "{%*CUSTOM_LIB{$_}}/MANIFEST".IO.e for <home site vendor perl>;

my $dists = (
	{
		name => 'Perl',
		auth => 'cpan:TPF',
		ver  => '6.0.0',
	},
	{
		name => 'Perl',
		auth => 'cpan:TPF',
		ver  => 'v6.0.0',
	},
);

sub use ( $module ) is export {
	if my $bag = S11Versioning::Grammar.parse( $module ) {
		#say 'Whooohoo! ' ~ $module;

		for @dists.values -> $dist {
			say $dist;
			next unless $bag<name> eq $dist<name>;

			if $bag<auth>[0]<name> {
				next unless $bag<auth>[0]<name> eq 'Any'
				         || $bag<auth>[0]<name> eq '*'
				         || $bag<auth>[0]<name> eq $dist<author>
			}
			elsif $bag<auth>[0]<url> {
				next unless $bag<auth>[0]<url> eq $dist<author>
			}
			elsif $bag<auth>[0]<code> {
				my $s = '-> $_ {' ~ $bag<auth>[0]<code> ~ '}';
				next unless (eval $s)( $dist<author> );
			}
			elsif $bag<auth>[0]<regex> {
				next unless $dist<author> ~~ /<{$bag<auth>[0]<regex>}>/;
			}

			if $bag<ver>[0] {
				my $ver = Version.new( ~$dist<version> );

				if $bag<ver>[0]<version_from> && $bag<ver>[0]<version_to> {
					my $from = Version.new( ~$bag<ver>[0]<version_from> );
					my $to   = Version.new( ~$bag<ver>[0]<version_to>   );

					next unless $from !after $ver && $ver !after $to;
				}
				elsif $bag<ver>[0]<version> && $bag<ver>[0]<version> ne 'Any' {
					next unless Version.new( ~$bag<ver>[0]<version> ) !after $ver;
				}
			}

			#say $dist
		}
	}
	else {
		#say 'Dope -.- ' ~ $module;
	}
}
