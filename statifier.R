library(jsonlite)

#' Get results from Welch Two Sample t-test
#' @serializer unboxedJSON
#' @param group:character The group col you would like to group data by
#' @param variable:character The variable you would like to be compared between groups
#' @post /twosamplettest/<group>/<variable>
function(req, group, variable) {
  data_as_df <- fromJSON(req$postBody)
  group_data <- data_as_df[group]
  variable_data <- data_as_df[variable]
  relevant_data <- cbind(group_data, variable_data)
  colnames(relevant_data) <- c("A", "B")
  results <- t.test(B ~ A, data=relevant_data, alternative="two.sided", var.equal=FALSE)
  means <- cbind(results["estimate"], attr(results$estimate, "names"))
  return(list(pvalue=results$p.value, means=toJSON(cbind(attr(results$estimate, "names"), results$estimate)), stderr=results$stderr))
}
