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


    ;Main function of the program
    (define (main in-file)

        ;Load the image and save it into a bitmap structure
        (define bitmap-image (open-image in-file))
        
        ;Transform the image into grayscale
        (define grayscale-image (color->gray bitmap-image))
        
        ;Save the new image
        (send grayscale-image save-file "./test.jpeg" 'jpeg)
        
    )

    ;Function 
    (define (color->gray color-bm)
        (define color-dc (new bitmap-dc% [bitmap color-bm]))
        (define-values (w h) (send color-dc get-size))
        (define width (exact-floor w))
        (define height (exact-floor h))
        (define gray-bm (make-bitmap width height))
        (define gray-dc (new bitmap-dc% [bitmap gray-bm]))
        (define pixels (make-bytes (* 4 width height)))
        (send color-dc get-argb-pixels 0 0 width height pixels)
        (for ([i (in-range 0 (* 4 width height) 4)])
            (define α (bytes-ref pixels i))
            (define r (bytes-ref pixels (+ i 1)))
            (define g (bytes-ref pixels (+ i 2)))
            (define b (bytes-ref pixels (+ i 3)))
            (define l (exact-floor (+ (* 0.2126 r) (* 0.7152 g) (* 0.0722 b))))    
            (bytes-set! pixels (+ i 1) l)
            (bytes-set! pixels (+ i 2) l)
            (bytes-set! pixels (+ i 3) l))
        (send gray-dc set-argb-pixels 0 0 width height pixels)
        gray-bm)