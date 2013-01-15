use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'HTML::ImageToMosaic',
    PMLIBDIRS => [ 'lib' ],
    PREREQ_PM => {
        'Carp' => 0,
	'Image::Magick' => 0,
        'LWP' => 0,
        'Test::More' => 0
    },
    'test' => {
	TESTS => join(' ', map { glob } qw( t/*.t )),
    },
    VERSION_FROM => 'lib/HTML/ImageToMosaic.pm',
    AUTHOR => 'Kevin Kamel <kamelkev@mailermailer.com>',
    ABSTRACT => '',
    LICENSE => 'perl',
);

sub MY::postamble {
  return <<'MAKE_FRAG';
all :: README

README: lib/HTML/ImageToMosaic.pm
	pod2text $> > README
MAKE_FRAG
}
