Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/pandoc")
Sys.setenv(RMARKDOWN_MATHJAX_PATH="C:/Program Files/RStudio/resources/mathjax-23/MathJax.js")
library(bookdown)
unlink('_bookdown_files', recursive = TRUE)

tryCatch(bookdown::render_book('.'), error= function(e) stop(e))
