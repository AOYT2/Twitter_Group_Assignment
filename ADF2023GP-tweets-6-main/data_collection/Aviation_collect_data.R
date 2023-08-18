
library("httr")
library("tictoc")
library("tidyverse")
source(here::here("aux_objects.R"))
source(here::here("aux_functions.R"))

my_header <- f_test_API(token_type = "essential")


ALL_tweet_fields <- stringr::str_c(ALL_tweet_fields, collapse = ",")
ALL_expansions   <- stringr::str_c(ALL_expansions, collapse = ",")


############################################ Ryan Air ################################################################

response_objects <- NULL
replies_objects <- NULL


request_number_replies <- 1
request_number <- 1
N_requests <- 11


url_conversation <- paste0("https://api.twitter.com/2/tweets/search/recent")
  
user_id <- 1542862735 #Ryanair 
url_handle <- paste0('https://api.twitter.com/2/users/', user_id, "/tweets")

  
params <- list(max_results = 50,
               tweet.fields = ALL_tweet_fields,
               expansions = ALL_expansions,
               exclude = "replies")

  
while(request_number < N_requests) {
    tic("duration for request number: ")
    response <- httr::GET(url = url_handle,
                          config = httr::add_headers(.headers = my_header[["headers"]]),
                          query = params)


    httr::status_code(response)
    obj <- httr::content(response)
    
    obj[["meta"]][["next_token"]]


    cat(paste0("Response Request number: ", request_number, 
               " has HTTP status: ", httr::status_code(response), "\n"))

    response_objects[[request_number]] <- response
    names(response_objects)[request_number] <- paste0("request_", request_number)
    request_number <- request_number + 1
    

    params[["pagination_token"]] <- obj[["meta"]][["next_token"]]
    
    
    timeline_response <- httr::content(response)
    tweets <- timeline_response$data
    Sys.sleep('60')
    
    for (tweet in tweets) {
      tweet_id <- tweet$id
      
      params_reply <- list(query = paste0("conversation_id:", tweet_id),
                           tweet.fields = ALL_tweet_fields,
                           expansions = ALL_expansions,
                           max_results = 20)

      
      response_reply <- httr::GET(url = url_conversation,
                                  config = httr::add_headers(.headers = my_header[["headers"]]),
                                  query = params_reply)
      
      httr::status_code(response_reply)

      replies_response <- httr::content(response_reply)
      
      replies_response[["meta"]][["next_token"]]

      cat(paste0("Reply Request number: ", request_number_replies, 
                 " has HTTP status: ", httr::status_code(response_reply), "\n"))

      replies_objects[[request_number_replies]] <- response_reply
      names(replies_objects)[request_number_replies] <- paste0("request_", request_number_replies)
      
      request_number_replies <- request_number_replies + 1
      
      Sys.sleep('60')
      
    
    }
    

    toc()
  }


############################################ united  ################################################################

response_objects_united<- NULL
replies_objects_united<- NULL


request_number_replies_united<- 1
request_number_united<- 1
N_requests_united<- 11



user_id <- 260907612  #united


url_handle_united<- paste0('https://api.twitter.com/2/users/', user_id, "/tweets")


params_united<- list(max_results = 50,
                      tweet.fields = ALL_tweet_fields,
                      expansions = ALL_expansions,
                      exclude = "replies")


while(request_number_united< N_requests_united) {

  tic("duration for request number: ")
  response_united<- httr::GET(url = url_handle_united,
                        config = httr::add_headers(.headers = my_header[["headers"]]),
                        query = params_united)
  
  httr::status_code(response_united)
  obj_united<- httr::content(response_united)
  
  obj_united[["meta"]][["next_token"]]
  
  
 
  cat(paste0("Response Request number: ", request_number_united, 
             " has HTTP status: ", httr::status_code(response_united), "\n"))
  # you could also add a check on the http status code in the while loop
  
  
  response_objects_united[[request_number_united]] <- response_united
  names(response_objects_united)[request_number_united] <- paste0("request_", request_number_united)
  request_number_united<- request_number_united+ 1
  
  # add the current response to response_objects
  params_united[["pagination_token"]] <- obj_united[["meta"]][["next_token"]]
  
  
  timeline_response_united<- httr::content(response_united)
  tweets_united<- timeline_response_united$data
  
  Sys.sleep("60")
  
  for (tweet in tweets_united) {
    tweet_id_united<- tweet$id
    
    params_reply_united<- list(query = paste0("conversation_id:", tweet_id_united),
                         tweet.fields = ALL_tweet_fields,
                         expansions = ALL_expansions,
                         max_results = 20)
    
    
    response_reply_united<- httr::GET(url = url_conversation,
                                config = httr::add_headers(.headers = my_header[["headers"]]),
                                query = params_reply_united)
    
    httr::status_code(response_reply_united)
    
    replies_response_united<- httr::content(response_reply_united)
    
    replies_response_united[["meta"]][["next_token"]]

    cat(paste0("Reply Request number: ", request_number_replies_united, 
               " has HTTP status: ", httr::status_code(response_reply_united), "\n"))
    replies_objects_united[[request_number_replies_united]] <- response_reply_united
    names(replies_objects_united)[request_number_replies_united] <- paste0("request_", request_number_replies_united)
    
    request_number_replies_united<- request_number_replies_united+ 1
    
    Sys.sleep("60")
  }
  
  toc()
}

############################################### Qatar #############################################################


response_objects_Qat <- NULL
replies_objects_Qat <- NULL


request_number_replies_Qat <- 1
request_number_Qat <- 1
N_requests_Qat <- 11



url_conversation <- paste0("https://api.twitter.com/2/tweets/search/recent")

user_id <- 14589119 #Qat


url_handle_Qat <- paste0('https://api.twitter.com/2/users/', user_id, "/tweets")


params_Qat <- list(max_results = 50,
                  tweet.fields = ALL_tweet_fields,
                 expansions = ALL_expansions,
                 exclude = "replies")


while(request_number_Qat < N_requests_Qat) {
  tic("duration for request number: ")
  response_Qat <- httr::GET(url = url_handle_Qat,
                            config = httr::add_headers(.headers = my_header[["headers"]]),
                            query = params_Qat)
  
  httr::status_code(response_Qat)
  obj_Qat <- httr::content(response_Qat)
  
  obj_Qat[["meta"]][["next_token"]]
  

  cat(paste0("Response Request number: ", request_number_Qat, 
             " has HTTP status: ", httr::status_code(response_Qat), "\n"))

  response_objects_Qat[[request_number_Qat]] <- response_Qat
  names(response_objects_Qat)[request_number_Qat] <- paste0("request_", request_number_Qat)
  request_number_Qat <- request_number_Qat + 1
  
  params_Qat[["pagination_token"]] <- obj_Qat[["meta"]][["next_token"]]

  
  timeline_response_Qat <- httr::content(response_Qat)
  tweets_Qat <- timeline_response_Qat$data
  
  Sys.sleep("60")
  
  for (tweet in tweets_Qat) {
    tweet_id_Qat <- tweet$id
    
    params_reply_Qat <- list(query = paste0("conversation_id:", tweet_id_Qat),
                             tweet.fields = ALL_tweet_fields,
                             expansions = ALL_expansions,
                             max_results = 20)
    
    
    response_reply_Qat <- httr::GET(url = url_conversation,
                                    config = httr::add_headers(.headers = my_header[["headers"]]),
                                    query = params_reply_Qat)
    
    httr::status_code(response_reply_Qat)
    
    replies_response_Qat <- httr::content(response_reply_Qat)
    
    replies_response_Qat[["meta"]][["next_token"]]

    cat(paste0("Reply Request number: ", request_number_replies_Qat, 
               " has HTTP status: ", httr::status_code(response_reply_Qat), "\n"))

    replies_objects_Qat[[request_number_replies_Qat]] <- response_reply_Qat
    names(replies_objects_Qat)[request_number_replies_Qat] <- paste0("request_", request_number_replies_Qat)
    
    request_number_replies_Qat <- request_number_replies_Qat + 1
    
    Sys.sleep("60")
    
  }
  
  toc()
}

############################################### Emirates #############################################################

response_objects_Em <- NULL
replies_objects_Em <- NULL


request_number_replies_Em <- 301
request_number_Em <- 7
N_requests_Em <- 11

url_conversation <- paste0("https://api.twitter.com/2/tweets/search/recent")

user_id <- 821045162 #Emirates


url_handle_Em <- paste0('https://api.twitter.com/2/users/', user_id, "/tweets")


params_Em <- list(max_results = 50,
                  tweet.fields = ALL_tweet_fields,
                  expansions = ALL_expansions,
                  exclude = "replies")


while(request_number_Em < N_requests_Em) {
 
  tic("duration for request number: ")
  response_Em <- httr::GET(url = url_handle_Em,
                           config = httr::add_headers(.headers = my_header[["headers"]]),
                           query = params_Em)
  
  httr::status_code(response_Em)
  obj_Em <- httr::content(response_Em)
  
  obj_Em[["meta"]][["next_token"]]
  

  cat(paste0("Response Request number: ", request_number_Em, 
             " has HTTP status: ", httr::status_code(response_Em), "\n"))

  
  response_objects_Em[[request_number_Em]] <- response_Em
  names(response_objects_Em)[request_number_Em] <- paste0("request_", request_number_Em)
  request_number_Em <- request_number_Em + 1
  
  params_Em[["pagination_token"]] <- obj_Em[["meta"]][["next_token"]]
  
  timeline_response_Em <- httr::content(response_Em)
  tweets_Em <- timeline_response_Em$data
  Sys.sleep("60")
  for (tweet in tweets_Em) {
    tweet_id_Em <- tweet$id
    
    params_reply_Em <- list(query = paste0("conversation_id:", tweet_id_Em),
                            tweet.fields = ALL_tweet_fields,
                            expansions = ALL_expansions,
                            max_results = 20)
    
    
    response_reply_Em <- httr::GET(url = url_conversation,
                                   config = httr::add_headers(.headers = my_header[["headers"]]),
                                   query = params_reply_Em)
    
    httr::status_code(response_reply_Em)
    
    replies_response_Em <- httr::content(response_reply_Em)
    
    replies_response_Em[["meta"]][["next_token"]]

    cat(paste0("Reply Request number: ", request_number_replies_Em, 
               " has HTTP status: ", httr::status_code(response_reply_Em), "\n"))

    replies_objects_Em[[request_number_replies_Em]] <- response_reply_Em
    names(replies_objects_Em)[request_number_replies_Em] <- paste0("request_", request_number_replies_Em)
    
    request_number_replies_Em <- request_number_replies_Em + 1
    
    Sys.sleep("60")
    

  }

  toc()
}



############################################### Turkish airlines #############################################################


response_objects_TKA <- NULL
replies_objects_TKA <- NULL


request_number_replies_TKA <- 401
request_number_TKA <- 1
N_requests_TKA <- 11


url_conversation <- paste0("https://api.twitter.com/2/tweets/search/recent")

user_id <- 18909186 #Turkish Airline

# get the first batch
url_handle_TKA <- paste0('https://api.twitter.com/2/users/', user_id, "/tweets")


params_TKA <- list(max_results = 50,
                  tweet.fields = ALL_tweet_fields,
                 expansions = ALL_expansions, exclude = "replies")


while(request_number_TKA < N_requests_TKA) {
  tic("duration for request number: ")
  response_TKA <- httr::GET(url = url_handle_TKA,
                            config = httr::add_headers(.headers = my_header[["headers"]]),
                            query = params_TKA)

  httr::status_code(response_TKA)
  obj_TKA <- httr::content(response_TKA)
  
  obj_TKA[["meta"]][["next_token"]]

  cat(paste0("Response Request number: ", request_number_TKA, 
             " has HTTP status: ", httr::status_code(response_TKA), "\n"))

  response_objects_TKA[[request_number_TKA]] <- response_TKA
  names(response_objects_TKA)[request_number_TKA] <- paste0("request_", request_number_TKA)
  request_number_TKA <- request_number_TKA + 1

  params_TKA[["pagination_token"]] <- obj_TKA[["meta"]][["next_token"]]
  
  
  timeline_response_TKA <- httr::content(response_TKA)
  tweets_TKA <- timeline_response_TKA$data
  
  Sys.sleep("60")
  
  for (tweet in tweets_TKA) {
    tweet_id_TKA <- tweet$id
    
    params_reply_TKA <- list(query = paste0("conversation_id:", tweet_id_TKA),
                             tweet.fields = ALL_tweet_fields,
                             expansions = ALL_expansions,
                             max_results = 20)
    
    
    response_reply_TKA <- httr::GET(url = url_conversation,
                                    config = httr::add_headers(.headers = my_header[["headers"]]),
                                    query = params_reply_TKA)
    
    httr::status_code(response_reply_TKA)
    
    replies_response_TKA <- httr::content(response_reply_TKA)
    
    replies_response_TKA[["meta"]][["next_token"]]

    cat(paste0("Reply Request number: ", request_number_replies_TKA, 
               " has HTTP status: ", httr::status_code(response_reply_TKA), "\n"))

    replies_objects_TKA[[request_number_replies_TKA]] <- response_reply_TKA
    names(replies_objects_TKA)[request_number_replies_TKA] <- paste0("request_", request_number_replies_TKA)
    
    request_number_replies_TKA <- request_number_replies_TKA + 1
    
    Sys.sleep("60")
    
    
  }
  
  toc()
}


############################################### easyjet  #############################################################


response_objects_EJ <- NULL
replies_objects_EJ <- NULL


request_number_replies_EJ <- 401
request_number_EJ <- 1
N_requests_EJ <- 11

url_conversation <- paste0("https://api.twitter.com/2/tweets/search/recent")

user_id <- 38676903 #EeasyJet


url_handle_EJ <- paste0('https://api.twitter.com/2/users/', user_id, "/tweets")


params_EJ <- list(max_results = 50,
                 tweet.fields = ALL_tweet_fields,
                expansions = ALL_expansions, exclude = "replies")


while(request_number_EJ < N_requests_EJ) {

  tic("duration for request number: ")
  response_EJ <- httr::GET(url = url_handle_EJ,
                           config = httr::add_headers(.headers = my_header[["headers"]]),
                           query = params_EJ)

  httr::status_code(response_EJ)
  obj_EJ <- httr::content(response_EJ)
  
  obj_EJ[["meta"]][["next_token"]]
  

  cat(paste0("Response Request number: ", request_number_EJ, 
             " has HTTP status: ", httr::status_code(response_EJ), "\n"))
  
  
  response_objects_EJ[[request_number_EJ]] <- response_EJ
  names(response_objects_EJ)[request_number_EJ] <- paste0("request_", request_number_EJ)
  request_number_EJ <- request_number_EJ + 1
  
  params_EJ[["pagination_token"]] <- obj_EJ[["meta"]][["next_token"]]
  
  
  timeline_response_EJ <- httr::content(response_EJ)
  tweets_EJ <- timeline_response_EJ$data
  
  Sys.sleep("60")
  
  for (tweet in tweets_EJ) {
    tweet_id_EJ <- tweet$id
    
    params_reply_EJ <- list(query = paste0("conversation_id:", tweet_id_EJ),
                            tweet.fields = ALL_tweet_fields,
                            expansions = ALL_expansions,
                            max_results = 20)
    
    
    response_reply_EJ <- httr::GET(url = url_conversation,
                                   config = httr::add_headers(.headers = my_header[["headers"]]),
                                   query = params_reply_EJ)
    
    httr::status_code(response_reply_EJ)
    
    replies_response_EJ <- httr::content(response_reply_EJ)
    
    replies_response_EJ[["meta"]][["next_token"]]

    cat(paste0("Reply Request number: ", request_number_replies_EJ, 
               " has HTTP status: ", httr::status_code(response_reply_EJ), "\n"))

    replies_objects_EJ[[request_number_replies_EJ]] <- response_reply_EJ
    names(replies_objects_EJ)[request_number_replies_EJ] <- paste0("request_", request_number_replies_EJ)
    
    request_number_replies_EJ <- request_number_replies_EJ + 1
    
    Sys.sleep("60")
 
    
  }
  
  toc()
}


############################################### Delta  #############################################################

response_objects_Delta <- NULL
replies_objects_Delta <- NULL


request_number_replies_Delta <- 1
request_number_Delta <- 1
N_requests_Delta <- 11


url_conversation <- paste0("https://api.twitter.com/2/tweets/search/recent")

user_id <- 5920532 #Delta


url_handle_Delta <- paste0('https://api.twitter.com/2/users/', user_id, "/tweets")

params_Delta <- list(max_results = 8,
                     tweet.fields = ALL_tweet_fields,
                     expansions = ALL_expansions, exclude = "replies")


while(request_number_Delta < N_requests_Delta) {

  response_Delta <- httr::GET(url = url_handle_Delta,
                              config = httr::add_headers(.headers = my_header[["headers"]]),
                              query = params_Delta)
  

  httr::status_code(response_Delta)
  obj_Delta <- httr::content(response_Delta)
  
  obj_Delta[["meta"]][["next_token"]]
  

  cat(paste0("Response Request number: ", request_number_Delta, 
             " has HTTP status: ", httr::status_code(response_Delta), "\n"))

  response_objects_Delta[[request_number_Delta]] <- response_Delta
  names(response_objects_Delta)[request_number_Delta] <- paste0("request_", request_number_Delta)
  request_number_Delta <- request_number_Delta + 1
  
  params_Delta[["pagination_token"]] <- obj_Delta[["meta"]][["next_token"]]
  
  timeline_response_Delta <- httr::content(response_Delta)
  tweets_Delta <- timeline_response_Delta$data
  
  Sys.sleep("60")
  
  for (tweet in tweets_Delta) {
    tweet_id_Delta <- tweet$id
    
    params_reply_Delta <- list(query = paste0("conversation_id:", tweet_id_Delta),
                               tweet.fields = ALL_tweet_fields,
                               expansions = ALL_expansions,
                               max_results = 20)
    
    
    response_reply_Delta <- httr::GET(url = url_conversation,
                                      config = httr::add_headers(.headers = my_header[["headers"]]),
                                      query = params_reply_Delta)
    
    httr::status_code(response_reply_Delta)
    
    replies_response_Delta <- httr::content(response_reply_Delta)
    
    replies_response_Delta[["meta"]][["next_token"]]

    cat(paste0("Reply Request number: ", request_number_replies_Delta, 
               " has HTTP status: ", httr::status_code(response_reply_Delta), "\n"))

    replies_objects_Delta[[request_number_replies_Delta]] <- response_reply_Delta
    names(replies_objects_Delta)[request_number_replies_Delta] <- paste0("request_", request_number_replies_Delta)
    
    request_number_replies_Delta <- request_number_replies_Delta + 1
    
    Sys.sleep("60")
    

  }
  
  toc()
}


save( obj, params, replies_objects,response_objects,
      obj_united, params_united, replies_objects_united, response_objects_united,
      obj_Qat, params_Qat, replies_objects_Qat, response_objects_Qat,
      obj_Em, params_Em, replies_objects_Em, response_objects_Em,

     file = here::here("data_collection", 
                       "raw_dataset.RData"))



save(obj_TKA, params_TKA, replies_objects_TKA, response_objects_TKA,

     file = here::here("data_collection", 
                       "raw_dataset_TKA.RData"))



save(obj_Delta, params_Delta, replies_objects_Delta, response_objects_Delta,
      file = here::here("data_collection", 
                        "raw_dataset_united.RData"))


save(obj_EJ, params_EJ, replies_objects_EJ, response_objects_EJ,
     file = here::here("data_collection", 
                       "raw_dataset_EJ.RData"))





