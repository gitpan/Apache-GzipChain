
=head1 NAME

Apache::GzipChain - compress HTML in the OutputChain

=head1 SYNOPSIS

In the configuration of your apache add something like

	<Files *.html>
	SetHandler perl-script
	PerlHandler Apache::OutputChain Apache::GzipChain Apache::PassHtml
	</Files>

=head1 DESCRIPTION

This module compresses any output from another perl handler iff the
browser understands gzip encoding. To determine if the browser is able
to understand us we check the User-Agent. We do not rely on the
correct HTTP header I<Accept-Encoding>, because too few browsers send
it currently.

Instead we have set up an enquiry form at
http://www.kulturbox.de/perl/test/content-encoding-gzip where many
users can check their browsers' abilities and leave us a message. Thus
we can test a regular expression against the I<User-Agent> header.

=head1 PREREQUISITES

Compress::Zlib

=head1 AUTHOR

Andreas Koenig, koenig@kulturbox.de based on code from Jan Pazdziora,
adelton@fi.muni.cz

=cut

# ' himacs!

package Apache::GzipChain;
use Compress::Zlib 1.0;
use strict;
use vars qw(@ISA $VERSION);
$VERSION = "0.01";

use Apache::OutputChain;
@ISA = qw( Apache::OutputChain );

sub handler {
  my($r) = shift;
  my $user_agent = $r->header_in("User-Agent");
  if ($user_agent =~ m{
		       ^Mozilla/
		       .+
		       \b(
			  X11 |
			  MSIE\s4\.0 |
			  PPC,\sNav |
			  WebTV
			 )\b
		      }x
     ) {
    $r->header_out('Content-Encoding','gzip');
    Apache::OutputChain::handler($r, 'Apache::GzipChain');
  }
}

sub TIEHANDLE {
  my ($class, @opt) = @_;
  my $self = [ @opt ];
  bless $self, $class;
}

sub PRINT {
  my $self = shift;
  my $res = join "", @_;
  $self->Apache::OutputChain::PRINT(Compress::Zlib::memGzip($res));
}

1;
