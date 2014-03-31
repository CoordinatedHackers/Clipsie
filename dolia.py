MCAST_GROUP = '224.5.5.6'
MCAST_PORT = 5008

class scanner(object):
    def __init__(self):
        import socket
        import struct

        self.sock = socket.socket(
            socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP
        )
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.sock.bind(('', MCAST_PORT))
        self.sock.setsockopt(
            socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
            struct.pack(
                "4sl", socket.inet_aton(MCAST_GROUP), socket.INADDR_ANY
            )
        )

        self.sock.recv()

class cli(object):

    def __init__(self):
        from optparse import OptionParser

        parser = OptionParser(usage="%prog [options] [file [...]|text]")
        options, args = parser.parse_args()

        if len(args) > 1:
            parser.error("TODO: file support (incl. multiple arguments)");
        elif args:
            parser.error("TODO");
        else:
            scanner()
