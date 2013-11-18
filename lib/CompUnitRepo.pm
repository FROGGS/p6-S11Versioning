
class CompUnitRepo {
    my Mu $p6ml := nqp::gethllsym('perl6', 'ModuleLoader');
    my @repos;

    method candidates($longname, :$file, :$auth, :$ver) {
        my @candi;
        for @repos {
            @candi := (@candi, .candidates($longname, :$file, :$auth, :$ver)).flat
        }
        @candi.sort: { $^b<ver> cmp $^a<ver> }
    }

    method add_repo($repo) {
        @repos.push: $repo
    }

    method p6ml { $p6ml }

    method load_module($module_name, %opts, *@GLOBALish, :$line, :$file is copy) {
        $file //= self.candidates($module_name, :auth(%opts<auth>), :ver(%opts<ver>))[0]<key>;
        $p6ml.load_module($module_name, %opts, @GLOBALish, $file, :$file);
    }

    method absolute_path($path) { $p6ml.absolute_path($path) }
    method load_setting($setting_name) { $p6ml.load_setting($setting_name) }
}

if 'libraries.cfg'.IO.e {
    my @lines = slurp('libraries.cfg').lines;
    my %repos;
    for @lines -> $repo {
        if $repo ~~ / $<class>=[ <.ident>+ % '::' ] '=' $<path>=.+ / {
            %repos{~$<class>} //= [];
            %repos{~$<class>}.push(~$<path>);
        }
    }
    for %repos.kv -> $longname, $args {
        my $name = 'lib/' ~ $longname.split('::').join('/') ~ '.pm';
        require $name;
        CompUnitRepo.add_repo( ::($longname).new(|@$args) );
    }
}

nqp::bindhllsym('perl6', 'ModuleLoader', CompUnitRepo);

if %*COMPILING<%?OPTIONS><I> {
    # XXX do something with it
    # say %*COMPILING<%?OPTIONS><I>
}
