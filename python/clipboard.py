from Cocoa import NSPasteboard

def copy():
	pb = NSPasteboard.generalPasteboard()
	return {
		t: bytes(pb.dataForType_(t)) for t in pb.types()
	}

def paste(data):
	pb = NSPasteboard.generalPasteboard()
	pb.clearContents()
	for k, v in data.items():
		pb.setData_forType_(v, k)
