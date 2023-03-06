This is a general purpose prank application to repeatedly prompt a user with an
unavoidable math prompt, which they will have to solve correctly to keep using
the computer.  This is the general flow of how the program operates.


1)  Upon login, a flag file will be placed in this directory indicating that
    the user is "safe" and cannot be logged out.

2) Schedule a background process to cycle every so often to prompt user with a
    jamfHelper fullscreen prompt.  The prompt will contain a random math
    equation and a choice of two answers, one being right and the other being
    wrong (but still close enough).  Additionally, a countdown timer will be
    specified in the JamfHelper window to indicate that if the user does not
    pick the right answer they will be logged off.

2a) When the window is opened, delete the safeguard file and spawn another
    process with the same timer as the window to check for the existence of the
    safeguard file.  If they answer the question correctly, replace the
    safeguard file.  However, if they do not answer correctly, just log them
    out immediately.

3) Also, sends an annoying email to the user whenever they answer a question.
