#!/usr/bin/env perl

require 'test_depends.pl' if -x 'test_depends.pl';

use Test::More tests => 7;
use Test::Exception;

use warnings;
use strict;

require_ok('logjam.pl');

# our job is really just to:
# 1. split lines into (month, day, time, host, tag, message)
# 	- how can this go wrong? help!
# 2. insert them into a database
# 	- how can this go wrong? help!

sub isnt_acceptable_log_line {
	my ($log_line, $exception_matches_this_regex, $test_description) = @_;

	throws_ok
		{ logjam::parse_log_line($log_line) }
		$exception_matches_this_regex,
		$test_description;
}

# tests we care about (our job):
# - if we INSERT this line as is, how much will it screw up queries later?

isnt_acceptable_log_line(
	"one two three four five",
	qr/too few fields/,
	q{reject log lines that don't have enough fields},
);

isnt_acceptable_log_line(
	"one two three four five six seven",
	qr/not our application/,
	q{reject log lines that aren't from OpaqueImportantThing},
);

isnt_acceptable_log_line(
	"one two three four OpaqueImportantThing six seven",
	qr/not our application/,
	q{reject log lines that aren't tagged with a trailing colon},
);

my %fields = logjam::parse_log_line(
	"one two three four OpaqueImportantThing: six seven eight  nine ten",
);
is(
	$fields{tag},
	"OpaqueImportantThing:",
	q{accept log lines tagged with OpaqueImportantThing},
);
is(
	$fields{message},
	"six seven eight  nine ten",
	q{preserve message, spaces and all},
);

isnt_acceptable_log_line(
	"one two three four OpaqueImportantThing: ",
	qr/no message logged/,
	q{reject log lines that have empty message},
);
