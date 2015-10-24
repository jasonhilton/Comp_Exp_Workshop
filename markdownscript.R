### Script to generate md file from rmd file
setwd("Z:/mydocuments/Documents/conferences and papers/abm course")
library(knitr)


knit("master_Mac_Design_and_Analysis_Computer_Experiments.Rmd")
knit("master_Design_and_Analysis_Computer_Experiments.Rmd")

render("master_Design_and_Analysis_Computer_Experiments.md", pdf_document())
knit("apply_basics.Rmd")




library(rmarkdown)
pandoc_convert('Design_and_Analysis_Computer_Experiments.md', to="html", output= "Design_and_Analysis_Computer_Experiments.html")
render('Design_and_Analysis_Computer_Experiments.md',html_document())