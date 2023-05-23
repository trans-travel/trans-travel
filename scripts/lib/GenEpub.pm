use 5.36.0;

package GenEpub;

use Path::Tiny;
use EBook::EPUB;
use Text::Markdown qw/ markdown /;

sub generate {

    my $epub = EBook::EPUB->new;

    $epub->add_title('Trans travel');
    $epub->add_language('en');

    my $id     = 1;
    my @states = path('./us')->children(qr/\.md$/);
    @states = sort @states;
    my @files = ( @states, path('./notes')->children(qr/\.md$/) );
    unshift @files, path('./README.md');

    for my $file (@files) {
        my $content = $file->slurp;

        $content =~ /^#\s*(.*)/;
        my $title = $1;

        my $html = join "\n",
          "<html><body>",
          convert_markdown($content), "</body></html>";

        my $temp = Path::Tiny->tempfile();
        $temp->spew($html);

        my $chapter_id =
          $epub->copy_xhtml( $temp, $file->relative('.') =~ s/.md/.html/r );

        my $navpoint = $epub->add_navpoint(
            label      => $title,
            id         => $chapter_id,
            content    => $file->relative('.') =~ s/.md/.html/r,
            play_order => $id++,
        );

    }

    # Generate resulting ebook
    $epub->pack_zip('./output/trans-travel.epub');
}

sub convert_markdown ($md) {
    $md =~ s!(\(\..*?)\.md\)!$1.html)!g;

    return markdown($md);
}

1;
