#! /usr/bin/env perl

use strict;
use warnings;
use v5.10;
use Data::Dumper;
use HTTP::Tiny;
use File::Slurp;
use Storable qw(lock_store lock_nstore lock_retrieve);

## conf
my $url = 'https://dl.google.com/dl/edgedl/chromeos/recovery/recovery.conf';
my $model = qr/C201PA/;
my $file = '/tmp/recovery.conf';
my $stored_file = $file.".stored";
##

my $res = HTTP::Tiny->new->mirror($url,$file) or die $!;
die "error ".$res->{status}." ".$res->{reason} unless ($res->{success});

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


exit if ($data{version} eq $rdata->{version});

lock_nstore \%data, $stored_file;

say "*** OLD ***";
say Dumper($rdata);
say "*** NEW ***";
say Dumper(\%data);
say join("\n",@data);
