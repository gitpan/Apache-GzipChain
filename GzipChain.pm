package Apache::GzipChain;
use Compress::Zlib 1.0;
use strict;
use vars qw(@ISA $VERSION);
$VERSION = "0.06";

use Apache::OutputChain;
@ISA = qw( Apache::OutputChain );

sub handler {
  my($r) = shift;
  my($can_gzip);
  my @vary = $r->header_out('Vary') if $r->header_out('Vary');
  push @vary, "Accept-Encoding", "User-Agent";
  $r->header_out('Vary',
		 join ", ",
		 @vary
		);
  my($accept_encoding) = $r->header_in("Accept-Encoding");
  $can_gzip = 1 if index($accept_encoding,"gzip")>=0;
  unless ($can_gzip) {
    my $user_agent = $r->header_in("User-Agent");
    if ($user_agent =~ m{
			 ^Mozilla/
			 \d+
			 \.
			 \d+
			 [\s\[\]\w\-]+
			 (
			  \(X11 |
			  Macint.+PPC,\sNav
			 )
			}x
       ) {
      $can_gzip = 1;
    }
  }
  if ($can_gzip) {
    $r->header_out('Content-Encoding','gzip');
    Apache::OutputChain::handler($r, 'Apache::GzipChain');
  }
}

sub PRINT {
  my $self = shift;
  my $res = join "", @_;
  return unless length($res);
  $self->Apache::OutputChain::PRINT(Compress::Zlib::memGzip($res));
}

1;

__END__


=head1 NAME

Apache::GzipChain - compress HTML (or anything) in the OutputChain

=head1 SYNOPSIS

In the configuration of your apache add something like

    <Files *.html>
    SetHandler perl-script
    PerlHandler Apache::OutputChain Apache::GzipChain Apache::PassFile
    </Files>

=head1 STATUS

B<This module is alpha software. Occasional SEGV have been observed.
Use with caution!>

You currently cannot mix perl's own C<print> statements that print to
STDOUT and the C<print> or C<write_client> methods in Apache.pm. If
you do that, you will very likely encounter empty documents and
probably core dumps too.

=head1 DESCRIPTION

This module compresses any output from another perl handler if and
only if the browser understands gzip encoding. To determine if the
browser is able to understand us we check both its I<Accept-Encoding>
header and its I<User-Agent> header. We check the latter because too
few browsers send the I<Accept-Encoding> header currently. Instead I
have set up an enquiry form at
http://www.kulturbox.de/perl/test/content-encoding-gzip where many
users already have checked their browsers' abilities and left a
message. Thus we can test a regular expression against the
I<User-Agent> header.

The module seems to work without influencing the other handlers. The
only thing that can be noticed by the other handler is that the
response header 'Content-Encoding' has been set. If GzipChain decides
not to do any compression, it just declines and doesn't even register
itself for the output chain.

GzipChain compresses every single buffer content it receives via the
output chain separately according to the GZIP specification (RFC
1952). The compression ratio therefore suffers if the other module
sends its data in very small chunks. It is recommended that you use as
few print statements as possible in conjunction with the GzipChain.
The Apache::PassFile module is an example of an efficient file reader
for this purpose.

=head1 PREREQUISITES

Compress::Zlib, Apache::OutputChain

=head1 AUTHOR

Andreas Koenig, koenig@kulturbox.de based on code by Jan Pazdziora,
adelton@fi.muni.cz

=cut

