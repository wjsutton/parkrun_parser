# Takes url 
# e.g. 'https://www.parkrun.com/results/consolidatedclub/?clubNum=1242&eventdate=2020-03-14'
# and will find the next i consolidated club urls

# Load Libraries
library(rvest)
library(RCurl)
library(stringr)
library(XML)
library(dplyr)

get_parkrun_cc_report_urls <- function(url,i) {
  
  # check url of the form https://www.parkrun.com/results/consolidatedclub/?clubNum=
  if(substr(url,0,58)!='https://www.parkrun.com/results/consolidatedclub/?clubNum='){
    print("Not of form https://www.parkrun.com/results/consolidatedclub/?clubNum=____")
  }
  
  if(substr(url,0,58)=='https://www.parkrun.com/results/consolidatedclub/?clubNum='){
    report_links <- url
    if(i>1){
      repeat {
        Sys.sleep(30)
        page <- getURL(report_links[length(report_links)])
        page <- read_html(page)
        
        links <- html_nodes(page, "p a")
        prev_rep <- as.character(links[grepl('consolid',links)])
        
        # Extracting url link from a href
        prev_rep <- substr(prev_rep
                           ,str_locate_all(prev_rep,'"')[[1]][1]+1
                           ,str_locate_all(prev_rep,'"')[[1]][2]-1)
        prev_rep <- gsub("amp;",'',prev_rep)
        
        report_links <- c(report_links,prev_rep)
        print(paste0(length(report_links)," done!"))
        if(length(report_links)==i){
          break
        }
      }
    }
    return(report_links)
  }
}