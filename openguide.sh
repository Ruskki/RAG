#!/bin/bash
tmux new-session \; split-window -h "curl https://raw.githubusercontent.com/Ruskki/RAG/main/README.md | less"
