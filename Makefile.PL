use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	      'NAME'	=> 'Apache::GzipChain',
	      'VERSION_FROM' => 'GzipChain.pm', # finds $VERSION
	      'PREREQ_PM' => {'Compress::Zlib' => 1.0,
			      'Apache::OutputChain' => 0.0 },
	      dist => {
		       PREOP => 'co -l README && pod2text GzipChain.pm > README && ci -u README',
		       SUFFIX => 'gz',
		       COMPRESS => 'gzip -9',
		      }
);

