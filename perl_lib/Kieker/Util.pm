use strict;
use warnings;

package Kieker::Util;

use Time::HiRes qw(gettimeofday);

=head1 NAME

Kieker::Util - Kieker utility functions

=head1 SYNOPSIS

 use Kieker::Util;
 my $time = Kieker::Util->time();   # Get current time in (pseudo)-nanoseconds

=head1 DESCRIPTION

This module provides utility functions for other Kieker modules.

=head1 METHODS

=head2 $time = Kieker::Util->time();

Returns current time in pseudo nanoseconds. Perl doesn't provide a real
nanosecond timer but only microseconds. Output is formatted to match kieker
time format.
NO REAL NANOSECONDS, MICROSECOND PRECISION.

=cut

sub time {
  (my $s, my $usec) = gettimeofday();
  return ($s*1000000+$usec)*1000;
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
