#!/usr/bin/env python3
import sys
import socket
import select
import threading
import json
import time

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

    def __init__(self, recv_sock, send_sock):
        self.recv_sock = recv_sock
        self.send_sock = send_sock
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
        return address[0], json.loads(message.decode('utf-8'))

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
        c = self.sock.accept()[0]
        while True:
            d = c.recv(4096);
            if not d: break
            sys.stdout.buffer.write(d)



class dest(object):
    def __init__(self, ip, desc):
        self.ip = ip
        self.desc = desc

    def send(self, data):
        conn = socket.socket()
        conn.connect((self.ip, self.desc['port']))
        conn.sendall(data.encode('utf-8'))

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

            ip, message = self.transport.recv()
            if 'scan' in message:
                continue
            elif 'name' in message:
                res.append(dest(ip, message))
            else:
                print('scanner: ignoring unknown message:', message)

        return res


class cli(object):

    def __init__(self):
        from optparse import OptionParser

        parser = OptionParser(usage="%prog [options] [file [...]|text]")
        options, args = parser.parse_args()

        try:
            if len(args) > 1:
                parser.error("TODO: file support (incl. multiple arguments)");
            elif args:
                s = scanner()
                while True:
                    dests = s.scan(0.2)
                    if dests:
                        for i, dest in enumerate(dests):
                            print(i, dest.desc['name'])
                        choice = input('> ')
                        if choice:
                            d = dests[int(choice)]
                            d.send(args[0])
                            break
                    else:
                        input('Nothing found, press enter to scan again ')

            else:
                    print("Ready.", file=sys.stderr)
                    client().accept()
        except KeyboardInterrupt:
            print('')
            pass

if __name__ == '__main__':
    cli()
