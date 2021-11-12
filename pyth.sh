#! /bin/cat


pyth () {
    local __doc__="""Run script, which might have a shebang, under interpreters (default python)"""
    local python_= local_python_=python3
    local words_= options_= 
    if [[ $1 =~ ipython3* ]]; then
        local_python_=$1
        shift
    fi
    for arg_ in "$@"; do
        if [[ $arg_ =~ ^- ]]; then
            options_="$options_ $arg_"
            continue
        fi
        if [[ -d "$arg_" ]]; then
            echo Choose one: $(ls "$arg_/")
            continue
        fi
        if type "$arg_" >/dev/null 2>&1; then
            if [[ $arg_ =~ py ]]; then
                local type_python_=$(type "$arg_" 2>/dev/null)
                [[ $type_python_ ]] && python_="$type_python_"
            fi
        fi
        if [[ "$arg_" == ";" ]]; then
            [[ $python_ ]] || python_=$local_python_
            pypath $python_ $words
            words_=
            continue
        fi
        words_="$words_ $arg_"
        [[ -f "$arg_" ]] || continue
        local script_="$arg_"
        local shebang_python_=$(shebang_interpreter $python_ "$script_")
        [[ $shebang_python_ ]] && python_=$shebang_python_
    done
    [[ $python_ ]] || python_=$local_python_
    pypath $python_ $options_ $words_
}

pypath () {
    local __doc__="""Restrict PATH when running python commands"""

    local interpreter_=$1; shift
    local script_=$1; shift

    local path_="$HOME/bin:/usr/local/bin:/usr/bin"
    local venv_bin_="${VIRTUAL_ENV:-xxx}"/bin
    local active_dir_=$( [[ -e $script_ ]] && $(dirname $script_) )
    local activate_=
    if [[ -d $script_dir_ ]]; then
        local active_file_=$script_dir_/activate
        activate_=$( [[ -f $active_file_ ]] && echo "$active_file_" )
        if [[ $activate_ ]]; then
            activate_link_=$(readlink -f "$activate_")
            venv_bin_=$(dirname $activate_link_)
        fi
    fi
    if [[ -d $venv_bin_ ]] ; then
        if [[ -e $venv_bin_/$interpreter_ ]] ; then
            path_="$venv_bin_:$path_"
        else
            [[ -f "$activate_" ]] && echo "Not executable: $venv_bin_/$interpreter_" >&2
            which $interpreter_ > /dev/null || return 1
        fi
    fi
    if [[ -n $NO_SUB_SHELL ]]; then
        # works per call only e.g.
        #     $ NO_SUB_SHELL=1 pypath python -c "import sys; sys.stdout.write('hello world'"
        PATH=$path_ $interpreter_ $script_ "$@"
        NO_SUB_SHELL=
    elif [[ $interpreter_ =~ python || -f "$activate_" ]]; then
        (
            [[ -f "$activate_" ]] && source "$activate_";
            PATH=$path_ $interpreter_ $script_ "$@"
        )
    else
        # Other programs might not like the subshell so much
        # pudb refused to co-operate
        PATH=$path_ $interpreter_ $script_ "$@"
    fi
}

shebang_line () {
    head -n 1 "$1"
}

shebang_interpreter () {
    local interpreter_=$1; shift
    local $arg="$1_"; shift
    [[ -f "$arg_" ]] || return 1
    local script_="$arg_"
    local shebang_line_=$(shebang_line "$script_")
    local shebang_executable_=
    local shebang_interpreter_=
    if [[ $shebang_line_ =~ pyth ]]; then
        if [[ $shebang_line_ =~ python ]]; then
            shebang_executable_=$(shebang_line "$script_" | sed -e "s:#!::")
            local debug_executable_=${shebang_line_/\#\!/}
            [[ $debug_executable_ == $shebang_executable_ ]] && echo TRUE >&2 || echo FALSE >&2
            if [[ -e $shebang_executable_ ]]; then
                shebang_interpreter_=$($shebang_executable_ -c "import sys; sys.stdout.write(sys.executable)")
                echo $shebang_interpreter_
                return 0
            fi
        elif [[ $shebang_line_ =~ pyth$ ]]; then
            if [[ ! $shebang_line_ =~ ':-)' ]]; then
                sed -i -e "s=$shebang_line_=$shebang_line_ :-)=" $script_
            fi
        fi
    elif [[ $_shebang_line ]]; then
        [[ $_shebang_line =~ pip|pudb|ipython ]] || echo "SHEBANG $_shebang_line" >&2
    fi
    return 1
}

