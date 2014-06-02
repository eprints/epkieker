use strict;
use warnings;

package Kieker::Record::OperationEntryEvent;

=head1 NAME

Kieker::Record::OperationEntryEvent - Kieker Event to be produced at the start
of a function call.

=head1 SYNOPSIS

 my $record = Kieker::Record::OperationEntryEvent->new(
                 Kieker::Util->time(),
                 $control->getTrace(),
                 $control->getOrderIndex($control->getTrace()),
                 $functionName,$packageName);
 $writer->write($record->genoutput());

=head1 DESCRIPTION

Generates a OperationEntryEvent. This Event should be generated at the start of
each monitored function.

=head1 METHODS

=head2 $record = Kieker::Record::OperationEntryEvent->new(timestamp, trace, orderIndex, function, package);

Creates a new Record. It needs a timestamp, a trace with its corresponding
orderIndex, a function name and a package name.

=cut

sub new {
  my ($type, $timest, $traceID, $orderID, $funName, $packName) = @_;
  my $this = {
    timestamp     => $timest,
    traceID       => $traceID,
    orderIndex    => $orderID,
    functionName  => $funName,
    packageName   => $packName
  };
  
  return bless($this,$type);
}

=head2 $string = $record->genoutput();

Serializes the record for output. Returns the serialized form of the record.
Uses the identifier "1" for the event type.

=cut

sub genoutput {
  my ($self) = @_;
  return 
    "1;".$self->{timestamp}.";".$self->{traceID}.";".
    $self->{orderIndex}.";".$self->{functionName}.";".$self->{packageName};
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
