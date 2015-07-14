## `aux-funs`: A collection of auxiliary functions for MATLAB

### A very short introduction
How often did you find yourself doing the same small, but tedious task in MATLAB? Like exporting an array to a LaTeX table, or commenting and uncommenting code snippets, or specifying a pleasant colour shade instead of the ugly default ones? If you only could have a nice collection of functions doing it for you!

Well, this toolbox aims squarely at increasing your MATLAB productivity by offering a broad functionality, from plots to statistics, from editor tweaking to LaTeX export. Of course it is not perfect nor it is unique, but it does what it should do.

### Prerequisites:
For `Aux.FigureOperations.PrintTrim` you will need the following softwar:e
* a Perl distribution, e.g. [ActivePerl](http://www.activestate.com/activeperl/downloads)
* a LaTeX distribution with [`pdfcrop`](https://www.ctan.org/pkg/pdfcrop?lang=en), e.g. [MiKTeX](http://miktex.org/download)
* [ImageMagick](http://www.imagemagick.org/script/binary-releases.php)

### Functions overview
* `+Editor`
 * `ToggleTags` : Toggle comments in selected blocks of your file
* `+FigureOperations`
 * `PrintTrim` : Print and auto-trim the specified figure. Both raster (`.png`) and vector (`.pdf`) formats are supported.

