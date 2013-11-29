
use lib 't/deps/JSON-Tiny/lib';
use JSON::Tiny;

class CompUnitRepo::Local::Installation {
    has %!dists;
    method new( *@locations ) {
        self.bless(:@locations)
    }

    method BUILD( :@locations ) {
        for @locations -> $path {
            %!dists{$path} = from-json( slurp "$path/MANIFEST" ).list if "$path/MANIFEST".IO.e
        }
        self
    }

    method install( $source, $from? ) {
        ...
    }

    method candidates( $longname, :$file, :$auth, :$ver ) {
        my @candi;
        for %!dists.kv -> $path, $repo {
            for @$repo -> $dist is rw {
                $dist<ver> = Version.new( $dist<ver> ) unless $dist<ver> ~~ Version;
                
                if (!$auth || $dist<auth> ~~ $auth)
                && (!$ver  || $dist<ver>  ~~ $ver)
                && $dist<provides>{$longname} {
                    my $candi   = $dist;
                    $candi<key> = $path ~ '/' ~ $dist<provides>{$longname};
                    @candi.push: $candi;
                }
            }
        }
        @candi
    }
}
