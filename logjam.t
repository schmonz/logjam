#!/usr/bin/env perl

BEGIN { require 'test_depends.pl' if -x 'test_depends.pl' }

use Test::More tests => 7;
use Test::Exception;

use warnings;
use strict;

require_ok('./logjam.pl');

sub test_parse_log_line {
	my $unit = \&logjam::parse_log_line;

	my $isnt_acceptable_log_line = sub {
		my ($log_line, $regex_in_exception, $test_description) = @_;
		throws_ok
			{ $unit->($log_line) }
			$regex_in_exception,
			$test_description;
	};

	$isnt_acceptable_log_line->(
		"one two three four five",
		qr/too few fields/,
		q{reject log lines that don't have enough fields},
	);

	$isnt_acceptable_log_line->(
		"one two three four five six seven",
		qr/not our application/,
		q{reject log lines that aren't from OpaqueImportantThing},
	);

	$isnt_acceptable_log_line->(
		"one two three four OpaqueImportantThing six seven",
		qr/not our application/,
		q{reject log lines that aren't tagged with a trailing colon},
	);

	my %fields = $unit->(
		"one two three four OpaqueImportantThing: six seven"
			. " eight  nine ten",
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

	$isnt_acceptable_log_line->(
		"one two three four OpaqueImportantThing: ",
		qr/no message logged/,
		q{reject log lines that have empty message},
	);
}

sub test_store_log_line {
	my $unit = \&logjam::store_log_line;

	my %good_input = (
		month	=> 'one',
		day	=> 'two',
		time	=> 'three',
		host	=> 'four',
		tag	=> 'five',
		message	=> 'six seven eight  nine ten ELEVEN 12',
	);

	# use case: got a bunch of log files to analyze now
	#
	# we did the parsing, so we know we have enough fields, etc.
	# if we can't connect to database, die
	# if the table doesn't exist, create it
	# if we've already written this log line, die? nope, not the use case
	# if the table exists, write the line
	# if the line didn't write, die
	# if the line wrote, prove it
	# if it isn't actually there, die
}

sub main() {
	test_parse_log_line();
	test_store_log_line();
}

main();
