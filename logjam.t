#!/usr/bin/env perl

use Test::More;

use warnings;
use strict;

require_ok('logjam.pl');

my $got = logjam::hi_everyone();
my $expected = "oodles";
my $description = q{should be oodles};

is($got, $expected, $description);

# see example logfile for how lines are formatted
#
# we can concatenate logfiles outside our program, so we only need to read one
#
# we don't even need to read it ourselves, we can make Unix do that for us
#
# our job is really just to:
# 1. split lines into (month, day, time, host, tag, message)
# 	- how can this go wrong? help!
# 2. insert them into a database
# 	- how can this go wrong? help!

done_testing();
