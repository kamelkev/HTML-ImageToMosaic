use strict;
use warnings;
use lib qw( ./lib ../lib );

use Test::More;
use Cwd;
use HTML::ImageToMosaic;

use FindBin qw($Bin);

plan(tests => 3);

my $html_path = "$Bin/html/";
my $result_file = $html_path . 'remote_result.html';

use_ok('HTML::ImageToMosaic');
use_ok('LWP::UserAgent');

# Create a user agent object, create the request and get the response
my $ua = LWP::UserAgent->new;
my $uri = 'http://upload.wikimedia.org/wikipedia/en/2/24/Lenna.png';
my $req = HTTP::Request->new('GET',$uri);
my $res = $ua->request($req);

# if not successful
if (!$res->is_success()) {
  die 'There was an error in fetching the document for '.$uri.' : '.$res->message;
}

my $mosaic = new HTML::ImageToMosaic({ image => $res->content });

my $result = $mosaic->generate({ pixel_size => 64 });

open( my $fh, $result_file ) or die "can't open $result_file: $!!\n";
my $correct_result = do { local( $/ ) ; <$fh> } ;

ok($result eq $correct_result, 'result was correct');
