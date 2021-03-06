// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module charge.math.picture;

import std.string;
import std.stdio;

import charge.math.color;
import charge.sys.resource;
import charge.sys.logger;
import charge.sys.file;
import charge.util.png;


class Picture : public Resource
{
public:
	const char[] uri = "pic://";

	Color4b *pixels;

	uint width;
	uint height;

private:
	mixin Logging;

public:
	static Picture opCall(char[] filename)
	{
		auto p = Pool();
		if (filename is null)
			return null;
		
		auto r = p.resource(uri, filename);
		auto pic = cast(Picture)r;
		if (r !is null) {
			assert(pic !is null);
			return pic;
		}

		auto i = getImage(filename);
		if (i is null)
			return null;

		return new Picture(p, filename, i, true);
	}

	static Picture opCall(char[] name, char[] filename)
	{
		auto i = getImage(filename);
		if (i is null)
			return null;

		return new Picture(Pool(), name, i, true);
	}

protected:
	this(Pool p, char[] name, uint w, uint h, bool dynamic)
	{
		super(p, uri, name, dynamic);

		width = w;
		height = h;
		pixels = cast(Color4b*)std.c.stdlib.malloc(w*h*Color4b.sizeof);
	}

	this(Pool p, char[] name, PngImage image, bool dynamic)
	{
		// Call base calss constructor
		super(p, uri, name, dynamic);

		this.width = image.width;
		this.height = image.height;
		this.pixels = cast(Color4b*)image.pixels.steal.ptr;
	}

	~this()
	{
		std.c.stdlib.free(pixels);
	}

	static PngImage getImage(char[] filename)
	{
		auto file = FileManager(filename);
		if (file is null) {
			l.warn("Failed to load %s: file not found", filename);
			return null;
		}
		scope(exit)
			delete file;

		return pngDecode(file.peekMem, true);
	}
}
