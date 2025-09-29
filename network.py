#!/usr/bin/env python3

"Lab code for DVAD21 - Lab 1: AQM"

from __future__ import print_function
import sys
import json
from mininet.topo import Topo
from mininet.node import CPULimitedHost
from mininet.link import TCLink
from mininet.net import Mininet
from mininet.util import dumpNodeConnections
from mininet.cli import CLI
from mininet.log import setLogLevel

def run_cmd(node, cmd):
    print(cmd)
    node.cmd(cmd)
   
class AQMTopo(Topo):
    def __init__(self):
        super(AQMTopo, self).__init__()

        for i in range(config['n']):
            self.addHost('h%d' % (i + 1))

        self.addSwitch('s1', fail_mode='open')

        self.addLink('h1', 's1', bw=config['bw_host'], delay=config['delay'], max_queue_size=int(config['maxq']))

        for i in range(1, config['n']):
            self.addLink('h%d' % (i + 1), 's1', bw=config['bw_host'])

if __name__ == '__main__':
    try:
        with open('config.json') as configfile:
            config = json.load(configfile)
    except Exception as e:
        print(e, file=sys.stderr)
        exit()

    setLogLevel('info')
    topo = AQMTopo()
    net = Mininet(topo=topo, link=TCLink)

    net.start()

    h2 = net.getNodeByName('h2')

    run_cmd(h2, 'iperf3 -Ds')
    run_cmd(h2, 'netserver')
    run_cmd(h2, 'irtt server &')

    dumpNodeConnections(net.hosts)
    net.pingAll()

    CLI(net)
