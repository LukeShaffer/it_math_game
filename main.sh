#! /bin/bash

CURRENT_ID=$(last -1 <TARGET_USER>)

if [[ "$CURRENT_ID" == *"still logged in"* ]]; then
	1+1
else
	exit 0
fi

TITLE_PROMPT=$'Hi Derek!! It\'s time to test your math skills in order to keep using this computer!  Better be quick!'


TIMER=20 #seconds to answer the question

ANSWER_FILE="/Users/Shared/math_game/window_out.txt" 

#Reset the safeguard file
#if [ -f $ANSWER_FILE ]; then
#	rm $ANSWER_FILE
#fi

echo 5 > /Users/Shared/math_game/window_out.txt


#redirect stderror and stdout to trash might break correct answer reporting
#> /dev/null 2>&1

#prompt array holds, in this order: a,operator,b,c,d

#using the c++ program is sometimes buggy and doesnt pipe output to the jamf window correctly, so the default case is necessary to catch that 
IFS=' ' read -r -a prompt <<< $(/Users/Shared/math_game/a.out)

#display problem and ask him to solve it
case ${prompt[1]} in
0)
PROB_TO_SOLVE="${prompt[0]} + ${prompt[2]} = ?"
;;
1)
PROB_TO_SOLVE="${prompt[0]} - ${prompt[2]} = ?"
;;
2)
PROB_TO_SOLVE="${prompt[0]} * ${prompt[2]} = ?"
;;
3)
PROB_TO_SOLVE="${prompt[0]} / ${prompt[2]} = ?"
;;
*)   # new default case to catch when the program bugs out with the random number generation
exit 1;
;;

esac

#Random number to determine if c is button 1 or button 2
#"Default_button" is the one that will be selected when the timer on the window runs out and is the incorrect answer

C_Button=$((1 + RANDOM % 2))

if [ "$C_Button" -eq 1 ]; then
	BUTTON1="${prompt[3]}"
	BUTTON2="${prompt[4]}"
	DEFAULT_BUTTON=2
else
	BUTTON1="${prompt[4]}"
	BUTTON2="${prompt[3]}"
	DEFAULT_BUTTON=1
fi

#Create a jamfHelper window with all the information placed
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper  -windowType hud -heading "$TITLE_PROMPT" -description "$PROB_TO_SOLVE" -button1 "$BUTTON1" -button2 "$BUTTON2" -defaultButon "$DEFAULT_BUTTON" -timeout "$TIMER" -countdown -lockHUD > /Users/Shared/math_game/window_out.txt


#handle the case when the window is force closed without selecting an answer

#Spawn a process in the background to check the answer file after the whole wait
if [ "$C_Button" -eq 1 ]; then
    nohup /Users/Shared/math_game/sleeper_check.sh "$TIMER" 0 > /dev/null 2>&1&
else
    nohup /Users/Shared/math_game/sleeper_check.sh "$TIMER" 2 > /dev/null 2>&1&
fi

#Determine what we need to look for in the safeguard file, 0 for button1 or 2
# for button2 (correct answer) - returned by the jamf window
if [ "$C_Button" -eq 1 ]
then
	CORRECT_ANSWER=0
#if the correct button was button2
else
	CORRECT_ANSWER=2
fi

# Successful answer
if grep -q $CORRECT_ANSWER /Users/Shared/math_game/window_out.txt; then 
	echo "good job! proud of you!" | mail -s "Good job!" USER_EMAIL
# User closed the jamf popup
elif grep -q 239 /Users/Shared/math_game/window_out.txt; then
	echo "You can't run!" | mail -s "No Cheating!" USER_EMAIL
	rm /Users/Shared/math_game/window_out.txt
	sudo launchctl bootout user/$(id -u $(whoami))
# Wrong answer clicked
else
	echo "WRONG!" | mail -s "Try Again next time :(" USER_EMAIL
	rm /Users/Shared/math_game/window_out.txt
	sudo launchctl bootout user/$(id -u $(whoami))
fi
