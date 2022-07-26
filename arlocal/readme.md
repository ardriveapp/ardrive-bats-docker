# CLI & BATS + ARLOCAL

## Quick Guide

-> If service is running
- Attach to CLI `docker attach cli`

-> At repo place yourself inside ./arlocal folder
- Start services `docker-compose up`
- Start services from scratch `docker-compose up --force-recreate`
- Stop services `CTRL ^ C`

-> Inside docker at ~/arlocal
- Setup and load ENV Vars `. magic.sh`

-> Test Setup
- Should return latest wallet PATH `echo $ARLOCAL_WALLET`
