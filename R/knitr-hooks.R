#' Initialize testrmd
#'
#' Call from the setup chunk of an Rmd document to enable the `test=TRUE` chunk
#' option on R chunks.
#' @export
init <- function() {
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
  knitr::knit_hooks$set(
    chunk = knitr_chunk_hook,
    error = error
  )
}

increment_count <- function(type) {
  (current_chunk_counts[[type]] <- current_chunk_counts[[type]] + 1L)
}
reset_counts <- function() {
  current_chunk_counts$error <- 0
  current_chunk_counts$pass <- 0
}
get_count <- function(type) {
  current_chunk_counts[[type]]
}

current_chunk_counts <- new.env(parent = emptyenv())
reset_counts()

#' @export
styles <- function() {
  htmltools::attachDependencies(
    htmltools::tagList(),
    htmltools::htmlDependency("testrmd", packageVersion("testrmd"),
      src = system.file("css", package = "testrmd"),
      stylesheet = "testrmd.css")
  )
}

render_template <- function(template_name, data) {
  path <- system.file("templates", paste0(template_name, ".html"), package = "testrmd")
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
      increment_count("error")
    }
    old_hook(x, options)
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

  on.exit(reset_counts(), add = TRUE)

  pass <- get_count("error") == 0

  data <- list(
    chunk_id = sprintf("testrmd-chunk-%07d", sample.int(9999999, 1)),
    button_class = "default",
    bootstrap_class = if (pass) "default" else "danger",
    status = if (pass) "pass" else "fail",
    pass = pass,
    pass_count = get_count("pass"),
    error_count = get_count("error")
  )
  begin <- render_template("chunk-begin", data)
  end <- render_template("chunk-end", data)

  html <- paste0(
    begin,
    paste(x, collapse = "\n"),
    end
  )

  html
}
