#!/usr/bin/env python

# Copyright (c) 2019 Computer Vision Center (CVC) at the Universitat Autonoma de
# Barcelona (UAB).
#
# This work is licensed under the terms of the MIT license.
# For a copy, see <https://opensource.org/licenses/MIT>.

"""Performs a single connection check to the simulator."""

import glob
import os
import sys

try:
    os.chdir(os.path.dirname(__file__))
    sys.path.append(glob.glob('../carla/dist/carla-*%d.%d-%s.egg' % (
        sys.version_info.major,
        sys.version_info.minor,
        'win-amd64' if os.name == 'nt' else 'linux-x86_64'))[0])
except IndexError:
    pass


import carla

import argparse


def main():
    argparser = argparse.ArgumentParser(
        description=__doc__)
    argparser.add_argument(
        '--host',
        metavar='H',
        default='127.0.0.1',
        help='IP of the host server (default: 127.0.0.1)')
    argparser.add_argument(
        '-p', '--port',
        metavar='P',
        default=2000,
        type=int,
        help='TCP port to listen to (default: 2000)')
    argparser.add_argument(
        '--timeout',
        metavar='T',
        default=1.0,
        type=float,
        help='time-out in seconds (default: 1)')
    args = argparser.parse_args()

    try:
        client = carla.Client(args.host, args.port)
    except RuntimeError:
        print('IP/Hostname %s could not be resolved' % (args.host))
        return 1
    
    client.set_timeout(args.timeout)

    try:
        print('CARLA %s connected at %s:%d.' % (client.get_server_version(), args.host, args.port))
        return 0
    except RuntimeError:
        print('Failed to connect to %s:%d before time-out of %d second(s).' % (args.host, args.port, args.timeout))
        return 1


if __name__ == '__main__':

    sys.exit(main())
