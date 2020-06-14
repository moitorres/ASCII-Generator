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

    (define (main in-file)

        (displayln "Main Thread Starting")

        (define in (open-input-file in-file))

        (read-ppm in)
        
        (close-input-port in))



    (define (read-ppm port)
        (parameterize ([current-input-port port])
            (define magic (read))
            (define width (read))
            (define height (read))
            (define maxcol (read))
            (define bm (make-object bitmap% width height))
            (define dc (new bitmap-dc% [bitmap bm]))
            (send dc set-smoothing 'unsmoothed)
            (define (adjust v) (* 255 (/ v maxcol)))
            (for/list ([x width ])
                (for/list ([y height ])
                    (printf "Fila ~a , Columna ~a \n" x y)
                    
                    (define red (read))
                    (define green (read))
                    (define blue (read))

                    (define color (make-object color% (adjust red) (adjust green) (adjust blue)))
                    (send dc set-pen color 1 'solid)
                    (send dc draw-point x y) ))
        bm))