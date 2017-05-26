# testrmd

Provides testing facilities for RMarkdown chunks.

## Introduction

Very often we want to generate RMarkdown reports where tests are performed on
the data, but we do not want the knitting of the report to fail completely 
if the tests don't pass. Rather, we would like to see **information about the
failing tests** in the final document.

`testrmd` provides facilities to enable testing of and reporting on tested
RMarkdown chunks.

## Installation

```r
devtools::install_github("ropenscilabs/testrmd")
```

## Basic Use

To enable testing of RMarkdown chunks in your document, you will need to add
two function calls in a chunk before you want to do testing.

```r
testrmd::init()
testrmd::styles()
```

Thereafter, any chunk that you want to have as part of the testing, you simply
need to add `test = TRUE` in the chunk header, and then have testing code
that returns an error if the test fails. As a simple example, lets test if
a variable is numeric:

    ```{r test_chunk, test = TRUE}
    y <- "5"
    stopifnot(is.numeric(y))
    ```

## Supported Frameworks

The validation frameworks that most easily return errors if there is a problem include:

* `stopifnot`
* `testthat` (patched 1.0.2)
* `assertthat`
* `assertr`
* `ensurer`
* `assertive`
* `checkmate`
