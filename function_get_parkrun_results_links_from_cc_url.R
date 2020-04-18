# Takes url 
# e.g. 'https://www.parkrun.com/results/consolidatedclub/?clubNum=1242&eventdate=2020-03-14'
# and will get the urls for parkrun result tables

# Load Libraries
library(rvest)
library(RCurl)
library(stringr)
library(XML)
library(dplyr)

get_parkrun_results_links_from_cc_url <- function(url) {
  
  # check url of the form https://www.parkrun.com/results/consolidatedclub/?clubNum=
  if(substr(url,0,58)!='https://www.parkrun.com/results/consolidatedclub/?clubNum='){
    print("Not of form https://www.parkrun.com/results/consolidatedclub/?clubNum=____")
  }
  
  if(substr(url,0,58)=='https://www.parkrun.com/results/consolidatedclub/?clubNum='){
    page <- getURL(url[length(url)])
    page <- read_html(page)
    links <- html_nodes(page, "p a")
    result_links <- links[grepl('results',links)]
    parkrun_results_links <- as.character(result_links[!grepl('consolid',result_links)])
    
    if(length(parkrun_results_links) == 0){
      print("No parkrun results this week.")
    }
    
    if(length(parkrun_results_links) > 0){
      print(paste0(length(parkrun_results_links)," Parkrun results found."))
      
      url_pattern <- "http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"
      parkrun_results_links <- stringr::str_extract(parkrun_results_links, url_pattern)
      
      return(parkrun_results_links)
    }
  }
}

