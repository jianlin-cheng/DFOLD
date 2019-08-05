
### https://cran.r-project.org/web/packages/magick/vignettes/intro.html


options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)
print(args)
print(length(args))
if(length(args) !=5)
{
  stop("The number of parameter is not correct in Rscript!\n")
}

native_image = args[1] #T0951_native.pdb.png
native_annotation = args[2]#native_info.txt
model_image = args[3] #
model_annotation = args[4]
output_file  = args[5]

require('magick')

# Read external images
#native_pdb = image_read("T0951_native.pdb.png")
native_pdb = image_read(native_image)
#native_pdb = image_trim(native_pdb)
singleString <- paste(readLines(native_annotation), collapse="\n")
native_pdb = image_annotate(native_pdb, singleString, gravity = "north", size = 100, color = "red")


model = image_read(model_image)
#model = image_trim(model)
singleString <- paste(readLines(model_annotation), collapse="\n")
model = image_annotate(model, singleString, gravity = "north", size = 60, color = "red")


imgs = c(native_pdb, model)

# concatenate them left-to-right (use 'stack=T' to do it top-to-bottom)
side_by_side = image_append(imgs, stack=F)

# save the pdf
image_write(side_by_side, path = output_file, format = "png")
