scc_available <- nchar(Sys.which("scc")) > 0L

# Helper: create an isolated temp dir and populate it with known files.
# Returns the dir path; cleanup is automatic via withr.
make_test_dir <- function(files) {
  dir <- withr::local_tempdir(.local_envir = parent.frame())
  for (nm in names(files)) {
    writeLines(files[[nm]], file.path(dir, nm))
  }
  dir
}

# Known R file content:
#   3 code lines, 2 comment lines, 1 blank line → 6 lines total
r_content <- c(
  "# comment one",
  "# comment two",
  "x <- 1",
  "y <- 2",
  "",
  "z <- 3"
)

# Known Python file content:
#   2 code lines, 1 comment line, 1 blank line → 4 lines total
py_content <- c(
  "# python comment",
  "x = 1",
  "",
  "y = 2"
)

# --- find_scc() -------------------------------------------------------------

test_that("find_scc() returns a valid path when scc is installed", {
  skip_if_not(scc_available, "scc not on PATH")
  path <- glockr:::find_scc()
  expect_type(path, "character")
  expect_true(file.exists(path))
})

test_that("find_scc() stops with an informative message when scc is absent", {
  withr::with_envvar(c(PATH = ""), {
    expect_error(glockr:::find_scc(), regexp = "Cannot find 'scc'")
    expect_error(glockr:::find_scc(), regexp = "boyter/scc")
  })
})

# --- scc_version() ----------------------------------------------------------

test_that("scc_version() returns a string containing 'scc'", {
  skip_if_not(scc_available, "scc not on PATH")
  v <- scc_version()
  expect_type(v, "character")
  expect_length(v, 1L)
  expect_match(v, "scc")
})

# --- scc_languages() --------------------------------------------------------

test_that("scc_languages() returns a tibble with language and extensions columns", {
  skip_if_not(scc_available, "scc not on PATH")
  langs <- scc_languages()
  expect_s3_class(langs, "tbl_df")
  expect_named(langs, c("language", "extensions"))
})

test_that("scc_languages() includes well-known languages", {
  skip_if_not(scc_available, "scc not on PATH")
  langs <- scc_languages()
  expect_true("R" %in% langs$language)
  expect_true("Python" %in% langs$language)
  expect_true("Go" %in% langs$language)
})

test_that("scc_languages() returns more than 50 languages", {
  skip_if_not(scc_available, "scc not on PATH")
  langs <- scc_languages()
  expect_gt(nrow(langs), 50L)
})

test_that("scc_languages() extensions column is always non-empty strings", {
  skip_if_not(scc_available, "scc not on PATH")
  langs <- scc_languages()
  expect_true(all(nzchar(langs$extensions)))
})

# --- scc() ------------------------------------------------------------------

test_that("scc() returns a tibble", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir)
  expect_s3_class(result, "tbl_df")
})

test_that("scc() has the expected column names", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir)
  expect_named(result,
    c("language", "files", "lines", "code", "comments", "blanks",
      "complexity", "weighted_complexity", "bytes", "uloc"))
})

test_that("scc() counts lines = code + comments + blanks", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir)
  r_row  <- result[result$language == "R", ]
  expect_equal(r_row$lines, r_row$code + r_row$comments + r_row$blanks)
})

test_that("scc() detects the correct language for .R files", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir)
  expect_true("R" %in% result$language)
})

test_that("scc() counts one file when given one file", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("a.R" = r_content))
  result <- scc(dir)
  r_row  <- result[result$language == "R", ]
  expect_equal(r_row$files, 1L)
})

test_that("scc() aggregates multiple files of the same language", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list("a.R" = r_content, "b.R" = r_content))
  result <- scc(dir)
  r_row  <- result[result$language == "R", ]
  expect_equal(r_row$files, 2L)
})

test_that("scc() returns a row for each language present", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list("script.R" = r_content, "script.py" = py_content))
  result <- scc(dir)
  expect_true("R"      %in% result$language)
  expect_true("Python" %in% result$language)
})

test_that("scc() include_ext restricts results to the specified language", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list("script.R" = r_content, "script.py" = py_content))
  # scc normalises extensions to lowercase: use "py" not "py" (unambiguous)
  result <- scc(dir, include_ext = "py")
  expect_true("Python" %in% result$language)
  expect_false("R"     %in% result$language)
})

test_that("scc() exclude_ext omits the specified language", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list("script.R" = r_content, "script.py" = py_content))
  # scc normalises extensions to lowercase: use "r" not "R"
  result <- scc(dir, exclude_ext = "r")
  expect_true("Python" %in% result$language)
  expect_false("R"     %in% result$language)
})

test_that("scc() no_complexity = TRUE sets complexity to 0", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, no_complexity = TRUE)
  expect_true(all(result$complexity == 0L))
})

test_that("scc() returns 0-row tibble for a directory with no recognised files", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("notes.xyz_unknown" = c("hello")))
  result <- scc(dir)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0L)
})

test_that("scc() bytes column is positive for non-empty files", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir)
  expect_true(all(result$bytes > 0L))
})

# --- scc_by_file() ----------------------------------------------------------

test_that("scc_by_file() returns a tibble", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc_by_file(dir)
  expect_s3_class(result, "tbl_df")
})

test_that("scc_by_file() has the expected column names", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc_by_file(dir)
  expect_named(result,
    c("language", "filename", "location", "lines", "code", "comments",
      "blanks", "complexity", "weighted_complexity", "bytes",
      "generated", "minified"))
})

test_that("scc_by_file() returns one row per file", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("a.R" = r_content, "b.R" = r_content))
  result <- scc_by_file(dir)
  r_rows <- result[result$language == "R", ]
  expect_equal(nrow(r_rows), 2L)
})

test_that("scc_by_file() location is an absolute path to an existing file", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc_by_file(dir)
  expect_true(all(startsWith(result$location, "/")))
  expect_true(all(file.exists(result$location)))
})

test_that("scc_by_file() filename matches the basename of location", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc_by_file(dir)
  expect_equal(result$filename, basename(result$location))
})

test_that("scc_by_file() generated and minified are logical columns", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc_by_file(dir)
  expect_type(result$generated, "logical")
  expect_type(result$minified,  "logical")
})

test_that("scc_by_file() lines = code + comments + blanks per file", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc_by_file(dir)
  expect_equal(result$lines, result$code + result$comments + result$blanks)
})

test_that("scc_by_file() returns 0-row tibble for unrecognised files", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("data.xyz_unknown" = c("hello")))
  result <- scc_by_file(dir)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0L)
})
