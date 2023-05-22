use Path::Tiny;
use EBook::EPUB;
use Text::Markdown qw/ markdown /;

my $epub = EBook::EPUB->new;

$epub->add_title('Trans travel');
$epub->add_language('en');

my $id    = 1;
my @files = path('./us')->children(/\.md$/);
@files = sort @files;

for my $file (@files) {

    my $content = $file->slurp;

    $content =~ /^#\s*(.*)/;
    my $title = $1;

    my $html = join "\n",
      "<html><body>",
      markdown($content), "</body></html>";

    my $temp = Path::Tiny->tempfile();
    $temp->spew($html);

    my $chapter_id =
      $epub->copy_xhtml( $temp, $file->basename =~ s/.md/.html/r );

    my $navpoint = $epub->add_navpoint(
        label      => $title,
        id         => $chapter_id,
        content    => $file->basename=~ s/.md/.html/r,
        play_order => $id++,
    );

}

# Generate resulting ebook
$epub->pack_zip('./output/trans-travel.epub');
