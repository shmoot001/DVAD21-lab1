#!/bin/bash

if [ $# -eq 0 ]; then
  printf "Usage: $0 queue_discipline\n"
  printf "Example: $0 pfifo_fast\n"
  printf "Example: $0 codel\n"
  printf "Example: $0 fq_codel\n"
  exit
fi

if [ "$EUID" -ne 0 ]; then
  printf "Please run as root\n"
  printf "For example: sudo $0\n"
  exit
fi


qdisc=$*

rate=10000kbit

function add_qdisc {
    dev=$1

    # Remove previously configured queueing disciplines
    tc qdisc del dev $dev root

    # Add a rate limiter (tbf, token bucket filter) to shift the bottleneck to
    # the host to gain control over the queue. "latency" specifies the
    # maximum time packets can be in the tbf
    tc qdisc add dev $dev root handle 1 tbf rate $rate burst 1514 latency 2000ms

    # Apply a queueing discipline to control the queue

    tc qdisc add dev $dev parent 1: handle 110: $qdisc

}

add_qdisc s1-eth1
add_qdisc s1-eth2
