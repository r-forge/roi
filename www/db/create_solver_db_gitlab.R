library("curl")
library("jsonlite")
library("gitlabr")
source("create_solver_db_functions.R")


resp <- curl_fetch_memory("https://gitlab.com/api/v4/groups/14294280/projects")
json <- rawToChar(resp[["content"]])
df <- fromJSON(json)
df <- df[, sapply(df, function(x) sum(lengths(x)) > 0)]
df <- df[, sapply(df, function(x) sum(nchar(x), na.rm = TRUE) > 0)]
df <- df[grepl("^ROI\\.plugin\\.", df$name, ignore.case = TRUE), ]
df <- df[!grepl("-deleted-", df$name), ]
head(colnames(df), 30)
sort(df[, "name"])


prefix <- "roigrp/solver"
r_version <- "R"
lib.loc <- head(.libPaths(), 1)
?unique
solver_names <- unique(sort(c("ROI.plugin.gurobi", df$name)))
repos <- file.path(prefix, solver_names, fsep = "/")
# repos <- repos[!basename(repos) %in% installed.packages()[, 1]]
# remotes::install_gitlab(repos[3])


CRAN <- "https://cran.r-project.org/"

## r_version, lib.loc, repos
solver_db_gitlab <- create_solver_db_gitlab(r_version, lib.loc, repos, CRAN, reinstall = FALSE)
setdiff(solver_names, solver_db_gitlab$Package)
solver_db_gitlab$Repository

b <- sapply(solver_db_gitlab$Signature, nrow) == 0L
solver_db_gitlab$Package[b]

saveRDS(solver_db_gitlab, file = "SOLVERS_GITLAB.rds")


if (FALSE) {
    r_version <- R
    lib.loc <- head(.libPaths(), 1L)
    cran <- CRAN
    repos <- REPOS

    as <- ROI:::ROI_available_solvers(milp)[, c("Package", "Repository")]
    sub("/ROI.plugin.*", "", as$Repository)
}
