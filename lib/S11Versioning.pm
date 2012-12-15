
module S11Versioning;

use S11Versioning::Grammar;

use JSON::Tiny;

my %dists = {};
%dists{$_} = from-json( slurp "{%*CUSTOM_LIB{$_}}/MANIFEST" ).flat if "{%*CUSTOM_LIB{$_}}/MANIFEST".IO.e for <home site vendor perl>;

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

		my @candidates = ();

		for <home site vendor perl> -> $dir {
			next unless %dists{ $dir };

			for %dists{ $dir }.values -> $dist {
				#say $dist;
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
					$dist<version> = Version.new( ~$dist<version> );

					if $bag<ver>[0]<version_from> && $bag<ver>[0]<version_to> {
						my $from       = ~$bag<ver>[0]<version_from>;
						$from          = $from eq '*'
						               ?? Version.new( 'v0' )
						               !! Version.new( $from );
						my $to         = ~$bag<ver>[0]<version_to>;
						my $before_to  = $to   ~~ s[^\^] = '';
						$to            = Version.new( $to );

						next unless $dist<version> !before $from; # equal or after

						if $before_to {
							next unless $dist<version> before $to
						}
						else {
							next unless $dist<version> !after $to # before or equal
						}
					}
					elsif $bag<ver>[0]<version> && $bag<ver>[0]<version> ne 'Any' {
						my $version        = ~$bag<ver>[0]<version>;
						my $before_version = $version ~~ s[^\^] = '';

						if $before_version {
							next unless $dist<version> before $version
						}
						else {
							next unless $dist<version> !before $version # equal or after
						}
					}
				}

				$dist<dir> = $dir;
				@candidates.push: $dist
			}
		}

		if @candidates.elems {
			@candidates = @candidates.sort: { $^b<version> cmp $^a<version> };
			return %*CUSTOM_LIB{ @candidates[0]<dir> } ~ '/' ~ @candidates[0]<modules>{ $bag<name> };
		}

		die "No such module, version or auth for \xFF62$module\xFF63";
	}

	die "Unable to parse \xFF62$module\xFF63"
}
