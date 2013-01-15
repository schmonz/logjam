#!/usr/bin/env perl

package logjam;

use warnings;
use strict;

sub hi_everyone {
	return "noodles";
}

sub main {
	exit(0);
}

main() unless caller();
