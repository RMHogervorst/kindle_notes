##### just the code for turning kindle notes into a tidy ######################
# description: This is the code belonging to the blogpost: 
#               http://rmhogervorst.nl/cleancode/blog/2017/05/08/making-kindle-highlights-tidy.html
# Author: Roel M Hogervorst
# date:  2017-05-08
# requirements : none 
# packages in use: tidyverse, strinr
###############################################################################
library(tidyverse)
# Read the file
raw_text <- read_file("data/My Clippings.txt") # read in the text file
per_chunk <- unlist(strsplit(raw_text, "=========="))  # seperate into chunks


#### functions ####
#' This function takes a chunk of character information
#' and seperates it into lines. 
seperate_into_lines <- function(chunk){
    result <- stringr::str_split(chunk, "\r\n")
    unlist(result)
}

#' Extract title sentance and remove author
#' This function presumes that you already extracted the raw data into
#' character chunks.
extract_title <- function(linechunk){
    # search for second line
    titleline <- linechunk[2]
    return <- gsub("\\(.*\\)", "", titleline) # it took me some 
    #time to work this regular expression out.
    stringr::str_trim(return, side = "both") # remove whitespace at ends
}

#' Extract the author from chunk, this function looks 
#' very much like the one above, it uses the same logic.
extract_author <- function(linechunk){
    # search for second line
    titleline <- linechunk[2] # identical
    author <- stringr::str_extract(titleline, "\\(.*\\)") # extract piece
    return <- gsub("\\(|\\)", "", author)  # 
    stringr::str_trim(return, side = "both")
}

#' this function extracts all the pieces
#' and subsequent functions will deal with the seperate stuff.
extract_type_location_date <- function(linechunk){
    meta_row <- linechunk[3]
    pieces <- stringr::str_split(meta_row, "\\|") # the literal character, 
    # the '|' has a special meaning in regexp.
    unlist(pieces)
}

#' extract type from combined result.
#' Here the use of the pipe `%>%` operator 
#' makes the steps clear.
extract_type <- function(pieces){
    pieces[1] %>%  # select the first row
        stringr::str_extract( "- [[:alnum:]]{1,} ") %>% # extract at least one character.
        gsub("-", "", .) %>% # replace - with nothing, removing it
        stringr::str_trim( side = "both") # remove whitespace at both sides
}

#' extract page number by selecting first piece,
#' trimming off of whitespace
#' selecting a number, at least 1 times, followed by end of line.
extract_pagenumber <- function(pieces){
    pieces[1] %>%
        stringr::str_trim( side = "right") %>% # remove right end
        stringr::str_extract("[0-9]{1,}$") %>% 
        as.numeric()
}

#' Extract locations. Just like above.
extract_locations <- function(pieces){
    pieces[2] %>% 
        stringr::str_trim( side = "both") %>% 
        stringr::str_extract("[0-9]{1,}-[0-9]{1,}$")
}


#' Extract date and convert to standard time, not US centric.
#' I use the strptime from the base package here. The time is 
#' US-centric, but structured, so we can use the formatting from strptime.
#' For example: %B is Full month name in the current locale
#' and %I:%M %p means hours, minutes, am/pm. 
extract_date <- function(pieces){
    pieces[3] %>% 
        stringr::str_trim( side = "both") %>% 
        stringr::str_extract("[A-z]{3,} [0-9]{1,2}, [0-9]{4}, [0-9]{2}:[0-9]{2} [A-Z]{2}") %>% 
        strptime(format = "%B %e, %Y, %I:%M %p") 
}

#' Extract the highlight part.
extract_highlights <- function(linechunk){
    linechunk[5]
}

##### combination step, extracting the parts and putting into data frame ####
finalframe <- data_frame(
    author = character(length = length(per_chunk)),
    title = character(length(per_chunk)),
    location = character(length(per_chunk)),
    pagenr = numeric(length(per_chunk)),
    type = character(length(per_chunk)),
    highlight = character(length(per_chunk))
)

for( i in seq_along(per_chunk)){
    hold <- per_chunk[i] %>% seperate_into_lines()
    finalframe$author[i] <- hold %>% extract_author()
    finalframe$title[i] <- hold %>% extract_title()
    finalframe$location[i] <- hold %>% extract_type_location_date() %>% extract_locations()
    finalframe$pagenr[i] <- hold %>% extract_type_location_date() %>% extract_pagenumber()
    finalframe$type[i] <- hold %>% extract_type_location_date() %>% extract_type()
    finalframe$highlight[i] <- hold %>% extract_highlights()
}

