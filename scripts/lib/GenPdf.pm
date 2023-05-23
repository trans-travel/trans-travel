use 5.36.0;

package GenPdf;

use Path::Tiny;
use Text::Markdown qw/ markdown /;

sub generate {

    my $template = path('./pdf/template.html')->slurp;

    my @states = path('./us')->children(qr/\.md$/);
    @states = sort @states;
    my @files = ( @states, path('./notes')->children(qr/\.md$/) );
    unshift @files, path('./README.md');

    my $book;
    my @toc;
    my $toc_id = 1;

    for my $file (@files) {
        my $content = $file->slurp;

        $content =~ /^#\s*(.*)/;
        my $title = $1;

        $content =~ s!^# (.*)!
            my $id = 'toc-' . $toc_id++ ;
            push @toc, [ $1, $id];
            qq{<h1 id="$id">$1</h1>} !gem;

            $book .= '<section>'.convert_markdown($content).'</section>';
    }

    my $toc = genToc(@toc);

    $template =~ s/^.*CONTENT.*$/ $toc $book /m;

    print $template;
}

sub convert_markdown ($md) {
    $md =~ s!(\(\..*?)\.md\)!$1.html)!g;

    return markdown($md);
}

sub genToc(@entries) {
    return join "\n", '<section class="table-of-contents" id="contents">',
      '<h1>Table Of Contents</h1>',
      '<nav id="toc">',
      (map {
              "<li><a href='#".$_->[1]."'>".$_->[0]."</a></li>"
          } @entries),
      '</nav></section>';
}
1;
