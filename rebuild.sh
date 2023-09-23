#!/bin/bash

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    perl ./scripts/gen-docsify-sidebar.pl > _sidebar.md
    perl ./scripts/gen-pdf.pl >output/trans-travel.html \
        && weasyprint output/trans-travel.html output/trans-travel.pdf
}

doit "$@"


