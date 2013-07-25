#!/bin/bash

# Shell script to generate documentation
# For this to work, you need to have NaturalDocs installed
#    (http://www.naturaldocs.org)

NaturalDocs=NaturalDocs

$NaturalDocs -i `pwd` -xi dist -o html doc -p .naturaldocs_project

