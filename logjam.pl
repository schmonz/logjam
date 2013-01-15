#!/usr/bin/env perl

BEGIN { require 'code_depends.pl' if -x 'code_depends.pl' }

package logjam;

use warnings;
use strict;

sub parse_log_line {
	my ($line) = @_;
	my $NUM_FIELDS = 6;

	my @numbered_fields = split(/ /, $line, $NUM_FIELDS);

	die "too few fields"
		if $NUM_FIELDS > @numbered_fields;

	my %named_fields = (
		month	=> $numbered_fields[0],
		day	=> $numbered_fields[1],
		time	=> $numbered_fields[2],
		host	=> $numbered_fields[3],
		tag	=> $numbered_fields[4],
		message	=> $numbered_fields[5],
	);

	die "not our application"
		if 'OpaqueImportantThing:' ne $named_fields{tag};

	die "no message logged"
		if '' eq $named_fields{message};

	return %named_fields;
}

sub main {
	exit(0);
}

main() unless caller();
