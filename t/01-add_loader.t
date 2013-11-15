
use v6;
use Test;
use lib 'lib';
use lib 't/deps';
use MyModuleLoader;
use JSON::Tiny;

plan 1;

my $err_msg;

BEGIN {
    class MyModuleLoader::TheObvious {
        method load_module($module_name, %opts, *@GLOBALish, :$line, :$file) {
            $err_msg = "'$module_name' does not seem to be installed."
        }
    }

    MyModuleLoader.add_loader( MyModuleLoader::TheObvious );
}

use ThereIsNoSuchModule;
ok $err_msg eq "'ThereIsNoSuchModule' does not seem to be installed.", 'got the right error message';

done();
