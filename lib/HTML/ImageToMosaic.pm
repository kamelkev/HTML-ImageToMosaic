# Copyright 2013 MailerMailer, LLC - http://www.mailermailer.com

package HTML::ImageToMosaic;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = '.01';

use Carp;

use Image::Magick;
use LWP::UserAgent;

=pod

=head1 NAME

HTML::ImageToMosaic - Library for converting an image reference to an HTML table based mosaic

=head1 SYNOPSIS

use HTML::ImageToMosaic;

open IMAGE, 'image.png' or croak $!;

my $mosaic = new HTML::ImageToMosaic({ image => $image });

print $mosaic->generate();

=head1 DESCRIPTION

Library for converting an image reference to an HTML table based mosaic.

=cut

BEGIN {
  my $members = [ 'image' ];

  #generate all the getter/setter we need
  foreach my $member (@{$members}) {
    no strict 'refs';

    *{'_' . $member} = sub {
      my ($self,$value) = @_;

      $self->_check_object();

      $self->{$member} = $value if defined($value);

      return $self->{$member};
    }
  }
}

=pod

=head1 CONSTRUCTOR

=over 1

=item new

Instantiates the Mosaic object. Sets up class variables that are used
during file parsing/processing. Possible options are:

Input Parameters:
  image - Pass in a scalar blob representing the image (optional)

=back

=cut

sub new {
  my ($proto, $params) = @_;

  my $class = ref($proto) || $proto;

  my $self = {
    image => $$params{image}
  };

  bless $self, $class;
  return $self;
}

=head1 METHODS

=cut

=pod

=over 1

=item generate

Processes the image data specified either through the constructor or setter.

Input Parameters:

 pixel_size - size of the "pixel" you want in the final rendering (optional)
 mode - technique to use to generate a mosaic, can be either "resize" or the default "scale" (optional)
 filter - resize mode allows a variety of filters to be used including:
          Point, Box, Triangle, Hermite, Hanning, Hamming, Blackman, Gaussian, Quadratic, 
          Cubic, Catrom, Mitchell, Lanczos, Bessel, Sinc

=cut

sub generate {
  my ($self,$params) = @_;

  $self->_check_object();

  my $image = Image::Magick->new();

  if ($image->BlobToImage($self->{image}) == 0) {
    croak "The image appears to be corrupted or of an unrecognized type";
  }

  my ($width,$height) = $image->Get('width', 'height');

  # set up conversion parameters
  my $pixel_size = $$params{pixel_size} || 10;
  my $scale = 100 / $pixel_size;

  # shrink the image down using mode, then embiggen it, creates pixels of requested size
  if ($$params{mode} && $$params{mode} =~ m/resize/i) {
    my $filter = $$params{filter} // 'box';

    $image->Resize(geometry => $scale . '%', filter => $filter);
    $image->Resize(width => $width, height => $height);
  }
  else {
    $image->Scale($scale . '%');
    $image->Scale(width => $width, height => $height);
  }

  # set quantum depth to 8 for proper color representation
  $image->Set(depth=>8);

  my $table = ''; # placeholder for table mosaic data
  my ($prev_color,$span);
 
  $table .= "<table width=\"$width\" height=\"$height\" cellpadding=\"0\" border=\"0\" cellspacing=\"0\" style=\"line-height:0\">\n";
  for (my $row = 1; $row < $height; $row+=$pixel_size) {
    $prev_color = '';
    $span = 0;

    $table .= "<tr>\n";
    for (my $col = 1; $col < $width; $col+=$pixel_size) {
      my $first = ($row == 1 && $col == 1) ? 1 : 0;
      my $last_col = ($col + $pixel_size >= $width) ? 1 : 0;
  
      my ($r,$g,$b) = $image->GetPixels(x => $col, y => $row, type => 0, map => "RGB" );

      # calculate pixel color
      my $color = '#' . sprintf('%02x', $r % 256) . sprintf('%02x', $g % 256) . sprintf('%02x', $b % 256);

      if ($row == 1) { # https://bugzilla.mozilla.org/show_bug.cgi?id=293052
        $table .= "<td width=\"$pixel_size\" height=\"$pixel_size\" bgcolor=\"$color\"></td>\n";
      }
      elsif ($prev_color && $color ne $prev_color) {
        $table .= "<td width=\"$pixel_size\" height=\"$pixel_size\" bgcolor=\"$prev_color\" colspan=\"$span\"></td>\n";
        $span = 1;
      }
      else {
        $span++;
      }

      if ($last_col && $row != 1) {
        $table .= "<td width=\"$pixel_size\" height=\"$pixel_size\" bgcolor=\"$color\" colspan=\"$span\"></td>\n";
      }

      $prev_color = $color;
    }
    $table .= "</tr>\n";
  }
  $table .= '</table>';

  return $table;
}

####################################################################
#                                                                  #
# The following are all private methods and are not for normal use #
#                                                                  #
####################################################################

sub _check_object {
  my ($self, $params) = @_;

  unless (ref $self) {
   croak "You must instantiate this class in order to properly use it";
  }

  return ();
}
