##############################################################################################
# 
# FORMANT EXTRACTOR
# This praat script parses through a directory, selects all pairs of .wav & .TextGrid files, 
# extracts F1 & F2 from two measurement points (25% and 75% of vowel length) for a 
# specific vowel label (here: "1") and exports the data into a table in a .txt file format. 
# 
# It assumes that phonemes are in tier 4 and words in tier 2; but this can be adapted.
# The .txt output will be saved into the same directory where the .wav &. textgrid files are
# located.
# 
# This script is based on Katherine Crosswhite's formant logger at
# http://phonetics.linguistics.ucla.edu/facilities/acoustic/formant_logging.txt
# 
# and on the amazing workshop&scripts by Joey Stanley & Lisa Lipani:
# http://joeystanley.com/downloads/191002-formant_extraction.html
#
# This script is distributed under the GNU General Public License.
# Copyright 13/11/2020 by Andreas Weilinghoff.
#
##############################################################################################

# Insert directory here. Do not forget the last (back)slash, so that the script reads all files from directory.
dir$ = "C:\Users\Input_directory\"

# Delete previous versions of output file.
filedelete 'dir$'formant-log.txt

# Set up output variables & name of output file.
header_row$ = "Filename" + tab$ + "phoneme" + tab$ + "Word" + tab$ + "F1nucleus" + tab$ + "F2nucleus" + tab$ + "F1glide" + tab$ + "F2glide" + tab$ + "duration" +  newline$
header_row$ > 'dir$'formant-log.txt

# Create a sting list with all .wav files from directory.
Create Strings as file list...  list 'dir$'*.wav
number_files = Get number of strings

# Main loop starts
for j from 1 to number_files

     # Select first file from list
     select Strings list
     current_token$ = Get string... 'j'
     Read from file... 'dir$''current_token$'

     # Create variable "object_name$" which will be reused in the following loops.   
     object_name$ = selected$ ("Sound")

     # Execute formant analysis. Change max frequency to 5500 for female speakers.
     To Formant (burg)... 0.0025 5 5000 0.025 50

     # Reselect variable.
     select Sound 'object_name$'

     # Read in corresponding textgrid (names must be identical!)
     Read from file... 'dir$''object_name$'.TextGrid

     # Select Textgrid, check for the number of intervals in tier 4 and store this into variable 
     # "number_of_intervals". Then, get all labels of intervals.
     select TextGrid 'object_name$'
     number_of_intervals = Get number of intervals... 4
     for b from 1 to number_of_intervals
         select TextGrid 'object_name$'
          interval_label$ = Get label of interval... 4 'b'

          # Start if-loop. If interval_label$ = "1", do the following steps below.
          if interval_label$ = "1"
               # Get start & end time of vowel label and calculate its duration.
               begin_vowel = Get starting point... 4 'b'
               end_vowel = Get end point... 4 'b'
               duration = begin_vowel - end_vowel

               # First measurement point (25%) 
               nucleus_measurement = begin_vowel + ((end_vowel - begin_vowel)*0.25)
               # Second measurement point (75%)
               glide_measurement = begin_vowel + ((end_vowel - begin_vowel)*0.75)

               # Get corresponding word interval for vowel in tier 2.
               thisWordInterval = Get interval at time: 2, nucleus_measurement
               thisWord$ = Get label of interval: 2, thisWordInterval

               # Select formant and get formant values at measurement points
               select Formant 'object_name$'
               f_one_nucleus = Get value at time... 1 'nucleus_measurement' Hertz Linear
               f_two_nucleus = Get value at time... 2 'nucleus_measurement' Hertz Linear
               f_one_glide = Get value at time... 1 'glide_measurement' Hertz Linear
               f_two_glide = Get value at time... 2 'glide_measurement' Hertz Linear
               
               # Transform duration value into milliseconds.
               duration = (end_vowel - begin_vowel) * 1000

               # Transfer data into table.
              fileappend "'dir$'formant-log.txt" 'object_name$''tab$''interval_label$''tab$''thisWord$''tab$''f_one_nucleus:0''tab$''f_two_nucleus:0''tab$''f_one_glide:0''tab$''f_two_glide:0''tab$''duration:3''newline$'
            endif
     endfor

     # Go to next file and finish loop after each file in directory has been parsed.
     select all
     minus Strings list
     Remove
endfor

# Clean up Praat objects and write a message confirming that script has been successfully executed.

select all
Remove
clearinfo
print Script has been successfully executed. Hooray!