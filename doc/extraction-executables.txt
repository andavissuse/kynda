# Extraction Executables
## Overview
A feature "extraction executable" is responsible for extracting a specific type of feature data from a data bundle.  An extraction executable may be as simple as a script that greps a file in a data bundle to extract a value, or it may be a script that calls other more complex executables to extract feature values.  The only requirements for a comparison executable are:

* Arguments:  The executable should take a data bundle as its argument.

* Return values:  The executable should return a list of the values for the intended feature.  The values should be returned as one string per line (even numeric values are treated as strings; it is the responsibility of the comparison executable to transform the strings into other types of values for comparison.

## Template
See .\/templates\/extraction-executable.tmpl
