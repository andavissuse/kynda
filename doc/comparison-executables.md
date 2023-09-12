# Comparison Executables
## Overview
A feature "comparison executable" is responsible for comparing specific feature value(s) against existing value(s) in a dataset.  A comparison executable may be a simple script, or it may be a script that calls other more complex executables to perform comparisons.  The only requirements for a comparison executable are:

* Arguments:  The executable should take 3 arguments:
  * File containing feature values to be compared (on string per line)
  * dataset containing existing features
  * comparison operator

* Content:
  * The executable should contain code to handle 6 comparison operators:
    * = (equal)
    * < (less-than)
    * > (greater-than)
    * <= (less-than-or-equal)
    * >= (greater-than-or-equal)
    * ~ (similar)

* Return values:  The executable should return a list of the data bundles (one per line) that meet the comparison requested.

## Template
See .\/templates\/comparison-executable.tmpl
