use 5.36.0;

use Path::Tiny;

say "* [Intro](.)";

say "* USA States";

for my $file ( sort( path('us/')->children(qr/\.md$/) ) ) {
    my $title = extract_title( $file->slurp );
    $title =~ s/USA -//;
    say "  - [$title](./$file)";
}

say "* Notes";

for my $file ( sort( path('notes/')->children(qr/\.md$/) ) ) {
    my $title = extract_title( $file->slurp );
    say "  - [$title](./$file)";
}
sub extract_title($md) {
    $md =~ /^# (.*)/m;
    return $1;
}
