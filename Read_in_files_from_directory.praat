####################################################################
# This is a simple praat script that reads in all .TextGrid and .wav 
# files from a directory. You can exchange the extensions if needed.
#  
# The last bit removes the string objects (not mandatory).
#
# This script is distributed under the GNU General Public License.
# Copyright 08/11/2020 by Andreas Weilinghoff.
####################################################################

#Insert directory here. Do not forget the last (back)slash, so that the script reads all files from the directory.
directory$ = "C:\Users\User\Desktop\Face_utterances_scipt_testing\"

Create Strings as file list: "files", directory$ + "*.wav"
Create Strings as file list: "files", directory$ + "*.TextGrid"
readFiles = Get number of strings
for x from 1 to readFiles
    selectObject: "Strings files"
    file$ = Get string: x
    fullname$ = file$ - ".wav"
    fullname$ = file$ - ".TextGrid"
    Read from file: directory$ + fullname$ + ".wav"
    Read from file: directory$ + fullname$ + ".TextGrid"
endfor

# Remove the srings (Not necessarily important)
selectObject: "Strings files"
Remove
selectObject: "Strings files"
Remove
