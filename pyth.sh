#! /bin/cat


__file__=$BASH_SOURCE

pyth () {
    local __doc__="""Run script, which might have a shebang, under interpreters (default python)"""
    local _default_interpreter=python
    if [[ $1 =~ ipython ]]; then
        _default_interpreter=$1
        shift
    fi
    local _words=
    for _arg in "$@"; do
        if [[ -d "$_arg" ]]; then
            echo Choose one: $(ls "$_arg/")
            continue
        fi
        if type $_arg >/dev/null 2>&1; then
            _interpreter=$_arg
            continue
        fi
        if [[ $_arg == ";" ]]; then
            [[ ! _interpreter ]] && _interpreter=$_default_interpreter
            pypath $_interpreter $words
            _interpreter=$_default_interpreter
            _words=
            continue
        fi
        _words="$_words $_args"
        [[ -f "$_arg" ]] || continue
        local _script="$_arg"
        local _shebang_interpreter=$(shebang_interpreter $_interpreter "$_script")
        [[ $_shebang_interpreter ]] && _interpreter=$_shebang_interpreter
    done
    [[ ! _interpreter ]] && _interpreter=$_default_interpreter
    pypath $_interpreter $words
}

pypath () {
    local __doc__="""Restrict PATH when running python commands"""

    local _interpreter=$1; shift
    local _script=$2; shift

    local _path="$HOME/bin:/usr/local/bin:/usr/bin"
    local _venv_bin="${VIRTUAL_ENV:-xxx}"/bin
    local _script_dir=$(dirname $_script)
    local _activate=
    if [[ -f $_script_dir/activate ]]; then
        _activate=$_script_dir/activate
        _activate_link=$(readlink -f "$_activate")
        _venv_bin=$(dirname $_activate_link)
    fi
    if [[ -d $_venv_bin ]] ; then
        if [[ -e $_venv_bin/$_interpreter ]] ; then
            _path="$_venv_bin:$_path"
        else
            [[ -f "$_activate" ]] && echo "Not executable: $_venv_bin/$_interpreter" >&2
            which $_interpreter > dev/null || return 1
        fi
    fi
    if [[ -n $NO_SUB_SHELL ]]; then
        # works per call only e.g. 
        #     $ NO_SUB_SHELL=1 pypath python -c "import sys; sys.stdout.write('hello world'"
        PATH=$_path $_interpreter "$@"
        NO_SUB_SHELL= 
    elif [[ $_interpreter =~ python || -f "$_activate" ]]; then
        (
            [[ -f "$_activate" ]] && source "$_activate";
            PATH=$_path $_interpreter "$@"
        )
    else
        # Other programs might not like the subshell so much
        # pudb refused to co-operate
        PATH=$_path $_interpreter "$@"
    fi
}

shebang_line () {
    head -n 1 "$1"
}

shebang_interpreter () {
    local _interpreter=$1; shift
    local $_arg="$1"; shift
    [[ -f "$_arg" ]] || return 1
    local _script="$_arg"
    local _shebang_line=$(shebang_line "$_script")
    local _shebang_executable=
    local _shebang_interpreter=
    if [[ $_shebang_line =~ pyth ]]; then
        if [[ $_shebang_line =~ python ]]; then
            _shebang_executable=$(shebang_line "$_script" | sed -e "s:#!::")
            local _debug_executable=${_shebang_line/\#\!/}
            [[ $_debug_executable == $_shebang_executable ]] && echo TRUE >&2 || echo FALSE >&2
            if [[ -e $_shebang_executable ]]; then
                _shebang_interpreter=$($_shebang_executable -c "import sys; sys.stdout.write(sys.executable)")
                echo $_shebang_interpreter
                return 0
            fi
        elif [[ $_shebang_line =~ pyth$ ]]; then
            if [[ ! $_shebang_line =~ ':-)' ]]; then
                sed -i -e "s=$_shebang_line=$_shebang_line :-)=" $_script
            fi
        fi
    elif [[ $_shebang_line ]]; then
        [[ $_shebang_line =~ pip|pudb|ipython ]] || echo "SHEBANG $_shebang_line" >&2
    fi
    return 1
}

