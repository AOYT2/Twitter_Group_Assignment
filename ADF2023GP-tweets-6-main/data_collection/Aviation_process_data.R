# there's no need for rm(list=ls()) at the start of the file
# to restart the R Session on Windows, use CTRL + SHIFT + F10

# you need httr to GET data from the API and then to extract the content
# note that httr can be used also with other APIs, 
#		it this is not specific to the Twitter API
library("httr")
# you need the tidyverse to process data, we'll be relying on purrr quite a bit
library("tidyverse")
# add more packages ONLY if you need to use them

# f_aux_functions.R contains functions for data processing
source(here::here("aux_functions.R"))
source(here::here("aux_objects.R"))


# load the dataset you've just collected
load(here::here(
  "data_collection", 
  "raw_dataset.RData"))


load(here::here(
  "data_collection", 
  "raw_dataset_TKA.RData"))

load(here::here(
  "data_collection", 
  "raw_dataset_finalDelta.RData"))


load(here::here(
  "data_collection", 
  "raw_dataset_Delta.RData"))


####################RYANAIR##########################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################


raw_content <- purrr::map(response_objects, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each element in the raw_dataset list

# this is how many response objects you've received from the API
length(raw_content)

# this gives the names of the elements within the raw_obj list
purrr::map(raw_content, names)
# each element in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
raw_tweets <- purrr::map(raw_content, "data")
# extract all "includes" lists in a separate list
raw_includes <- purrr::map(raw_content, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(raw_tweets, length)
# this is how many tweets there are in total
sum(purrr::map_int(raw_tweets, length))
# check how raw_tweets looks like and then flatten it
# flatten rDeltaoves the first level of indexes from the list
raw_tweets <- purrr::flatten(raw_tweets)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elDeltaents as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(raw_tweets)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(raw_tweets, length))
purrr::map(raw_tweets, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(raw_includes, length)
purrr::map(raw_includes, names)


raw_ref_tweets <- map(raw_includes, "tweets")
purrr::map_int(raw_ref_tweets, length)
sum(purrr::map_int(raw_ref_tweets, length))
raw_ref_tweets <- purrr::flatten(raw_ref_tweets)
length(raw_ref_tweets)


df_tweets <- raw_tweets %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}


df_ref_tweets <- raw_ref_tweets %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(df_ref_tweets)
df_ref_tweets <- distinct(df_ref_tweets)
nrow(df_ref_tweets)

#################################################################################################

replies_raw_content <- purrr::map(replies_objects, httr::content)
# the line above is equivalent to a for loop 


# this is how many response objects you've received from the API
length(replies_raw_content)

# this gives the names of the elements within the raw_obj list
purrr::map(replies_raw_content, names)
# each element in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
replies_raw_tweets <- purrr::map(replies_raw_content, "data")
# extract all "includes" lists in a separate list
replies_raw_includes <- purrr::map(replies_raw_content, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(replies_raw_tweets, length)
# this is how many tweets there are in total
sum(purrr::map_int(replies_raw_tweets, length))
# check how raw_tweets looks like and then flatten it
# flatten removes the first level of indexes from the list
replies_raw_tweets <- purrr::flatten(replies_raw_tweets)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elements as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(replies_raw_tweets)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(replies_raw_tweets, length))
purrr::map(replies_raw_tweets, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(replies_raw_includes, length)
purrr::map(replies_raw_includes, names)


replies_raw_ref_tweets <- map(replies_raw_includes, "tweets")
purrr::map_int(replies_raw_ref_tweets, length)
sum(purrr::map_int(replies_raw_ref_tweets, length))
replies_raw_ref_tweets <- purrr::flatten(replies_raw_ref_tweets)
length(replies_raw_ref_tweets)


# you need to use functions to extract elements that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
replies_df_tweets <- replies_raw_tweets %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



replies_df_ref_tweets <- replies_raw_ref_tweets %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(replies_df_ref_tweets)
replies_df_ref_tweets <- distinct(replies_df_ref_tweets)
nrow(replies_df_ref_tweets)


###################### FOR Delta #################################
#################################################################################################
#################################################################################################
#################################################################################################

raw_content_Delta <- purrr::map(response_objects_Delta, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each element in the raw_dataset list

# this is how many response objects you've received from the API
length(raw_content_Delta)

# this gives the names of the elemaents within the raw_obj list
purrr::map(raw_content_Delta, names)
# each element in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
raw_tweets_Delta <- purrr::map(raw_content_Delta, "data")
# extract all "includes" lists in a separate list
raw_includes_Delta <- purrr::map(raw_content_Delta, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(raw_tweets_Delta, length)
# this is how many tweets there are in total
sum(purrr::map_int(raw_tweets_Delta, length))
# check how raw_tweets looks like and then flatten it
# flatten removes the first level of indexes from the list
raw_tweets_Delta <- purrr::flatten(raw_tweets_Delta)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elements as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(raw_tweets_Delta)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(raw_tweets_Delta, length))
purrr::map(raw_tweets_Delta, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(raw_includes_Delta, length)
purrr::map(raw_includes_Delta, names)


raw_ref_tweets_Delta <- map(raw_includes_Delta, "tweets")
purrr::map_int(raw_ref_tweets_Delta, length)
sum(purrr::map_int(raw_ref_tweets_Delta, length))
raw_ref_tweets_Delta <- purrr::flatten(raw_ref_tweets_Delta)
length(raw_ref_tweets_Delta)


# you need to use functions to extract elements that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
df_tweets_Delta <- raw_tweets_Delta %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



df_ref_tweets_Delta <- raw_ref_tweets_Delta %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(df_ref_tweets_Delta)
df_ref_tweets_Delta <- distinct(df_ref_tweets_Delta)
nrow(df_ref_tweets_Delta)

#################################################################################################

replies_raw_content_Delta <- purrr::map(replies_objects_Delta, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each elDeltaent in the raw_dataset list

# this is how many response objects you've received from the API
length(replies_raw_content_Delta)

# this gives the names of the elDeltaents within the raw_obj list
purrr::map(replies_raw_content_Delta, names)
# each elDeltaent in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
replies_raw_tweets_Delta <- purrr::map(replies_raw_content_Delta, "data")
# extract all "includes" lists in a separate list
replies_raw_includes_Delta <- purrr::map(replies_raw_content_Delta, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(replies_raw_tweets_Delta, length)
# this is how many tweets there are in total
sum(purrr::map_int(replies_raw_tweets_Delta, length))
# check how raw_tweets looks like and then flatten it
# flatten rDeltaoves the first level of indexes from the list
replies_raw_tweets_Delta <- purrr::flatten(replies_raw_tweets_Delta)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elDeltaents as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(replies_raw_tweets_Delta)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(replies_raw_tweets_Delta, length))
purrr::map(replies_raw_tweets_Delta, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(replies_raw_includes_Delta, length)
purrr::map(replies_raw_includes_Delta, names)


replies_raw_ref_tweets_Delta <- map(replies_raw_includes_Delta, "tweets")
purrr::map_int(replies_raw_ref_tweets_Delta, length)
sum(purrr::map_int(replies_raw_ref_tweets_Delta, length))
replies_raw_ref_tweets_Delta <- purrr::flatten(replies_raw_ref_tweets_Delta)
length(replies_raw_ref_tweets_Delta)


# you need to use functions to extract elDeltaents that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
replies_df_tweets_Delta <- replies_raw_tweets_Delta %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



replies_df_ref_tweets_Delta <- replies_raw_ref_tweets_Delta %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(replies_df_ref_tweets_Delta)
replies_df_ref_tweets_Delta <- distinct(replies_df_ref_tweets_Delta)
nrow(replies_df_ref_tweets_Delta)


###################### FOR Qat #################################
#################################################################################################
#################################################################################################
#################################################################################################

raw_content_Qat <- purrr::map(response_objects_Qat, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each elQatent in the raw_dataset list

# this is how many response objects you've received from the API
length(raw_content_Qat)

# this gives the names of the elQatents within the raw_obj list
purrr::map(raw_content_Qat, names)
# each elQatent in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
raw_tweets_Qat <- purrr::map(raw_content_Qat, "data")
# extract all "includes" lists in a separate list
raw_includes_Qat <- purrr::map(raw_content_Qat, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(raw_tweets_Qat, length)
# this is how many tweets there are in total
sum(purrr::map_int(raw_tweets_Qat, length))
# check how raw_tweets looks like and then flatten it
# flatten rQatoves the first level of indexes from the list
raw_tweets_Qat <- purrr::flatten(raw_tweets_Qat)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elQatents as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(raw_tweets_Qat)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(raw_tweets_Qat, length))
purrr::map(raw_tweets_Qat, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(raw_includes_Qat, length)
purrr::map(raw_includes_Qat, names)


raw_ref_tweets_Qat <- map(raw_includes_Qat, "tweets")
purrr::map_int(raw_ref_tweets_Qat, length)
sum(purrr::map_int(raw_ref_tweets_Qat, length))
raw_ref_tweets_Qat <- purrr::flatten(raw_ref_tweets_Qat)
length(raw_ref_tweets_Qat)


# you need to use functions to extract elQatents that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
df_tweets_Qat <- raw_tweets_Qat %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



df_ref_tweets_Qat <- raw_ref_tweets_Qat %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(df_ref_tweets_Qat)
df_ref_tweets_Qat <- distinct(df_ref_tweets_Qat)
nrow(df_ref_tweets_Qat)

#################################################################################################

replies_raw_content_Qat <- purrr::map(replies_objects_Qat, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each elQatent in the raw_dataset list

# this is how many response objects you've received from the API
length(replies_raw_content_Qat)

# this gives the names of the elQatents within the raw_obj list
purrr::map(replies_raw_content_Qat, names)
# each elQatent in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
replies_raw_tweets_Qat <- purrr::map(replies_raw_content_Qat, "data")
# extract all "includes" lists in a separate list
replies_raw_includes_Qat <- purrr::map(replies_raw_content_Qat, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(replies_raw_tweets_Qat, length)
# this is how many tweets there are in total
sum(purrr::map_int(replies_raw_tweets_Qat, length))
# check how raw_tweets looks like and then flatten it
# flatten rQatoves the first level of indexes from the list
replies_raw_tweets_Qat <- purrr::flatten(replies_raw_tweets_Qat)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elQatents as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(replies_raw_tweets_Qat)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(replies_raw_tweets_Qat, length))
purrr::map(replies_raw_tweets_Qat, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(replies_raw_includes_Qat, length)
purrr::map(replies_raw_includes_Qat, names)


replies_raw_ref_tweets_Qat <- map(replies_raw_includes_Qat, "tweets")
purrr::map_int(replies_raw_ref_tweets_Qat, length)
sum(purrr::map_int(replies_raw_ref_tweets_Qat, length))
replies_raw_ref_tweets_Qat <- purrr::flatten(replies_raw_ref_tweets_Qat)
length(replies_raw_ref_tweets_Qat)


# you need to use functions to extract elQatents that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
replies_df_tweets_Qat <- replies_raw_tweets_Qat %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



replies_df_ref_tweets_Qat <- replies_raw_ref_tweets_Qat %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(replies_df_ref_tweets_Qat)
replies_df_ref_tweets_Qat <- distinct(replies_df_ref_tweets_Qat)
nrow(replies_df_ref_tweets_Qat)



###################### FOR Em #################################
#################################################################################################
#################################################################################################
#################################################################################################


raw_content_Em <- purrr::map(response_objects_Em, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each element in the raw_dataset list

# this is how many response objects you've received from the API
length(raw_content_Em)

# this gives the names of the elements within the raw_obj list
purrr::map(raw_content_Em, names)
# each element in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
raw_tweets_Em <- purrr::map(raw_content_Em, "data")
# extract all "includes" lists in a separate list
raw_includes_Em <- purrr::map(raw_content_Em, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(raw_tweets_Em, length)
# this is how many tweets there are in total
sum(purrr::map_int(raw_tweets_Em, length))
# check how raw_tweets looks like and then flatten it
# flatten removes the first level of indexes from the list
raw_tweets_Em <- purrr::flatten(raw_tweets_Em)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elements as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(raw_tweets_Em)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(raw_tweets_Em, length))
purrr::map(raw_tweets_Em, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(raw_includes_Em, length)
purrr::map(raw_includes_Em, names)


raw_ref_tweets_Em <- map(raw_includes_Em, "tweets")
purrr::map_int(raw_ref_tweets_Em, length)
sum(purrr::map_int(raw_ref_tweets_Em, length))
raw_ref_tweets_Em <- purrr::flatten(raw_ref_tweets_Em)
length(raw_ref_tweets_Em)


# you need to use functions to extract elements that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
df_tweets_Em <- raw_tweets_Em %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



df_ref_tweets_Em <- raw_ref_tweets_Em %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(df_ref_tweets_Em)
df_ref_tweets_Em <- distinct(df_ref_tweets_Em)
nrow(df_ref_tweets_Em)

#################################################################################################

replies_raw_content_Em <- purrr::map(replies_objects_Em, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each element in the raw_dataset list

# this is how many response objects you've received from the API
length(replies_raw_content_Em)

# this gives the names of the elements within the raw_obj list
purrr::map(replies_raw_content_Em, names)
# each element in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
replies_raw_tweets_Em <- purrr::map(replies_raw_content_Em, "data")
# extract all "includes" lists in a separate list
replies_raw_includes_Em <- purrr::map(replies_raw_content_Em, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(replies_raw_tweets_Em, length)
# this is how many tweets there are in total
sum(purrr::map_int(replies_raw_tweets_Em, length))
# check how raw_tweets looks like and then flatten it
# flatten removes the first level of indexes from the list
replies_raw_tweets_Em <- purrr::flatten(replies_raw_tweets_Em)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elements as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(replies_raw_tweets_Em)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(replies_raw_tweets_Em, length))
purrr::map(replies_raw_tweets_Em, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(replies_raw_includes_Em, length)
purrr::map(replies_raw_includes_Em, names)


replies_raw_ref_tweets_Em <- map(replies_raw_includes_Em, "tweets")
purrr::map_int(replies_raw_ref_tweets_Em, length)
sum(purrr::map_int(replies_raw_ref_tweets_Em, length))
replies_raw_ref_tweets_Em <- purrr::flatten(replies_raw_ref_tweets_Em)
length(replies_raw_ref_tweets_Em)


# you need to use functions to extract elements that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
replies_df_tweets_Em <- replies_raw_tweets_Em %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



replies_df_ref_tweets_Em <- replies_raw_ref_tweets_Em %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(replies_df_ref_tweets_Em)
replies_df_ref_tweets_Em <- distinct(replies_df_ref_tweets_Em)
nrow(replies_df_ref_tweets_Em)


###################### FOR TKA #################################
#################################################################################################
#################################################################################################
#################################################################################################


raw_content_TKA <- purrr::map(response_objects_TKA, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each elTKAent in the raw_dataset list

# this is how many response objects you've received from the API
length(raw_content_TKA)

# this gives the names of the elTKAents within the raw_obj list
purrr::map(raw_content_TKA, names)
# each elTKAent in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
raw_tweets_TKA <- purrr::map(raw_content_TKA, "data")
# extract all "includes" lists in a separate list
raw_includes_TKA <- purrr::map(raw_content_TKA, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(raw_tweets_TKA, length)
# this is how many tweets there are in total
sum(purrr::map_int(raw_tweets_TKA, length))
# check how raw_tweets looks like and then flatten it
# flatten rTKAoves the first level of indexes from the list
raw_tweets_TKA <- purrr::flatten(raw_tweets_TKA)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elTKAents as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(raw_tweets_TKA)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(raw_tweets_TKA, length))
purrr::map(raw_tweets_TKA, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(raw_includes_TKA, length)
purrr::map(raw_includes_TKA, names)


raw_ref_tweets_TKA <- map(raw_includes_TKA, "tweets")
purrr::map_int(raw_ref_tweets_TKA, length)
sum(purrr::map_int(raw_ref_tweets_TKA, length))
raw_ref_tweets_TKA <- purrr::flatten(raw_ref_tweets_TKA)
length(raw_ref_tweets_TKA)


# you need to use functions to extract elTKAents that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
df_tweets_TKA <- raw_tweets_TKA %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



df_ref_tweets_TKA <- raw_ref_tweets_TKA %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(df_ref_tweets_TKA)
df_ref_tweets_TKA <- distinct(df_ref_tweets_TKA)
nrow(df_ref_tweets_TKA)

#################################################################################################

replies_raw_content_TKA <- purrr::map(replies_objects_TKA, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each elTKAent in the raw_dataset list

# this is how many response objects you've received from the API
length(replies_raw_content_TKA)

# this gives the names of the elTKAents within the raw_obj list
purrr::map(replies_raw_content_TKA, names)
# each elTKAent in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
replies_raw_tweets_TKA <- purrr::map(replies_raw_content_TKA, "data")
# extract all "includes" lists in a separate list
replies_raw_includes_TKA <- purrr::map(replies_raw_content_TKA, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(replies_raw_tweets_TKA, length)
# this is how many tweets there are in total
sum(purrr::map_int(replies_raw_tweets_TKA, length))
# check how raw_tweets looks like and then flatten it
# flatten rTKAoves the first level of indexes from the list
replies_raw_tweets_TKA <- purrr::flatten(replies_raw_tweets_TKA)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elTKAents as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(replies_raw_tweets_TKA)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(replies_raw_tweets_TKA, length))
purrr::map(replies_raw_tweets_TKA, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(replies_raw_includes_TKA, length)
purrr::map(replies_raw_includes_TKA, names)


replies_raw_ref_tweets_TKA <- map(replies_raw_includes_TKA, "tweets")
purrr::map_int(replies_raw_ref_tweets_TKA, length)
sum(purrr::map_int(replies_raw_ref_tweets_TKA, length))
replies_raw_ref_tweets_TKA <- purrr::flatten(replies_raw_ref_tweets_TKA)
length(replies_raw_ref_tweets_TKA)


# you need to use functions to extract elTKAents that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
replies_df_tweets_TKA <- replies_raw_tweets_TKA %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



replies_df_ref_tweets_TKA <- replies_raw_ref_tweets_TKA %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(replies_df_ref_tweets_TKA)
replies_df_ref_tweets_TKA <- distinct(replies_df_ref_tweets_TKA)
nrow(replies_df_ref_tweets_TKA)

##################### FOR EJ #################################
#################################################################################################
#################################################################################################
#################################################################################################


raw_content_EJ <- purrr::map(response_objects_EJ, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each elEJent in the raw_dataset list

# this is how many response objects you've received from the API
length(raw_content_EJ)

# this gives the names of the elEJents within the raw_obj list
purrr::map(raw_content_EJ, names)
# each elEJent in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
raw_tweets_EJ <- purrr::map(raw_content_EJ, "data")
# extract all "includes" lists in a separate list
raw_includes_EJ <- purrr::map(raw_content_EJ, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(raw_tweets_EJ, length)
# this is how many tweets there are in total
sum(purrr::map_int(raw_tweets_EJ, length))
# check how raw_tweets looks like and then flatten it
# flatten rEJoves the first level of indexes from the list
raw_tweets_EJ <- purrr::flatten(raw_tweets_EJ)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elEJents as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(raw_tweets_EJ)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(raw_tweets_EJ, length))
purrr::map(raw_tweets_EJ, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(raw_includes_EJ, length)
purrr::map(raw_includes_EJ, names)


raw_ref_tweets_EJ <- map(raw_includes_EJ, "tweets")
purrr::map_int(raw_ref_tweets_EJ, length)
sum(purrr::map_int(raw_ref_tweets_EJ, length))
raw_ref_tweets_EJ <- purrr::flatten(raw_ref_tweets_EJ)
length(raw_ref_tweets_EJ)


# you need to use functions to extract elEJents that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
df_tweets_EJ <- raw_tweets_EJ %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



df_ref_tweets_EJ <- raw_ref_tweets_EJ %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(df_ref_tweets_EJ)
df_ref_tweets_EJ <- distinct(df_ref_tweets_EJ)
nrow(df_ref_tweets_EJ)

#################################################################################################

replies_raw_content_EJ <- purrr::map(replies_objects_EJ, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each elEJent in the raw_dataset list

# this is how many response objects you've received from the API
length(replies_raw_content_EJ)

# this gives the names of the elEJents within the raw_obj list
purrr::map(replies_raw_content_EJ, names)
# each elEJent in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
replies_raw_tweets_EJ <- purrr::map(replies_raw_content_EJ, "data")
# extract all "includes" lists in a separate list
replies_raw_includes_EJ <- purrr::map(replies_raw_content_EJ, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(replies_raw_tweets_EJ, length)
# this is how many tweets there are in total
sum(purrr::map_int(replies_raw_tweets_EJ, length))
# check how raw_tweets looks like and then flatten it
# flatten rEJoves the first level of indexes from the list
replies_raw_tweets_EJ <- purrr::flatten(replies_raw_tweets_EJ)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elEJents as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(replies_raw_tweets_EJ)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(replies_raw_tweets_EJ, length))
purrr::map(replies_raw_tweets_EJ, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(replies_raw_includes_EJ, length)
purrr::map(replies_raw_includes_EJ, names)


replies_raw_ref_tweets_EJ <- map(replies_raw_includes_EJ, "tweets")
purrr::map_int(replies_raw_ref_tweets_EJ, length)
sum(purrr::map_int(replies_raw_ref_tweets_EJ, length))
replies_raw_ref_tweets_EJ <- purrr::flatten(replies_raw_ref_tweets_EJ)
length(replies_raw_ref_tweets_EJ)


# you need to use functions to extract elEJents that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
replies_df_tweets_EJ <- replies_raw_tweets_EJ %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



replies_df_ref_tweets_EJ <- replies_raw_ref_tweets_EJ %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(replies_df_ref_tweets_EJ)
replies_df_ref_tweets_EJ <- distinct(replies_df_ref_tweets_EJ)
nrow(replies_df_ref_tweets_EJ)





###################### FOR Delta #################################
#################################################################################################
#################################################################################################
#################################################################################################


raw_content_Delta <- purrr::map(response_objects_Delta, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each elDeltaent in the raw_dataset list

# this is how many response objects you've received from the API
length(raw_content_Delta)

# this gives the names of the elDeltaents within the raw_obj list
purrr::map(raw_content_Delta, names)
# each elDeltaent in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
raw_tweets_Delta <- purrr::map(raw_content_Delta, "data")
# extract all "includes" lists in a separate list
raw_includes_Delta <- purrr::map(raw_content_Delta, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(raw_tweets_Delta, length)
# this is how many tweets there are in total
sum(purrr::map_int(raw_tweets_Delta, length))
# check how raw_tweets looks like and then flatten it
# flatten rDeltaoves the first level of indexes from the list
raw_tweets_Delta <- purrr::flatten(raw_tweets_Delta)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elDeltaents as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(raw_tweets_Delta)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(raw_tweets_Delta, length))
purrr::map(raw_tweets_Delta, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(raw_includes_Delta, length)
purrr::map(raw_includes_Delta, names)


raw_ref_tweets_Delta <- map(raw_includes_Delta, "tweets")
purrr::map_int(raw_ref_tweets_Delta, length)
sum(purrr::map_int(raw_ref_tweets_Delta, length))
raw_ref_tweets_Delta <- purrr::flatten(raw_ref_tweets_Delta)
length(raw_ref_tweets_Delta)


# you need to use functions to extract elDeltaents that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
df_tweets_Delta <- raw_tweets_Delta %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



df_ref_tweets_Delta <- raw_ref_tweets_Delta %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(df_ref_tweets_Delta)
df_ref_tweets_Delta <- distinct(df_ref_tweets_Delta)
nrow(df_ref_tweets_Delta)

#################################################################################################

replies_raw_content_Delta <- purrr::map(replies_objects_Delta, httr::content)
# the line above is equivalent to a for loop 
# that applies the function httr::content to each elDeltaent in the raw_dataset list

# this is how many response objects you've received from the API
length(replies_raw_content_Delta)

# this gives the names of the elDeltaents within the raw_obj list
purrr::map(replies_raw_content_Delta, names)
# each elDeltaent in the raw_obj list contains data, includes, and meta

# extract all "data" lists in a separate list
replies_raw_tweets_Delta <- purrr::map(replies_raw_content_Delta, "data")
# extract all "includes" lists in a separate list
replies_raw_includes_Delta <- purrr::map(replies_raw_content_Delta, "includes")

# let's process the tweet information in "raw_tweets"
# this shows how many tweets were returned by each API response
purrr::map_int(replies_raw_tweets_Delta, length)
# this is how many tweets there are in total
sum(purrr::map_int(replies_raw_tweets_Delta, length))
# check how raw_tweets looks like and then flatten it
# flatten rDeltaoves the first level of indexes from the list
replies_raw_tweets_Delta <- purrr::flatten(replies_raw_tweets_Delta)
# check how raw_tweets looks like now and notice the differences 
#		to understand what flatten does
# the flattened list should have as many elDeltaents as the number of tweets returned
#		by sum(map_int(raw_tweets, length)) above
length(replies_raw_tweets_Delta)
# tweet objects within the raw_tweets have different lengths
table(purrr::map_int(replies_raw_tweets_Delta, length))
purrr::map(replies_raw_tweets_Delta, names)

# similar to what you've done for "data", process information in "includes"
purrr::map_int(replies_raw_includes_Delta, length)
purrr::map(replies_raw_includes_Delta, names)


replies_raw_ref_tweets_Delta <- map(replies_raw_includes_Delta, "tweets")
purrr::map_int(replies_raw_ref_tweets_Delta, length)
sum(purrr::map_int(replies_raw_ref_tweets_Delta, length))
replies_raw_ref_tweets_Delta <- purrr::flatten(replies_raw_ref_tweets_Delta)
length(replies_raw_ref_tweets_Delta)


# you need to use functions to extract elDeltaents that are in nested lists
# the functions used by this script are already included in f_aux_functions.R -> check the examples

# rearrange the data in a tibble
replies_df_tweets_Delta <- replies_raw_tweets_Delta %>% 
  {tibble(tweet_id           = map_chr(., "id"),
          text               = map_chr(., "text"),
          lang               = map_chr(., "lang"),
          created_at         = map_chr(., "created_at"),
          author_id          = map_chr(., "author_id"),
          conversation_id    = map_chr(., "conversation_id"),
          reply_settings     = map_chr(., "reply_settings"),
          geo_place_id       = map_chr(., f_get_geo_placeid),
          retweet_count      = map_int(., f_get_retweet_count),
          reply_count        = map_int(., f_get_reply_count),
          like_count         = map_int(., f_get_like_count),
          quote_count        = map_int(., f_get_quote_count),
          tweet_type         = map_chr(., f_get_tweet_type),
          ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
# check ?map for more info



replies_df_ref_tweets_Delta <- replies_raw_ref_tweets_Delta %>% 
  {tibble(ref_tweet_id           = map_chr(., "id"),
          ref_text               = map_chr(., "text"),
          ref_lang               = map_chr(., "lang"),
          ref_created_at         = map_chr(., "created_at"),
          ref_author_id          = map_chr(., "author_id"),
          ref_conversation_id    = map_chr(., "conversation_id"),
          ref_reply_settings     = map_chr(., "reply_settings"),
          ref_geo_place_id       = map_chr(., f_get_geo_placeid),
          ref_retweet_count      = map_int(., f_get_retweet_count),
          ref_reply_count        = map_int(., f_get_reply_count),
          ref_like_count         = map_int(., f_get_like_count),
          ref_quote_count        = map_int(., f_get_quote_count),
          ref_tweet_type         = map_chr(., f_get_tweet_type),
          ref_ref_tweet_id       = map_chr(., f_get_ref_tweet_id))}
nrow(replies_df_ref_tweets_Delta)
replies_df_ref_tweets_Delta <- distinct(replies_df_ref_tweets_Delta)
nrow(replies_df_ref_tweets_Delta)




save(df_tweets, df_ref_tweets, replies_df_tweets, replies_df_ref_tweets,
     df_tweets_Delta, df_ref_tweets_Delta, replies_df_tweets_Delta, replies_df_ref_tweets_Delta,
     df_tweets_Em, df_ref_tweets_Em, replies_df_tweets_Em, replies_df_ref_tweets_Em,
     df_tweets_Qat, df_ref_tweets_Qat, replies_df_tweets_Qat, replies_df_ref_tweets_Qat,
     file = here::here( 
       "data_collection", 
       "processed_data.RData"))


save( df_tweets_TKA, df_ref_tweets_TKA, replies_df_tweets_TKA, replies_df_ref_tweets_TKA,
     file = here::here( 
       "data_collection", 
       "processed_data_TKA.RData"))


save(df_tweets_Delta, df_ref_tweets_Delta, replies_df_tweets_Delta, replies_df_ref_tweets_Delta,
  file = here::here( 
    "data_collection", 
    "processed_data_Delta.RData"))

save(df_tweets_EJ, df_ref_tweets_EJ, replies_df_tweets_EJ, replies_df_ref_tweets_EJ,
     file = here::here( 
       "data_collection", 
       "processed_data_EJ.RData"))

