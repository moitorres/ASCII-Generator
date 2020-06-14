#|
    Final project por the 'Programming Languages' course

    program that transforms an image into a representation of that image using ASCII code

    Camila Rovirosa Ochoa - A01024192
    Moises Uriel Torres Machorro - A01021323
    16/June/2020

|#


#lang racket
(require racket/draw) ; Library to open an image and save it into a bitmap
(require pict)	 
 	 	

    ;Main function of the program
    (define (main in-file)

        ;Load the image and save it into a bitmap structure
        (define bitmap-image (open-image in-file))
        
        ;Transform the image into grayscale
        (define grayscale-image (color->gray bitmap-image))
        
        ;Save the new image
        (send grayscale-image save-file "./test.jpeg" 'jpeg)
    
    )


    ;Function that opens an image from a file and returns a bitmap structure
    (define (open-image filename)
        ;Create a bitmap
        (define bitmap (make-object bitmap% 300 300))
        ;The image is loaded and saved into a bitmap
        (send bitmap load-file filename)
        ;The program checks if the image was loaded successfully
        (if (send bitmap ok?)
            (displayln "Image loaded successfully")
            (displayln "Error while loading image"))
        ;Return the bitmap
        bitmap)


    ;Function that receives a bitmap with a color image and returns a list with the pixel values in grayscale
    (define (color->gray color-bitmap)
        ;A bitmap-dc is created out of the bitmap
        (define color-bitmap-dc (new bitmap-dc% [bitmap color-bitmap]))
        ;The width and height of the bitmap are saved into variables
        (define-values (w h) (send color-bitmap-dc get-size))
        ;The width and height are transformed to int's
        (define width (exact-floor w))
        (define height (exact-floor h))
        ;A new bitmap is created with the same height and widht as the original bitmap
        (define gray-bitmap (make-bitmap width height))
        ;A bitmap-dc is created out of the previous bitmap
        (define gray-bitmap-dc (new bitmap-dc% [bitmap gray-bitmap]))
        ;A string of bytes is created with the total amount of pixels in the image
        ;It is multiplied by 4 to get the argb value for each one of the pixels
        (define pixels (make-bytes (* 4 width height)))
        ;The function "get-argb-pixels" is used to get the argb values of the pixels in the bitmap-dc and stored them in the "pixels" string
        ;The function gets all the pixels from the coordinates (0,0) to the max width and height of the image
        (send color-bitmap-dc get-argb-pixels 0 0 width height pixels)
        ;Loop that goes from zero to the total number of pixels with a leap of four by four (To skip over the argb values)
        (for ([i (in-range 0 (* 4 width height) 4)])
            ;The first value of the pixel is the alpha, the opacity of the pixel
            (define α (bytes-ref pixels i))
            ;The current pixel plus one is the red value
            (define r (bytes-ref pixels (+ i 1)))
            ;The current pixel plus one is the green value
            (define g (bytes-ref pixels (+ i 2)))
            ;The current pixel plus one is the blue value
            (define b (bytes-ref pixels (+ i 3)))
            ;The luminance of the pixel is calculated and rounded using the formula for luminance in RGB color spaces
            ;https://en.wikipedia.org/wiki/Relative_luminance
            (define l (exact-floor (+ (* 0.2126 r) (* 0.7152 g) (* 0.0722 b))))
            ;All the pixels are set with the same value, which is from 0 to 255, according to the luminance   
            ;0 is black and 255 is white
            (bytes-set! pixels (+ i 1) l)
            (bytes-set! pixels (+ i 2) l)
            (bytes-set! pixels (+ i 3) l))
        (send gray-bitmap-dc set-argb-pixels 0 0 width height pixels)
        gray-bitmap)