package Data::Convert::MicrochipTechnology::Float;
use strict;

BEGIN {
    use vars qw($VERSION);
    $VERSION     = '0.01';
}

=head1 NAME

Data::Convert::MicrochipTechnology::Float - Converts Microchip Technology 32 bit float to a number

=head1 SYNOPSIS

  use Data::Convert::MicrochipTechnology::Float;
  my $object = Data::Convert::MicrochipTechnology::Float->new();
  my $float=$obj->convert("\0\0\0\0");
  print "$float\n";

=head1 DESCRIPTION

The format of the PIC 32-bit float is eeeeeeee smmmmmmm mmmmmmmm mmmmmmmm

  The number has value v: v = s × 2e × m
  s = +1 (positive numbers) when the sign bit is 0
  s = -1 (negative numbers) when the sign bit is 1
  e = Exp - 127 (the exponent is biased with 127)
  m = 1.fraction in binary (that is, the significand is the binary number 1 followed by the radix point followed by the binary bits of the fraction). Therefore, 1 = m < 2.

=head1 USAGE

=head1 CONSTRUCTOR

=head2 new

  my $object = Data::Convert::MicrochipTechnology::Float->new();

=cut

sub new {
  my $this = shift();
  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;
  #$self->initialize(@_);
  return $self;
}

=head1 METHODS

=head2 convert

  my $float=$obj->convert("\0\0\0\0");
  my @list=$obj->convert("\0\0\0\0", "\0\0\0\0");

=cut

sub convert {
  my $self=shift();
  if (1 == scalar(@_)) {
    return $self->float_from_string(shift());
  } else {
    my @list=map {$self->float_from_string($_)} @_;
    return wantarray ? @list : \@list;
  }
}

=head2 float_from_string

  my $float=$obj->float_from_array("\0\0\0\0");

=cut

sub float_from_string {
  my $self=shift();
  my $string=shift();
  return $self->float_from_array(unpack("CCCC", $string));
}

=head2 float_from_array

  my $float=$obj->float_from_array("\0", "\0", "\0", "\0");

=cut

sub float_from_array {
  my $self=shift();
  my ($b0, $b1, $b2, $b3)=@_;
  my $s = $b1 & 128 ? -1 : 1;
  my $e = $b0 - 127;
  my $m = 1 + ((($b1 & 127) * 256 + $b2) * 256 + $b3) / (2 ** 23);
  my $v = $s * 2 ** $e * $m;
  $v = 0 if (0==$b0 and (0==$b1 or 128==$b1) and 0==$b2 and 0==$b3); #eliminates the round off error
  return $v;
}

=head1 BUGS

The math introduces floating point rounding errors.

=head1 TODO

Add a strict bit vector capability to eliminate any rounding errors.

=head1 SUPPORT

=head1 AUTHOR

    Michael R. Davis
    CPAN ID: MRDVT
    DavisNetworks.com
    account=>perl,tld=>com,domain=>michaelrdavis
    http://www.davisnetworks.com/

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

L<Bit::Vector>

=cut

1;
