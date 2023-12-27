library(purrr)
library(arrow)
library(fs)
library(stringr)
library(dplyr)
download_dir <- "download"
data_dir <- "brick"
fs::dir_create(data_dir)

# get col names for tables
extract_cols <- function(table_str) {
    col_regex <- "`([\\w|\\d]*)`"
    stringr::str_match_all(table_str, col_regex)[[1]][, 2]
}
table_regex <- "CREATE TABLE `(\\w*)` \\(([\\s|\\w|`|\\(|\\)|,|'|=]*)\\)"
sql_file <- "download/tables.sql"
sql_str <- readChar(sql_file, file.info(sql_file)$size)
df <- stringr::str_match_all(sql_str, table_regex) |>
    data.frame() |>
    dplyr::select(X2, X3) |>
    dplyr::rename("Table_Name" = X2, "Col_Defs" = X3) |>
    dplyr::rowwise() |>
    dplyr::mutate("Col_Names" = list(extract_cols(Col_Defs))) |>
    dplyr::select("Table_Name", "Col_Names")

# Process the files into tables
process_file <- function(filename) {
    table_name <- basename(filename) |>
        strsplit("\\.") |>
        purrr::pluck(1) |>
        purrr::pluck(1)
    parquet_name <- paste0(table_name, ".parquet")
    col_names <- df |>
        dplyr::filter(Table_Name == table_name) |>
        dplyr::select(Col_Names) |>
        pluck(1) |> pluck(1)
    df <- vroom::vroom(filename,col_names=FALSE)
    colnames(df) <- col_names
    arrow::write_parquet(df,sink=file.path(data_dir,parquet_name))
}

fs::dir_ls(path = download_dir, glob = "*.gz") |>
    map(process_file)