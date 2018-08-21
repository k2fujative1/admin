#!/bin/bash
ssh-keygen -t rsa && cat ~/.ssh/id_rsa.pub | ssh daniel2@10.0.2.15 "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"

