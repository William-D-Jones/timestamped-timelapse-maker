# Time-Stamped Time-Lapse Movie Maker (timestamped-timelapse-maker)

The Time-Stamped Time-Lapse Movie Maker (timestamped-timelapse-maker) is an
ImageJ macro to assemble time-lapse movies from individual images that follow
a specific naming scheme used by some time-lapse camera software. In this
naming scheme, sequentially numbered images (0.tiff, 1.tiff, ..., n.tiff) are
placed in folders with a time-stamp with the time-lapse capturing began: 
for example: Sep 25, 2019 02-46-56 PM.

## Prerequisites:

1. ImageJ or Fiji (last tested on Fiji/ImageJ v1.54e)

## Getting Started:

```
git clone https://github.com/William-D-Jones/timestamped-timelapse-maker.git
```

## How to Assemble Time-Lapse Movies:

1. The macro is designed to assemble time-lapse movies with files in a
particular organization. For example:
```
/image_project/Sep 25, 2019 02-46-56 PM/0.tiff
/image_project/Sep 25, 2019 02-46-56 PM/1.tiff
/image_project/Sep 25, 2019 02-46-56 PM/2.tiff
/image_project/Sep 25, 2019 03-00-00 PM.tiff
/image_project/Sep 25, 2019 03-05-00 PM/0.tiff
```
The macro handles images in multiple time-stamped sub-directories as well
as individual time-stamped images, as long as they follow the format specified
above. The images will be assembled into a new sub-directory
(Exclude_MovieMakerRun_TIMESTAMP) and sequentially numbered.
Each image will have a time-stamp in minutes relative to the start of the
time-lapse experiment (the earliest directory or file). Finally, a .avi time-
lapse movie will be assembled in the same directory.

Additional files or directories in the image directory are allowed, but must
begin with the name Exclude_ to mark that they should be skipped by the macro.

2. When your files are ready, open Fiji/ImageJ and open the macro: 
File > Open > maketimelapse_.ijm

3. Run the macro with Run > Run.

4. At the file selection prompt, choose a directory of time-lapse images.

5. At the prompt, enter the time between images in minutes.

6. The Log window will print a description of each directory and image that
was processed. A new sub-directory will be created called
Exclude_MovieMakerRun_TIMESTAMP with the sequentially-numbered and time-stamped
images inside. For further analysis, the images can be opened with ImageJ's
Open Image Sequence option. Finally, a .avi movie is deposited into the new
sub-directory with the final time-lapse movie.

