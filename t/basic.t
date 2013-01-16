use strict;
use warnings;
use lib qw( ./lib ../lib );

use Test::More;
use Cwd;
use HTML::ImageToMosaic;

use FindBin qw($Bin);

plan(tests => 3);

my $image_path = "$Bin/images/";
my $image_file = $image_path . 'Lenna.jpg';

my $html_path = "$Bin/html/";
my $result_file = $html_path . 'basic_result.html';

use_ok('HTML::ImageToMosaic');
use_ok('LWP::UserAgent');

open IMAGE, '<', $image_file;
local $/;
my $image = <IMAGE>;

my $mosaic = new HTML::ImageToMosaic({ image => $image });

my $result = $mosaic->generate({ pixel_size => 16, filter => 'Box' });

open( my $fh, $result_file ) or die "can't open $result_file: $!!\n";
my $correct_result = do { local( $/ ) ; <$fh> } ;

ok($result eq $correct_result, 'result was correct');
