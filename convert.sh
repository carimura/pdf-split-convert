export MAGICK_CONFIGURE_PATH=./__debs__/usr/lib/x86_64-linux-gnu/ImageMagick-6.7.7/config
export MAGICK_CODER_MODULE_PATH=./__debs__/usr/lib/x86_64-linux-gnu/ImageMagick-6.7.7/modules-Q16/coders
convert.im6 --version
convert.im6 -density 400 -units PixelsPerInch page.pdf -blur 1x65535 -blur 1x65535 -contrast -normalize -despeckle -despeckle -type grayscale -sharpen 1 -enhance $1
