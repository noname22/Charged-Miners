// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module minecraft.classic.runner;

private import std.stdio;

import std.c.unix.unix;

import std.file;
import std.stream;
import std.intrinsic;

import charge.charge;
import charge.util.zip;

import minecraft.world;
import minecraft.runner;
import minecraft.viewer;
import minecraft.gfx.manager;
import minecraft.actors.helper;
import minecraft.terrain.common;
import minecraft.terrain.finite;
import minecraft.classic.proto;
import minecraft.classic.connection;
import minecraft.importer.network;
import minecraft.importer.converter;

alias charge.net.util.ntoh ntoh;

class ClassicWorld : public World
{
private:
	mixin SysLogging;

	FiniteTerrain ct;

public:
	this(RenderManager rm, ResourceStore rs)
	{
		this.spawn = Point3d(64, 67, 64);

		super(rm, rs);

		// Create initial terrain
		newLevel(128, 128, 128);

		// Set the level with some sort of valid data
		generateLevel(ct);
	}

	~this()
	{
		delete ct;
		ct = null;
		t = null;
	}

	/**
	 * Change the current level
	 */
	void newLevel(uint x, uint y, uint z)
	{
		delete ct;

		ct = new FiniteTerrain(this, rs, x, y, z);
		t = ct;
		t.buildIndexed = rm.textureArray;
		t.setBuildType(rm.bt);
	}

	/**
	 * "Generate" a level.
	 */
	void generateLevel(FiniteTerrain ct)
	{
		for (int x; x < ct.xSize; x++) {
			for (int z; z < ct.zSize; z++) {
				ct[x, 0, z] =  7;
				for (int y = 1; y < ct.ySize; y++) {
					if (y < 64)
						ct[x, y, z] = 1;
					else if (y == 64)
						ct[x, y, z] = 3;
					else if (y == 65)
						ct[x, y, z] = 3;
					else if (y == 66)
						ct[x, y, z] = 2;
					else
						ct[x, y, z] = 0;
				}
			}
		}
	}
}


/**
 * Inbuilt ViewerRunner
 */
class ClassicRunner : public ViewerRunner, public ClassicClientNetworkListener
{
private:
	mixin SysLogging;
	ClientConnection c;
	ClassicWorld w;

public:
	this(Router r, RenderManager rm, ResourceStore rs)
	{
		w = new ClassicWorld(rm, rs);

		char[] address = "localhost";
		ushort port = 25565;

		char[] username = "Username";
		char[] password = "-";

		c = new ClientConnection(this, address, port,
					 username, password);
		super(r, w, rm);

		grabbed = false;
	}

	~this()
	{
	}

	void close()
	{
		if (c is null)
			return;

		c.shutdown();
		c.close();
		c.wait();
		delete c;
	}

	void logic()
	{
		super.logic();
		if (c !is null)
			c.doPackets();
	}


	/*
	 *
	 * Network functions.
	 *
	 */


	void ping()
	{
	}

	void indentification(ubyte ver, char[] name, char[] motd, ubyte type)
	{
		std.stdio.writefln("Connected\n\t%s\n\t%s", name, motd);
	}

	void levelInitialize()
	{
	}

	void levelLoadUpdate(ubyte percent)
	{
		std.stdio.writefln("percent", percent);
	}

	void levelFinalize(uint xSize, uint ySize, uint zSize, ubyte[] data)
	{
		ubyte from, block, meta;
		w.newLevel(xSize, ySize, zSize);

		// Get the pointer directly to the data
		auto p = w.ct.getBlockPointer(0, 0, 0);

		// Flip the world
		for (int x; x < xSize; x++) {
			for (int z; z < zSize; z++) {
				for (int y; y < ySize; y++) {
					from = data[(xSize*y + x) * zSize + z];
					convertClassicToBeta(from, block, meta);
					*p = block;
					p++;
				}
			}
		}

		c.sendClientMessage("Charged viewer ready!");
	}

	void setBlock(short x, short y, short z, ubyte type)
	{
	}

	void playerSpawn(byte id, char[] name,
			 double x, double y, double z,
			 ubyte yaw, ubyte pitch)
	{
		name = removeColorTags(name);

		std.stdio.writefln("Spawn #%s: %s (%s, %s, %s)", id, name, x, y, z);
	}

	void playerTeleport(byte id, double x, double y, double z,
			    ubyte yaw, ubyte pitch)
	{
		std.stdio.writefln("Teleport #%s (%s, %s, %s)", id, x, y, z);
	}

	void playerUpdatePosOri(byte id, double x, double y, double z,
				ubyte yaw, ubyte pitch)
	{
		std.stdio.writefln("Move #%s (%s, %s, %s) %s %s", id, x, y, z, yaw, pitch);
	}

	void playerUpdatePos(byte id, double x, double y, double z)
	{
		std.stdio.writefln("Move #%s (%s, %s, %s)", id, x, y, z);
	}

	void playerUpdateOri(byte id, ubyte yaw, ubyte pitch)
	{
		std.stdio.writefln("Move #%s %s %s", id, yaw, pitch);
	}

	void playerDespawn(byte id)
	{
		std.stdio.writefln("Despawn #%s", id);
	}

	void playerType(ubyte type)
	{
		std.stdio.writefln("Change type %s", type);
	}

	void message(byte playerId, char[] msg)
	{
		std.stdio.writefln("msg: %s", removeColorTags(msg));
	}

	void disconnect(char[] reason)
	{
		std.stdio.writefln("Disconnect %s", removeColorTags(reason));
	}
}
