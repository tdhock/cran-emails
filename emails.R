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

commercial_patterns <- c(
  "novartis", "roche", "google", "amazon", "facebook", "apple", 
  "microsoft",
  "iddb", "appsilon", "certara", "merck", "poissonconsulting",
  "gene", "cynkra", "thinkr", "gsk", "windsor", "openanalytics",
  "erasmusmc", "atorusresearch", "humanpredictions", "pfizer", "ixpantia",
  "boehringer-ingelheim", "business-science", "lilly", "astrazeneca",
  "sanofi", "dreamrs", "rand", "win-vector", "civisanalytics", "novonordisk",
  "symbolix", "ardata", "westat", "4dscape", "mango-solutions",
  "bnosac", "abbvie", "epiconcept", "for-cast", "h2o", "insight-rx",
  "sunholo", "crunch", "analythium", "biogen", "eworkx", "occams",
  "mirai-solutions", "bayer", "rte-france", "curso-r", "bms", "amgen",
  "medtronic", "sevenbridges", "velsera", "menne-biomed", "databricks",
  "aggregate-genius", "peak.ai", "rconis.com", "walker-data.com",
  "metrumrg.com", "tidy-intelligence.com", "datastorm.fr", "utiligize.com",
  "fromdatatowisdom.com", "helgasoft.com",
  ##"arjohnsonau.com",
  "ibacon.com",
  ##"flowervalleyconsulting.com",
  ##"statistikkonsult.com",
  "illumina.com",
  "gradientmetrics.com",
  "softwareag.com",
  "beckman.com",
  "jumpingrivers.com",
  "tillotts.com",
  "zarathu.com",
  "canva.com",
  "experis.com",
  "wlogsolutions.com",
  "fellstat.com",
  "lixoft.com",
  "quantil")
domain_pat <- paste0("(", paste(commercial_patterns, collapse="|"), ")[.]")
company_dt <- email_pkg_dt[
  grep(domain_pat, domain)
][order(domain, email)]
(email_dt <- company_dt[, .(
  packages=length(unique(Package)),
  emails=length(unique(email))
), by=domain][order(-emails, -packages)])
fwrite(company_dt[, .(email,Package)], "emails.csv")

domains_dt <- email_pkg_dt[, .(
  count=.N
), by=domain
][
  order(-count)
][
, commercial := ifelse(count >= 4, 0, NA)
][
  company_dt, commercial := 1, on="domain"
][]
fwrite(domains_dt, "domains.csv")
