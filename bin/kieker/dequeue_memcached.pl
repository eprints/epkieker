#!/usr/bin/perl -w 

use strict;
use Cache::Memcached::Fast;
use Sys::Hostname;

use POSIX qw( strftime );
use Time::HiRes qw(gettimeofday);

my $cached = new Cache::Memcached::Fast({
              servers => [
                           'localhost:11211',
                ],
              namespace => 'my:',
              connect_timeout => 0.2,
              io_timeout => 0.5,
              close_on_error => 1,
              compress_threshold => 100_000,
              compress_ratio => 0.9,
              compress_methods => [ \&IO::Compress::Gzip::gzip,
                                    \&IO::Uncompress::Gunzip::gunzip ],
              max_failures => 3,
              failure_timeout => 2,
              ketama_points => 150,
              nowait => 1,
              hash_namespace => 1,
              serialize_methods => [ \&Storable::freeze, \&Storable::thaw ],
              utf8 => ($^V ge v5.8.1 ? 1 : 0),
              max_size => 512 * 1024,
          });


# kieker-20140501-142512041-UTC-000-Thread-2.dat
my $kieker_fn = "kieker".strftime( '%Y-%m-%dT%H:%M:%SZ', gmtime(@_ ? $_[0] : time())).".dat";
my $obj_fn = "objects".strftime( '%Y-%m-%dT%H:%M:%SZ', gmtime(@_ ? $_[0] : time())).".out";

open KDATA, "+>./$kieker_fn" or die( "failed to open $kieker_fn for output" );
open OBJDATA, "+>./$obj_fn" or die( "failed to open $obj_fn for output" );

binmode( KDATA, ":utf8" );
binmode( OBJDATA, ":utf8" );

my $i = 0;

my $hostname = hostname();

my $init_done = 0;
my $prev_tm = undef;
my $init_pkg = undef;
my $init_stack = 0;	# keep a track of starting init_pkg

my $processed = 0;

my $check_init_pkg = 0;

my @delayed_writes;

my %OBJECTS;

while( defined ( my $data = $cached->get( "kieker-".$i++ ) ) )
{
	if( $check_init_pkg )
	{
		print STDERR "UNCONSISTENCY DETECTED for $init_pkg ($processed)?\n";
		$check_init_pkg = 0;
	}

	my( $type, $timestamp, $conn_id, $rec_id, $pkg, $ptr ) = split( /;/, $data );

	# kieker format:
	$pkg =~ s/::/\./g;		# EPrints.Repository.config
	$pkg =~ /^(.*)\..*?$/;	
	my $class = $1 || $pkg;			# EPrints.Repository

	$type = '$2' if $type eq '1';
	$type = '$3' if $type eq '2';

	if( defined $ptr && length $ptr )
	{
		$OBJECTS{$ptr}++;
	}

	if( !$init_done )
	{
		# keep track of the starting point - consistency check
		$init_pkg = $pkg;

		# writes Kieker 1.9 metadata to the log file:
		print KDATA "\$0;".($timestamp-100_000).";1.9;KIEKER;$hostname;1;false;0;NANOSECONDS;1\n";

		print KDATA "\$1;".($timestamp-100_000).";$conn_id;0;0;$hostname;0;0\n";

		$init_done = 1;
	}

	if( defined $init_pkg && $init_pkg eq $pkg && $processed > 0 )
	{
		if( $type eq '$2' )
		{
			# init_pkg called again?
			$init_stack++;

			print STDERR "Inc init stack ($processed)\n";
		}
		elsif( $type eq '$3' )
		{
			# init_pkg returned...
			# which is OK if init_stack > 0 or if it's the last statement
			if( $init_stack > 0 )
			{
				$init_stack--;
				print STDERR "Dec init stack ($processed)\n";
			}
			else
			{
				# we cannot know if it's an error until the next call to memcached->get
				$check_init_pkg = 1;
				push @delayed_writes, [$type, $timestamp, $timestamp, $conn_id, 0, $pkg, $class];
				next;
			}
		}

	}
	
	# $3;1399489107356112000;1399489107356112000;19927;16;EPrints.Repository.config;EPrints.Repository
	print KDATA join( ";", $type, $timestamp, $timestamp, $conn_id, $processed++, $pkg, $class )."\n";
}


foreach my $dw ( reverse @delayed_writes )
{
	print STDERR "delayed write\n";

	# fixes the incremental counter:
	$dw->[4] = $processed++;
	
	print KDATA join( ";", @$dw )."\n"; 
}

$cached->flush_all if( defined $ARGV[0] && $ARGV[0] eq '--flush' );

print STDERR "Processed $processed records\n";

my %COUNTS;
my %CALLS;
foreach my $ref ( keys %OBJECTS )
{
	next if( $ref !~ /=HASH/ );
	my $calls = $OBJECTS{$ref};
	$ref =~ s/=HASH.*$//g;
	$COUNTS{$ref}++;
	$CALLS{$ref} += $calls;
}

print OBJDATA join( ";", "Object type", "Objects used", "Calls" )."\n";

foreach my $ref ( sort keys %COUNTS )
{
	print OBJDATA join( ";", $ref, $COUNTS{$ref}, $CALLS{$ref} )."\n";
}


close( KDATA );
close( OBJDATA );

# Finaly the required "kieker.map" file
open MAP, "+>./kieker.map" or die( "failed to open 'kieker.map' for output" );

print MAP <<MAP;
\$0=kieker.common.record.misc.KiekerMetadataRecord
\$1=kieker.common.record.flow.trace.TraceMetadata
\$2=kieker.common.record.flow.trace.operation.BeforeOperationEvent
\$3=kieker.common.record.flow.trace.operation.AfterOperationEvent
MAP

close( MAP );


