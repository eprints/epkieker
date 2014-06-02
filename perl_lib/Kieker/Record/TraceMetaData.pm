use strict;
use warnings;

use Net::Domain qw(hostname hostfqdn hostdomain);

package Kieker::Record::TraceMetaData;

=head1 NAME

Kieker::Record::TraceMetaData - Kieker Event indicating one trace. 
Gets autocreated by Kieker::Controlling.

=head1 SYNOPSIS

 my $record = Kieker::Record::TraceMetaData->new($traceID);
 $writer->write($record->genoutput());

=head1 DESCRIPTION

Generates a TraceMetaData. This Event should be generated at the end of
each monitored function.

=head1 METHODS

=head2 $record = Kieker::Record::TraceMetaData->new(traceID);

Creates a new trace with the given trace ID. Currently there are only two 
elements of TraceMetaData from Kieker used (traceID and hostname).

=cut

sub new {
  my ($type, $traceID) = @_;
  my $this = {
    traceID	=> $traceID,
    hostname    => Net::Domain::hostname()};
  
  return bless($this,$type);
}

=head2 $string = $record->genoutput();

Serializes the record for output. Returns the serialized form of the record.
Uses the identifier "3" for the event type. 
The output format is identified by $traceID;0;0;hostname;0;0.

=cut

sub genoutput {
  my ($self) = @_;
  return "3;".$self->{traceID}.";0;0;".$self->{hostname}.";0;0";
}

=head1 BUGS

If you find any bugs please let me know via email.

=head1 COPYRIGHT and LICENCE

Copyright 2014 Christian Zirkelbach, Kiel, Germany, czi@informatik.uni-kiel.de

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
