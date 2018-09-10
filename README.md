# parkrun_parser
Extracting data from parkrun.org to build a data source for my running club, West 4 Harriers

## parkrun_functions.R
Contains two functions, both designed for handling the consolidated club report page, e.g. http://www.parkrun.com/results/consolidatedclub/?clubNum=1242

### extract_parkrun_cc_report_urls
This function will take one or a list of consolidated club report urls, visit each parkrun mentioned and extract all of that week's results. 

A data frame of all the results will be returned once parsing has been completed. This function also handles known variations in parkrun reporting, e.g. missing positions for french reports, different page names for polish results.

Note: Various delays have been added to stop parkrun blocking IP addresses.

### get_parkrun_cc_report_urls
This function takes two variables:
  - the starting consolidated club report url, with the club number, e.g. http://www.parkrun.com/results/consolidatedclub/?clubNum=1242
  - the number of reports you would like to extract, e.g. the last 10 reports

The url list produced by this function call can then be fed back into extract_parkrun_cc_report_urls to retrieve the full results
Note: Various delays have been added to stop parkrun blocking IP addresses.


## parkrun_import_lastest_week.R
This is a script I run as a scheduled task every Sunday morning (around 1am). This extracts the latest week of data, combines it with my existing dataset and uploads it to Google Sheets where it is then updated in Tableau Public, here: https://public.tableau.com/profile/will7508#!/vizhome/West4HarriersParkrunReport/Introduction

Note: Tableau refreshes the Google Sheets data source around 10am, this is currently unchangable.
