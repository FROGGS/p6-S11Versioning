
use lib 'lib';
use S11Versioning;

use( 'Dog' );
use( 'Dog:auth(Any):ver(Any)' );
use( 'Dog:<*>' );
use( 'Dog:<1.2.1>' );
use( 'Dog:auth(Any):ver<1.2.1>' );
use( 'Dog:ver(v1.2.1..v1.2.3)' );
use( 'Dog:ver(v1.2.1..^v1.3)' );
use( 'Dog:ver(v1.2.1..*)' );
use( 'Dog:ver<6.*>' );
use( 'Dog:<6.0>' );
use( 'Dog:<6.0.0>' );
use( 'Dog:<6.2.7.1>' );
use( 'Dog:auth<cpan:TPF>' );
use( 'Dog:auth(http://www.some.com/~jrandom)' );
use( 'Dog:auth(mailto:jrandom@some.com)' );
use( 'Dog:auth(/:i jrandom/)' );
use( 'Dog:ver(v1.2.1 | v1.3.4)' );
use( 'Dog:auth(/:i jrandom/):ver(v1.2.1 | v1.3.4)' );
use( 'Dog:auth({ .substr(0,5) eq "cpan:"})' );
use( 'Dog:auth({ .substr(0,5) eq "cpan:"}):ver(Any)' );

use( 'Perl' );
use( 'Perl:auth(Any):ver(Any)' );
use( 'Perl:<*>' );
use( 'Perl:<1.2.1>' );
use( 'Perl:auth(Any):ver<1.2.1>' );
use( 'Perl:ver(v1.2.1..v1.2.3)' );
use( 'Perl:ver(v1.2.1..^v1.3)' );
use( 'Perl:ver(v1.2.1..*)' );
use( 'Perl:ver<6.*>' );
use( 'Perl:<6.0>' );
use( 'Perl:<6.0.0>' );
use( 'Perl:<6.2.7.1>' );
use( 'Perl:auth<cpan:TPF>' );                      # /usr/lib/perl6/rakudo-1.0/Perl-6.0.0-
use( 'Perl:auth(http://www.some.com/~jrandom)' );  # /usr/lib/perl6/niecza-1.2/
use( 'Perl:auth(mailto:jrandom@some.com)' );       # 
# http://search.cpan.org/~sburke/Text-Unidecode-0.04/lib/Text/Unidecode.pm
# 6PAN site, where you can upload or register repo urls like github. releases need to be tagged, "dev"-version are tag+X-commits
use( 'Perl:auth(/:i jrandom/)' );
use( 'Perl:auth(/:i tpf/)' );
use( 'Perl:ver(v1.2.1 | v1.3.4)' );
use( 'Perl:auth(/:i jrandom/):ver(v1.2.1 | v1.3.4)' );
use( 'Perl:auth({ .substr(0,5) eq "cpan:"})' );
use( 'Perl:auth({ .substr(0,5) eq "cpan:"}):ver(Any)' );
