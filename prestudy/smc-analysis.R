# Load necessary library
if (!requireNamespace("irr", quietly = TRUE)) {
  install.packages("irr")
}
library(irr)

### CONFIG

retry_num = 2

###

scale_and_round <- function(x) {
  # Scale: (-1 to 1) -> (0 to 2)
  scaled <- x + 1  # Shift by 1
  # Round to nearest integer (0, 1, 2)
  # rounded <- round(scaled)
  return(rounded)
}

# Load CSV data
script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)  # Works in RStudio
file <- file.path(script_dir, "ergebnisse_en_bloc.csv")
data <- read.csv(file)

# Apply scaling and rounding to K0 to K5 columns
#for (col in c("K0", "K1", "K2", "K3", "K4", "K5")) {
#  data[[col]] <- scale_and_round(data[[col]])
#}

# Calculate the mean of K0 to K5 and store it in a new column named "mean"
data$mean <- rowMeans(data[, c("K0", "K1", "K2", "K3", "K4", "K5")], na.rm = TRUE)


# Initialize a list to store alpha values
alpha_values <- c()

# Get unique article IDs
article_ids <- unique(data$article_id)

# Loop through each article and calculate alpha
for (art_id in article_ids) {
  # Filter rows for the current article
  article_data <- subset(data, article_id == art_id & retry == retry_num)
  
  # Extract K0 to K5 columns 
  ratings <- article_data[, c("K0", "K1", "K2", "K3", "K4", "K5")]
  
  # Convert to matrix
  ratings_matrix = as.matrix(ratings)
  
  # Calculate Krippendorff's Alpha for the article
  if (nrow(ratings_matrix) > 1) {  # Ensure there are enough rows for calculation
    alpha <- kripp.alpha(ratings_matrix, method = "interval")$value
    alpha_values <- c(alpha_values, alpha)
  } else {
    # Append NA if not enough data
    alpha_values <- c(alpha_values, NA)
  }
}

# Compute average alpha, ignoring NAs
average_alpha <- mean(alpha_values, na.rm = TRUE)

# Print results
print(paste("Average Krippendorff's Alpha:", average_alpha))



########


# Initialize a data frame to store alpha values and corresponding article IDs
alpha_results <- data.frame(article_id = integer(), article_title = character(), alpha = numeric(), stringsAsFactors = FALSE)

# Get unique article IDs
article_ids <- unique(data$article_id)
titles <- unique(data$article_title)

# Loop through each article and calculate alpha
for (art_id in article_ids) {
  # Filter rows for the current article
  article_data <- subset(data, article_id == art_id & retry == retry_num)
  
  # Extract K0 to K5 columns
  ratings <- article_data[, c("K0", "K1", "K2", "K3", "K4", "K5")]
  
  # Convert to matrix
  ratings_matrix <- as.matrix(ratings)
  
  # Calculate Krippendorff's Alpha for the article
  if (nrow(ratings_matrix) > 1) {  # Ensure there are enough rows for calculation
    alpha <- kripp.alpha(ratings_matrix, method = "interval")$value
  } else {
    alpha <- NA  # Not enough data for alpha calculation
  }
  
  print(titles[art_id+1])
  
  # Append results to the data frame
  alpha_results <- rbind(alpha_results, data.frame(article_id = art_id, article_title = titles[art_id+1], alpha = alpha))
}

# Find the article with the highest alpha value
max_alpha <- max(alpha_results$alpha, na.rm = TRUE)
min_alpha <- min(alpha_results$alpha, na.rm = TRUE)
best_article <- alpha_results[which.max(alpha_results$alpha), ]
worst_article <- alpha_results[which.min(alpha_results$alpha), ]
# Print the article with the highest alpha value
print(paste("best article: ",best_article$article_id, best_article$alpha))
print(paste("worst article:",worst_article$article_id, worst_article$alpha))

# write results to disk
# write.csv(alpha_results, "/Users/schaer/ownCloud/SMC-Experts/interrater-agreement.csv", row.names=FALSE, quote=TRUE) 
