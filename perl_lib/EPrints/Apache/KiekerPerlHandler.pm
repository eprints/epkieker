package EPrints::Apache::KiekerPerlHandler;

use strict;
use warnings;

use EPrints::Apache::Rewrite;

my $KIEKER_WRITE = "Kieker::Writer::Memcached";

my $MONIT_URI = "/";

my $MONIT_IP = "123.45.6.78";

my $MONIT_PACKAGES = "EPrints EPrints::*";

sub handler
{
	my( $r, $real_handler ) = @_;

	$real_handler ||= \&EPrints::Apache::Rewrite::handler;

	if( defined $MONIT_IP )
	{
		my $ip = real_client_ip( $r );
		if( $ip ne $MONIT_IP )
		{
			return &$real_handler( $r );
		}
	}

	if( defined $MONIT_URI )
	{
		if( $r->uri ne $MONIT_URI )
		{
			return &$real_handler( $r );
		}
	}

	if( init_kieker() )
	{
		printf STDERR "Kieker monitoring enabled on URL %s\n", $r->uri;
	}

	# wrapping the call within a monitoring fake call:

	my %kieker_options = ( 
		writer_class => $KIEKER_WRITE,
	);
	
	use Kieker;
	my $instrumentationFunction = "monitoring";
	my $instrumentationPackage = "Kieker";
	my $kieker = Kieker->new( %kieker_options );
	$kieker->EntryEvent($instrumentationFunction,$instrumentationPackage);
	
	my $rc = &$real_handler( $r );

	$kieker->ExitEvent($instrumentationFunction,$instrumentationPackage);

	return $rc;
}

sub real_client_ip
{
	my( $r ) = @_;

	my $ip = $r->headers_in->{"X-Forwarded-For"} || $r->connection->remote_ip;

	return $ip;
}

sub init_kieker
{

	eval "no warnings; no strict;

	my %kieker_options = ( 
		writer_class => $KIEKER_WRITE,
	);
	use Kieker::WrapEPrints
		packages => [qw($MONIT_PACKAGES)],
	".'
		pre => sub { 
			use Kieker;
			my $kieker = Kieker->new( %kieker_options ); # Creates a new monitoring instance

			my $pkg = $_[0];
			my $ptr = "";

			if( defined $_[1] && ref( $_[1] ) ne "EPrints::URL" && ref( $_[1] ) ne "" )
			{
				$ptr = "$_[1]";
			}

			$kieker->EntryEvent( $pkg, $ptr );

		},  
		post => sub {
			use Kieker;
			my $kieker = Kieker->new( %kieker_options ); # Uses the corresponding monitoring instance
			
			$kieker->ExitEvent( $_[0], "" );
		};  
	';
	
	if( $@ )
	{
		print STDERR "Kieker handler failed: $@\n";
		return 0;
	}

	return 1;
}

1;

