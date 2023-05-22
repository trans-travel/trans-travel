use Test2::V0;

use GenEpub;

ok GenEpub::convert_markdown("[a](../notes/tsa.md)") =~ /\.html/,
  ".md turned into .html";

done_testing;
