// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module charge.math.frustum;

import charge.math.movable;
import charge.math.matrix4x4d;

struct ABox
{
	Point3d min;
	Point3d max;
}

struct Planed
{
	union {
		struct {
			double a, b, c, d;
		};
		struct {
			Vector3d vec;
			double vec_length;
		};
		double array[4];
	};

	void normalize()
	{
		auto mag = vec.length;
		a /= mag;
		b /= mag;
		c /= mag;
		d /= mag;
	}

	char[] toString()
	{
		return "(" ~ std.string.toString(a) ~
		       ", " ~ std.string.toString(b) ~
		       ", " ~ std.string.toString(c) ~
		       ", " ~ std.string.toString(d) ~ ")";
	}

	bool check(ref ABox box)
	{
		Vector3d p = box.min;
		if (a > 0)
			p.x = box.max.x;
		if (b > 0)
			p.y = box.max.y;
		if (c > 0)
			p.z = box.max.z;
		if (vec.dot(p) <= -d)
			return false;
		return true;
	}
}

struct Frustum
{
	Planed p[6];
	enum Planes {
		Left,
		Right,
		Top,
		Bottom,
		Far,
		Near,
	};

	alias Planes.Left Left;
	alias Planes.Right Right;
	alias Planes.Top Top;
	alias Planes.Bottom Bottom;
	alias Planes.Far Far;
	alias Planes.Near Near;

	void setGLMatrix(ref Matrix4x4d mat)
	{
		p[Left].a = mat.m[0][3] + mat.m[0][0];
		p[Left].b = mat.m[1][3] + mat.m[1][0];
		p[Left].c = mat.m[2][3] + mat.m[2][0];
		p[Left].d = mat.m[3][3] + mat.m[3][0];
		p[Left].normalize();

		p[Right].a = mat.m[0][3] - mat.m[0][0];
		p[Right].b = mat.m[1][3] - mat.m[1][0];
		p[Right].c = mat.m[2][3] - mat.m[2][0];
		p[Right].d = mat.m[3][3] - mat.m[3][0];
		p[Right].normalize();

		p[Top].a = mat.m[0][3] - mat.m[0][1];
		p[Top].b = mat.m[1][3] - mat.m[1][1];
		p[Top].c = mat.m[2][3] - mat.m[2][1];
		p[Top].d = mat.m[3][3] - mat.m[3][1];
		p[Top].normalize();

		p[Bottom].a = mat.m[0][3] + mat.m[0][1];
		p[Bottom].b = mat.m[1][3] + mat.m[1][1];
		p[Bottom].c = mat.m[2][3] + mat.m[2][1];
		p[Bottom].d = mat.m[3][3] + mat.m[3][1];
		p[Bottom].normalize();

		p[Far].a = mat.m[0][3] - mat.m[0][2];
		p[Far].b = mat.m[1][3] - mat.m[1][2];
		p[Far].c = mat.m[2][3] - mat.m[2][2];
		p[Far].d = mat.m[3][3] - mat.m[3][2];
		p[Far].normalize();

		p[Near].a = mat.m[0][3] + mat.m[0][2];
		p[Near].b = mat.m[1][3] + mat.m[1][2];
		p[Near].c = mat.m[2][3] + mat.m[2][2];
		p[Near].d = mat.m[3][3] + mat.m[3][2];
		p[Near].normalize();
	}

	bool check(ref ABox b)
	{
		foreach(p; p)
			if (!p.check(b))
				return false;
		return true;
	}
}
