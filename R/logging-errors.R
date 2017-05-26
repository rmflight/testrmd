log_env <- new.env(parent = emptyenv())

init_log_file <- function(){
  testrmd_log <- getOption("testrmd_log")

  # deciding whether or not to do error logging:
  #  logic is:
  #   if TRUE, log to default file
  #   if character, assume that it is a file name, log to that file
  #   if FALSE, don't log
  #   if not set, check for interactivity, and if NOT interactive, log to default file
  #browser(expr = TRUE)
  if (!is.null(testrmd_log)) {
    if (isTRUE(testrmd_log)) {
      log_env$do_logging <- TRUE
      log_env$log_file <- file.path(getwd(), "testrmd_errors.log")
    } else if (is.character(testrmd_log)) {
      log_env$do_logging <- TRUE
      log_env$log_file <- testrmd_log
    } else if (!isTRUE(testrmd_log) && is.logical(testrmd_log)) {
      log_env$do_logging <- FALSE
    }
  } else {
    if (!interactive()) {
      log_env$do_logging <- TRUE
      log_env$log_file <- file.path(getwd(), "testrmd_errors.log")
    } else {
      log_env$do_logging <- FALSE
    }
  }

  if (log_env$do_logging) {
    cat(as.character(Sys.time()), file = log_env$log_file, sep = "\n", append = FALSE)
  }
}

write_to_log <- function(x, options){
  if (log_env$do_logging) {
    error_code <- options$code
    error_message <- gsub("##", "", x)
    error_message <- gsub("\n", "", error_message)

    #browser(expr = TRUE)

    log_error <- paste0(error_message, " :: ", error_code)
    cat(log_error, file = log_env$log_file, sep = "\n", append = TRUE)
  }

}
