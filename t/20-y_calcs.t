#!/usr/bin/perl

use strict;
use warnings;

use PDL;
use PDL::IO::Touchstone qw/rsnp
	s_to_y
	s_to_abcd
	abcd_to_s
	y_inductance
	y_capacitance
	y_resistance
	y_parallel
	abcd_serial
	/;
use File::Temp qw/tempfile/;

use Test::More tests => 8;

my $tolerance = 1e-6;

my $datadir = 't/test-data';

opendir(my $dir, $datadir) or die "$datadir: $!";

my @files = map { "$datadir/$_" } grep { /\.s2p$/i } readdir($dir);
closedir($dir);

#@files = grep { !/IDEAL_OPEN/ } @files;
@files = ();

# real examples:
my $S = pdl [
		[
			[0.7163927 + i() * -0.4504119, 0.2836073 + i() *  0.4504119],
			[0.2836073 + i() *  0.4504119, 0.7163927 + i() * -0.4504119]
		]
	];

my $A = pdl [
		[
			[1 + i() * -1.60515694288942e-16, 0.107065112465306 + i() * -158.985376613117],
			[0 + i() *  0                   , 1                 + i() *   -1.60515694288942e-16]
		]
	];

foreach my $fn (@files, @ARGV)
{
	my ($f, $m, $param_type, $z0, $comments, $fmt, $funit, $orig_f_unit) = rsnp($fn);

	next unless $param_type eq 'S';

	my $Y = s_to_y($m, $z0);
	my $ABCD = s_to_abcd($m, $z0);

	#$m = y_parallel($Y, $Y);
	$m = abcd_serial($ABCD, $ABCD);
	$m = abcd_to_s($m, $z0);
	$m = s_to_y($m, $z0);

	print $m;

	#print "$fn: " . (y_resistance($m, $f))->dummy(0,1)
	print "$fn: " . (y_capacitance($m, $f)*1e12)->dummy(0,1)
	#print "$fn: " . (y_inductance($m, $f)*1e9)->dummy(0,1)
	

}

