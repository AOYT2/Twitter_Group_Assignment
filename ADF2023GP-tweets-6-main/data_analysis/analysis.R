# Data loading and set-up ------------------------------------------------------
library(httr)
library(tidyverse)
library(sentimentr)
library(textdata)
library(stringr)
library(stargazer)
library(reshape2)
library(cowplot)
library(sjPlot)
library(gridExtra)

# Loading the original dataset with Ryanair, Emirates, Qatar and United
load(here::here(
  "data_collection", 
  "processed_data.RData"))

# Loading the Turkish Airlines data
load(here::here(
  "data_collection", 
  "processed_data_TKA.RData"))

# Loading EasyJet data
load(here::here(
  "data_collection", 
  "processed_data_EJ.RData"))






# Data pre-processing ----------------------------------------------------------
# Adding new columns to the datasets before merging to indicate whether they 
# are anthropomorphic, the company name and the follower count

## Pre-processing for the first analysis ##
df_tweets$ant_dummy <- 1
df_tweets$company <- 'Ryanair'
df_tweets$follower_count <- 724327 #as of 25 May 2023 11:22

df_tweets_united$ant_dummy <- 1
df_tweets_united$company <- 'United Airlines'
df_tweets_united$follower_count <- 1175281

df_tweets_Em$ant_dummy <- 0
df_tweets_Em$company <- 'Emirates'
df_tweets_Em$follower_count <- 1679515

df_tweets_Qat$ant_dummy <- 0
df_tweets_Qat$company <- 'Qatar Airways'
df_tweets_Qat$follower_count <- 1926979

df_tweets_EJ$ant_dummy <- 0
df_tweets_EJ$company <- 'EasyJet'
df_tweets_EJ$follower_count <- 576956

df_tweets_TKA$ant_dummy <- 0
df_tweets_TKA$company <- 'Turkish Airlines'
df_tweets_TKA$follower_count <- 1881352

# Connecting all datasets for the analysis
df_tweets_full <- bind_rows(df_tweets, df_tweets_united, df_tweets_Em, 
                            df_tweets_Qat, df_tweets_EJ, df_tweets_TKA)

# Only keeping the tweets that are original, not replies 
# (since from the dataset, replies and original tweets have wildly different
# engagement numbers, which may skew results in favor of anthropomorphic brands)
df_tweets_original <- subset(df_tweets_full, tweet_type != 'replied_to')

# Scaling the metrics using the follower count to minimize the effect of higher
# follower counts on the results (analysis will be run on both non-scaled and
# scaled)
df_tweets_original$retweet_count_scaled <- df_tweets_original$retweet_count/df_tweets_original$follower_count
df_tweets_original$reply_count_scaled <- df_tweets_original$reply_count/df_tweets_original$follower_count
df_tweets_original$like_count_scaled <- df_tweets_original$like_count/df_tweets_original$follower_count
df_tweets_original$quote_count_scaled <- df_tweets_original$quote_count/df_tweets_original$follower_count


## Pre-processing for the second (sentiment_based) analysis ##
# Getting the sentiment scores of the original tweet text
# Pre-processing text to feed it into our sentiment analysis model
df_tweets_original$text_processed <- str_replace_all(df_tweets_original$text, 
                                                     "http\\S+|www\\S+|[^[:alnum:]\\s]", "")

# Generating sentiment scores
sentiment_scores <- sentiment(df_tweets_original$text_processed)
df_tweets_original$sentiment_score <- sentiment_scores$sentiment

# Getting the sentiment scores of the replies to the original tweets
# Creating one reply dataframe to make the analysis easier
replies_df_tweets_full <- bind_rows(replies_df_tweets, replies_df_tweets_Em, 
                                    replies_df_tweets_Qat, replies_df_tweets_united, 
                                    replies_df_tweets_EJ, replies_df_tweets_TKA)

# Pre-processing of the text for the sentiment analysis model
# Removing the handles for the replies since all of them start with one, cluttering
# the text
replies_df_tweets_full$text_processed <- str_replace_all(replies_df_tweets_full$text, "@\\w+", "")

# Removing http links
replies_df_tweets_full$text_processed <- str_replace_all(replies_df_tweets_full$text_processed, "http\\S+|www\\S+|[^[:alnum:]\\s]", "")

# Removing empty cells after text cleaning
replies_df_tweets_full$text_processed<- str_trim(replies_df_tweets_full$text_processed)
df_replies <- subset(replies_df_tweets_full, text_processed !="")

# Removing non-English text
df_replies <- subset(df_replies, lang == 'en')


# Generating the sentiment scores of the replies
sentiment_reply_scores <- sentiment(df_replies$text_processed)
df_replies$reply_sentiment_score <- sentiment_reply_scores$sentiment






# First Analysis - t-test of engagement numbers --------------------------------
metrics = c('retweet_count','reply_count','like_count','quote_count')

# Performing the t-tests for the different metrics
t_test_results = list()
for (metric in metrics) {
  t_test_results[[metric]] <- t.test(df_tweets_original[[metric]] ~ df_tweets_original$ant_dummy)
}

# create an empty dataframe to store the results in a presentable format:
df_results <- data.frame(metric = character(),
                         mean_in_group_0 = numeric(),
                         mean_in_group_1 = numeric(),
                         p_value = numeric())


for (metric in metrics){
  df_results = rbind(df_results, data.frame(metric = metric,
                                            mean_in_group_0 = t_test_results[[metric]][['estimate']][['mean in group 0']],
                                            mean_in_group_1 = t_test_results[[metric]][['estimate']][['mean in group 1']],
                                            p_value = t_test_results[[metric]][['p.value']]
                                            )
                     )
}


# Creating Barcharts to visualize our results
# Calculate the average values for each metric and ant_dummy value
avg_values <- aggregate(df_tweets_original[, metrics], by = list(df_tweets_original$ant_dummy), FUN = mean)

# Reshape the data from wide to long format
avg_values_long <- reshape2::melt(avg_values, id.vars = "Group.1", variable.name = "metric", value.name = "avg_value")

# Create the bar chart using ggplot2
bar_chart <- ggplot(avg_values_long, aes(x = metric, y = avg_value, fill = factor(Group.1))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "Metric", y = "Average Value", fill = "Anthropomorphism") +
  scale_fill_discrete(labels = c("No", "Yes")) +
  ggtitle("Average Values of Metrics by Anthropomorphism") +
  theme_bw()

# Display the bar chart
print(bar_chart)

output_path = here::here('data_analysis','visualizations' ,'metrics_barchart.png')

# Save the bar chart to the folder
ggsave(output_path, width = 8, height = 6)

# the anthropomorphic brands have consistently higher metrics of engagement, 
# and p-values highly significant (<0.05) for all of them


# Running the same analysis but on the scaled metrics
metrics_scaled <- lapply(metrics, function(x) paste0(x,'_scaled'))
t_test_results_scaled = list()
for (metric in metrics_scaled) {
  t_test_results_scaled[[metric]] <- t.test(df_tweets_original[[metric]] ~ df_tweets_original$ant_dummy)
}

for (metric in metrics_scaled){
  df_results = rbind(df_results, data.frame(metric = metric,
                                            mean_in_group_0 = t_test_results_scaled[[metric]][['estimate']][['mean in group 0']],
                                            mean_in_group_1 = t_test_results_scaled[[metric]][['estimate']][['mean in group 1']],
                                            p_value = t_test_results_scaled[[metric]][['p.value']]
  )
  )
}

# again, the anthropomorphic brands have consistently higher metrics of engagement, 
# and p-values remain highly significant (<0.05)

# trying a visualization
metrics_scaled <- unlist(metrics_scaled)
# Calculate the average values for each metric and ant_dummy value
avg_values <- aggregate(df_tweets_original[, metrics_scaled], by = list(df_tweets_original$ant_dummy), FUN = mean)

# Reshape the data from wide to long format
avg_values_long <- reshape2::melt(avg_values, id.vars = "Group.1", variable.name = "metric", value.name = "avg_value")

# Create the bar chart using ggplot2
bar_chart <- ggplot(avg_values_long, aes(x = metric, y = avg_value, fill = factor(Group.1))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "Metric", y = "Average Value", fill = "Anthropomorphism") +
  scale_fill_discrete(labels = c("No", "Yes")) +
  ggtitle("Average Values of Metrics by Anthropomorphism") +
  theme_bw()

# Display the bar chart
print(bar_chart)

output_path <- here::here('data_analysis','visualizations', 'metrics_barchart_scaled.png')

ggsave(output_path,  width = 8, height = 6)






# Second Analysis - sentiment-related analyses----------------------------------
# Grouping the replies based on which tweet they belong to to calculate the average
# comment sentiment per tweet for each company
df_replies_average <- df_replies %>%
  group_by(conversation_id) %>%
  summarise(average_reply_sentiment = mean(reply_sentiment_score))

# Merging it with the original dataframe to get a new engagement metric - reply/comment
# sentiment score
df_final <- merge(df_tweets_original, df_replies_average, by.x = "tweet_id", by.y = "conversation_id", all.x = TRUE)


# Running a t-test on this newly acquired metric and adding it to the results table
sentiment_ttest <- t.test(df_final$average_reply_sentiment ~ df_final$ant_dummy)

# There is almost a significant difference in sentiment values of replies of the 
# anthropomorphic and non-antropomorphic group (0.06444)

df_results <- rbind(df_results, data.frame(metric = 'reply_sentiment_score',
                                           mean_in_group_0 = sentiment_ttest[['estimate']][['mean in group 0']],
                                           mean_in_group_1 = sentiment_ttest[['estimate']][['mean in group 1']],
                                           p_value = sentiment_ttest[['p.value']]))

output_results <- here::here('data_analysis', 'results.csv')

write.csv(df_results, output_results, row.names = FALSE)


# Running the linear regressions with sentiment_scores as independent variable 
# and the metrics as dependent variables
# Fit the linear regression models
model_rt <- lm(retweet_count ~ sentiment_score*ant_dummy, data = df_final)
model_rt_scaled <- lm(retweet_count_scaled ~ sentiment_score*ant_dummy, data = df_final)

model_rp <- lm(reply_count ~ sentiment_score*ant_dummy, data = df_final)
model_rp_scaled <- lm(reply_count_scaled ~ sentiment_score*ant_dummy, data = df_final)

model_lk <- lm(like_count ~ sentiment_score*ant_dummy, data = df_final)
model_lk_scaled <- lm(like_count_scaled ~ sentiment_score*ant_dummy, data = df_final)

model_qt <- lm(quote_count ~ sentiment_score*ant_dummy, data = df_final)
model_qt_scaled <- lm(quote_count_scaled ~ sentiment_score*ant_dummy, data = df_final)

# Print the model summaries
stargazer(model_rt, model_lk , model_rp, model_qt, align = TRUE, type = "text")

stargazer(model_rt_scaled, model_lk_scaled,  model_rp_scaled, model_qt_scaled, align = TRUE, type = "text")

# Save the models in an RData file
save( model_rt, model_rt_scaled, model_rp,model_rp_scaled,
      model_lk, model_lk_scaled, model_qt, model_qt_scaled,
      
      file = here::here("data_analysis", 
                        "linear_models.RData"))

# Creating a visualization for the interaction effect of anthropomorphism
models <- list(model_rt, model_rt_scaled,
               model_rp, model_rp_scaled,
               model_lk, model_lk_scaled,
               model_qt, model_qt_scaled)

model_names <- list('model_rt', 'model_rt_scaled',
                    'model_rp', 'model_rp_scaled',
                    'model_lk', 'model_lk_scaled',
                    'model_qt', 'model_qt_scaled')


i <- 0
# Loop through each model and generate the plot
for (model in models) {
  i <- i+1
  plot <- plot_model(model, type = "int")
  model_name <- model_names[i]
  file_name = paste0(model_name,'.png')
  output_path = here::here('data_analysis', 'visualizations',file_name)
  ggsave(output_path, width = 8, height = 6)
}




