use 5.36.0;

use Path::Tiny;

my %fake_countries = (
    "us" => "United States",
    "ca" => "Canada",
);
my %fake_levels = (
    %fake_countries,
    "notes" => "Notes",
    "jurisdictions" => "Jurisdictions",
);

my @subdivisions;
for my $country (keys %fake_countries) {
    push @subdivisions, path("./$country")->children(qr/\.md$/);
}

my @countries = path('.')->children(qr/^..\.md$/);
my @locations = sort { extract_title($a) cmp extract_title($b) } (@subdivisions, keys(%fake_countries), @countries);
my @notes = sort(path('./notes')->children(qr/\.md$/));
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

for my $file (@files) {
    my $link;
    if ($file =~ m/\.md$/) {
        $link = "[" . extract_title($file) . "]($file)"
    } else {
        $link = extract_title($file);
    }
    if (! exists $level{$file}) {
        say "* " . $link;
    } elsif ($level{$file} == 1) {
        say "* " . $link;
    } elsif ($level{$file} == 2) {
        say "  * " . $link;
    } elsif ($level{$file} == 3) {
        say "    - " . $link;
    }
}

my %cache;
sub extract_title($fn) {
    return $cache{$fn} if exists $cache{$fn};

    if (exists $fake_levels{$fn}) {
        return $fake_levels{$fn};
    }

    my $content = $fn->slurp;

    $content =~ /^#\s*(.*)/;
    my $title = $1;

    return $title;
}

1;
