Animation Generator utility software for the DIY Gamer Kit

Keyboard Shortcuts
==================

Drawing
-------
C         > copy animation as Arduino Gamer library code
backspace > clear the current image
e     	  > toggle 'erase mode' (brush erases/turns pixels off rather than on)
i     	  > invert the current image
s		  > save animation on computer*
l		  > load animation
Animating
---------
=	  > add a blank frame
+	  > clone the current frame
-	  > remove the current frame
n	  > clear all frames (brand new animation)

Previewing
----------
space > toggle animation playback 
LEFT  > move playhead to the previous frame
NEXT  > move playhead to the next frame
ALT+C > copy the current frame
ALT+V > paste a copied frame (at the current location)
(hint: if a lot of blank frames are available you can draw while playing back which allows for a hacky sequencer like animation recorder)

*Animation format
=================
Now the software has the ability to save your animation on disk for later editing.
Each animation is saved in CSV(comma separated values) format as follows:
 - each frame is stored as a one row of data. 
 - each pixel in a frame is stored as either a 1 or a 0. 
   the only catch is the grid/2d array is flattened to a 1d array like so: pixels for row 1,pixels for row 2...pixels for row 8

Credits
=======
Illustration by  Edward Carvalho-Monaghan 
Interface design by Adam Shepard
Code by George Profenza
