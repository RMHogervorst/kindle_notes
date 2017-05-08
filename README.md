Turning kindle notes into a tidy data
================

It is my dream to do everything with R. And we aRe almost there. We can write blogs in blogdown or bookdown, write reports in RMarkdown (thank you [Yihui Xie!](https://twitter.com/xieyihui)) create interactive webpages with Shiny (thank you [Winston Chang](https://twitter.com/winston_chang)). Control our lifx lights with [lifxr](https://github.com/cboettig/lifxr) (great work [Carl!](http://carlboettiger.info/)) and use emoticons everywhere with the emo package.

There is even a novel of my vision! I recently found chapter 40 of [A Dr. Primestein Adventure™ The Day the Priming Stopped](http://www.psi-chology.com/the-day-the-priming-stopped/). There is a scene in there which says:

> “This Fortress is a monumental technological achievement,” explained Professor Power. “Every aspect of the Fortress’s security is run by R.” As they arrived at the metal doors, the Professor pressed a small button on the wall to the right. “This is an elevatoR, run by its own R package.” They waited for the doors to open, but nothing happened. After a few minutes of alternately waiting and then mashing the elevatoR button, Professor Power called someone on his mobile phone. “The eleva- toR is not working...what? Why would they do that?...call Hadley Wickham!...doesn’t anyone around here check packages against the development version of R before upgrading?...yes, we’ll wait.” “Someone upgraded R without permission. Should be fixed soon,” Professor Power explained.

But enough about jokeRs and jesteRs. As it is my life long mission to do everything in R and preferably in the [tidyverse](http://tidyverse.org/), I found something that wasn't tidy 😞 !!! Kindle notes!

kindle notes and highlights.
============================

I have a 2010 kindle to read E-books on and once in a while I write a note or highlight some text in the book. If you connect your kindle to the computer you can extract the highlights by copying the file \`My Clippings.txt' to your computer.

This is great, it's a text file which means you can open it on every computer and search throug the contents. However...

> It's not tidy.

Let's change that. The general procedure is thus:

1.  Create a new project in Rstudio
2.  Create a new folder called `data` (or don't but really this is neat isn't it?)
3.  Copy the `My Clippings.txt` file to that `data`-folder
4.  Load the tidyverse \`library(tidyverse)'
5.  Hammer away untill the txt file is a data frame.
6.  profit?

### What is in this text file?

First we do some exploratory work on the file. I've found that the text file is structured in a particular way:

    title  (author)
    - Highlight on Page 128 | Loc. 1962-68  | Added on Sunday, December 27, 2015, 03:09 PM
    <empty line>
    highlighted text
    ==========
    title of the next highlighted book (author)
    etc.

**So how do we force this into a data frame?**

Recognize the structure ( we will create functions for that)

-   Chunks end with the ten ===== signs, we can split on that
-   first line is the title and (author)
-   *we can seperate the author and the title*
-   next line of information is devided by '|' signs.
-   *type, page, location, added date and time (in american time of course...)*
-   highlighted text (or if it is a bookmark, nothing)

``` r
library(tidyverse)
```

    ## Loading tidyverse: ggplot2
    ## Loading tidyverse: tibble
    ## Loading tidyverse: tidyr
    ## Loading tidyverse: readr
    ## Loading tidyverse: purrr
    ## Loading tidyverse: dplyr

    ## Conflicts with tidy packages ----------------------------------------------

    ## filter(): dplyr, stats
    ## lag():    dplyr, stats

``` r
raw_text <- read_file("data/My Clippings.txt") # read in the text file
per_chunk <- unlist(strsplit(raw_text, "=========="))  # seperate into chunks
per_chunk[4]
```

    ## [1] "\r\nThe Clean Coder_ A Code of Conduct For Professional Programmers - Robert C. Martin (Robert C. Martin)\r\n- Highlight on Page 90 | Added on Monday, January 25, 2016, 04:06 PM\r\n\r\nK ATA In martial arts, a kata is a precise set of choreographed movements that simulates one side of a combat. The goal, which is asymptotically approached, is perfection. The artist strives to teach his body to make each movement perfectly and to assemble those movements into fluid enactment. Well-executed kata are beautiful to watch. Beautiful though they are, the purpose of learning a kata is not to perform it on stage. The purpose is to train your mind and body how to react in a particular combat situation. The goal is to make the perfected movements automatic and instinctive so that they are there when you need them. A programming kata is a precise set of choreographed keystrokes and mouse movements that simulates the solving of some programming problem. You arent actually solving the problem because you already know the solution. Rather, you are practicing the movements and decisions involved in solving the problem.\r\n"

Above I have created seperate chunks that represent seperate highlights. And a example so you can see what I see.

Now for extracting the seperate elements. I create functions that do one thing.

``` r
# This function takes a chunk of character information
# and seperates it into lines. 
seperate_into_lines <- function(chunk){
    result <- stringr::str_split(chunk, "\r\n")
    unlist(result)
}
# result <- seperate_into_lines(per_chunk[100])  # testing if this works 
## you should put this into formal test frameworks such as testhat if you
## build a package. 



# Extract title sentance and remove author
# This function presumes that you already extracted the raw data into
# character chunks.
extract_title <- function(linechunk){
    # search for second line
    titleline <- linechunk[2]
    return <- gsub("\\(.*\\)", "", titleline) # it took me some 
            #time to work this regular expression out.
    stringr::str_trim(return, side = "both") # remove whitespace at ends
}
#extract_title(result) # testcase to see if it works for me.


# Extract the author from chunk, this function looks 
# very much like the one above, it uses the same logic.
extract_author <- function(linechunk){
    # search for second line
    titleline <- linechunk[2] # identical
    author <- stringr::str_extract(titleline, "\\(.*\\)") # extract piece
    return <- gsub("\\(|\\)", "", author)  # 
    stringr::str_trim(return, side = "both")
}
# extract_author(result)
```

Let's see if this works on a subset of the data. I usually take multiple notes in one book before I open another, so in this case the first 20 notes are really boring and all from the same book. To spice this up I take a random subset of rows. I will use a simple for-loop here, but I will use functional programming in the end-result. It works kind of the same, but is more explicit.

Some people will tell you that for-loops are slow in R, or that 'loops are bad' but they don't know what they are talking about.[1]

I first create a data\_frame [2] and pre-populate it.

``` r
# testset <- per_chunk[1:20]  # You would use this if you want the first 20 pieces.
set.seed(4579)  # if you do random stuff, it is wise to 
# set the seed so that others can reproduce your work.
testset <- per_chunk[base::sample(x =1:length(per_chunk),size = 20)] 
# unfortunately dplyr also has a function called sample. to specify that
# we want the 'normal' one I specify the name of the package followed by
# two ':'. 
testingframe <- data_frame(
    author = character(length = length(testset)),
    title = character(length(testset)))
for( i in seq_along(testset)){
    hold <- testset[i] %>% seperate_into_lines()
    testingframe$author[i] <- hold %>% extract_author()
    testingframe$title <- hold %>% extract_title()
}
testingframe
```

    ## # A tibble: 20 × 2
    ##                                     author
    ##                                      <chr>
    ## 1             Andrew Hunt and David Thomas
    ## 2             Andrew Hunt and David Thomas
    ## 3                            Alex Reinhart
    ## 4                              David Price
    ## 5            City Watch #1 Terry Pratchett
    ## 6            City Watch #1 Terry Pratchett
    ## 7                              Mark Manson
    ## 8                     Kim Stanley Robinson
    ## 9                     Kim Stanley Robinson
    ## 10                    Kim Stanley Robinson
    ## 11         Douglas DeCarlo, James P. Lewis
    ## 12                             David Price
    ## 13           City Watch #2 Terry Pratchett
    ## 14 Kenneth Knoblauch & Laurence T. Maloney
    ## 15                           Alex Reinhart
    ## 16            Andrew Hunt and David Thomas
    ## 17                        Robert C. Martin
    ## 18            Andrew Hunt and David Thomas
    ## 19            Andrew Hunt and David Thomas
    ## 20                             David Price
    ## # ... with 1 more variables: title <chr>

The author and title functions seem to work, let's extract some more information. The third row contained multiple pieces of information

example:

    - Highlight on Page 132 | Loc. 2017-20  | Added on Saturday, August 20, 2016, 09:37 AM

Like the first functions we first select the correct row [3] and than apply some magic.

``` r
# this function extracts all the pieces
# and subsequent functions will deal with the seperate stuff.
extract_type_location_date <- function(linechunk){
    meta_row <- linechunk[3]
    pieces <- stringr::str_split(meta_row, "\\|") # the literal character, 
    # the '|' has a special meaning in regexp.
    unlist(pieces)
}
# extract_type_location_date(result) # test function

# extract type from combined result.
# Here the use of the pipe `%>%` operator 
# makes the steps clear.
extract_type <- function(pieces){
    pieces[1] %>%  # select the first row
        stringr::str_extract( "- [[:alnum:]]{1,} ") %>% # extract at least one character.
        gsub("-", "", .) %>% # replace - with nothing, removing it
        stringr::str_trim( side = "both") # remove whitespace at both sides
}
# extract_type_location_date(result) %>% 
#     extract_type()


# extract page number by selecting first piece,
# trimming off of whitespace
# selecting a number, at least 1 times, followed by end of line.
extract_pagenumber <- function(pieces){
    pieces[1] %>%
        stringr::str_trim( side = "right") %>% # remove right end
        stringr::str_extract("[0-9]{1,}$") %>% 
        as.numeric()
}
# extract_type_location_date(result) %>%
#     extract_pagenumber()

# Extract locations. Just like above.
extract_locations <- function(pieces){
    pieces[2] %>% 
        stringr::str_trim( side = "both") %>% 
        stringr::str_extract("[0-9]{1,}-[0-9]{1,}$")
}
# extract_type_location_date(result) %>% 
#     extract_locations()

# Extract date and convert to standard time, not US centric.
# I use the strptime from the base package here. The time is 
# US-centric, but structured, so we can use the formatting from strptime.
# For example: %B is Full month name in the current locale
# and %I:%M %p means hours, minutes, am/pm. 
extract_date <- function(pieces){
    pieces[3] %>% 
        stringr::str_trim( side = "both") %>% 
        stringr::str_extract("[A-z]{3,} [0-9]{1,2}, [0-9]{4}, [0-9]{2}:[0-9]{2} [A-Z]{2}") %>% 
        strptime(format = "%B %e, %Y, %I:%M %p") 
}

# Extract the highlight part.
extract_highlights <- function(linechunk){
    linechunk[5]
}
# extract_highlights(result)
```

In general:

-   Split into chunks (already did that: per\_chunk)
-   Create a data frame
-   Apply extractors per chunk into data\_frame

-   I would really love it if someone showed me how to do this with purrr

``` r
finalframe <- data_frame(
    author = character(length = length(testset)),
    title = character(length(testset)),
    location = character(length(testset)),
    pagenr = numeric(length(testset)),
    type = character(length(testset)),
    highlight = character(length(testset))
    )
# loop through all values 
for( i in seq_along(testset)){
    hold <- testset[i] %>% seperate_into_lines()
    finalframe$author[i] <- hold %>% extract_author()
    finalframe$title[i] <- hold %>% extract_title()
    finalframe$location[i] <- hold %>% extract_type_location_date() %>% extract_locations()
    finalframe$pagenr[i] <- hold %>% extract_type_location_date() %>% extract_pagenumber()
    finalframe$type[i] <- hold %>% extract_type_location_date() %>% extract_type()
    finalframe$highlight[i] <- hold %>% extract_highlights()
}
finalframe
```

    ## # A tibble: 20 × 6
    ##                                     author
    ##                                      <chr>
    ## 1             Andrew Hunt and David Thomas
    ## 2             Andrew Hunt and David Thomas
    ## 3                            Alex Reinhart
    ## 4                              David Price
    ## 5            City Watch #1 Terry Pratchett
    ## 6            City Watch #1 Terry Pratchett
    ## 7                              Mark Manson
    ## 8                     Kim Stanley Robinson
    ## 9                     Kim Stanley Robinson
    ## 10                    Kim Stanley Robinson
    ## 11         Douglas DeCarlo, James P. Lewis
    ## 12                             David Price
    ## 13           City Watch #2 Terry Pratchett
    ## 14 Kenneth Knoblauch & Laurence T. Maloney
    ## 15                           Alex Reinhart
    ## 16            Andrew Hunt and David Thomas
    ## 17                        Robert C. Martin
    ## 18            Andrew Hunt and David Thomas
    ## 19            Andrew Hunt and David Thomas
    ## 20                             David Price
    ## # ... with 5 more variables: title <chr>, location <chr>, pagenr <dbl>,
    ## #   type <chr>, highlight <chr>

### state of machine

<details> <summary> click to expand to see machine info</summary>

``` r
sessioninfo::session_info()
```

    ## - Session info ----------------------------------------------------------
    ##  setting  value                       
    ##  version  R version 3.3.3 (2017-03-06)
    ##  os       Windows 10 x64              
    ##  system   x86_64, mingw32             
    ##  ui       RTerm                       
    ##  language (EN)                        
    ##  collate  Dutch_Netherlands.1252      
    ##  tz       Europe/Berlin               
    ##  date     2017-05-08                  
    ## 
    ## - Packages --------------------------------------------------------------
    ##  package     * version    date       source                             
    ##  assertthat    0.1        2013-12-06 CRAN (R 3.3.0)                     
    ##  backports     1.0.5      2017-01-18 CRAN (R 3.3.2)                     
    ##  broom         0.4.2      2017-02-13 CRAN (R 3.3.2)                     
    ##  clisymbols    1.1.0      2017-01-27 CRAN (R 3.3.3)                     
    ##  colorspace    1.3-2      2016-12-14 CRAN (R 3.3.2)                     
    ##  DBI           0.6-1      2017-04-01 CRAN (R 3.3.3)                     
    ##  digest        0.6.12     2017-01-27 CRAN (R 3.3.3)                     
    ##  dplyr       * 0.5.0      2016-06-24 CRAN (R 3.3.1)                     
    ##  emo           0.0.0.9000 2017-04-27 Github (hadley/emo@97754fd)        
    ##  evaluate      0.10       2016-10-11 CRAN (R 3.3.3)                     
    ##  forcats       0.2.0      2017-01-23 CRAN (R 3.3.2)                     
    ##  foreign       0.8-67     2016-09-13 CRAN (R 3.3.3)                     
    ##  ggplot2     * 2.2.1      2016-12-30 CRAN (R 3.3.2)                     
    ##  gtable        0.2.0      2016-02-26 CRAN (R 3.3.0)                     
    ##  haven         1.0.0      2016-09-23 CRAN (R 3.3.1)                     
    ##  hms           0.3        2016-11-22 CRAN (R 3.3.2)                     
    ##  htmltools     0.3.5      2016-03-21 CRAN (R 3.3.0)                     
    ##  httr          1.2.1      2016-07-03 CRAN (R 3.3.1)                     
    ##  jsonlite      1.3        2017-02-28 CRAN (R 3.3.3)                     
    ##  knitr         1.15.1     2016-11-22 CRAN (R 3.3.2)                     
    ##  lattice       0.20-35    2017-03-25 CRAN (R 3.3.3)                     
    ##  lazyeval      0.2.0      2016-06-12 CRAN (R 3.3.0)                     
    ##  lubridate     1.6.0      2016-09-13 CRAN (R 3.3.1)                     
    ##  magrittr      1.5        2014-11-22 CRAN (R 3.3.0)                     
    ##  mnormt        1.5-5      2016-10-15 CRAN (R 3.3.2)                     
    ##  modelr        0.1.0      2016-08-31 CRAN (R 3.3.2)                     
    ##  munsell       0.4.3      2016-02-13 CRAN (R 3.3.0)                     
    ##  nlme          3.1-131    2017-02-06 CRAN (R 3.3.3)                     
    ##  plyr          1.8.4      2016-06-08 CRAN (R 3.3.0)                     
    ##  psych         1.7.3.21   2017-03-22 CRAN (R 3.3.3)                     
    ##  purrr       * 0.2.2      2016-06-18 CRAN (R 3.3.1)                     
    ##  R6            2.2.0      2016-10-05 CRAN (R 3.3.1)                     
    ##  Rcpp          0.12.10    2017-03-19 CRAN (R 3.3.3)                     
    ##  readr       * 1.1.0      2017-03-22 CRAN (R 3.3.3)                     
    ##  readxl        0.1.1      2016-03-28 CRAN (R 3.3.0)                     
    ##  reshape2      1.4.2      2016-10-22 CRAN (R 3.3.2)                     
    ##  rmarkdown     1.4        2017-03-24 CRAN (R 3.3.3)                     
    ##  rprojroot     1.2        2017-01-16 CRAN (R 3.3.2)                     
    ##  rvest         0.3.2      2016-06-17 CRAN (R 3.3.1)                     
    ##  scales        0.4.1      2016-11-09 CRAN (R 3.3.2)                     
    ##  sessioninfo   0.0.0.9000 2017-04-25 Github (r-pkgs/sessioninfo@0a5b58f)
    ##  stringi       1.1.5      2017-04-07 CRAN (R 3.3.3)                     
    ##  stringr       1.2.0      2017-02-18 CRAN (R 3.3.3)                     
    ##  tibble      * 1.3.0      2017-04-01 CRAN (R 3.3.3)                     
    ##  tidyr       * 0.6.1      2017-01-10 CRAN (R 3.3.2)                     
    ##  tidyverse   * 1.1.1      2017-01-27 CRAN (R 3.3.2)                     
    ##  withr         1.0.2      2016-06-20 CRAN (R 3.3.1)                     
    ##  xml2          1.1.1      2017-01-24 CRAN (R 3.3.2)                     
    ##  yaml          2.1.14     2016-11-12 CRAN (R 3.3.2)

</details>

Notes
-----

[1] ^1

[2] I use the tidyverse form of a data.frame called tibble or data\_frame, it is like a data.frame but it never converts character to factor and never adds rownames . See more at `?tibble::tibble`.

[3] This is absolutely not a robust way of programming, if the format ever changes, all my functions are screwed.
