suppressWarnings
suppressMessages

details <- read.csv(file = "gmail_details.csv")
sender <- details$email
client_id <- details$client_id
client_secret <- details$client_secret


library(rmarkdown)
rmarkdown::render("parkrun_report.Rmd", "html_document")
rawHTML <- paste(readLines("parkrun_report.html"), collapse="\n")

library(gmailr)

gmail_auth(scope = "full",
		 id = client_id,
		 secret = client_secret, 
		 secret_file = NULL)

draft <- (mime() %>%
		  to(recipients) %>% 
		  from(sender) %>%
		  subject("Weekly West 4 Harriers Parkrun Report") %>%
		  html_body(rawHTML)
		)

send_message(draft)