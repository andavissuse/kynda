# Feature Extraction Executable
## Overview
A "feature extraction executable" is responsible for extracting specific feature data from a data bundle.  The executable may be as simple as a script that greps a file in a data bundle to extract a value, or it may be a script that calls other more complex executables to extract value(s) for a specific feature.  The executable may have any name.  The requirements for a feature extraction executable are:

* Arguments:  The feature extraction executable should take a data bundle as its argument.  The data bundle may be in any format.

Note:  kynda-setup.sh also provides the ability to define an executable to pre-process a data bundle.  Using a pre-processing executable can greatly reduce data-ingestion time, since the pre-processing can be done once before any feature extraction rather than repeatedly for each feature.  Example: Assume data bundles are provided as compressed tarfiles.  If no pre-processing executable is defined, then each feature extraction executable must take the tarfile as its argument then uncompress the tarfile as needed to extract the feature data.  If a pre-processing executable is defined (in this case, a script to uncompress the tarfile), then the kynda-ingest.sh script can call the pre-processing script to uncompress the tarfile, then call the feature extraction executables on the uncompressed bundle.  In this case, each feature executable would take the uncompressed data as its data bundle argument.

* Return values:  The executable should return the value(s) (one-per-line) for the intended feature.

## Template
See .\/templates\/feature-extract.tmpl
