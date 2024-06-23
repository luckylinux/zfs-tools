#!/bin/bash

# Card 1
echo $(( 16#$( lsiutil -p1 -a 25,2,0,0 | grep IOCTemperature: | cut -dx -f2 ) ))

# Card 2
echo $(( 16#$( lsiutil -p2 -a 25,2,0,0 | grep IOCTemperature: | cut -dx -f2 ) ))
