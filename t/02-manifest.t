
use v6;
use Test;

use lib 't/deps/JSON-Tiny/lib';
use JSON::Tiny;

use lib 'lib';
use MyModuleLoader;

plan 7;

my @tests;
my $i = 0;

BEGIN {
    class MyModuleLoader::Classic {
        # The order _does_ matter here.
        my @prefixes = < t/libs/PERL6LIB >;

        method load_module($module_name, %opts, *@GLOBALish, :$line, :$file) {
            my $candi = MyModuleLoader.locate_candidates($module_name, @prefixes, :$file);
            @tests.push: $candi;
            $candi
        }
    }
    MyModuleLoader.add_loader( MyModuleLoader::Classic );

    class MyModuleLoader::MANIFEST {
        # The order does not matter here, really.
        my @paths  = < t/libs/home t/libs/perl t/libs/site t/libs/vendor >;
        my %dists  = {};
        %dists{$_} = from-json( slurp "$_/MANIFEST" ) if "$_/MANIFEST".IO.e for @paths;

        method load_module($module_name, %opts, *@GLOBALish, :$line, :$file) {
            my $candi;
            for %dists.kv -> $path, $dists {
                for @$dists -> $dist {
                    $dist<ver> = Version.new( $dist<ver> ) unless $dist<ver> ~~ Version;
                    
                    if (!%opts<auth> || $dist<auth> ~~ %opts<auth>)
                    && (!%opts<ver>  || $dist<ver>  ~~ %opts<ver>)
                    && (!$candi      || $dist<ver> cmp $candi<ver> == Order::More)
                    && $dist<modules>{$module_name} {
                        $candi      = $dist;
                        $candi<key> = $path ~ '/' ~ $dist<modules>{$module_name};
                    }
                }
            }
            @tests.push: $candi;
            $candi
        }
    }
    MyModuleLoader.add_loader( MyModuleLoader::MANIFEST );
}

use Baz;
ok !@tests[$i++], 'the classis loader fails for an unknown modules';
ok !@tests[$i++], 'so does the MyModuleLoader::MANIFEST';

use Foo;
ok @tests[$i++]<key> ~~ m|'t/libs/PERL6LIB/Foo.pm'|, 'classic loader found file in its paths';

use Foo::Bar;
ok !@tests[$i++], "classic loader can't find Foo::Bar";
ok @tests[$i++]<key> ~~ m|'t/libs/site/Foo/Bar.pm'|, 'MANIFEST-loader found the newest version of Foo::Bar';

use Foo::Bar:ver<1.0.1>;
ok !@tests[$i++], "classic loader still can't find Foo::Bar";
ok @tests[$i++]<key> ~~ m|'t/libs/site/Foo/Bar-1.pm'|, 'MANIFEST-loader found specific version';

done();
