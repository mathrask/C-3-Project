require(knitr)
require(markdown)
#Set wd
path <-getwd()
setwd(")
knit("run_analysis.Rmd", encoding="ISO8859-1")
markdownToHTML("run_analysis.md", "run_analysis.html")