#|
    Final project por the 'Programming Languages' course

    program that transforms an image into a representation of that image using ASCII code

    Camila Rovirosa Ochoa - A01024192
    Moises Uriel Torres Machorro - A01021323
    16/June/2020

|#

#lang racket
(require racket/draw) ; Library to open an image and save it into a bitmap	 

;Main function of the program
(define (main in-file out-file)

    ;Load the image and save it into a bitmap structure
    (define bitmap-image (open-image in-file))
    
    ;Create the output port
    (define out (open-output-file out-file #:exists 'truncate))

    ;Transform the image into grayscale and store the pixels into a list
    ;Here our image is no longer a bitmap% and is instead a list of lists with the value of the pixels
    (define list-image (get-pixels bitmap-image))
    
    ;Scale the image to have the proper aspect ratio according to the size of the pixels
    (define scaled-image (aspect-ratio list-image))

    ;Chnge the pixels values into ascii
    (define ascii-image (pixels->ascii scaled-image))

    ;Function that prints the list into a .txt
    (list-printer ascii-image out)

    ;The output port is closed
    (close-output-port out))


; ********************************************** Functions ************************************************************

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
(define (get-pixels color-bitmap)
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
    (bitmap->list pixels width height))


;Function that receives a pixel structure and returns a list of lists of pixels, according to the width an the height of the image
(define (bitmap->list pixels width height) 
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
                        (+ current-pixel 4) ;The next pixel is the current pixel plus 4, because each pixel has 4 values for the argb
                        (+ row 1) ;The loop changes to the next row
                        1 ;The columns are resetted to 1
                        (append grayscale-pixels (list (append current-row (list l)))) ;The list of the row (with the value of the current pixel) is appended to the result list
                        empty) ;The list of the row is resetted and emptied 

                    ;If this is not the last column
                    (loop
                        (+ current-pixel 4) ;The next pixel is the current pixel plus 4, because each pixel has 4 values for the argb
                        row ;The row is the same
                        (+ column 1) ;The loop changes to the next column
                        grayscale-pixels ;The result list is the same
                        (append current-row (list l)))))))) ;The value of the current pixel is appended to the list of the row


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


;Function that divides the image into grids of 3x3 pixels and replaces the grid with the average of those pixels
;This is so the original aspect-ratio of the image is maintained, as an ASCII character is a lot bigger than a pixel
(define (aspect-ratio pixels)

    ;Get the rounded number of rows and columns in the image divided by three
    (define _rows (exact-floor (/ (length pixels) 3)))
    (define _columns (exact-floor(/ (length (car pixels)) 3)))

    ;Loop that goes over the whole list of pixels
    (let loop
        ([rows _rows] ;Number of the current row. It starts at the max value for the rows and ends at zero
         [columns _columns] ;Number of the current column. It starts at the max value for the columns and ends at zero
         [pixels pixels] ;List of lists that contains the values for the pixels of the image by rows.
         [current-row empty] ;List to store the resulting pixel values of the current row
         [result empty]) ;List of lists that stores the resulting pixel values of the whole image by rows
        
        ;If the current row is at number zero, it means the loop has gone over all the image
        (if (zero? rows)
            ;It returns the result's list
            result
            ;If the loop hasn't finished
            (let()
                
                ;The 9 pixels that will be part of the current grid are obtained
                (define pixel1 (caar pixels)) ;The first pixel of the current row
                (define pixel2 (cadar pixels)) ;The second pixel of the current row
                (define pixel3 (caddar pixels)) ;The third pixel of the current row
                (define pixel4 (caadr pixels)) ;The first pixel of the next row
                (define pixel5 (cadadr pixels)) ;The second pixel of the next row
                (define pixel6 (caddar (cdr pixels))) ;The third pixel of the next row
                (define pixel7 (caaddr pixels)) ;The first pixel of the third row
                (define pixel8 (cadadr (cdr pixels))) ;The second pixel of the third row
                (define pixel9 (caddar (cddr pixels))) ;The third pixel of the third row
                
                ;The average value of the pixels is calculated and rounded
                (define average (round (/ (+ pixel1 pixel2 pixel3 pixel4 pixel5 pixel6 pixel7 pixel8 pixel9) 9)))

                ;If the current column minus 1 is equal to zero, it means this is the last column of the row
                (if (zero? (- columns 1 ))

                    ;If this is the last column
                    (loop
                        (- rows 1) ;The value of the current row diminishes by one
                        _columns ;The value for the columns is resetted to the max value for columns
                        (cdddr pixels) ;The three first rows of the list of pixels are eliminated
                        empty ;The list for the resulting values of the current row is resetted and emptied
                        (append result (list (append current-row (list average))))) ;The current row of pixels (plus the current average) is appended to the list of results
                    
                    ;If this isn't the last column of the row
                    (let()
                        ;The first three rows are updated by deleting the first three pixels of each row
                        (define new-first-row (cdddar pixels))
                        (define new-second-row (cdddar (cdr pixels)))
                        (define new-third-row (cdddar (cddr pixels)))
                        ;The loop is called
                        (loop
                            rows ;The value for the row stays the same
                            (- columns 1) ;The value for the columns diminishes by one
                            (append (list new-first-row) (list new-second-row) (list new-third-row) (cdddr pixels)) ;The value for pixels is updated with the first three rows
                            (append current-row (list average)) ;The current average is appended to the list of results for the current row
                            result))))))) ;The resulting list stays the same

;Function that transforms a list with the values of pixels to a list with ascii characters
(define (pixels->ascii ascii-image )
    (let loop
        ([ascii-img (cdr ascii-image)] ;variable to save the list of pixels
        [temp-img empty] ;temporal list to save the row of new ascii value
        [result-img empty] ; final list to save the entire new list with the ascii value
        [current-row (car ascii-image)]) ; variable to store the current row pixel values
        ;If to check if the as list of pixels is empty
        (if(empty? ascii-img)
            ;If the ascii-img is empty it means the loop finish checking all the rows
            result-img 

             ;Else go and check each value per row
            (let ()
                ;Creates the value that stores the converted pixel into ascii
              (define value (translator (car current-row)))
               ;Check if the row is empyt 
               (if (empty? (cdr current-row))
                    ;If the row is empy then saves the converted ascii row in the result 
                    (loop
                        ;Changes row
                        (cdr ascii-img)
                        ;We empty the current-row 
                        empty
                        ;Saves the values in the result img
                        (append result-img (list(append temp-img (list value))))
                        ;Here the current-row becones the next line of the ascii-img
                        (car ascii-img)
                    )
                    ;Else the currnet-row still has values
                    (loop
                        ;The line stays the same
                        ascii-img
                        ;We save each transformed value in a temporal list
                        (append temp-img (list value))
                        ;The result-img stays the same 
                        result-img
                        ;Moves the values inside the current-row
                        ( cdr current-row)))))))

;Function that changes the pixel values into ascii values
(define (translator pixel)
    ;Nested ifs to check if each value of the pixels
    (cond 
        [(>= pixel 225) " "] ;if the pixel is within range it will change its value to an espace
        [(and (>= pixel 200) (< pixel 225)) "."] ;if the pixel is within range it will change its value to a .
        [(and (>= pixel 175) (< pixel 200)) ":"] ;if the pixel is within range it will change its value to a :
        [(and (>= pixel 150) (< pixel 175)) "-"] ;if the pixel is within range it will change its value to a -
        [(and (>= pixel 125) (< pixel 150)) "="] ;if the pixel is within range it will change its value to a =
        [(and (>= pixel 100) (< pixel 125)) "+"] ;if the pixel is within range it will change its value to a +
        [(and (>=  pixel 75) (< pixel 100)) "*"] ;if the pixel is within range it will change its value to a *
        [(and (>= pixel 50) (< pixel 75)) "#"] ;if the pixel is within range it will change its value to a #
        [(and (>= pixel 25) (< pixel 50)) "%"] ;if the pixel is within range it will change its value to a %
        [(< pixel 25) "@"] ;if the pixel is within range it will change its value to a @

    ))


;Function that transforms a prints a list of lists into a text file
(define (list-printer image out)
    (let loop
        ([image (cdr image)] ;variable to save the list of pixels
        [current-row (car image)]) ; variable to store the current row of pixel values

        ;If to check if the list of pixels is empty
        (if(empty? image)

            ;If the ascii-img is empty it means the loop has finished and the program has finished as well
            (printf "Image transformed to ascii succesfully \n")

             ;Else, the loop continues
            (let ()

                ;The character of the current row is printed into the text file
                (display (car current-row) out)

               ;Check if the row is empty
               (if (empty? (cdr current-row))

                    ;If this is the last value of the row
                    (let()
                        ;An enter is printed into the text file
                        (displayln " " out)
        
                        (loop
                            ;The row is deleted from the image
                            (cdr image)
                            ;The current-row becomes the next line of the image
                            (car image)))

                    ;If this isn't the last value of the row
                    (loop
                        ;The image stays the same
                        image
                        ;Moves the values inside the current-row
                        ( cdr current-row)))))))