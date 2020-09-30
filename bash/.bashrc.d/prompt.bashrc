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
    # export GBT_CARS='Status,Git,Dir,Sign'
    export GBT_CARS='Status,Dir,Sign'   

    PS1='$(gbt $?)'
}

# set default prompt
my_prompt
