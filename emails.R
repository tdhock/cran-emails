if(!file.exists("packages.rds")){
  download.file(
    "https://cloud.r-project.org/web/packages/packages.rds",
    "packages.rds")
}
pkg_mat <- readRDS("packages.rds")
library(data.table)
pkg_dt <- data.table(pkg_mat)
subject <- paste(pkg_mat[,"Authors@R"], pkg_mat[,"Author"])
email_pkg_dt <- pkg_dt[, nc::capture_all_str(
  paste(`Authors@R`, Author),
  '["<]',
  email=list('[^">]+@', domain='.*?'),
  '[">]'),
  by=Package]
domains <- c(
  "novartis", "roche", "google", "amazon", "facebook", "apple", 
  "microsoft", "jpmorganchase", "goldmansachs", "bankofamerica", 
  "morganstanley", "citigroup", "barclays", "wellsfargo", "bnpparibas", 
  "db", "jefferies")
domain_pat <- paste0("(", paste(domains, collapse="|"), ")[.]")
company_dt <- email_pkg_dt[
  grep(domain_pat, domain)
][order(domain, email)]
(email_dt <- company_dt[, .(
  packages=length(unique(Package)),
  emails=length(unique(email))
), by=domain][order(-emails, -packages)])
fwrite(company_dt[, .(email,Package)], "emails.csv")
