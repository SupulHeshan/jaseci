#!/bin/bash

git clone --depth 1 https://github.com/antlr/grammars-v4.git
cp -r grammars-v4/javascript/javascript/Python3 .
cp -r grammars-v4/javascript/javascript/*g4 .
rm -rf Cpp CSharp Java JavaScript examples Go _scripts
rm -rf grammars-v4
pip install antlr4-python3-runtime
python Python3/transformGrammar.py
antlr4 -Dlanguage=Python3 JavaScript*.g4 -o gen
cp Python3/JavaScript*py gen/
rm -rf *g4* Python3