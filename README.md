
<!-- README.md is generated from README.Rmd. Please edit that file -->

# glockr

*A **g**o **l**anguage c**o**de **c**ounter pac**k**age in **r***

<!-- badges: start -->

<!-- badges: end -->

The goal of `glockr` is to wrap the [`scc` code
counter](https://github.com/boyter/scc) in an R package:

> “*Goal is to be the fastest code counter possible, but also perform
> COCOMO calculation like sloccount, LOCOMO estimation for LLM-based
> development costs, estimate code complexity similar to cyclomatic
> complexity calculators and produce unique lines of code or DRYness
> metrics. In short one tool to rule them all.*”

This project was hugely inspired by the [`cloc` R
package](https://github.com/hrbrmstr/cloc) by [boB
Rudis](https://github.com/hrbrmstr).

## Installation

You can install the development version of `glockr` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("mjfrigaard/glockr")
```

## Examples

Below is an example using the popular [`dplyr`
package](https://dplyr.tidyverse.org/).

``` r
library(glockr)
scc_version()
#> [1] "scc version 3.7.0"
```

``` r
pkg_path <- system.file(package = "dplyr")
```

Set `uloc` to `TRUE` for the weighted complexity.

``` r
scc(pkg_path, uloc = TRUE)
#> # A tibble: 6 × 10
#>   language files lines  code comments blanks complexity weighted_complexity
#>   <chr>    <int> <int> <int>    <int>  <int>      <int>               <dbl>
#> 1 HTML        12  8905  8490       20    395          0                0   
#> 2 Markdown     1  3611  2387        0   1224          0                0   
#> 3 R           10  1561   853      401    307         29                3.40
#> 4 CSS          1   130   106        0     24          0                0   
#> 5 SVG         10    10    10        0      0          0                0   
#> 6 License      1     2     2        0      0          0                0   
#> # ℹ 2 more variables: bytes <int>, uloc <int>
```

Filter to just the R source files and sort by `complexity` for a tighter
view:

``` r
r_files <- scc_by_file(pkg_path, include_ext = "r")
r_files_sub <- r_files[, c("filename", "lines", "code", "comments", "blanks", "complexity")]
r_files_sub[order(r_files_sub$complexity, decreasing = TRUE), ]
#> # A tibble: 10 × 6
#>    filename             lines  code comments blanks complexity
#>    <chr>                <int> <int>    <int>  <int>      <int>
#>  1 base.R                 164    83       40     41         10
#>  2 programming.R          189   124       35     30          6
#>  3 recoding-replacing.R   291   195       53     43          5
#>  4 dplyr.R                152    66       53     33          2
#>  5 rowwise.R              203   112       50     41          2
#>  6 window-functions.R     101    41       37     23          2
#>  7 grouping.R             143    81       29     33          2
#>  8 colwise.R              173    96       43     34          0
#>  9 in-packages.R           71    19       41     11          0
#> 10 two-table.R             74    36       20     18          0
```

`scc` estimates cyclomatic complexity by counting control-flow keywords
(`if`, `for`, `while`, etc.). The `complexity` column is the raw total;
`weighted_complexity` divides by lines of code to give a per-line rate.

``` r
r_files[order(-r_files$weighted_complexity),
        c("filename", "code", "complexity", "weighted_complexity")]
#> # A tibble: 10 × 4
#>    filename              code complexity weighted_complexity
#>    <chr>                <int>      <int>               <dbl>
#>  1 base.R                  83         10               12.0 
#>  2 window-functions.R      41          2                4.88
#>  3 programming.R          124          6                4.84
#>  4 dplyr.R                 66          2                3.03
#>  5 recoding-replacing.R   195          5                2.56
#>  6 grouping.R              81          2                2.47
#>  7 rowwise.R              112          2                1.79
#>  8 colwise.R               96          0                0   
#>  9 in-packages.R           19          0                0   
#> 10 two-table.R             36          0                0
```

`scc_languages()` returns every language `scc` recognizes, along with
the file extensions it maps to that language.

``` r
langs <- scc_languages()
nrow(langs)
#> [1] 358
```

Number of languages:

``` r
#> [1] 358
```

``` r
head(langs, 10)
#> # A tibble: 10 × 2
#>    language     extensions     
#>    <chr>        <chr>          
#>  1 ABAP         abap           
#>  2 ABNF         abnf           
#>  3 ActionScript as             
#>  4 Ada          ada,adb,ads,pad
#>  5 Agda         agda           
#>  6 Alchemist    crn            
#>  7 Alex         x              
#>  8 Algol 68     a68            
#>  9 Alloy        als            
#> 10 Amber        ab
```

``` r
#> # A tibble: 10 × 2
#>    language     extensions     
#>    <chr>        <chr>          
#>  1 ABAP         abap           
#>  2 ABNF         abnf           
#>  3 ActionScript as             
#>  4 Ada          ada,adb,ads,pad
#>  5 Agda         agda           
#>  6 Alchemist    crn            
#>  7 Alex         x              
#>  8 Algol 68     a68            
#>  9 Alloy        als            
#> 10 Amber        ab
```

Last published: 2026-05-18 13:43:52.958717
