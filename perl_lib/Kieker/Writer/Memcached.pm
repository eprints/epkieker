use strict;
use warnings;

package Kieker::Writer::Memcached;

use Cache::Memcached::Fast;

=head1 NAME

Kieker::Writer::Memcached - Provides a Kieker Writer for the memcached daemon (which we must run locally)

=head1 SYNOPSIS

 use Kieker::Writer::Memcached;
 my $writer = Kieker::Writer::Memcached->instance();
                                      # Get writer instance

 $writer->write($string);             # writes string to JMS

=head1 DESCRIPTION

Writes Kieker records to memcached. A unique incremental number is assigned to
each string. 

=head1 REQUIREMENTS

Uses Cache::Memcached::Fast

=head1 METHODS

=head2 $writer = Kieker::Writer::Memcached->instance();

Returns the writer singleton instance. This object holds the handle currently 
wrinting to. If no instance exists, it is created and a connection to memcached
 is opened. Currently no configuration options are provided and the
location of the provider is static in the source. (localhost:11211)

=cut

=pod

sf2 / default connection params:

new Cache::Memcached::Fast({
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
})

=cut

my $singleton;
my $i = 0;

sub instance {

  # check Singleton
  unless (defined $singleton) {
    my ($type)  = @_;

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

    my $this    = {
      handle => $cached,
    };
    $singleton  = bless $this, $type;
  }

  return $singleton;
}

=head2 $writer->write(STRING);

Writes STRING to memcached, prefixed with "kieker-%i"

=cut

sub write {
  my ($self, $msg)  = @_;

  $self->{handle}->set( "kieker-".$i++, $msg );

}

1;
