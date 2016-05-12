git pull origin master
Rscript.exe generate-gh-pages.R
git add -A
git commit -m "Update gh-pages"
git push origin gh-pages
