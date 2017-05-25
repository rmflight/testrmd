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

  knitr::knit_hooks$set(chunk = knitr_chunk_hook)
}

render_template <- function(template_name, data) {
  path <- system.file("templates", paste0(template_name, ".html"), package = "testrmd")
  if (!nzchar(path)) {
    stop("Template ", template_name, " not found")
  }

  template <- paste(readLines(path, warn = FALSE), collapse = "\n")
  whisker::whisker.render(template, data)
}

knitr_chunk_hook <- function(x, options) {
  if (!isTRUE(options$test)) {
    return(x)
  }

  data <- list(
    chunk_id = sprintf("testrmd-chunk-%07d", sample.int(9999999, 1)),
    button_class = "default"
  )
  begin <- render_template("chunk-begin", data)
  end <- render_template("chunk-end", data)

  paste0(
    begin,
    paste(x, collapse = "\n"),
    end
  )
}
