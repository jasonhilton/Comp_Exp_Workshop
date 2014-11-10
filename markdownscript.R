### Script to generate md file from rmd file
setwd("Z:/mydocuments/Documents/conferences and papers/abm course")
library(knitr)


knit("master_Design_and_Analysis_Computer_Experiments.Rmd")

render("master_Design_and_Analysis_Computer_Experiments.md", pdf_document())
knit("apply_basics.Rmd")

library(rmarkdown)
render('Design_and_Analysis_Computer_Experiments.md',html_document())
