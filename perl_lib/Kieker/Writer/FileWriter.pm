use strict;
use warnings;

package Kieker::Writer::FileWriter;

=head1 NAME

Kieker::Writer::FileWriter - Provides a Kieker Writer for file output.

=head1 SYNOPSIS

 use Kieker::Writer::FileWriter;
 my $writer = Kieker::Writer::FileWriter->instance();
                                      # Get writer instance

 $writer->write($string);             # writes string to the current file

=head1 DESCRIPTION

Writes Kieker records to a Logfile. Can also be used to write other strings to
log files.

=head1 METHODS

=head2 $writer = Kieker::Writer::FileWriter->instance();

Returns the writer singleton instance. Thsi object holds the filehandle 
currently wrinting to. If no instance exists, it is created and a new logfile
is created using the current time for the filename.

=cut

my $oneTrueSelf;

sub instance {
  # check singleton
  unless (defined $oneTrueSelf) {
    my ($type) = @_;

    # generate filename from time
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    my $filename = 'kieker_monitoring_output_'.($year+1900).'-'.sprintf("%02d", ($mon+1)).'-'.$mday.'_'.$hour.':'.$min.':'.$sec.'.log';
    # open filehandle
    open(my $filehandle, "> $filename") || die ("can't open output file: $!");

    my $this = {
      file => $filehandle
    };
    $oneTrueSelf = bless $this, $type;
  }

  return $oneTrueSelf;
}

=head2 $writer->write(STRING);

Writes STRING to the filehandle.

=cut

sub write {
  my ($self, $string) = @_;
  my $handle = $self->{file};
  my $old_fh = select($handle);
  $| = 1;
  select($old_fh);
  print $handle $string;
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
