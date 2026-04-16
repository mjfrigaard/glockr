# Fixtures -----------------------------------------------------------------

lang_json <- '[
  {
    "Name": "R",
    "Bytes": 200,
    "CodeBytes": 0,
    "Lines": 10,
    "Code": 6,
    "Comment": 2,
    "Blank": 2,
    "Complexity": 3,
    "Count": 2,
    "WeightedComplexity": 3,
    "Files": [],
    "LineLength": null,
    "ULOC": 5
  },
  {
    "Name": "Python",
    "Bytes": 150,
    "CodeBytes": 0,
    "Lines": 8,
    "Code": 5,
    "Comment": 1,
    "Blank": 2,
    "Complexity": 1,
    "Count": 1,
    "WeightedComplexity": 1,
    "Files": [],
    "LineLength": null,
    "ULOC": 4
  }
]'

by_file_json <- '[
  {
    "Name": "R",
    "Bytes": 200,
    "CodeBytes": 0,
    "Lines": 10,
    "Code": 6,
    "Comment": 2,
    "Blank": 2,
    "Complexity": 3,
    "Count": 2,
    "WeightedComplexity": 3,
    "Files": [
      {
        "Language": "R",
        "PossibleLanguages": ["R"],
        "Filename": "foo.R",
        "Extension": "R",
        "Location": "/project/foo.R",
        "Symlocation": "",
        "Bytes": 120,
        "Lines": 6,
        "Code": 4,
        "Comment": 1,
        "Blank": 1,
        "Complexity": 2,
        "WeightedComplexity": 2,
        "Hash": null,
        "Binary": false,
        "Minified": false,
        "Generated": false,
        "EndPoint": 0,
        "Uloc": 4
      },
      {
        "Language": "R",
        "PossibleLanguages": ["R"],
        "Filename": "bar.R",
        "Extension": "R",
        "Location": "/project/bar.R",
        "Symlocation": "",
        "Bytes": 80,
        "Lines": 4,
        "Code": 2,
        "Comment": 1,
        "Blank": 1,
        "Complexity": 1,
        "WeightedComplexity": 1,
        "Hash": null,
        "Binary": false,
        "Minified": true,
        "Generated": true,
        "EndPoint": 0,
        "Uloc": 2
      }
    ],
    "LineLength": null,
    "ULOC": 5
  },
  {
    "Name": "Python",
    "Bytes": 0,
    "CodeBytes": 0,
    "Lines": 0,
    "Code": 0,
    "Comment": 0,
    "Blank": 0,
    "Complexity": 0,
    "Count": 0,
    "WeightedComplexity": 0,
    "Files": [],
    "LineLength": null,
    "ULOC": 0
  }
]'

# --- parse_scc_json() by_file = FALSE ---------------------------------------

test_that("parse_scc_json() returns a tibble for language-level JSON", {
  result <- glockr:::parse_scc_json(lang_json, by_file = FALSE)
  expect_s3_class(result, "tbl_df")
})

test_that("parse_scc_json() has the correct columns for language-level output", {
  result <- glockr:::parse_scc_json(lang_json, by_file = FALSE)
  expect_named(result,
    c("language", "files", "lines", "code", "comments", "blanks",
      "complexity", "weighted_complexity", "bytes", "uloc"))
})

test_that("parse_scc_json() returns one row per language", {
  result <- glockr:::parse_scc_json(lang_json, by_file = FALSE)
  expect_equal(nrow(result), 2L)
})

test_that("parse_scc_json() maps JSON fields to the correct columns", {
  result <- glockr:::parse_scc_json(lang_json, by_file = FALSE)
  r_row  <- result[result$language == "R", ]
  expect_equal(r_row$files,               2L)
  expect_equal(r_row$lines,              10L)
  expect_equal(r_row$code,               6L)
  expect_equal(r_row$comments,           2L)
  expect_equal(r_row$blanks,             2L)
  expect_equal(r_row$complexity,         3L)
  expect_equal(r_row$weighted_complexity,3L)
  expect_equal(r_row$bytes,            200L)
  expect_equal(r_row$uloc,              5L)
})

test_that("parse_scc_json() column types are correct for language-level output", {
  result <- glockr:::parse_scc_json(lang_json, by_file = FALSE)
  expect_type(result$language,            "character")
  expect_type(result$files,               "integer")
  expect_type(result$lines,               "integer")
  expect_type(result$code,                "integer")
  expect_type(result$comments,            "integer")
  expect_type(result$blanks,              "integer")
  expect_type(result$complexity,          "integer")
  expect_type(result$weighted_complexity, "integer")
  expect_type(result$bytes,               "integer")
  expect_type(result$uloc,                "integer")
})

# --- parse_scc_json() by_file = TRUE ----------------------------------------

test_that("parse_scc_json() returns a tibble for by-file JSON", {
  result <- glockr:::parse_scc_json(by_file_json, by_file = TRUE)
  expect_s3_class(result, "tbl_df")
})

test_that("parse_scc_json() has the correct columns for by-file output", {
  result <- glockr:::parse_scc_json(by_file_json, by_file = TRUE)
  expect_named(result,
    c("language", "filename", "location", "lines", "code", "comments",
      "blanks", "complexity", "weighted_complexity", "bytes",
      "generated", "minified"))
})

test_that("parse_scc_json() returns one row per file (languages without files dropped)", {
  result <- glockr:::parse_scc_json(by_file_json, by_file = TRUE)
  # Python block has 0 files → only R's 2 files appear
  expect_equal(nrow(result), 2L)
  expect_true(all(result$language == "R"))
})

test_that("parse_scc_json() maps file-level JSON fields correctly", {
  result   <- glockr:::parse_scc_json(by_file_json, by_file = TRUE)
  foo_row  <- result[result$filename == "foo.R", ]
  expect_equal(foo_row$location,  "/project/foo.R")
  expect_equal(foo_row$lines,     6L)
  expect_equal(foo_row$code,      4L)
  expect_equal(foo_row$comments,  1L)
  expect_equal(foo_row$blanks,    1L)
  expect_equal(foo_row$bytes,     120L)
  expect_false(foo_row$generated)
  expect_false(foo_row$minified)
})

test_that("parse_scc_json() sets generated and minified TRUE from JSON", {
  result  <- glockr:::parse_scc_json(by_file_json, by_file = TRUE)
  bar_row <- result[result$filename == "bar.R", ]
  expect_true(bar_row$generated)
  expect_true(bar_row$minified)
})

test_that("parse_scc_json() generated and minified are always logical", {
  result <- glockr:::parse_scc_json(by_file_json, by_file = TRUE)
  expect_type(result$generated, "logical")
  expect_type(result$minified,  "logical")
})

# --- empty / edge cases -----------------------------------------------------

test_that("parse_scc_json() returns 0-row tibble for empty JSON array", {
  result <- glockr:::parse_scc_json("[]", by_file = FALSE)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0L)
})

test_that("parse_scc_json() returns 0-row by-file tibble for empty JSON array", {
  result <- glockr:::parse_scc_json("[]", by_file = TRUE)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0L)
})

test_that("parse_scc_json() returns 0-row tibble for blank input", {
  result <- glockr:::parse_scc_json("", by_file = FALSE)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0L)
})

test_that("empty tibbles have the correct column schema", {
  lang_empty    <- glockr:::parse_scc_json("[]", by_file = FALSE)
  by_file_empty <- glockr:::parse_scc_json("[]", by_file = TRUE)

  expect_named(lang_empty,
    c("language", "files", "lines", "code", "comments", "blanks",
      "complexity", "weighted_complexity", "bytes", "uloc"))
  expect_named(by_file_empty,
    c("language", "filename", "location", "lines", "code", "comments",
      "blanks", "complexity", "weighted_complexity", "bytes",
      "generated", "minified"))
})
