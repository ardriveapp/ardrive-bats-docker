#!/bin/bash

yarn node index.mjs && export $(cat bats-variables.env | egrep -v '^(#.*|\\s*)$')
