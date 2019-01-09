pyth
====


Works as a shorter `$ python`
`$ pyth -c "print('hello')"`

`;` starts "a new command" in pyth, e.g.
`$ pyth -c "print('hello')"; my_great_script; pudb fred.py; -c "print('hello')"`

interpreter
-----------

pyth chooses interpreters and venvs depending on what the environ or script says
In the e.g. above: `pudb fred.py`
    pudb might run under `python3` (my normal environement), or under `python2` if
    # fred.py has a shebang command for python2
    # fred.py is in a dir with an activate script, which resolves to a python2
    # TODO: fred.py is in a project with an activate ...

The interpreter starts as whatever local shell says `python` is
If the first word on a new command is a bash command and has a pythonic file
    the interpreter adds the file to itself
Else
  The interpreter is changed back to shell python
fi

These rules work with ipython, pip2, pudb3, ... (WFM, YMMV: every pythonic program)

Sub Shell
---------

Commands may find a need to activate another virtualenv, so are run in a subshell by default

Turn that off with `NO_SUB_SHELL`, e.g.

`$ NO_SUB_SHELL=1 pyth pudb fred.py`

.bashrc
-------

If you like it, you'll find a place for it

contributions
-------------

welcome