use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	      'NAME'	=> 'Apache::GzipChain',
	      'VERSION_FROM' => 'GzipChain.pm', # finds $VERSION
              depend => { Makefile => '$(VERSION_FROM)' },
	      'PREREQ_PM' => {'Compress::Zlib' => 1.0,
			      'Apache::OutputChain' => 0.04 },
	      dist => {
                       DIST_DEFAULT => 'README all tardist',
                       COMPRESS => 'gzip -9f'
		       # PREOP => 'co -l README && pod2text GzipChain.pm > README && ci -u README',
		      }
);

sub MY::postamble {
  q{
README: GzipChain.pm Makefile
	chmod +w $@
	pod2text GzipChain.pm > $@

}
}
