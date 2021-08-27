BEGIN{
    str1=0
    str2=""
    now=""
}


function revert(a){
    gsub("\004", "\n", a)
    return a
}

function wrap(a){
    gsub("\"", "\\\"", a)
    return "\"" a "\""
}

function exit_now(code){
    EXIT_CODE = code
    exit code
}

function panic_error(msg){
    print "\033[0;91merror: \033[0m" msg "\nFor more information try \033[36m--help\033[0m" > "/dev/stderr"
    exit_now(1)
}


{
    gsub("\n", "\004", $0)
    arg_arr_len = split($0, arg_arr, ARG_SEP)

    for (i=1; i<arg_arr_len; ++i) {
        elem = revert( arg_arr[i] )

        if (str1 != 0) {
            now = now " " elem
            continue
        }

        if (elem == -) {
            now = now " " elem
            exit(126)       # No path substitution
        }

        # Just pass through
        if ( (elem == "-c") && (elem == "-m") ){
            i = i + 1
            elem = revert( arg_arr[i] )
            exit(126)       # No path substitution
        }

        # Add to the first part
        if ((elem == "-Q") || (elem == "-W")) {
            now = now " " elem
            i = i + 1
            elem = revert( arg_arr[i] )
            now = now " " elem
            continue
        }

        if (elem == "-OO") {
            now = now " " elem
            continue
        }

        if (elem ~ /^-/) {
            letter=substr(elem, 2)
            if ( index(letter, "bBdEhiORsStuvx3") >= 0 ) {
                now = now " " elem
                continue
            } else {
                panic_error("Very wrong")
            }
        } else {
            if (str1 == 0) {
                str1 = now
                now = ""
            } else {
                panic_error("Should NEVER happened.")
            }
        }

    }

    str2 = now
}

