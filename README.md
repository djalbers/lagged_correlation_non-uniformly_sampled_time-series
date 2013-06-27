lagged_correlation_non-uniformly_sampled_time-series
====================================================

his source contains a non-optimized, sometimes stupidly parallelized,
version of the lagged linear correlation for a non-uniformly sampled
population. .  the data file is assumed to be a matrix of the form:
mrn time value

the code is split into two categories corresponding to the following directories:

cluster_code: contains an example script, file structure, example
data, set-up scripts, and the code, for submitting a stupidly paralllel
version of the llc calculation to matlab via a torque queue'd cluster.

single_case: this contains a couple different versions (e.g.,
bootstrap, non-bootstrap, etc.) versions of the llc calculation that
can be used on a single data set. this data set can contain multiple
patients, but only two variables. example data, scripts, etc., are
provided.

