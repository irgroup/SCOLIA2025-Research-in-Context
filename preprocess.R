#!/usr/bin/env Rscript

library(jsonlite)

# Define file paths
script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)  # Works in RStudio
input_file <- file.path(script_dir, "articles.json")
output_file <- file.path(script_dir, "filtered-date.json")

# 1) Read JSON as a list of lists (avoid automatic data-frame conversion)
data <- fromJSON(input_file, simplifyVector = FALSE)

# 2) Process each object in the JSON array
for (i in seq_along(data)) {
  
  # 2a) Keep only the three top-level fields
  keep_fields <- c("title", "statements", "primary_source","date")
  data[[i]] <- data[[i]][ intersect(names(data[[i]]), keep_fields) ]
  
  # 2b) If "statements" exists, process each expert block
  if (!is.null(data[[i]]$statements)) {
    
    # data[[i]]$statements is a list of experts, each with:
    #   "expert", "description", and a sub-list "statements" containing multiple (type=..., text=...)
    
    for (j in seq_along(data[[i]]$statements)) {
      entry <- data[[i]]$statements[[j]]
      
      # If there's a sub-list of statements, filter out headings, keep only paragraphs
      if (!is.null(entry$statements)) {
        # Extract the text from items where type == "paragraph"
        paragraphs <- lapply(entry$statements, function(x) {
          if (is.list(x) && !is.null(x$type) && x$type == "paragraph") {
            return(x$text)
          } else {
            return(NULL)
          }
        })
        
        # paragraphs is a list of text or NULL; remove NULL entries
        paragraphs <- paragraphs[!vapply(paragraphs, is.null, logical(1))]
        
        # Combine paragraph texts into a single string
        combined_paragraphs <- paste(unlist(paragraphs), collapse = "\n")
        
        # Place that combined text into a new field, for example "text"
        entry$text <- combined_paragraphs
        
        # Remove the original sub-list of statements
        entry$statements <- NULL
      }
      
      # Update the j-th statement block in the top-level list
      data[[i]]$statements[[j]] <- entry
    }
    
  }
}

# 3) Write the filtered JSON to disk
write_json(data, output_file, pretty = TRUE, auto_unbox = TRUE)
cat("Filtered JSON data has been written to", output_file, "\n")