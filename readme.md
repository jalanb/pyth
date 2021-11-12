pyth
====


pyth works as a shorter name for `python`

    $ pyth -c "print('hello')"

interpreter
-----------

`;` starts "a new `command`" in pyth, e.g.

    $ pyth -c "print('hello')"; my_great_script; pudb fred.py; -c "print('hello')"`

`pyth` chooses interpreters and `venvs` depending on what the `environment` or `script` says

In the example above pyth will interpret the command `pudb fred.py` as:
    pudb should run under `python3` (default), or under `python2` if
 * fred.py has a shebang command for python2
 * fred.py is in a dir with an activate script, which resolves to a python2
  * TODO: fred.py is in a project with an activate ...

The interpreter starts as whatever the local shell says `python` is

    If the first word on a new command is a bash command and has a pythonic file then 
        the interpreter adds the file to itself
    Else
        The interpreter is changed back to shell python
    fi

These rules work with `ipython`, `pip2`, `pudb3`, ... 
    and should work with any pythonic program (WFM, YMMV)

Sub Shell
---------

Commands may find a need to activate another virtualenv, so are run in a subshell by default

Turn that off with `NO_SUB_SHELL`, e.g.

`$ NO_SUB_SHELL=1 pyth pudb fred.py`

