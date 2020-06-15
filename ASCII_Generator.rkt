#|
    Final project por the 'Programming Languages' course

    program that transforms an image into a representation of that image using ASCII code

    Camila Rovirosa Ochoa - A01024192
    Moises Uriel Torres Machorro - A01021323
    16/June/2020

|#


#lang racket
(require racket/draw) ; Library to open an image and save it into a bitmap	 

;Out-channel
(define out-channel (make-channel))
;Output file to write the results
(define out (open-output-file "ascii_result.txt" #:exists 'truncate))


;Thread for printing to a text file
(define printer
    (thread 
        (lambda ()
        (let loop
            ()
            ;The thread gets a message from the out-channet
            (define msg (channel-get out-channel))
            ;(displayln msg)
            (cond
                ;If the message is "end", the thread finishes
                [(equal? msg 'end)
                    ;The thread closes the output file
                    (close-output-port out)
                    (printf "Printer thread finishing\n")]
                ;If the message is a string
                [(list? msg)
                    ;The thread prints it to the file and repeats the loop
                    (display msg out)
                    (loop)])))))


;Main function of the program
(define (main in-file)

    ;Load the image and save it into a bitmap structure
    (define bitmap-image (open-image in-file))
    
    ;Transform the image into grayscale and store the pixels into a list
    (define grayscale-image (color->gray bitmap-image))
    
    (define scaled-image (aspect-ratio grayscale-image))
    
    (printf "~a ~a" (length scaled-image) (length (car scaled-image)))

    ;(channel-put out-channel scaled-image)
    ;(channel-put out-channel 'end)
)


;Function that divides the image into grids of 3x3 pixels and reeplaces the grid with the average of those pixels
;This is so the original aspect-ratio of the image is maintained, as an ASCII character is a lot bigger than a pixel
(define (aspect-ratio pixels)

    ;Get the rounded number of rows and columns in the image
    (define _rows (exact-floor (/ (length pixels) 3)))
    
    (define _columns (exact-floor(/ (length (car pixels)) 3)))

    ;Loop that goes over
    (let loop
        ([rows _rows]
         [columns _columns]
         [pixels pixels]
         [current-row empty]
         [result empty])
        
        (if (zero? rows)

            result

            (let()
                (define pixel1 (caar pixels))
                (define pixel2 (car (cdr (car pixels))))
                ;(define pixel2 (cadar pixels))
                (define pixel3 (caddar pixels))
                (define pixel4 (car (car (cdr pixels))))
                ;(define pixel4 (cdaar pixels))
                (define pixel5 (car (cdr (car (cdr pixels)))))
                ;(define pixel5 (cdadar pixels))
                (define pixel6 (car (cdr (cdr (car (cdr pixels))))))
                ;(define pixel6 (cdaddar pixels))
                (define pixel7 (car (car (cdr (cdr pixels)))))
                ;(define pixel7 (cddaar pixels))
                (define pixel8 (car (cdr (car (cdr (cdr pixels))))))
                ;(define pixel8 (cddadar pixels))
                (define pixel9 (car (cdr (cdr (car (cdr (cdr pixels)))))))
                ;(define pixel9 (cddaddar pixels))

                (define average (/ (+ pixel1 pixel2 pixel3 pixel4 pixel5 pixel6 pixel7 pixel8 pixel9) 9))

                (if (zero? (- columns 1 ))
                    
                    (let ()
                        (loop
                            (- rows 1)
                            _columns
                            (cdddr pixels)
                            empty
                            (append result (list (append current-row (list average))))
                        )      
                    )
                

                    (let()

                        ;(cadddr pixels)
                        (define new-first-row (cdr (cdr (cdr (car pixels)))))
                        ;(cdadddr pixels)
                        (define new-second-row (cdr (cdr (cdr (car (cdr pixels))))))
                        ;(cddadddr pixels)
                        (define new-third-row (cdr (cdr (cdr (car (cdr (cdr pixels)))))))
                        
                        (loop
                            rows
                            (- columns 1)
                            (append (list new-first-row) (list new-second-row) (list new-third-row) (cdddr pixels))
                            (append current-row (list average))
                            result
                        )
                    )

                
                )
            )
            
        )
    )


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


;Function that receives a bitmap with a loaded color image and returns a list of lists (for each row of pixels) with the pixel values in grayscale
(define (color->gray color-bitmap)
    ;A bitmap-dc is created out of the bitmap
    (define color-bitmap-dc (new bitmap-dc% [bitmap color-bitmap]))
    ;The width and height of the bitmap are saved into variables
    (define-values (w h) (send color-bitmap-dc get-size))
    ;The width and height are transformed to int's
    (define width (exact-floor w))
    (define height (exact-floor h))
    ;A string of bytes is created with the total amount of pixels in the image
    ;It is multiplied by 4 to get the argb value for each one of the pixels
    (define pixels (make-bytes (* 4 width height)))
    ;The function "get-argb-pixels" is used to get the argb values of the pixels in the bitmap-dc and stored them in the "pixels" string
    ;The function gets all the pixels from the coordinates (0,0) to the max width and height of the image
    (send color-bitmap-dc get-argb-pixels 0 0 width height pixels)
    ;The function "pixels->list" is called to transform the pixels into a list of pixels
    ;Each pixel inside the list will contain the grayscale value of the pixel
    (pixels->list pixels width height))


;Function that receives a pixel structure and returns a list of lists of pixels, according to the width an the height of the image
(define (pixels->list pixels width height) 
    ;Loop that goes through all the pixels stored in the pixels structure
    (let loop
        ([current-pixel 0] ;Number of the current pixel
        [row 1] ;Number of the current row 
        [column 1] ;Number of the current column (They start as 1 to make the if's lest confusing)
        [grayscale-pixels empty] ;List of lists of the whole image
        [current-row empty]) ;List of the pixels of the current row

        ;If the current row is equal to the height plus 1, it means the loop went over the image, so the loop finishes
        (if (equal? row (+ height 1))
            ;The function returns the list of grayscale pixels
            grayscale-pixels
            ;If the loop hasn't finished
            (let ()
                ;The luminescence of each pixel is calculated using the "get-luminance" function
                (define l (get-luminance pixels current-pixel))
                ;If the column is equal to the width, it means this is the last column of the row
                (if (equal? column width)
                    ;If this is the last column
                    (loop
                        ;The next pixel is the current pixel plus 4, because each pixel has 4 values for the argb
                        (+ current-pixel 4)
                        ;The loop changes to the next row
                        (+ row 1)
                        ;The columns are resetted to 1
                        1
                        ;The list of the row (with the value of the current pixel) is appended to the result list
                        (append grayscale-pixels (list (append current-row (list l))))
                        ;The list of the row is resetted and emptied
                        empty)
                    ;If this is not the last column
                    (loop
                        ;The next pixel is the current pixel plus 4, because each pixel has 4 values for the argb
                        (+ current-pixel 4)
                        ;The row is the same
                        row
                        ;The loop changes to the next column
                        (+ column 1)
                        ;The result list is the same
                        grayscale-pixels
                        ;The value of the current pixel is appended to the list of the row
                        (append current-row (list l)) ))))))


;Function that, given a structure of pixels and the current pixel, returns the luminance value of that pixel
(define (get-luminance pixels current-pixel)
    ;The first value of the pixel is the alpha, the opacity of the pixel
    (define α (bytes-ref pixels current-pixel))
    ;The current pixel plus one is the red value
    (define r (bytes-ref pixels (+ current-pixel 1)))
    ;The current pixel plus two is the green value
    (define g (bytes-ref pixels (+ current-pixel 2)))
    ;The current pixel plus three is the blue value
    (define b (bytes-ref pixels (+ current-pixel 3)))
    ;The luminance of the pixel is calculated and rounded using the formula for luminance in RGB color spaces
    ;https://en.wikipedia.org/wiki/Relative_luminance
    (exact-floor (+ (* 0.2126 r) (* 0.7152 g) (* 0.0722 b))))
