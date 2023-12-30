##############################################################################################
# 
# TEXTGRID SUPER EXTRACTOR
# This praat script parses through all the textgrid files in a directory and extracts the 
# following information with interconnected loop commands:
#
# 1. filename, utterance transcription (labels in tier 1), the utterance duration (duration 
# of labels in tier 1) and the appropriate syllable number (tier 3) of the utterances.
# 
# 2. Based on the utterance transcription, it also extracts the appropriate word annotations
# within them. Thus, it extracts the word transcriptions (labels in tier 2), the word
# durations (durations of labels in tier 2) and the appropriate syllable count for the words
# based on the syllable number (tier 3).
#
# 3. One loop further, it also extracts the phone/phonemic annotations (tier 5) within the 
# word structures. Thus, it extracts the phone label, the phone duration and it also obtains 
# the previous and following phone segment as well as the total number of phone segnments 
# found in the particular word.
#  
# To conclude, it assumes the following tier structure: utterances (1), words (2), 
# syllables (3) and phones (5), but this can be adapted. 
# It exports the results into a tab-delimited .txt-file which can easily be transferred into
# a proper table structure. The file is saved in the same directory where the textgrids are
# located. 
#
# 
# The most outer loop is partially based on 
# http://phonetics.linguistics.ucla.edu/facilities/acoustic/formant_logging.txt
# 
# and some other parts of the script are partially based
# on the amazing workshop&scripts by Joey Stanley & Lisa Lipani:
# http://joeystanley.com/downloads/191002-formant_extraction.html
#
# This script is distributed under the GNU General Public License.
# Copyright 16/02/2020 by Andreas Weilinghoff.
# You may use/modify this script as you wish. It would just be nice if you cite me:
# Weilinghoff, A. (2020): Super_extractor.praat (Version 1.0) [Source code]. https://www.andreas-weilinghoff.com/#code
##############################################################################################

# Insert directory here. Do not forget the last (back)slash, so that the script reads all files from directory.
dir$ = "C:\Users\User\Desktop\Input\"

# Delete previous versions of output file.
filedelete 'dir$'super-log.txt

# Set up output variables & name of output file.
header_row$ = "Filename" + tab$ + "Utterance" + tab$ + "Utterance_duration" + tab$ + "Utterance_Syllable_number" + tab$ + "Word_label" + tab$ + "Word_duration" + tab$ + "Word_Syllable_number" + tab$ + "Next_word" + tab$ + "Phone_label" + tab$ + "Phone_duration" + tab$ + "Word_phone_number" + tab$ + "Previous_phone" + tab$ + "Following_phone" + newline$
header_row$ > 'dir$'super-log.txt

# Create a sting list with all .wav files from directory.
Create Strings as file list...  list 'dir$'*.TextGrid
number_files = Get number of strings

# Main loop starts
for j from 1 to number_files

     # Select first file from list
     select Strings list
     current_token$ = Get string... 'j'
     Read from file... 'dir$''current_token$'

     # Create variable "object_name$" which will be reused in the following loops.   
     object_name$ = selected$ ("TextGrid")

     # Reselect variable.
     select TextGrid 'object_name$'

     # Read in corresponding textgrid (names must be identical!)
     Read from file... 'dir$''object_name$'.TextGrid


     # Get interval numbers for utterances, words and syllables.
     
     number_of_utterances = Get number of intervals... 1
     number_of_phones = Get number of intervals... 5
     number_of_words = Get number of intervals... 2
     number_of_syllables = Get number of intervals... 3
    
     numberOfTiers = Get number of tiers
     for i to numberOfTiers

          for b from 1 to number_of_utterances  
               utterance_label$ = Get label of interval... 1 'b'
               # Get start & end time of word label.
               begin_utterance = Get starting point... 1 'b'
               end_utterance = Get end point... 1 'b'

               # Calculate word duration and transform value into milliseconds.
               utterance_duration = (end_utterance - begin_utterance) * 1000

               syllablestart = Get interval at time: 3, begin_utterance
               syllableend = Get interval at time: 3, end_utterance

               utterance_syllable_number = syllableend - syllablestart

               # Transfer data into table.
               wordstart = Get interval at time: 2, begin_utterance
               wordend = Get interval at time: 2, end_utterance
               
               for x from wordstart to wordend - 1
                    next_word = x + 1
                    next_word_label$ = ""
                    if next_word < number_of_words
                         next_word_label$ = Get label of interval... 2 'next_word'
                    endif
                    word_label$ = Get label of interval... 2 'x'
                    # Get start & end time of word label.
                    begin_word = Get starting point... 2 'x'
                    end_word = Get end point... 2 'x'

                    # Calculate word duration and transform value into milliseconds.
                    word_duration = (end_word - begin_word) * 1000

                    word_syllablestart = Get interval at time: 3, begin_word
                    word_syllableend = Get interval at time: 3, end_word

                    word_syllable_number = word_syllableend - word_syllablestart
                    

                    phonestart = Get interval at time: 5, begin_word
                    phoneend = Get interval at time: 5, end_word
                    phone_number = phoneend - phonestart
                    for y from phonestart to phoneend - 1
                         previous_token = y - 1
                         next_token = y + 1
                         previous_label$ = ""
                         next_label$ = ""
                         if previous_token > 0
                              previous_label$ = Get label of interval... 5 'previous_token'
                         endif
                         if next_token < number_of_phones
                              next_label$ = Get label of interval... 5 'next_token'
                         endif
                         phone_label$ = Get label of interval... 5 'y'
                         # Get start & end time of word label.
                         begin_phone = Get starting point... 5 'y'
                         end_phone = Get end point... 5 'y'

                         # Calculate word duration and transform value into milliseconds.
                         phone_duration = (end_phone - begin_phone) * 1000

                         fileappend "'dir$'super-log.txt" 'object_name$''tab$''utterance_label$''tab$''utterance_duration''tab$''utterance_syllable_number''tab$''word_label$''tab$''word_duration''tab$''word_syllable_number''tab$''next_word_label$''tab$''phone_label$''tab$''phone_duration''tab$''phone_number''tab$''previous_label$''tab$''next_label$''newline$'
                    endfor 
               endfor
          endfor
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