#
# prompt
#
PS1='[\u@\h \W]\$ '

function my_prompt
{
    safewhich gbt || return
    # Display only last 3 elements of the path
    export GBT_CAR_DIR_DEPTH='1'

    # Set the background color of the `Dir` car to light yellow
    export GBT_CAR_DIR_BG='yellow'
    # Set the foreground color of the `Dir` car to black
    export GBT_CAR_DIR_FG='black'

    # # Add the Time car into the train
    export GBT_CARS='Dir,Git,Sign'

    PS1='$(gbt $?)'
}

# set default prompt
my_prompt