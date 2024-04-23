library(purrr)
library(arrow)
library(fs)
library(stringr)
library(dplyr)
library(tools)
library(rvest)

download_dir <- "download"
data_dir <- "brick"
fs::dir_create(data_dir)

clean_html <- function(html) {
    raw_text <- rvest::html_text(html)
    raw_text
}

save_parquet <- function(file) {
    print(file)
    path <- file |>
        fs::path_file() |>
        paste0(".", "parquet")
    file_ext <- file_ext(file)
    if (file_ext == "fa") {
		print(file)
        file.copy(from = file, to = paste0(data_dir, "/", basename(file)))
    } else if (file_ext == "gff3") {
        df <- vroom::vroom(file, delim = "\t", comment="#", col_names = c(
            "seqid", "source", "type", "start", # nolint: indentation_linter.
            "end", "score", "strand", "phase", "attributes"
        ))
        arrow::write_parquet(df, fs::path(data_dir, path))
    } else if (!grepl("dat|dead|diff|html", file_ext)) {
        df <- vroom::vroom(file, delim = "\t")
        df <- df %>%
            rename_with(~ gsub("^#", "", .), 1)
        arrow::write_parquet(df, fs::path(data_dir, path))
    }
    
}

fs::dir_walk("./download", save_parquet)
