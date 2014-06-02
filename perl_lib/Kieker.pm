use strict;
use warnings;

package Kieker;

#use Kieker::Writer::JMSWriter;
#use Kieker::Writer::Memcached;
use Kieker::Record::OperationEntryEvent;
use Kieker::Record::OperationExitEvent;
use Kieker::Controlling;
use Kieker::Util;

=head1 NAME

Kieker - wraps Kieker Monitoring functions

=head1 SYNOPSIS

 use Kieker;
 my $kieker = Kieker->new();          # Creates a new monitoring instance

 $kieker->EntryEvent('Foo','Bar');    # Produces a new EntryEvent

 $kieker->ExitEvent('Foo','Bar');     # Produces a new ExitEvent 

=head1 DESCRIPTION

This module encapsulates the Kieker monitoring functions in one module. Upon 
creation the controlling and writing parts are loaded and the singleton
instances are stored.
After that Events can be constructed and written to the active writer.

=head1 METHODS

=head2 $object = Kieker->new()

Creates a new Kieker object. Currently takes no parameters for configuration.
Returns the object.

=cut

sub new {
  my ($type, %options) = @_;

  my $writer_class = delete $options{"writer_class"};
  $writer_class ||= "Kieker::Writer::JMSWriter";	# default

  eval "use $writer_class;";
 
  my $writer = $writer_class->instance;

  my $control = Kieker::Controlling->instance();
  
  my $this = {
    writer => $writer,
    control => $control
  };
  
  return bless $this, $type;
}

=head2 $object->EntryEvent($functionName, $packageName);

Creates and sends out a EntryEvent for a specified functionName in a specified
package. Uses the current timestamp. Returns nothing.

=cut

sub EntryEvent {
  my ($self,$functionName,$packageName) = @_;
  my $writer        = $self->{writer};
  my $control       = $self->{control};
  
  my $record = Kieker::Record::OperationEntryEvent->new(
                 Kieker::Util->time(),
                 $control->getTrace(),
                 $control->getOrderIndex($control->getTrace()),
                 $functionName,$packageName);
  $writer->write($record->genoutput());
  return;
}

=head2 $object->ExitEvent($functionName, $packageName);

Creates and sends out a ExitEvent for a specified functionName in a specified
package. Uses the current timestamp. Returns nothing.

=cut

sub ExitEvent {
  my ($self,$functionName,$packageName) = @_;
  my $writer        = $self->{writer};
  my $control       = $self->{control};
  
  my $record = Kieker::Record::OperationExitEvent->new(
                 Kieker::Util->time(),
                 $control->getTrace(),
                 $control->getOrderIndex($control->getTrace()),
                 $functionName,$packageName);
  $writer->write($record->genoutput());
  return;
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
