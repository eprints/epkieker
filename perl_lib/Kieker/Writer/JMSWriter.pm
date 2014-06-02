use strict;
use warnings;

package Kieker::Writer::JMSWriter;

use Net::Stomp;

=head1 NAME

Kieker::Writer::JMSWriter - Provides a Kieker Writer for JMS output.

=head1 SYNOPSIS

 use Kieker::Writer::JMSWriter;
 my $writer = Kieker::Writer::JMSWriter->instance();
                                      # Get writer instance

 $writer->write($string);             # writes string to JMS

=head1 DESCRIPTION

Writes Kieker records to a JMS provider. Can also be used to write other 
strings.

=head1 REQUIREMENTS

Uses Net::Stomp for the JMS connection.

=head1 METHODS

=head2 $writer = Kieker::Writer::JMSWriter->instance();

Returns the writer singleton instance. Thsi object holds the handle currently 
wrinting to. If no instance exists, it is created and a connection to the JMS
provider is opened. Currently no configuration options are provided and the
location of the provider is static in the source. (localhost:61613)

=cut

my $singleton;

my $hostname = 'localhost';
my $port = '61613';
my $destination = '/queue/kieker.tools.bridge';

my $username = 'hello';
my $password = 'there';

sub instance {
  # check Singleton
  unless (defined $singleton) {
    my ($type)  = @_;

    my $stomp   = Net::Stomp->new( { hostname => $hostname, port => $port } );
    $stomp->connect( { login => $username, passcode => $password } );
    
    my $this    = {
      handle => $stomp
    };
    $singleton  = bless $this, $type;
  }

  return $singleton;
}

=head2 $writer->write(STRING);

Writes STRING to JMS.

=cut

sub write {
  my ($self, $msg)  = @_;
  my $handle        = $self->{handle};
  
  $handle->send(
      { destination => $destination, body => $msg } );
}

=head1 BUGS

The package is probably full of bugs and is likely to break on every possible
occasion. If you find any please let me know via email.

=head1 COPYRIGHT and LICENCE

Copyright 2013 Nis Börge Wechselberg, Kiel, Germany, nbw@informatik.uni-kiel.de

The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the 
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=cut

1;
