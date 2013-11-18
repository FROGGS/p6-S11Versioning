
use v6;
use Test;

use lib 'lib';
use CompUnitRepo;

plan 10;

my $ml = nqp::gethllsym("perl6", "ModuleLoader");

ok !$ml.candidates("Baz"), 'Baz is unknown to us.';
ok $ml.candidates("Foo"), 'but we know about Foo';
is $ml.candidates("Foo").elems, 1, 'exactly one hit';
ok $ml.candidates("Foo")[0]<key> ~~ m/t.libs.PERL6LIB.Foo\.pm$/, 'we even get its path';
is $ml.candidates("Foo::Bar").elems, 3, 'we have 3 Foo::Bars installed';
is $ml.candidates("Foo::Bar")[0]<ver>, v1.0.4, 'best version first';
is $ml.candidates("Foo::Bar")[1]<ver>, v1.0.1, 'next lower version';
is $ml.candidates("Foo::Bar")[2]<ver>, v0.27, 'well, last is last';
is $ml.candidates("Foo::Bar", :ver(v1.*)).elems, 2, 'filtering by version gives correct results';
is $ml.candidates("Foo::Bar", :ver(v1.0.2..*)).elems, 1, 'filtering by version gives correct results';

done();
