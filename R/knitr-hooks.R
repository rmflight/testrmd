test_options <- new.env(parent = emptyenv())

#' Initialize testrmd
#'
#' Call from the setup chunk of an Rmd document to enable the `test=TRUE` chunk
#' option on R chunks.
#'
#' @param summary do you want a summary of your tests?
#' @param theme use the default or emoji theme?
#'
#' @export
#'
#' @include logging-errors.R
init <- function(summary = TRUE, theme = c("default", "emoji")) {
  theme <- match.arg(theme)
  knitr::opts_hooks$set(
    error = function(options) {
      if (isTRUE(options$test)) {
        options$error = TRUE
      }
      options
    }
  )

  error <- knitr_error_hook(knitr::knit_hooks$get("error"))
  evaluate <- knitr_evaluate_hook(knitr::knit_hooks$get("evaluate"))
  document <- knitr_document_hook(knitr::knit_hooks$get("document"))
  knitr::knit_hooks$set(
    chunk = knitr_chunk_hook,
    error = error,
    document = document
  )

  reset_doc_counts()
  test_options$summary <- summary
  test_options$theme <- theme
  init_log_file()

  dependencies()
}

increment_count <- function(type) {
  (current_chunk_counts[[type]] <- current_chunk_counts[[type]] + 1L)
  (current_doc_counts[[type]] <- current_doc_counts[[type]] + 1L)
}
reset_chunk_counts <- function() {
  current_chunk_counts$error <- 0
  current_chunk_counts$pass <- 0
}
reset_doc_counts <- function() {
  reset_chunk_counts()
  current_doc_counts$error <- 0
  current_doc_counts$pass <- 0
}
get_chunk_count <- function(type) {
  current_chunk_counts[[type]]
}
get_doc_count <- function(type) {
  current_doc_counts[[type]]
}

current_chunk_counts <- new.env(parent = emptyenv())
current_doc_counts <- new.env(parent = emptyenv())
reset_doc_counts()

dependencies <- function() {
  htmltools::attachDependencies(
    htmltools::tagList(),
    htmltools::htmlDependency("testrmd", packageVersion("testrmd"),
      src = system.file("css", package = "testrmd"),
      stylesheet = "testrmd.css")
  )
}

render_template <- function(template_name, data) {
  theme <- test_options$theme

  path <- system.file("templates", theme, paste0(template_name, ".html"), package = "testrmd")
  if (!nzchar(path)) {
    stop("Template ", template_name, " not found")
  }

  template <- paste(readLines(path, warn = FALSE), collapse = "\n")
  whisker::whisker.render(template, data)
}

knitr_error_hook <- function(old_hook) {
  force(old_hook)
  function(x, options) {
    if (isTRUE(options$test)) {
      #browser(expr = TRUE)
      increment_count("error")
      write_to_log(x, options)
    }
    old_hook(x, options)
  }
}

knitr_document_hook <- function(old_hook) {
  force(old_hook)

  function(x) {
    if (!isTRUE(test_options$summary)) {
      return(old_hook(x))
    }

    content <- old_hook(x)
    content <- paste(content, collapse = "\n")

    matches <- regexec("^(.*)\r?\n---\r?\n(.*)$", content)
    matches <- regmatches(content, matches)

    header <- matches[[1]][2]
    body <- matches[[1]][3]

    error_count <- get_doc_count("error")
    pass <- error_count == 0

    data <- list(
      content = body,
      pass = pass,
      error_count = error_count,
      noun = if (error_count == 1) "test" else "tests"
    )
    c(
      header,
      "---",
      render_template("document", data)
    )
  }
}

knitr_evaluate_hook <- function(old_hook) {
  force(old_hook)
  function(...) {
    withCallingHandlers(
      old_hook(...),
      expectation_success = function(e) {
        increment_count("pass")
      }
    )
  }
}

knitr_chunk_hook <- function(x, options) {
  if (!isTRUE(options$test)) {
    return(x)
  }

  on.exit(reset_chunk_counts(), add = TRUE)

  if (options$eval == FALSE) {
    return("")
  }

  error_count <- get_chunk_count("error")
  pass <- error_count == 0

  data <- list(
    chunk_id = sprintf("testrmd-chunk-%07d", sample.int(9999999, 1)),
    button_class = "default",
    bootstrap_class = if (pass) "info" else "danger",
    status = if (pass) "pass" else "fail",
    pass = pass,
    pass_count = get_chunk_count("pass"),
    error_count = error_count,
    content = paste(x, collapse = "\n"),
    noun = if (error_count == 1) "test" else "tests"
  )
  render_template("chunk", data)
}
