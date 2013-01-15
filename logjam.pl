#!/usr/bin/env perl

BEGIN { require 'code_depends.pl' if -x 'code_depends.pl' }

package logjam;

use warnings;
use strict;

use DBI;

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

sub connect_to_database {
	my ($database) = @_;

	die "no file specified" unless defined $database;
	return DBI->connect("dbi:SQLite:dbname=$database");
}

sub initialize_table {
	my ($dbh) = @_;

	die "no handle specified" unless defined $dbh;

	$dbh->do(
		'CREATE TABLE logs (
			month		VARCHAR NOT NULL,
			day		VARCHAR NOT NULL,
			time		VARCHAR NOT NULL,
			host		VARCHAR NOT NULL,
			tag		VARCHAR NOT NULL,
			message		VARCHAR NOT NULL
		);',
	);
}

sub store_log_line {
	my ($dbh, $parsed_log_line) = @_;

	die "no line specified" unless $parsed_log_line;
	die "no parsed line specified" unless 'HASH' eq ref($parsed_log_line);

	my $statement = 'INSERT INTO logs ('
		. join(',', keys %$parsed_log_line)
		. ') VALUES ('
		. join(',', map('?', keys %$parsed_log_line))
		. ')';
	my $sth = $dbh->prepare($statement);
	$sth->execute(map { $parsed_log_line->{$_} } keys %$parsed_log_line);
}

sub main {
	exit(0);
}

main() unless caller();
