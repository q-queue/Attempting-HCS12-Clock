#!/usr/bin/bash

for i in {0..7}; do
	python3 generate-timer.py "$i" > tickers/timer_ticker_"$i".asm
done
