context("check output")

# basically making sure output hasn't changed from iteration to iteration

# check for reference files
default_ref <- "cranlogs_default_ref.md"
emoji_ref <- "cranlogs_emoji_ref.md"
if (!file.exists(default_ref)) {
  set.seed(1234)
  knitr::knit("cranlogs_default.Rmd", output = "cranlogs_default_ref.md", quiet = TRUE)
}
default_digest <- digest::digest("cranlogs_default_ref.md", file = TRUE)

if (!file.exists(emoji_ref)) {
  set.seed(1234)
  knitr::knit("cranlogs_emoji.Rmd", output = "cranlogs_emoji_ref.md", quiet = TRUE)
}
emoji_digest <- digest::digest("cranlogs_emoji_ref.md", file = TRUE)


test_that("default theme", {
  set.seed(1234)
  knitr::knit("cranlogs_default.Rmd", output = "test_default.md", quiet = TRUE)
  expect_equal(digest::digest("test_default.md", file = TRUE), default_digest)
  unlink("test_default.md")
})

test_that("emoji theme", {
  set.seed(1234)
  knitr::knit("cranlogs_emoji.Rmd", output = "test_emoji.md", quiet = TRUE)
  expect_equal(digest::digest("test_emoji.md", file = TRUE), emoji_digest)
  unlink("test_emoji.md")
})
