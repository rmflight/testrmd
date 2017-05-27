---
title: "CRAN log processing"
output:
  html_document:
    self_contained: false
    lib_dir: libs
---


```r
params <- list(packages = c("assertr", "assertthat", "ensurer", "assertive", "checkmate", "validate"),
               start = as.Date("2016-01-01"),
               end = as.Date(Sys.time()) - 1)
```


This report shows downloads of the CRAN packages: assertr, assertthat, ensurer, assertive, checkmate, validate





```r
library(knitr)
library(dplyr)
library(ggplot2)
library(cranlogs)
library(lubridate)

packages <- strsplit(params$packages, ",\\s*")[[1]]
```




<!--html_preserve-->
<div class="testrmd-badge-container-outer">
  <div class="testrmd-badge-container-inner">
      <span class="testrmd-badge" data-toggle="collapse" data-target="#testrmd-chunk-1137034" aria-expanded="false" aria-controls="testrmd-chunk-1137034"><span style="font-size: 18px;">&#x1f44c;</span></span>
      </div>
</div>
<div id="testrmd-chunk-1137034" class="testrmd-chunk panel panel-info collapse">
  <div class="panel-heading">
<!--/html_preserve-->


```r
library(testthat)

expect_true(params$start < params$end)
expect_gt(length(packages), 0)
```


  </div>
</div>

## Fetch and summarize

The data comes from the [`cranlogs`](https://github.com/metacran/cranlogs) package, which uses [the logs from RStudio's CRAN mirrors](http://cran-logs.rstudio.com/).



```r
daily_downloads <- cran_downloads(packages, from = params$start, to = params$end)
head(daily_downloads)
```



```
##         date count package
## 1 2016-01-01     7 assertr
## 2 2016-01-02     9 assertr
## 3 2016-01-03     2 assertr
## 4 2016-01-04    15 assertr
## 5 2016-01-05    14 assertr
## 6 2016-01-06    13 assertr
```



<!--html_preserve-->
<div class="testrmd-badge-container-outer">
  <div class="testrmd-badge-container-inner">
      <span class="testrmd-badge" data-toggle="collapse" data-target="#testrmd-chunk-6222994" aria-expanded="false" aria-controls="testrmd-chunk-6222994"><span style="font-size: 18px;">&#x1f44c;</span></span>
      </div>
</div>
<div id="testrmd-chunk-6222994" class="testrmd-chunk panel panel-info collapse">
  <div class="panel-heading">
<!--/html_preserve-->


```r
expect_equal(colnames(daily_downloads), c("date", "count", "package"))
expect_gt(nrow(daily_downloads), 0)
expect_is(daily_downloads[["date"]], "Date")
expect_is(daily_downloads[["count"]], "numeric")
expect_is(daily_downloads[["package"]], "character")

for (pkg in packages) {
  package_daily_downloads <- daily_downloads %>%
    filter(package == pkg) %>%
    arrange(date)
  
  # Make sure no days are missing
  expected_range <- params$start:params$end
  expect_equal(
    as.integer(as.Date(package_daily_downloads$date)),
    expected_range,
    info = pkg
  )
}
```


  </div>
</div>

In addition to daily downloads, we'll calculate weekly downloads. We'll use lubridate's `floor_date` to add a new `week` column to the data frame, then group and sum.



```r
weekly_downloads <- daily_downloads %>%
  mutate(week = floor_date(date, "week")) %>%
  # Discard partial weeks
  filter(week >= ceiling_date(params$start, "week") & week < floor_date(Sys.time(), "week")) %>%
  group_by(package, week) %>%
  summarise(count = sum(count))
head(weekly_downloads)
```



```
## Source: local data frame [6 x 3]
## Groups: package [1]
## 
## # A tibble: 6 x 3
##   package       week count
##     <chr>     <date> <dbl>
## 1 assertr 2016-01-03    75
## 2 assertr 2016-01-10   114
## 3 assertr 2016-01-17   151
## 4 assertr 2016-01-24   133
## 5 assertr 2016-01-31    61
## 6 assertr 2016-02-07    69
```



<!--html_preserve-->
<div class="testrmd-badge-container-outer">
  <div class="testrmd-badge-container-inner">
      <span class="testrmd-badge" data-toggle="collapse" data-target="#testrmd-chunk-6092747" aria-expanded="false" aria-controls="testrmd-chunk-6092747"><span style="font-size: 18px;">&#x1f44c;</span></span>
      </div>
</div>
<div id="testrmd-chunk-6092747" class="testrmd-chunk panel panel-info collapse">
  <div class="panel-heading">
<!--/html_preserve-->


```r
zero_rows <- weekly_downloads %>%
  filter(count == 0)
expect_equal(nrow(zero_rows), 0, info = unique(zero_rows$package))
```


  </div>
</div>

## Downloads by week



```r
week_plot <- ggplot(weekly_downloads, aes(week, count, color = package)) +
  geom_line()
plotly::ggplotly(week_plot)
```



```
## Warning: We recommend that you use the dev version of ggplot2 with `ggplotly()`
## Install it with: `devtools::install_github('hadley/ggplot2')`
```



```
## Error in loadNamespace(name): there is no package called 'webshot'
```



## Total downloads



```r
daily_downloads %>%
  group_by(package) %>%
  summarise(count = sum(count))
```



```
## # A tibble: 1 x 2
##   package count
##     <chr> <dbl>
## 1 assertr  9340
```


