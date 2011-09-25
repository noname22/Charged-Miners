// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module miners.isle.world;

import std.math;
import std.stdio;

import charge.charge;

import charge.math.noise;
import charge.math.ints;

import miners.world;
import miners.options;
import miners.builder.data;
import miners.terrain.beta;
import miners.terrain.chunk;
import miners.terrain.common;
import miners.importer.info;

/**
 * World containing a infite floating island world.
 */
class IsleWorld : public World
{
public:
	BetaTerrain bt;

public:
	this(Options opts)
	{
		this.spawn = Point3d(-10, 64, -10);
		super(opts);

		t = bt = new BetaTerrain(this, opts, &newChunk);

		// Find the actuall spawn height
		auto x = cast(int)spawn.x;
		auto y = cast(int)spawn.y;
		auto z = cast(int)spawn.z;
		auto xPos = x < 0 ? (x - 15) / 16 : x / 16;
		auto zPos = z < 0 ? (z - 15) / 16 : z / 16;

		bt.setCenter(xPos, zPos);
		bt.loadChunk(xPos, zPos);

		auto p = bt.getTypePointer(x, z);
		bool foundFilled;
		for (int i = y; i < 128; i++) {
			if (tile[p[i]].filled) {
				foundFilled = true;
				continue;
			}
			if (tile[p[i+1]].filled)
				continue;
			if (!foundFilled)
				continue;

			spawn.y = i;
			break;
		}
	}

	void newChunk(Chunk c)
	{
		// Allocte valid data for the chunk
		c.allocBlocksAndData();

		float cutoff = .4;
		ubyte topBlock = 97, bottomBlock = 98;
		int underSideHang = 10;

		// For each block pillar in the chunk.
		for (int x; x < c.width; x++) {
			for (int z; z < c.depth; z++) {
				// Get the pointer to the first block in a pillar.
				auto ptr = c.getTypePointerUnsafe(x, z);

				for (int y = 0; y < c.height; y++){
					// Get the noise value for this location.
					bool getSolid(int x, int y, int z, float cutoff=cutoff)
					{
						// Go from local chunk coords to global scaled coords.
						auto xU = (x + c.xPos * 16) / 64.0;
						auto zU = (z + c.zPos * 16) / 64.0;
						auto yU = (y + c.yPos * 64) / 8.0;

						// Get the noise value for this location.
						return pnoise(xU, yU, zU) > cutoff;
					}

					ubyte getBlock(int x, int y, int z)
					{
						// If the block above is solid, make this one dirt, otherwise make it grass
						if(getSolid(x, y + 1, z)){
							return bottomBlock;
						}
						return topBlock;
					}

					if(getSolid(x, y, z)){
						ptr[y] = getBlock(x, y, z);
					}
				}
			}
		}
		
		c.valid = true;
		c.loaded = true;
	}
}
