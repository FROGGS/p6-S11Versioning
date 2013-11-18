
use v6;

use lib 'lib';
use CompUnitRepo;

BEGIN say "1..3";

use Foo::Bar;
use Foo::Bar:ver(*..^v1.0.4);
use Foo::Bar:ver<0.27>;
