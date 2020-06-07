#|
    Final project por the 'Programming Languages' course

    program that transforms an image into a representation of that image using ASCII code

    Camila Rovirosa Ochoa - A01024192
    Moises Uriel Torres Machorro - A01021323
    16/June/2020

|#

#lang racket
(require racket/draw) ; Library to open a ppm image
(require pict)	 
 	 	
    ;Function that opens an image and returns a bitmap
    (define (open-image filename)

        ;The image is loaded and saved into a bitmap
        (define image (make-object bitmap% filename))

        ;The program checks if the image was loaded successfully
        (if (send image ok?)
            (displayln "Image loaded successfully")
            (displayln "Error while loading image"))
        
        (send image get-width)

        ;(define image2 (make-monochrome-bitmap 300 300 ))
        ;(send image2 get-width)
    )


