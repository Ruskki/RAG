#!/bin/bash
tmux new-session \; split-window -h "curl -s https://raw.githubusercontent.com/Ruskki/RAG/main/README.md | less" \; resize-pane -R 30
