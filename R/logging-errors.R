log_env <- new.env(parent = emptyenv())

init_log_file <- function(){
  if (!interactive()) {
    log_env$do_logging <- TRUE
    log_env$log_file <- file.path(getwd(), "testrmd_errors.log")
    cat(as.character(Sys.time()), file = log_env$log_file, sep = "\n", append = FALSE)
  } else {
    log_env$do_logging <- FALSE
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
