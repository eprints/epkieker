use strict;
use warnings;

package Kieker::Controlling;

use Kieker::Record::TraceMetaData;
use Kieker::Writer::JMSWriter;

=head1 NAME

Kieker::Controlling - Provides Controlling mechanisms to Kieker Modules

=head1 SYNOPSIS

 use Kieker::Controlling;
 my $control = Kieker::Controlling->instance();   # Get controlling instance

 my $trace = $control->getTrace();                # Get current traceID

 my $orderId = $control->getOrderIndex($trace);   # Get current orderIndex

=head1 DESCRIPTION

This module provides controlling methods for Kieker. The main functions are
providing consistent trace and orderIDs. When new traces are created the 
corresponding traceEvents are created and written.

=head1 METHODS

=head2 $control = Kieker::Controlling->instance();

Returns the singleton instance of Kieker::Controlling. If no instance is defined
a new instance is created.

=cut

my $oneTrueSelf;

sub instance {
  # check singleton
  unless (defined $oneTrueSelf) {
    my ($type) = @_;
    my $this = {};
    
    $oneTrueSelf = bless $this, $type;
  }
  return $oneTrueSelf;
}

=head2 my $orderId = $control->getOrderIndex($trace);

Returns the current orderIndex and increments the count. If this is the first 
request a new traceEvent is created and written to the log.

=cut

sub getOrderIndex {
  my ($self, $trace) = @_;
  
  if (defined ($self->{$trace})) {
    my $orderIndex = $self->{$trace} + 1;
    $self->{$trace} = $orderIndex;
    return $orderIndex;
  } else {

#    my $kieker_writer = Kieker::Writer::JMSWriter->instance();
#    my $kieker_record = Kieker::Record::TraceMetaData->new($trace);
#    $kieker_writer->write($kieker_record->genoutput());
    $self->{$trace} = 0;

    return $self->{$trace};
  }
}

=head2 my $trace = $control->getTrace();

Returns the current traceID. In this version it uses the threadID and relies on
special Apache configuration.

=cut

sub getTrace {
  return $$;
}

=head1 BUGS

The package is probably full of bugs and is likely to break on every possible
occasion. If you find any please let me know via email.

=head1 COPYRIGHT and LICENCE

Copyright 2013 Nis Börge Wechselberg, Kiel, Germany, nbw@informatik.uni-kiel.de
Modified 2014 Christian Zirkelbach, Kiel, Germany, czi@informatik.uni-kiel.de

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
