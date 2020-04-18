# Parkrun Parser

[![Status](https://img.shields.io/badge/status-active-success.svg)]() [![GitHub Issues](https://img.shields.io/github/issues/wjsutton/parkrun_parser.svg)](https://github.com/wjsutton/parkrun_parser/issues) [![GitHub Pull Requests](https://img.shields.io/github/issues-pr/wjsutton/parkrun_parser.svg)](https://github.com/wjsutton/parkrun_parser/pulls) [![License](https://img.shields.io/badge/license-GNU-blue.svg)](/LICENSE)

---

<p align="center"> Extract parkrun.org results from the consolidated club report pages.
    <br> 
</p>

## 📝 Table of Contents
+ [About](#about)
+ [Getting Started](#getting_started)
+ [Usage](#usage)

## 🧐 About <a name = "about"></a>
Parkrun free is a weekly timed 5km run, popular with running clubs and communities. This project is for extracting data from parkrun.org consolidated club report page e.g. http://www.parkrun.com/results/consolidatedclub/?clubNum=1242 to build a data source for my running club, West 4 Harriers.

## 🏁 Getting Started <a name = "getting_started"></a>
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

The project is built using R version 3.6.2 and utilises a number of R packages to pull and shape data from parkrun.org.

### Prerequisites
- [R version 3.6.0 or higher](#r_version)
- [Required R packages](#r_packages)

What things you need to install the software and how to install them.

#### R Version 3.6.2 or higher <a name = "r_version"></a>
These scripts where built using R version 3.6.2 which can be downloaded from [https://www.r-project.org](https://www.r-project.org), results may differ if you are using a different version of R.

#### Installing code and required R packages <a name = "r_packages"></a>

##### Install Code

Git clone or download this repo

```
git clone https://github.com/wjsutton/icymi_email.git
```
##### Install R packages

As found in the R Script  `install.packages.R`

```
install.packages("rvest")
install.packages("RCurl")
install.packages("stringr")
install.packages("XML")
install.packages("dplyr")
```
## 🎈 Usage <a name="usage"></a>
There are three main funtions

1. `function_extract_parkrun_result_urls.R`
	Takes 1 or a list of parkrun result urls and creates a data frame
2. `function_get_parkrun_cc_report_urls.R`
	Takes an initial consolidated club url and retrieves a number of previous consolidated club urls
3. `function_get_parkrun_results_links_from_cc_url.R`
	Takes a consolidated club url and extract out just the result urls, which can then be put into `function_extract_parkrun_result_urls.R`

`w4h_fetch_club_results.R` gives a walkthrough of a typical import 1 week import

```
# Load libraries
library(rvest)
library(RCurl)
library(stringr)
library(XML)
library(dplyr)

# Load functions
source("function_get_parkrun_results_links_from_cc_url.R")
source("function_extract_parkrun_result_urls.R")

# Get a report for West 4 Harriers (ClubNum=1242)
cc_url <- 'https://www.parkrun.com/results/consolidatedclub/?clubNum=1242&eventdate=2020-03-14'

# Fetch only the results links from the consolidated club page
latest_result_urls <- get_parkrun_results_links_from_cc_url(cc_url)

# If there are results, extract them and filter for just West 4 Harriers
if(length(latest_result_urls)>0){
  latest_results <- extract_parkrun_result_urls(latest_result_urls)
  w4h_latest_results <- dplyr::filter(latest_results,club=='West 4 Harriers')
}

# Save results to csv, if the results exist
if(exists(w4h_latest_results)){
  
  if(!file.exists("w4h_parkrun_report.csv")){
    write.csv(w4h_latest_results,"w4h_parkrun_report.csv",row.names = F)
  }
  
  if(file.exists("w4h_parkrun_report.csv")){
    w4h_results_df <- read.csv("w4h_parkrun_report.csv",stringsAsFactors = F)
    report_dates <- unique(w4h_results_df$date)
    new_date <- unique(w4h_latest_results$date)
    
    w4h_results_df <- filter(w4h_results_df,date!=new_date)
    w4h_results_merged <- rbind(w4h_results_df,w4h_latest_results)
    write.csv(w4h_results_merged,"w4h_parkrun_report.csv",row.names = F)
  }
}
```

