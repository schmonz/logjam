#!/usr/bin/env perl

BEGIN { require 'test_depends.pl' if -x 'test_depends.pl' }

use Test::More tests => 14;
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

sub test_connect_to_database {
	my ($database) = @_;
	my $unit = \&logjam::connect_to_database;

	throws_ok { $unit->(undef) }
		qr/no file specified/,
		q{reject null filename};

	my $dbh;
	unlink $database;
	lives_ok { $dbh = $unit->($database) }
		q{accept non-null filename};

	return $dbh;
}

sub test_initialize_table {
	my ($dbh) = @_;
	my $unit = \&logjam::initialize_table;

	throws_ok { $unit->(undef) }
		qr/no handle specified/,
		q{reject null database handle};

	lives_ok { $unit->($dbh) }
		q{accept non-null database-handle};

	# XXX we haven't proven the table is really there, or looks right
	# XXX we haven't proven we bail if the table is already there
}

sub test_store_log_line {
	my ($dbh) = @_;
	my $unit = \&logjam::store_log_line;

	# we already unit-tested parsing; integration-test later, but not here
	my %good_input = (
		month	=> 'one',
		day	=> 'two',
		time	=> 'three',
		host	=> 'four',
		tag	=> 'five',
		message	=> 'six seven eight  nine ten ELEVEN 12',
	);

	throws_ok { $unit->($dbh, undef) }
		qr/no line specified/,
		q{reject null input};

	throws_ok { $unit->($dbh, 'just a scalar') }
		qr/no parsed line specified/,
		q{reject string input};

	lives_ok { $unit->($dbh, \%good_input) }
		q{accept parsed input};

	# XXX we haven't proven the line is really there
}

sub main() {
	test_parse_log_line();
	my $dbh = test_connect_to_database('some_file_name');
	test_initialize_table($dbh);
	test_store_log_line($dbh);
}

main();
