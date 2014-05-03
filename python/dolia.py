#!/usr/bin/env python3
import sys
import socket
import select
import threading
import json
import time

import clipboard

MCAST_GROUP = '224.5.5.6'
MCAST_PORT = 5008

def mcast_sock(send=False):
    import struct

    sock = socket.socket(
        socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP
    )
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    if send:
        sock.connect((MCAST_GROUP, MCAST_PORT))
    else:
        sock.bind((MCAST_GROUP, MCAST_PORT))
    sock.setsockopt(
        socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
        struct.pack(
            "4sl", socket.inet_aton(MCAST_GROUP), socket.INADDR_ANY
        )
    )

    return sock

class jsont(object):

    def __init__(self, recv_sock, send_sock=None):
        self.recv_sock = recv_sock
        self.send_sock = send_sock or recv_sock
        self.buf = b''

    def send(self, **kwargs):
        self.send_sock.sendall(json.dumps(kwargs).encode('utf-8'))
        self.send_sock.sendall(b'\n')

    def recv(self):
        message = None
        while message is None:
            data, address = self.recv_sock.recvfrom(4096)
            self.buf += data
            # print('recv: ', address)
            boundary = self.buf.find(b'\n')
            if boundary != -1:
                message = self.buf[:boundary]
                self.buf = self.buf[boundary + 1:]
        return address, json.loads(message.decode('utf-8'))

class listener(object):
    def __init__(self, port, name=socket.gethostname()):
        self.transport = jsont(mcast_sock(), mcast_sock(send=True))
        self.port = port
        self.name = name
        self.thread = threading.Thread(target=self.listen, daemon=True)
        self.thread.start()

    def listen(self):
        while True:
            address, message = self.transport.recv()
            if 'scan' in message and message['scan'] is True:
                self.transport.send(
                    name=self.name,
                    port=self.port
                )

class client(object):
    def __init__(self):
        self.sock = socket.socket()
        self.sock.bind(('', 0))
        self.sock.listen(5)
        self.listener = listener(self.sock.getsockname()[1])

    def accept(self):
        transport = jsont(self.sock.accept()[0])
        return transport.recv()[1]



class dest(object):
    def __init__(self, ip, desc):
        self.ip = ip
        self.desc = desc

    def send(self, data):
        conn = socket.socket()
        conn.connect((self.ip, self.desc['port']))
        transport = jsont(conn)
        transport.send(**data)

class scanner(object):
    def __init__(self):
        self.transport = jsont(mcast_sock(), mcast_sock(send=True))
        self.transport.recv_sock.setblocking(0)
        self.poll = select.poll()
        self.poll.register(self.transport.recv_sock, select.POLLIN)

    def scan(self, scantime):
        res = []
        self.transport.send(scan=True)

        # TODO: Move this all into jsont. Also separate data by source.
        while scantime > 0:
            start = time.time()
            pollres = self.poll.poll(scantime * 1000)
            if not pollres: break
            scantime -= time.time() - start

            addr, message = self.transport.recv()
            if 'scan' in message:
                continue
            elif 'name' in message:
                res.append(dest(addr[0], message))
            else:
                print('scanner: ignoring unknown message:', message)

        return res


class cli(object):

    def __init__(self):
        import argparse

        parser = argparse.ArgumentParser()
        parser.add_argument('command',
            metavar='command',
            choices=('copy', 'paste'),
            help="%(choices)s"
        )

        args = parser.parse_args()

        getattr(self, 'cmd_' + args.command)()

    def cmd_copy(self):
        from base64 import b64encode

        message = {
            "type": "clipboard",
            "data": { k: b64encode(v).decode('utf8') for k, v in clipboard.copy().items() }
        }

        s = scanner()
        while True:
            dests = s.scan(0.1)
            if dests:
                for i, dest in enumerate(dests):
                    print(i, dest.desc['name'])
                choice = input('> ')
                if choice:
                    d = dests[int(choice)]
                    d.send(message)
                    break
            else:
                input('Nobody found, press enter to scan again ')


    def cmd_paste(self):
        print("Waiting...", file=sys.stderr)
        d = client().accept()
        if "type" in d:
            t = d["type"]
            paste = getattr(self, 'paste_' + t, None)
            if not paste:
                print(
                    "Can't handle type \"{}\"".format(t),
                    file=sys.stderr
                )
                sys.exit(1)
            paste(d)
        else:
            print("Data is missing a \"type\" property", file=sys.stderr)
            sys.exit(1)

    def paste_clipboard(self, d):
        from base64 import b64decode
        cb = {k: b64decode(v) for k, v in d["data"].items()}

        url = None
        if 'public.url' in cb:
            url = cb['public.url'].decode('utf8')
        elif 'public.utf8-plain-text' in cb:
            import re
            text = cb['public.utf8-plain-text']
            # Super naive, please battle test or replace
            if re.match(rb"[a-z-]+:", text):
                url = text.decode('utf8')

        if url:
            print("Looks like a URL:")
            print(url)
            choice = input("Open it? [Yn] ")
            if not choice or choice.lower() == 'y':
                import webbrowser
                webbrowser.open(url)
                return

        clipboard.paste(cb)



if __name__ == '__main__':
    try:
        cli()
    except KeyboardInterrupt:
        print('')
