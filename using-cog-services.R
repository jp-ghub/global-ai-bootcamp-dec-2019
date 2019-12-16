library(tidyverse)
library(purrr)

df <- read_delim(
  file = "raw/tweets.txt",
  delim = "\t",
  col_types = cols(.default = "c"),
  col_names = c("id", "sentiment", "text"),
  quote = ""
)

library(jsonlite)

df_list <- list(documents = transpose(df %>% select(-sentiment)))

toJSON(df_list, pretty = T, auto_unbox = T)
# Convert DF to list/json for submission

# Load the endpoint object created in previous scripts
library(AzureCognitive)
text_api_endpoint <- readRDS("text-api-endpoint.rds")

lang_response <- call_cognitive_endpoint(
  text_api_endpoint,
  operation = "languages",
  body = df_list,
  http_verb = "POST"
)

#Error in process_cognitive_response(res, match.arg(http_status_handler),  :
#  Request Entity Too Large (HTTP 413). Failed to complete Cognitive Services operation. Message:
#Max allowed payload is 1MB.

# Use the first 1000 instead because of the error

df_list_small <-
  list(documents = transpose(df[1:1000,] %>% select(-sentiment)))

lang_response <- call_cognitive_endpoint(
  text_api_endpoint,
  operation = "languages",
  body = df_list_small,
  http_verb = "POST"
)

resp_tbl <-
  tibble::tibble(
    id = purrr::map_chr(lang_response[[1]], "id"),
    langlist = purrr::map(lang_response[[1]], "detectedLanguages", .default = NA)
  ) %>%
  mutate(langname = langlist %>% map_chr(function(x)
    x %>%
      pluck(1) %>% pluck(2)))
