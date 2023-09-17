use 5.36.0;

package GenPdf;

use DateTime;
use Path::Tiny;
use Text::Markdown qw/ markdown /;

my %fake_countries = (
    "us" => "USA",
    "ca" => "Canada",
);
my %fake_levels = (
    %fake_countries,
    "notes" => "Notes",
    "jurisdictions" => "Jurisdictions",
);

sub generate {

    my $template = path('./pdf/template.html')->slurp;

    my @subdivisions;
    for my $country (keys %fake_countries) {
        push @subdivisions, path("./$country")->children(qr/\.md$/);
    }

    my @countries = path('.')->children(qr/^..\.md$/);
    my @locations = sort { parsed($a)->[0] cmp parsed($b)->[0] } (@subdivisions, keys(%fake_countries), @countries);
    my @notes = path('./notes')->children(qr/\.md$/);
    my @files = ( "jurisdictions", @locations, "notes", @notes );
    unshift @files, path('./contributors.md');
    unshift @files, path('./README.md');
    push @files, path('./changes.md');

    my %level;
    for my $country (@countries) {
        $level{$country} = 2;
    }
    for my $state (@subdivisions) {
        $level{$state} = 3;
    }
    for my $note (@notes) {
        $level{$note} = 2;
    }
    for my $fake (keys %fake_levels) {
        if (exists $fake_countries{$fake}) {
            $level{$fake} = 2;
        } else {
            $level{$fake} = 1;
        }
    }

    my %filelink;
    my $file_id = 1;

    for my $file (@files) {
        my $id = "file-" . $file_id++;
        $filelink{$file} = $id;
    }

    my $book;
    my @toc;
    my $toc_id = 1;

    for my $file (@files) {
        my $fileid = $filelink{$file};
        if (exists $fake_levels{$file}) {
            push @toc, [ $fake_levels{$file}, undef, $level{$file} ];
            next;
        }
        my ($title, $content) = parsed($file)->@*;

        $content =~ s|^# (.*)|
            my $id = 'toc-' . $toc_id++ ;

            push @toc, [ $1, $id, $level{$file}];
            qq{<h1 id="$id">$1</h1>} |gem;

            $book .= "<section id='$fileid'>".convert_markdown($file, $content, \%filelink).'</section>';
    }

    my $toc = genToc(@toc);

    $template =~ s/_UPDATED_/DateTime->now->ymd()/eg;
    $template =~ s/^.*CONTENT.*$/ $toc $book /m;

    print $template;
}

sub convert_markdown ($fn, $md, $filelink) {
    my ($base) = $fn =~ m|^(.*/)|;
    $base //= "";

    $md =~ s!\( \.\./( [^)]+\.md ) \)!($1)!gxx;
    $md =~ s!\(([^/)]+\.md)\)!"(#".$filelink->{$base.$1}.")"!ge;
    $md =~ s!\(([^)]+\.md)\)!"(#".$filelink->{$1}.")"!ge;
    $md =~ s/^#/##/;

    return markdown($md);
}

sub genToc(@entries) {
    return join "\n", '<section class="table-of-contents" id="contents">',
      '<h1>Table of Contents</h1>',
      '<nav id="toc">',
      (map { tocEntry($_->@*) } @entries),
      '</nav></section>';
}

sub tocEntry($title, $id, $level) {
    $level //= 1;
    if (defined $id) {
        return "<li class='level$level'><a href='#".$id."'>".$title."</a></li>"
    } else {
        return "<li class='level$level'>".$title."</li>"
    }
}

my %cache;
sub parsed($fn) {
    return $cache{$fn} if exists $cache{$fn};

    if (exists $fake_levels{$fn}) {
        return [ $fake_levels{$fn}, undef ];
    }

    my $content = $fn->slurp;

    $content =~ /^#\s*(.*)/;
    my $title = $1;

    $cache{$fn} = [$title, $content];
    return $cache{$fn};
}

1;
