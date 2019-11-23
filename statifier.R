library(jsonlite)

#' Get results from Welch Two Sample t-test
#' @serializer unboxedJSON
#' @param group:character The group col you would like to group data by
#' @param variable:character The variable you would like to be compared between groups
#' @post /twosamplettest/<group>/<variable>
function(req, group, variable) {
  data_as_df <- fromJSON(req$postBody)

  results <- t.test(get(variable) ~ get(group), data=data_as_df)
  
  group_mean_df <- extractGroupsAndMeansFromTTestResults(results)

  test_results <- list(pvalue=results$p.value, group_stats=as.data.frame(group_mean_df), stderr=results$stderr)

  test_results
}

extractGroupsAndMeansFromTTestResults <- function(results) {
  mean_strings <- attr(results$estimate, "names")
  group <- extractGroupNamesFromMeanStrings(mean_strings)
  mean <- as.numeric(results$estimate)
  group_mean_df <- cbind(group, mean)

  group_mean_df
}

extractGroupNamesFromMeanStrings <- function(mean_strings) {
  group_names <- c()
  
  for (i in 1:length(mean_strings)) {
    group_names <- append(group_names, tail(strsplit(mean_strings, "\\s+")[[i]],n=1))
  }
  
  group_names
}