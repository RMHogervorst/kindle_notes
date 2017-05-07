Turning kindle notes into a data.frame
================

It is my dream to do everything with R. And we aRe LEKKER ONDERWEG. We can write blogs in blogdown, or bookdown, write reports in Rmarkdown (thank you [Yihui Xie!](https://twitter.com/xieyihui)) create interactive webpages with shiny (thank you [Winston Chang](https://twitter.com/winston_chang))

There's novels of my vision for example chapter 40 of [A Dr. Primestein Adventure™ The Day the Priming Stopped](http://www.psi-chology.com/the-day-the-priming-stopped/) says:

> “This Fortress is a monumental technological achievement,” explained Professor Power. “Every aspect of the Fortress’s security is run by R.” As they arrived at the metal doors, the Professor pressed a small button on the wall to the right. “This is an elevatoR, run by its own R package.” They waited for the doors to open, but nothing happened. After a few minutes of alternately waiting and then mashing the elevatoR button, Professor Power called someone on his mobile phone. “The eleva- toR is not working...what? Why would they do that?...call Hadley Wickham!...doesn’t anyone around here check packages against the development version of R before upgrading?...yes, we’ll wait.” “Someone upgraded R without permission. Should be fixed soon,” Professor Power explained.

But enough about jokeRs and jesteRs, As it is my life long mission to do everything in R and preferably in the [tidyverse](http://tidyverse.org/), I found something that wasn't tidy. 😞

kindle notes and highlights.
============================

I have a 2010 kindle to read E-books on and once in a while I make write a note or highlight some text in the book. If you connect your kindle to the computer you can extract the highlight when you copy the file \`My Clippings.txt' to your computer.

This is great, it's a text file which means you can open it on every computer and search throug the contents. However... It's not tidy. Let's change that.

1.  Create a new project in Rstudio
2.  Create a new folder called `data` (or don't but really this is neat isn't it?)
3.  Copy the `My Clippings.txt` file to that `data`-folder
4.  Load the tidyverse \`library(tidyverse)'
5.  Hammer away untill the txt file is a data frame.
6.  profit?

### What is in this text file?

I've found that the text file is structured in a particular way

    title  (author)
    - Highlight on Page 128 | Loc. 1962-68  | Added on Sunday, December 27, 2015, 03:09 PM
    <empty line>
    highlighted text
    ==========
    title of the next highlighted book (author)
    etc.

**So how do we force this into a data frame?**

Recognize the structure ( we will create functions for that)

-   Chunks end with the ten ===== signs.
-   first line is the title and (author) -- we can seperate the author and the title
-   next line of information is devided by '|' signs.
