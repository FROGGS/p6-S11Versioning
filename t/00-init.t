
use v6;
use Test;

plan 2;

shell('mkdir t/deps') unless 't/deps'.IO ~~ :d;

shell('git clone git://github.com/moritz/json.git t/deps/JSON-Tiny') unless 't/deps/JSON-Tiny'.IO ~~ :d;
shell('git clone git://github.com/perl6/DBIish.git t/deps/DBIish')   unless 't/deps/DBIish'.IO    ~~ :d;

ok 't/deps/JSON-Tiny/.git/'.IO ~~ :d, 'got JSON-Tiny in t/deps/';
ok 't/deps/DBIish/.git/'.IO    ~~ :d, 'got DBIish in t/deps/';

done();
