
=head1 NAME

Apache::PassFile - print a file to STDOUT

=head1 SYNOPSIS

In the conf/access.conf file of your Apache installation add lines

	<Files *.html>
	SetHandler perl-script
	PerlHandler Apache::OutputChain Apache::GzipChain Apache::PassFile
	</Files>

=head1 DESCRIPTION

This is an efficient version of cat(1) in perl. While it innocently
prints to STDOUT it may well be the case that STDOUT has been tied.

=head1 AUTHOR

(c) 1997 Jan Pazdziora, adelton@fi.muni.cz, at Faculty of Informatics,
Masaryk University, Brno (small performance changes by Andreas Koenig)


=cut

package Apache::PassFile;
use Apache::Constants ':common';
use FileHandle;
use strict;
use vars qw($VERSION);
$VERSION = "0.01";

sub handler {
  my $r = shift;
  my $filename = $r->filename();
  my $fh;

  if (-f $filename and
      -r _ and
      $fh = FileHandle->new($filename)) {
    $r->send_http_header;
    my($buf,$read);
    local $\;

    while (){
      defined($read = sysread($fh, $buf, 16384)) or return SERVER_ERROR;
      last unless $read;
      print $buf;
    }
    $fh->close;
    return OK;
  } else {
    return NOT_FOUND; 
  }
}

1;
