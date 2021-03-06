// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module charge.game.actors.playerspawn;

static import std.random;

import charge.util.vector;

import charge.math.point3d;
import charge.math.quatd;

import charge.game.world;

class PlayerSpawn : public Actor
{
private:
	/* XXX make this per world */
	static Vector!(PlayerSpawn) spawns;

public:
	this(World w, Point3d pos, Quatd rot)
	{
		super(w);
		spawns ~= this;
		this.pos = pos;
		this.rot = rot;
	}

	~this()
	{
		spawns.remove(this);
	}

	static PlayerSpawn random() {
		return spawns[std.random.rand() % spawns.length];
	}

}
