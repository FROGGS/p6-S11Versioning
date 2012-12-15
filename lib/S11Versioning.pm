
module S11Versioning;

use S11Versioning::Grammar;

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
		say 'Whooohoo! ' ~ $module;

		for $dists.values -> $dist {
			next unless $bag<name> eq $dist<name>;

			if $bag<auth>[0]<name> {
				next unless $bag<auth>[0]<name> eq 'Any'
				         || $bag<auth>[0]<name> eq '*'
				         || $bag<auth>[0]<name> eq $dist<auth>
			}
			elsif $bag<auth>[0]<url> {
				next unless $bag<auth>[0]<url> eq $dist<auth>
			}
			elsif $bag<auth>[0]<code> {
				my $s = '-> $_ {' ~ $bag<auth>[0]<code> ~ '}';
				next unless (eval $s)( $dist<auth> );
			}
			elsif $bag<auth>[0]<regex> {
				next unless $dist<auth> ~~ /<{$bag<auth>[0]<regex>}>/;
			}

			if $bag<ver>[0] {
				my $ver = Version.new( ~$dist<ver> );

				if $bag<ver>[0]<version_from> && $bag<ver>[0]<version_to> {
					my $from = Version.new( ~$bag<ver>[0]<version_from> );
					my $to   = Version.new( ~$bag<ver>[0]<version_to>   );

					next unless $from !after $ver && $ver !after $to;
				}
				elsif $bag<ver>[0]<version> && $bag<ver>[0]<version> ne 'Any' {
					next unless Version.new( ~$bag<ver>[0]<version> ) !after $ver;
				}
			}

			say $dist
		}
	}
	else {
		say 'Dope -.- ' ~ $module;
	}
}
