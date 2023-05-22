use 5.36.0;

use Test2::V0;

use Archive::Zip;
use Archive::Zip::MemberRead;

sub read_file ( $zip, $file ) {
    my $content = '';
    my $fh      = Archive::Zip::MemberRead->new( $zip, $file );

    $content .= $_ while ( defined( $_ = $fh->getline() ) );

    $fh->close;

    return $content;
}

my $zip = Archive::Zip->new;
$zip->read('./output/trans-travel.epub');

ok grep( { $_ eq "OPS/notes/tsa.html" } $zip->memberNames ),
  "we have tsa notes";

ok grep( { m!../notes/tsa.html! } read_file( $zip, 'OPS/us/ak.html' ) ),
  "urls are linked to the html files";

done_testing;

