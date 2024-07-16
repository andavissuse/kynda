# Feature Extraction Executable
## Overview
A "feature extraction executable" is responsible for extracting specific feature data from a data instance.  The executable might simply extract a value from a specific file or column in a data instance, or it might extract the value then perform additional processing on the value.  The executable may have any name.  The requirements for a feature extraction executable are:

* Arguments:  The feature extraction executable should take a data instance as its argument.  The data instance may be in any format (defined via the project configuration file).

Note:  kynda-setup.sh also provides the ability to define an executable to pre-process a data instance.  Using a pre-processing executable can greatly reduce data-ingestion time, since the pre-processing can be done once before any feature extraction rather than repeatedly for each feature.  Example: Assume data instances are provided as compressed tarfiles.  If no pre-processing executable is defined, then each feature extraction executable must take the tarfile as its argument, uncompress the tarfile, then extract the feature data.  If a pre-processing executable is defined (in this case, a script to uncompress the tarfile), then the kynda-ingest.sh script can call the pre-processing script to uncompress the tarfile once, then call each feature extraction executables on the uncompressed instance.  In this case, each feature executable would take the uncompressed data directory as its data instance argument.

* Return values:  The executable should return the value(s) (one-per-line) for the intended feature.

## Template
See .\/templates\/feature-extract.tmpl
