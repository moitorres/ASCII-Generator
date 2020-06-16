# ASCII-Generator
---


**Members**

<br>

  - Moisés Uriel Torres....A01021323   
  - Camila Rovirosa Ochoa...A01024192

<br>

**Professor:** Gilberto Echeverria Furio

<br>

**Lecture:** Programming Languages

---
## Project description  

Our project consists on a program that transforms an image into a representation of that image using ASCII code. The user inputs the image they want to transform and the result is printed into a text file. The resulting image will look as the following one:

![](Test_images/mona_lisa.jpg) ![](Test_images/ejemplo_de_Resultado.png)

## How does it work?  

For the process of creating the ASCII image, first, the original image is read and saved into the program. We did this with the “racket/draw” module and we stored the image into a bitmap. Then, we stored the value of each pixel into a list of lists. Each internal list represents a row of pixels of the original image. After that, each pixel is transformed into gray scale, to have only the luminous intensity of each pixel instead of the whole RGB value. This lumninance value goes from 0 to 255, with 0 being black and 255 being white. Then, we divided the image into a grid of small squares of 3x3, and for each square of the grid we got the average luminosity value. This is done because an ASCII character is much bigger than a pixel, so we need to reduce an area of pixels into one value so the original aspect ratio of the image is kept. Finally, we mapped each of this values with their corresponding ASCII character and we printed them into a text file. 

## Topics 

The topics seen in class that we used in the program are:
- Functional programming: We used functional programming by using racket as our programming language.
- File input/output: The program reads an image file and then outputs the result into a text file.
- Lists: We used lists to store the values for the pixels and for sending t

## How to run the program
1. Clone the git repository with "git clone" 
2. Install racket in your computer : https://docs.racket-lang.org/pollen/Installation.html
3. Run **Racket** in your terminal if you have Linux or in Dr. Racket for other OS
  -> using the comand "racket" inside the location where the code is
4. Then use the following comand to start the program: 
  -> (enter! "ASCII_Generator.rkt")
5. And then create your ASCII image using the following comand:
  -> (main "Test_images/not_bad.jpg" "nameOfYourNewFile.txt")
  - main is the function that runs the program. The first parameter is the path to the image you want to transform and the second parameter is the path and name for the resulting .txt with the ascii art.
  - Test_images is where we saved our fine selection of images to test
6. Enjoy your ASCII generator!!!

