
<!-- README.md is generated from README.Rmd. Please edit that file -->

# conflicted

<!-- badges: start -->

[![R-CMD-check](https://github.com/r-lib/conflicted/workflows/R-CMD-check/badge.svg)](https://github.com/r-lib/conflicted/actions)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/conflicted/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-lib/conflicted?branch=main)
<!-- badges: end -->

The goal of conflicted is to provide an alternative conflict resolution
strategy. R’s default conflict resolution system gives precedence to the
most recently loaded package. This can make it hard to detect conflicts,
particularly when introduced by an update to an existing package.
conflicted takes a different approach, making every conflict an error
and forcing you to choose which function to use.

Thanks to [@krlmlr](https://github.com/krlmlr) for this neat idea! This
code was previously part of the experimental
[strict](https://github.com/hadley/strict) package, but I decided
improved conflict resolution is useful by itself and worth its own
package.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("r-lib/conflicted")
```

## Usage

To use conflicted, all you need to do is load it:

``` r
library(conflicted)
library(dplyr)

filter(mtcars, cyl == 8)
#> Error: [conflicted] `filter` found in 2 packages.
#> Either pick the one you want with `::` 
#> * dplyr::filter
#> * stats::filter
#> Or declare a preference with `conflict_prefer()`
#> * conflict_prefer("filter", "dplyr")
#> * conflict_prefer("filter", "stats")
```

As suggested, you can either namespace individual calls:

``` r
dplyr::filter(mtcars, am & cyl == 8)
#>                 mpg cyl disp  hp drat   wt qsec vs am gear carb
#> Ford Pantera L 15.8   8  351 264 4.22 3.17 14.5  0  1    5    4
#> Maserati Bora  15.0   8  301 335 3.54 3.57 14.6  0  1    5    8
```

Or declare a session-wide preference:

``` r
conflict_prefer("filter", "dplyr")
#> [conflicted] Will prefer dplyr::filter over any other package
filter(mtcars, am & cyl == 8)
#>                 mpg cyl disp  hp drat   wt qsec vs am gear carb
#> Ford Pantera L 15.8   8  351 264 4.22 3.17 14.5  0  1    5    4
#> Maserati Bora  15.0   8  301 335 3.54 3.57 14.6  0  1    5    8
```

I recommend declaring preferences directly underneath the corresponding
library call:

``` r
library(dplyr)
conflict_prefer("filter", "dplyr")
```

You can ask conflicted to report any conflicts in the current session:

``` r
conflict_scout()
#> 2 conflicts:
#> * `filter`: [dplyr]
#> * `lag`   : dplyr, stats
```

Functions surrounded by `[]` have been chosen using one of the built-in
rules. Here `filter()` has been selected because of the preference
declared above; the set operations have been selected because they
follow the superset principle and extend the API of the base
equivalents.

### How it works

Loading conflicted creates a new “conflicted” environment that is
attached just after the global environment. This environment contains an
active binding for any object that is exported by multiple packages; the
active binding will throw an error message describing how to
disambiguate the name. The conflicted environment also contains bindings
for `library()` and `require()` that suppress conflict reporting and
update the conflicted environment with any new conflicts.

## Alternative approaches

It is worth comparing conflicted to
[modules](http://github.com/klmr/modules) and
[import](https://github.com/smbache/import). Both packages provide
strict alternatives to `library()`, giving much finer control over what
functions are added to the search path.

``` r
# modules expects you to namespace all package functions
dplyr <- modules::import_package('dplyr')
dplyr$filter(mtcars, cyl == 8)

# import expects you to explicit load functions
import::from(dplyr, select, arrange, dplyr_filter = filter)
dplyr_filter(mtcars, cyl == 8)
```

These require more upfront work than conflicted, in return for greater
precision and control.

## Code of conduct

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.
