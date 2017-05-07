#! /usr/bin/env perl

use strict;
use warnings;
use v5.10;
use Data::Dumper;
use LWP::Simple;
use File::Slurp;
use Storable qw(lock_store lock_nstore lock_retrieve);

## conf
my $url = 'https://dl.google.com/dl/edgedl/chromeos/recovery/recovery.conf';
my $model = qr/C201PA/;
my $file = '/tmp/recovery.conf';
my $stored_file = $file.".stored";
##

my $code = mirror($url,$file) or die $!;
die "erreur $code ".status_message($code) if ($code ne 200 and $code ne 304);
#say "$code ".status_message($code);

my @content = read_file($file) or die $!;
my @data;

for (@content){
	#print if /$model/ .. /^$/;
	chomp;
	push @data,$_ if /$model/ .. /^$/;
}

my %data = map { split( "=", $_, 2)} @data;


my $rdata={};
$rdata = lock_retrieve  $stored_file if (-r $stored_file);

lock_nstore \%data, $stored_file;

exit if ($data{version} eq $rdata->{version});

say "*** OLD ***";
say Dumper($rdata);
say "*** NEW ***";
say Dumper(\%data);
say join("\n",@data);
