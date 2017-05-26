<img src = "testrmd_hex.png", height = "100">

# testrmd

`testrmd` provides facilities to enable testing of and reporting on tested
RMarkdown chunks.

### Introduction

Very often we want to generate RMarkdown reports where tests are performed on
the data, but we do not want the knitting of the report to fail completely 
if the tests don't pass. Rather, we would like to see **information about the
failing tests** in the final document. `testrmd` allows you to see such 
information from within the margins of your document.

### Installation

```r
devtools::install_github("ropenscilabs/testrmd")
```

### Basic Use

To enable testing of RMarkdown chunks in your document, you will need to add
a function calls in a chunk before you want to do testing.

```r
testrmd::init()
```

Thereafter, for any chunk that you want to have as part of the testing, you simply
need to add the option `test = TRUE` in the chunk header, and then have testing code
that returns an error if the test fails. As a simple example, let's test if
a variable is numeric:

    ```{r test_chunk, test = TRUE}
    y <- "5"
    stopifnot(is.numeric(y))
    ```

### Example Output

The [default](https://ropenscilabs.github.io/testrmd/cranlogs_default.html) and [emoji](https://ropenscilabs.github.io/testrmd/cranlogs_emoji.html) examples of running
an analysis using `cranlogs` are available.

### Supported Frameworks

`testrmd` supports validation methods that throw errors when a test fails. The following validation frameworks have been shown to easily return errors compatible with `testrmd`:

* [`stopifnot`](https://stat.ethz.ch/R-manual/R-devel/library/base/html/stopifnot.html)
* [`testthat`](https://github.com/hadley/testthat) (version 1.0.2 and later)
* [`assertthat`](https://github.com/hadley/assertthat)
* [`assertr`](https://github.com/ropensci/assertr)
* [`ensurer`](https://github.com/smbache/ensure)
* [`assertive`](https://bitbucket.org/richierocks/assertive)
* [`checkmate`](https://github.com/mllg/checkmate)
* [`testit`](https://github.com/yihui/testit)

#### Unconfirmed Frameworks

The following validation methods have not been confirmed to work with `testrmd` because their core functionality does not throw errors to indicate a failed test:

* [`pointblank`](https://github.com/rich-iannone/pointblank)
* [`tester`](https://github.com/gastonstat/tester)
* [`validate`](https://github.com/data-cleaning/validate)

