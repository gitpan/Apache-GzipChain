package Apache::GzipChain;
use Compress::Zlib 1.0;
use strict;
use vars qw(@ISA $VERSION);
$VERSION = sprintf "%d.%02d", q$Revision: 1.13 $ =~ /(\d+).(\d+)/;

use Apache::OutputChain;
@ISA = qw( Apache::OutputChain );

sub handler {
  my($r) = shift;
  my($can_gzip);
  if ($r->dir_config('GzipForce')) {
    $can_gzip = 1;
  } else {
    my @vary;
    @vary = $r->header_out('Vary') if $r->header_out('Vary');
    push @vary, "Accept-Encoding";
    $r->header_out('Vary',
		   join ", ",
		   @vary
		  );
    my($accept_encoding) = $r->header_in("Accept-Encoding") || "";
    $can_gzip = 1 if index($accept_encoding,"gzip")>=0;
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
  if ($] > 5.007) {
    require Encode;
    $res = Encode::encode_utf8($res); # noop if $res doesn't have the UTF-8 flag set
  }
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
    PerlHandler Apache::OutputChain Apache::GzipChain __your_handler__
    PerlSetVar GzipForce on  # optional
    </Files>

=head1 DESCRIPTION

This module compresses any output from another perl handler if the
browser requesting the document understands gzip encoding or if the
config variable ForceGzip is set. To determine if the browser is able
to understand us we check its I<Accept-Encoding> header.

The module works without influencing the other handlers in the chain.
The only thing that can be noticed by other handlers is that the
response header 'Content-Encoding' has been set. If GzipChain decides
not to do any compression, it just declines and doesn't even register
itself for the output chain.

GzipChain compresses every single buffer content it receives via the
output chain separately according to the GZIP specification (RFC
1952). The compression ratio therefore suffers if the other module
sends its data in very small chunks. It is recommended that you use as
few print statements as possible in conjunction with the GzipChain.
One single print statement is recommended.

=head1 HEADERS

This handler sets the header C<Content-Encoding> to C<gzip> whenever
it sends gzipped data.

It also sets or appends to the C<Vary> header the values
C<Accept-Encoding> unless the config variable GzipForce is set, in
which case the output is the same for all user agents.

=head1 Unicode

Using this module under perl-5.8 or higher is ok for Unicode data.
UTF-8 data passed to Compress::Zlib::memGzip() are converted to raw
UTF-8 before compression takes place. Other data are simply passed
through.

=head1 PREREQUISITES

Compress::Zlib, Apache::OutputChain

=head1 AUTHOR

Andreas Koenig, koenig@kulturbox.de based on code by Jan Pazdziora,
adelton@fi.muni.cz

=cut
