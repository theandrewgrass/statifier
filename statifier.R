library(plumber)
library(jsonlite)
library(glue)
library(crayon)

#* Log some information about the incoming request
#* @filter logger
function(req) {
  time <- as.character(Sys.time())
  method <- req$REQUEST_METHOD
  path <- req$PATH_INFO
  user_agent <- req$HTTP_USER_AGENT
  address <- req$REMOTE_ADDR
  log_info <- glue(
    "Time: {time}",
    "Request Method: {method}",
    "Path: {path}",
    "User Agent: {user_agent}",
    "Remote Address: {address}",
    .sep="\n")

  printWithSeparator(log_info, 50)

  forward()
}

printWithSeparator <- function(content, num_sep_repeat) {
  separator_string <- strrep("-", num_sep_repeat)
  cat(separator_string, content, separator_string, sep="\n")
}

#* Warn user if post request missing body
#* @filter missingpostbody
function(req) {
  if (req$REQUEST_METHOD == "POST" && length(req$postBody) == 0) {
    req$status <- 400
    error_msg <- "Error: POST request missing body."
    cat(red(error_msg), "\n")
  } else {
    forward()
  }
}

#' Get results from Welch Two Sample t-test
#' @json
#' @param group:character The group col you would like to group data by
#' @param variable:character The variable you would like to be compared between groups
#' @post /twosamplettest/<group>/<variable>
function(req, group, variable) {
  data_as_df <- fromJSON(req$postBody)

  results <- t.test(get(variable) ~ get(group), data=data_as_df)
  
  group_mean_df <- extractGroupsAndMeansFromTTestResults(results)

  test_results <- list(pvalue=results$p.value, group_stats=as.data.frame(group_mean_df), stderr=results$stderr)
}

extractGroupsAndMeansFromTTestResults <- function(results) {
  mean_strings <- attr(results$estimate, "names")
  group <- extractGroupNamesFromMeanStrings(mean_strings)
  mean <- as.numeric(results$estimate)
  group_mean_df <- cbind(group, mean)
}

extractGroupNamesFromMeanStrings <- function(mean_strings) {
  group_names <- c()
  
  for (i in 1:length(mean_strings)) {
    group_names <- append(group_names, tail(strsplit(mean_strings, "\\s+")[[i]],n=1))
  }
}

#' Interweave multiple arrays to get alternating values (to be used with smart table web component)
#' @json
#' @post /interweavearrays
function(req) {
  parsed_data <- fromJSON(req$postBody)
  equal_length_df <- ensureEqualColLength(parsed_data)
  interweaved <- as.vector(t(equal_length_df))
}

ensureEqualColLength <- function(df) {
  n <- max(lengths(df))
  equal_length_df <- as.data.frame(do.call(cbind, lapply(df, `length<-`, n)))
}
