context("logging")

test_that("no logging set", {
  knitr::knit("no_log.Rmd", quiet = TRUE)
  expect_false(file.exists("testrmd_error.log"))
  unlink("no_log.md")
})

test_that("logging enabled", {
  knitr::knit("default_log.Rmd", quiet = TRUE)
  expect_true(file.exists("testrmd_errors.log"))
  unlink("default_log.md")
  unlink("testrmd_errors.log")
  options(testrmd_log = NULL)
})

test_that("custom log file", {
  knitr::knit("custom_log.Rmd", quiet = TRUE)
  expect_true(file.exists("custom_errors.log"))
  unlink("custom_log.md")
  unlink("custom_errors.log")
  options(testrmd_log = NULL)
})
