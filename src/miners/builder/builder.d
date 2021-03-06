// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module miners.builder.builder;

import charge.charge;

import miners.gfx.vbo;

import miners.builder.data;
import miners.builder.types;
import miners.builder.packers;
import miners.builder.helpers;
import miners.builder.workspace;


/**
 * Helper functions for emiting quads to a packer.
 */
template QuadEmitter()
{
	void emitQuadAOYP(int x1, int x2, int y, int z1, int z2,
			  ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			  ubyte texture, sideNormal normal)
	{
		p.pack(p, x1, y, z1, texture, aoTL, normal, uvCoord.LEFT, uvCoord.TOP);
		p.pack(p, x1, y, z2, texture, aoBL, normal, uvCoord.LEFT, uvCoord.BOTTOM);
		p.pack(p, x2, y, z2, texture, aoBR, normal, uvCoord.RIGHT, uvCoord.BOTTOM);
		p.pack(p, x2, y, z1, texture, aoTR, normal, uvCoord.RIGHT, uvCoord.TOP);
	}

	void emitQuadAOYP(int x1, int x2, int y, int z1, int z2,
			  ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			  ubyte texture, sideNormal normal, uvManip manip)
	{
		mixin UVManipulator!(manip);

		p.pack(p, x1, y, z1, texture, aoTL, normal, uTL, vTL);
		p.pack(p, x1, y, z2, texture, aoBL, normal, uBL, vBL);
		p.pack(p, x2, y, z2, texture, aoBR, normal, uBR, vBR);
		p.pack(p, x2, y, z1, texture, aoTR, normal, uTR, vTR);
	}

	void emitQuadMappedUVAOYP(int x1, int x2, int y, int z1, int z2,
				  ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
				  ubyte texture, sideNormal normal,
				  int u_offset, int v_offset, uvManip manip)
	{
		ushort uv[][] = genMappedManipUVsY(x1, x2, z1, z2, u_offset, v_offset, manip);

		p.pack(p, x1, y, z1, texture, aoTL, normal, uv[0][0], uv[0][1]);
		p.pack(p, x1, y, z2, texture, aoBL, normal, uv[1][0], uv[1][1]);
		p.pack(p, x2, y, z2, texture, aoBR, normal, uv[2][0], uv[2][1]);
		p.pack(p, x2, y, z1, texture, aoTR, normal, uv[3][0], uv[3][1]);
	}

	void emitQuadMappedUVAOYP(int x1, int x2, int y, int z1, int z2,
				  ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
				  ubyte texture, sideNormal normal,
				  int u_offset, int v_offset)
	{
		emitQuadMappedUVAOYP(x1, x2, y, z1, z2, aoBL, aoBR, aoTL, aoTR,
				     texture, normal, u_offset, v_offset, uvManip.NONE);
	}

	void emitQuadAOYN(int x1, int x2, int y, int z1, int z2,
			  ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			  ubyte texture, sideNormal normal)
	{
		p.pack(p, x1, y, z1, texture, aoTL, normal, uvCoord.LEFT, uvCoord.TOP);
		p.pack(p, x2, y, z1, texture, aoTR, normal, uvCoord.RIGHT, uvCoord.TOP);
		p.pack(p, x2, y, z2, texture, aoBR, normal, uvCoord.RIGHT, uvCoord.BOTTOM);
		p.pack(p, x1, y, z2, texture, aoBL, normal, uvCoord.LEFT, uvCoord.BOTTOM);
	}

	void emitQuadAOYN(int x1, int x2, int y, int z1, int z2,
			  ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			  ubyte texture, sideNormal normal, uvManip manip)
	{
		mixin UVManipulator!(manip);

		p.pack(p, x1, y, z1, texture, aoTL, normal, uTL, vTL);
		p.pack(p, x2, y, z1, texture, aoTR, normal, uTR, vTR);
		p.pack(p, x2, y, z2, texture, aoBR, normal, uBR, vBR);
		p.pack(p, x1, y, z2, texture, aoBL, normal, uBL, vBL);
	}

	void emitQuadMappedUVAOYN(int x1, int x2, int y, int z1, int z2,
				  ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
				  ubyte texture, sideNormal normal,
				  int u_offset, int v_offset, uvManip manip)
	{
		ushort uv[][] = genMappedManipUVsY(x1, x2, z1, z2, u_offset, v_offset, manip);

		p.pack(p, x1, y, z1, texture, aoTL, normal, uv[0][0], uv[0][1]);
		p.pack(p, x2, y, z1, texture, aoTR, normal, uv[3][0], uv[3][1]);
		p.pack(p, x2, y, z2, texture, aoBR, normal, uv[2][0], uv[2][1]);
		p.pack(p, x1, y, z2, texture, aoBL, normal, uv[1][0], uv[1][1]);
	}

	void emitQuadMappedUVAOYN(int x1, int x2, int y, int z1, int z2,
				  ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
				  ubyte texture, sideNormal normal,
				  int u_offset, int v_offset)
	{
		emitQuadMappedUVAOYN(x1, x2, y, z1, z2, aoBL, aoBR, aoTL, aoTR,
				     texture, normal, u_offset, v_offset, uvManip.NONE);
	}

	void emitQuadAOXZP(int x1, int x2, int y1, int y2, int z1, int z2,
			   ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			   ubyte texture, sideNormal normal)
	{
		p.pack(p, x2, y1, z1, texture, aoBR, normal, uvCoord.RIGHT, uvCoord.BOTTOM);
		p.pack(p, x2, y2, z1, texture, aoTR, normal, uvCoord.RIGHT, uvCoord.TOP);
		p.pack(p, x1, y2, z2, texture, aoTL, normal, uvCoord.LEFT, uvCoord.TOP);
		p.pack(p, x1, y1, z2, texture, aoBL, normal, uvCoord.LEFT, uvCoord.BOTTOM);
	}

	void emitQuadMappedUVAOXZP(int x1, int x2, int y1, int y2, int z1, int z2,
				   ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
				   ubyte texture, sideNormal normal,
				   int u_offset, int v_offset, uvManip manip)
	{
		ushort uv[][] = genMappedManipUVsXZ(x1, x2, y1, y2, z1, z2, u_offset, v_offset, normal, manip);

		p.pack(p, x2, y1, z1, texture, aoBR, normal, uv[2][0], uv[2][1]);
		p.pack(p, x2, y2, z1, texture, aoTR, normal, uv[3][0], uv[3][1]);
		p.pack(p, x1, y2, z2, texture, aoTL, normal, uv[0][0], uv[0][1]);
		p.pack(p, x1, y1, z2, texture, aoBL, normal, uv[1][0], uv[1][1]);
	}

	void emitQuadMappedUVAOXZP(int x1, int x2, int y1, int y2, int z1, int z2,
				   ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
				   ubyte texture, sideNormal normal,
				   int u_offset, int v_offset)
	{
		emitQuadMappedUVAOXZP(x1, x2, y1, y2, z1, z2, aoBL, aoBR, aoTL, aoTR,
				      texture, normal, u_offset, v_offset, uvManip.NONE);
	}

	void emitQuadAOXZN(int x1, int x2, int y1, int y2, int z1, int z2,
			   ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			   ubyte texture, sideNormal normal)
	{
		p.pack(p, x1, y1, z2, texture, aoBR, normal, uvCoord.RIGHT, uvCoord.BOTTOM);
		p.pack(p, x1, y2, z2, texture, aoTR, normal, uvCoord.RIGHT, uvCoord.TOP);
		p.pack(p, x2, y2, z1, texture, aoTL, normal, uvCoord.LEFT, uvCoord.TOP);
		p.pack(p, x2, y1, z1, texture, aoBL, normal, uvCoord.LEFT, uvCoord.BOTTOM);
	}

	void emitQuadMappedUVAOXZN(int x1, int x2, int y1, int y2, int z1, int z2,
				   ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
				   ubyte texture, sideNormal normal,
				   int u_offset, int v_offset, uvManip manip)
	{
		ushort uv[][] = genMappedManipUVsXZ(x1, x2, y1, y2, z1, z2, u_offset, v_offset, normal, manip);

		p.pack(p, x1, y1, z2, texture, aoBR, normal, uv[2][0], uv[2][1]);
		p.pack(p, x1, y2, z2, texture, aoTR, normal, uv[3][0], uv[3][1]);
		p.pack(p, x2, y2, z1, texture, aoTL, normal, uv[0][0], uv[0][1]);
		p.pack(p, x2, y1, z1, texture, aoBL, normal, uv[1][0], uv[1][1]);
	}

	void emitQuadMappedUVAOXZN(int x1, int x2, int y1, int y2, int z1, int z2,
				   ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
				   ubyte texture, sideNormal normal,
				   int u_offset, int v_offset)
	{
		emitQuadMappedUVAOXZN(x1, x2, y1, y2, z1, z1, aoBL, aoBR, aoTL, aoTR,
				      texture, normal, u_offset, v_offset, uvManip.NONE);
	}

	void emitQuadAOXZP(int x1, int x2, int y1, int y2, int z1, int z2,
			   ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			   ubyte texture, sideNormal normal, uvManip manip)
	{
		mixin UVManipulator!(manip);

		p.pack(p, x2, y1, z1, texture, aoBR, normal, uBR, vBR);
		p.pack(p, x2, y2, z1, texture, aoTR, normal, uTR, vTR);
		p.pack(p, x1, y2, z2, texture, aoTL, normal, uTL, vTL);
		p.pack(p, x1, y1, z2, texture, aoBL, normal, uBL, vBL);
	}

	void emitQuadAOXZN(int x1, int x2, int y1, int y2, int z1, int z2,
			   ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			   ubyte texture, sideNormal normal, uvManip manip)
	{
		mixin UVManipulator!(manip);

		p.pack(p, x1, y1, z2, texture, aoBR, normal, uBR, vBR);
		p.pack(p, x1, y2, z2, texture, aoTR, normal, uTR, vTR);
		p.pack(p, x2, y2, z1, texture, aoTL, normal, uTL, vTL);
		p.pack(p, x2, y1, z1, texture, aoBL, normal, uBL, vBL);
	}

	void emitHalfQuadAOXZP(int x1, int x2, int y1, int y2, int z1, int z2,
			       ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			       ubyte texture, sideNormal normal)
	{
		mixin UVManipulator!(uvManip.HALF_V);

		p.pack(p, x2, y1, z1, texture, aoBR, normal, uBR, vBR);
		p.pack(p, x2, y2, z1, texture, aoTR, normal, uTR, vTR);
		p.pack(p, x1, y2, z2, texture, aoTL, normal, uTL, vTL);
		p.pack(p, x1, y1, z2, texture, aoBL, normal, uBL, vBL);
	}

	void emitHalfQuadAOXZM(int x1, int x2, int y1, int y2, int z1, int z2,
			       ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			       ubyte texture, sideNormal normal)
	{
		mixin UVManipulator!(uvManip.HALF_V);

		p.pack(p, x1, y1, z2, texture, aoBR, normal, uBR, vBR);
		p.pack(p, x1, y2, z2, texture, aoTR, normal, uTR, vTR);
		p.pack(p, x2, y2, z1, texture, aoTL, normal, uTL, vTL);
		p.pack(p, x2, y1, z1, texture, aoBL, normal, uBL, vBL);
	}

	void emitQuadYP(int x1, int x2, int y, int z1, int z2,
			ubyte tex, sideNormal normal)
	{
		emitQuadAOYP(x1, x2, y, z1, z2, 0, 0, 0, 0, tex, normal);
	}

	void emitQuadYP(int x1, int x2, int y, int z1, int z2,
			ubyte tex, sideNormal normal, uvManip manip)
	{
		emitQuadAOYP(x1, x2, y, z1, z2, 0, 0, 0, 0, tex, normal, manip);
	}

	void emitQuadMappedUVYP(int x1, int x2, int y, int z1, int z2,
				  ubyte texture, sideNormal normal,
				  int u_offset, int v_offset, uvManip manip)
	{
		emitQuadMappedUVAOYP(x1, x2, y, z1, z2, 0, 0, 0, 0,
				     texture, normal, u_offset, v_offset, manip);
	}

	void emitQuadMappedUVYP(int x1, int x2, int y, int z1, int z2,
				  ubyte texture, sideNormal normal)
	{
		emitQuadMappedUVAOYP(x1, x2, y, z1, z2, 0, 0, 0, 0,
				     texture, normal, 0, 0, uvManip.NONE);
	}

	void emitQuadYN(int x1, int x2, int y, int z1, int z2,
			ubyte tex, sideNormal normal)
	{
		emitQuadAOYN(x1, x2, y, z1, z2, 0, 0, 0, 0, tex, normal);
	}

	void emitQuadYN(int x1, int x2, int y, int z1, int z2,
			ubyte tex, sideNormal normal, uvManip manip)
	{
		emitQuadAOYN(x1, x2, y, z1, z2, 0, 0, 0, 0, tex, normal, manip);
	}

	void emitQuadMappedUVYN(int x1, int x2, int y, int z1, int z2,
				  ubyte texture, sideNormal normal,
				  int u_offset, int v_offset, uvManip manip)
	{
		emitQuadMappedUVAOYN(x1, x2, y, z1, z2, 0, 0, 0, 0,
				     texture, normal, u_offset, v_offset, manip);
	}

	void emitQuadMappedUVYN(int x1, int x2, int y, int z1, int z2,
				  ubyte texture, sideNormal normal)
	{
		emitQuadMappedUVAOYN(x1, x2, y, z1, z2, 0, 0, 0, 0,
				     texture, normal, 0, 0, uvManip.NONE);
	}

	void emitQuadXZP(int x1, int x2, int y1, int y2, int z1, int z2,
			 ubyte tex, sideNormal normal)
	{
		emitQuadAOXZP(x1, x2, y1, y2, z1, z2, 0, 0, 0, 0, tex, normal);
	}

	void emitQuadXZN(int x1, int x2, int y1, int y2, int z1, int z2,
			 ubyte tex, sideNormal normal)
	{
		emitQuadAOXZN(x1, x2, y1, y2, z1, z2, 0, 0, 0, 0, tex, normal);
	}

	void emitQuadXZP(int x1, int x2, int y1, int y2, int z1, int z2,
			 ubyte tex, sideNormal normal, uvManip manip)
	{
		emitQuadAOXZP(x1, x2, y1, y2, z1, z2, 0, 0, 0, 0, tex, normal, manip);
	}

	void emitQuadXZN(int x1, int x2, int y1, int y2, int z1, int z2,
			 ubyte tex, sideNormal normal, uvManip manip)
	{
		emitQuadAOXZN(x1, x2, y1, y2, z1, z2, 0, 0, 0, 0, tex, normal, manip);
	}

	void emitTiltedQuadXZP(int bx1, int bx2, int tx1, int tx2, int y1, int y2,
			       int bz1, int bz2, int tz1, int tz2,
			       ubyte tex, sideNormal normal)
	{
		p.pack(p, bx2, y1, bz1, tex, 0, normal, uvCoord.RIGHT, uvCoord.BOTTOM);
		p.pack(p, tx2, y2, tz1, tex, 0, normal, uvCoord.RIGHT, uvCoord.TOP);
		p.pack(p, tx1, y2, tz2, tex, 0, normal, uvCoord.LEFT, uvCoord.TOP);
		p.pack(p, bx1, y1, bz2, tex, 0, normal, uvCoord.LEFT, uvCoord.BOTTOM);
	}

	void emitTiltedQuadXZN(int bx1, int bx2, int tx1, int tx2, int y1, int y2,
			       int bz1, int bz2, int tz1, int tz2,
			       ubyte tex, sideNormal normal)
	{
		p.pack(p, bx1, y1, bz2, tex, 0, normal, uvCoord.RIGHT, uvCoord.BOTTOM);
		p.pack(p, tx1, y2, tz2, tex, 0, normal, uvCoord.RIGHT, uvCoord.TOP);
		p.pack(p, tx2, y2, tz1, tex, 0, normal, uvCoord.LEFT, uvCoord.TOP);
		p.pack(p, bx2, y1, bz1, tex, 0, normal, uvCoord.LEFT, uvCoord.BOTTOM);
	}

	void emitQuadMappedUVXZP(int x1, int x2, int y1, int y2, int z1, int z2,
				 ubyte tex, sideNormal normal,
				 int u_offset, int v_offset, uvManip manip)
	{
		emitQuadMappedUVAOXZP(x1, x2, y1, y2, z1, z2, 0, 0, 0, 0,
				      tex, normal, u_offset, v_offset, manip);
	}

	void emitQuadMappedUVXZN(int x1, int x2, int y1, int y2, int z1, int z2,
				 ubyte tex, sideNormal normal,
				 int u_offset, int v_offset, uvManip manip)
	{
		emitQuadMappedUVAOXZN(x1, x2, y1, y2, z1, z2, 0, 0, 0, 0,
				      tex, normal, u_offset, v_offset, manip);
	}

	void emitQuadMappedUVXZP(int x1, int x2, int y1, int y2, int z1, int z2,
				 ubyte tex, sideNormal normal)
	{
		emitQuadMappedUVAOXZP(x1, x2, y1, y2, z1, z2, 0, 0, 0, 0,
			      tex, normal, 0, 0, uvManip.NONE);
	}

	void emitQuadMappedUVXZN(int x1, int x2, int y1, int y2, int z1, int z2,
				 ubyte tex, sideNormal normal)
	{
		emitQuadMappedUVAOXZN(x1, x2, y1, y2, z1, z2, 0, 0, 0, 0,
			      tex, normal, 0, 0, uvManip.NONE);
	}

	void emitDiagonalQuads(int x1, int x2, int y1, int y2, int z1, int z2, ubyte tex)
	{
		emitQuadAOXZN(x1, x2, y1, y2, z1, z2, 0, 0, 0, 0, tex, sideNormal.XNZN);
		emitQuadAOXZP(x1, x2, y1, y2, z1, z2, 0, 0, 0, 0, tex, sideNormal.XPZP);

		// We flip the z values to get the other two set of coords.
		emitQuadAOXZP(x1, x2, y1, y2, z2, z1, 0, 0, 0, 0, tex, sideNormal.XNZP);
		emitQuadAOXZN(x1, x2, y1, y2, z2, z1, 0, 0, 0, 0, tex, sideNormal.XPZN);
	}

	/*
		+--+
		|  |
		|  +--+
		| /   |
		|/    |
		o-----+
	*/
	void emitStairQuadsLP(int x1, int x3, int y1, int y3, int z1, int z3,
			      ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			      ubyte texture, sideNormal normal)
	{
		ubyte aoTC = cast(ubyte)((aoTL + aoTR)/2);
		ubyte aoMR = cast(ubyte)((aoBR + aoTR)/2);
		ubyte aoMC = cast(ubyte)((aoBL + aoTR)/2);

		int x2 = (x1 + x3)/2, y2 = (y1 + y3)/2, z2 = (z1 + z3)/2;

		p.pack(p, x2, y2, z2, texture, aoMC, normal, uvCoord.CENTER, uvCoord.MIDDLE);
		p.pack(p, x2, y3, z2, texture, aoTC, normal, uvCoord.CENTER, uvCoord.TOP);
		p.pack(p, x1, y3, z3, texture, aoTL, normal, uvCoord.LEFT,   uvCoord.TOP);
		p.pack(p, x1, y1, z3, texture, aoBL, normal, uvCoord.LEFT,   uvCoord.BOTTOM);

		p.pack(p, x2, y2, z2, texture, aoMC, normal, uvCoord.CENTER, uvCoord.MIDDLE);
		p.pack(p, x1, y1, z3, texture, aoBL, normal, uvCoord.LEFT,   uvCoord.BOTTOM);
		p.pack(p, x3, y1, z1, texture, aoBR, normal, uvCoord.RIGHT,  uvCoord.BOTTOM);
		p.pack(p, x3, y2, z1, texture, aoMR, normal, uvCoord.RIGHT,  uvCoord.MIDDLE);
	}

	void emitStairQuadsLN(int x1, int x3, int y1, int y3, int z1, int z3,
			      ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			      ubyte texture, sideNormal normal)
	{
		ubyte aoTC = cast(ubyte)((aoTL + aoTR)/2);
		ubyte aoML = cast(ubyte)((aoBL + aoTL)/2);
		ubyte aoMC = cast(ubyte)((aoBL + aoTR)/2);

		int x2 = (x1 + x3)/2, y2 = (y1 + y3)/2, z2 = (z1 + z3)/2;

		p.pack(p, x2, y2, z2, texture, aoMC, normal, uvCoord.CENTER, uvCoord.MIDDLE);
		p.pack(p, x1, y1, z3, texture, aoBR, normal, uvCoord.LEFT,   uvCoord.BOTTOM);
		p.pack(p, x1, y3, z3, texture, aoTR, normal, uvCoord.LEFT,   uvCoord.TOP);
		p.pack(p, x2, y3, z2, texture, aoTC, normal, uvCoord.CENTER, uvCoord.TOP);

		p.pack(p, x2, y2, z2, texture, aoMC, normal, uvCoord.CENTER, uvCoord.MIDDLE);
		p.pack(p, x3, y2, z1, texture, aoML, normal, uvCoord.RIGHT,  uvCoord.MIDDLE);
		p.pack(p, x3, y1, z1, texture, aoBL, normal, uvCoord.RIGHT,  uvCoord.BOTTOM);
		p.pack(p, x1, y1, z3, texture, aoBR, normal, uvCoord.LEFT,   uvCoord.BOTTOM);
	}

	/*
		   +--+
		   |  |
		+--+  |
		|   \ |
		|    \|
		o-----+
	*/
	void emitStairQuadsRP(int x1, int x3, int y1, int y3, int z1, int z3,
			      ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			      ubyte texture, sideNormal normal)
	{
		ubyte aoTC = cast(ubyte)((aoTL + aoTR)/2);
		ubyte aoML = cast(ubyte)((aoBL + aoTL)/2);
		ubyte aoMC = cast(ubyte)((aoBL + aoTR)/2);

		int x2 = (x1 + x3)/2, y2 = (y1 + y3)/2, z2 = (z1 + z3)/2;

		p.pack(p, x2, y2, z2, texture, aoMC, normal, uvCoord.CENTER, uvCoord.MIDDLE);
		p.pack(p, x1, y2, z3, texture, aoML, normal, uvCoord.LEFT,   uvCoord.MIDDLE);
		p.pack(p, x1, y1, z3, texture, aoBL, normal, uvCoord.LEFT,   uvCoord.BOTTOM);
		p.pack(p, x3, y1, z1, texture, aoBR, normal, uvCoord.RIGHT,  uvCoord.BOTTOM);

		p.pack(p, x2, y2, z2, texture, aoMC, normal, uvCoord.CENTER, uvCoord.MIDDLE);
		p.pack(p, x3, y1, z1, texture, aoBR, normal, uvCoord.RIGHT,  uvCoord.BOTTOM);
		p.pack(p, x3, y3, z1, texture, aoTR, normal, uvCoord.RIGHT,  uvCoord.TOP);
		p.pack(p, x2, y3, z2, texture, aoTC, normal, uvCoord.CENTER, uvCoord.TOP);
	}

	void emitStairQuadsRN(int x1, int x3, int y1, int y3, int z1, int z3,
			      ubyte aoBL, ubyte aoBR, ubyte aoTL, ubyte aoTR,
			      ubyte texture, sideNormal normal)
	{
		ubyte aoTC = cast(ubyte)((aoTL + aoTR)/2);
		ubyte aoMR = cast(ubyte)((aoBR + aoTR)/2);
		ubyte aoMC = cast(ubyte)((aoBL + aoTR)/2);

		int x2 = (x1 + x3)/2, y2 = (y1 + y3)/2, z2 = (z1 + z3)/2;

		p.pack(p, x2, y2, z2, texture, aoMC, normal, uvCoord.CENTER, uvCoord.MIDDLE);
		p.pack(p, x3, y1, z1, texture, aoBL, normal, uvCoord.RIGHT,  uvCoord.BOTTOM);
		p.pack(p, x1, y1, z3, texture, aoBR, normal, uvCoord.LEFT,   uvCoord.BOTTOM);
		p.pack(p, x1, y2, z3, texture, aoMR, normal, uvCoord.LEFT,   uvCoord.MIDDLE);

		p.pack(p, x2, y2, z2, texture, aoMC, normal, uvCoord.CENTER, uvCoord.MIDDLE);
		p.pack(p, x2, y3, z2, texture, aoTC, normal, uvCoord.CENTER, uvCoord.TOP);
		p.pack(p, x3, y3, z1, texture, aoTL, normal, uvCoord.RIGHT,  uvCoord.TOP);
		p.pack(p, x3, y1, z1, texture, aoBL, normal, uvCoord.RIGHT,  uvCoord.BOTTOM);
	}

	void emitAscendingRailQuadYP(int x1, int x2, int y1, int y2, int z1, int z2,
				    ubyte texture, sideNormal direction)
	{
		// swap Y values if it ascends in the opposite direction
		if (direction == sideNormal.XN || direction == sideNormal.ZN) {
			int tmp = y1; y1 = y2; y2 = tmp;
		}

		if (direction == sideNormal.XP || direction == sideNormal.XN) {
			p.pack(p, x1, y1, z2, texture, 0, sideNormal.YP, uvCoord.LEFT, uvCoord.TOP);
			p.pack(p, x2, y2, z2, texture, 0, sideNormal.YP, uvCoord.LEFT, uvCoord.BOTTOM);
			p.pack(p, x2, y2, z1, texture, 0, sideNormal.YP, uvCoord.RIGHT, uvCoord.BOTTOM);
			p.pack(p, x1, y1, z1, texture, 0, sideNormal.YP, uvCoord.RIGHT, uvCoord.TOP);
		} else if (direction == sideNormal.ZP || direction == sideNormal.ZN) {
			p.pack(p, x2, y2, z2, texture, 0, sideNormal.YP, uvCoord.LEFT, uvCoord.TOP);
			p.pack(p, x2, y1, z1, texture, 0, sideNormal.YP, uvCoord.LEFT, uvCoord.BOTTOM);
			p.pack(p, x1, y1, z1, texture, 0, sideNormal.YP, uvCoord.RIGHT, uvCoord.BOTTOM);
			p.pack(p, x1, y2, z2, texture, 0, sideNormal.YP, uvCoord.RIGHT, uvCoord.TOP);
		}
	}

	void emitAscendingRailQuadYN(int x1, int x2, int y1, int y2, int z1, int z2,
				    ubyte texture, sideNormal direction)
	{
		// swap Y values if it ascends in the opposite direction
		if (direction == sideNormal.XN || direction == sideNormal.ZN) {
			int tmp = y1; y1 = y2; y2 = tmp;
		}

		if (direction == sideNormal.XP || direction == sideNormal.XN) {
			p.pack(p, x1, y1, z2, texture, 0, sideNormal.YN, uvCoord.LEFT, uvCoord.TOP);
			p.pack(p, x1, y1, z1, texture, 0, sideNormal.YN, uvCoord.RIGHT, uvCoord.TOP);
			p.pack(p, x2, y2, z1, texture, 0, sideNormal.YN, uvCoord.RIGHT, uvCoord.BOTTOM);
			p.pack(p, x2, y2, z2, texture, 0, sideNormal.YN, uvCoord.LEFT, uvCoord.BOTTOM);
		} else if (direction == sideNormal.ZP || direction == sideNormal.ZN) {
			p.pack(p, x2, y2, z2, texture, 0, sideNormal.YN, uvCoord.LEFT, uvCoord.TOP);
			p.pack(p, x1, y2, z2, texture, 0, sideNormal.YN, uvCoord.RIGHT, uvCoord.TOP);
			p.pack(p, x1, y1, z1, texture, 0, sideNormal.YN, uvCoord.RIGHT, uvCoord.BOTTOM);
			p.pack(p, x2, y1, z1, texture, 0, sideNormal.YN, uvCoord.LEFT, uvCoord.BOTTOM);
		}
	}
}

/**
 * Constructs fullsized quads.
 *
 * Coordinates are shifted.
 */
template QuadBuilder()
{
	mixin QuadEmitter!();

	void makeY(BlockDescriptor *dec, uint x, uint y, uint z, sideNormal normal)
	{
		bool positive = isNormalPositive(normal);
		auto aoy = y + positive - !positive;
		mixin AOScannerY!();
		mixin AOCalculator!();

		int x1 = x, x2 = x+1;
		int z1 = z, z2 = z+1;
		y += positive;

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x1 <<= shift;
		x2 <<= shift;
		y  <<= shift;
		z1 <<= shift;
		z2 <<= shift;

		ubyte texture = calcTextureY(dec);

		if (positive) {
			emitQuadAOYP(x1, x2, y, z1, z2,
				     aoBL, aoBR, aoTL, aoTR,
				     texture, normal);
		} else {
			emitQuadAOYN(x1, x2, y, z1, z2,
				     aoBL, aoBR, aoTL, aoTR,
				     texture, normal);
		}
	}

	void makeStairXZ(BlockDescriptor *dec, uint x, uint y, uint z, sideNormal normal, bool left)
	{
		bool positive = isNormalPositive(normal);
		bool normalIsZ = isNormalZ(normal);
		bool normalIsX = !normalIsZ;

		mixin AOSetupScannerCoordsXZ!();
		mixin AOScannerXZ!();
		mixin AOCalculator!();

		// Where does the side stand.
		int x1 = x + (positive & normalIsX);
		int z1 = z + (positive & normalIsZ);

		// If the normal is parallel to the other axis change the coordinate.
		int x2 = x1 + normalIsZ;
		int z2 = z1 + normalIsX;

		// Height
		int y1 = y, y2 = y+1;

		ubyte texture = calcTextureXZ(dec);

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x1 <<= shift;
		x2 <<= shift;
		y1 <<= shift;
		y2 <<= shift;
		z1 <<= shift;
		z2 <<= shift;

		auto emitStairQuads = &emitStairQuadsLP;
		if (positive) {
			if (left) {
				emitStairQuads = &emitStairQuadsLP;
			} else {
				emitStairQuads = &emitStairQuadsRP;
			}
		} else {
			if (left) {
				emitStairQuads = &emitStairQuadsLN;
			} else {
				emitStairQuads = &emitStairQuadsRN;
			}
		}

		emitStairQuads(x1, x2, y1, y2, z1, z2,
			       aoBL, aoBR, aoTL, aoTR,
			       texture, normal);
	}

	void makeXZ(BlockDescriptor *dec, uint x, uint y, uint z, sideNormal normal)
	{
		bool positive = isNormalPositive(normal);
		bool normalIsZ = isNormalZ(normal);
		bool normalIsX = !normalIsZ;

		mixin AOSetupScannerCoordsXZ!();
		mixin AOScannerXZ!();
		mixin AOCalculator!();

		// Where does the side stand.
		int x1 = x + (positive & normalIsX);
		int z1 = z + (positive & normalIsZ);

		// If the normal is parallel to the other axis change the coordinate.
		int x2 = x1 + normalIsZ;
		int z2 = z1 + normalIsX;

		// Height
		int y1 = y, y2 = y+1;

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x1 <<= shift;
		x2 <<= shift;
		y1 <<= shift;
		y2 <<= shift;
		z1 <<= shift;
		z2 <<= shift;

		ubyte texture = calcTextureXZ(dec);

		if (positive) {
			emitQuadAOXZP(x1, x2, y1, y2, z1, z2,
				      aoBL, aoBR, aoTL, aoTR,
				      texture, normal);
		} else {
			emitQuadAOXZN(x1, x2, y1, y2, z1, z2,
				      aoBL, aoBR, aoTL, aoTR,
				      texture, normal);
		}
	}

	void makeXYZ(BlockDescriptor *dec, uint x, uint y, uint z, int set)
	{
		if (set & sideMask.XN)
			makeXZ(dec, x, y, z, sideNormal.XN);

		if (set & sideMask.XP)
			makeXZ(dec, x, y, z, sideNormal.XP);

		if (set & sideMask.YN)
			makeY(dec, x, y, z, sideNormal.YN);

		if (set & sideMask.YP)
			makeY(dec, x, y, z, sideNormal.YP);

		if (set & sideMask.ZN)
			makeXZ(dec, x, y, z, sideNormal.ZN);

		if (set & sideMask.ZP)
			makeXZ(dec, x, y, z, sideNormal.ZP);
	}

	void makeHalfY(BlockDescriptor *dec, uint x, uint y, uint z,
		       uint height = VERTEX_SIZE_DIVISOR / 2)
	{
		auto aoy = y;
		mixin AOScannerY!();
		mixin AOCalculator!();

		int x1 = x, x2 = x+1;
		int z1 = z, z2 = z+1;

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x1 <<= shift;
		x2 <<= shift;
		z1 <<= shift;
		z2 <<= shift;

		y <<= shift;
		y += height;

		ubyte texture = calcTextureY(dec);

		emitQuadAOYP(x1, x2, y, z1, z2,
			     aoBL, aoBR, aoTL, aoTR,
			     texture, sideNormal.YP);
	}

	void makeHalfXZ(BlockDescriptor *dec, uint x, uint y, uint z, sideNormal normal,
			uint height = VERTEX_SIZE_DIVISOR / 2)
	{
		bool positive = isNormalPositive(normal);
		bool normalIsZ = isNormalZ(normal);
		bool normalIsX = !normalIsZ;

		mixin AOSetupScannerCoordsXZ!();

		auto c1 = data.filled(aoXn, y-1, aoZn);
		auto c2 = data.filled(aoXm, y-1, aoZm);
		auto c3 = data.filled(aoXp, y-1, aoZp);
		auto c4 = data.filled(aoXn, y  , aoZn);
		auto c5 = data.filled(aoXp, y  , aoZp);
		auto c6 = false;
		auto c7 = false;
		auto c8 = false;

		mixin AOCalculator!();

		// Where does the side stand.
		int x1 = x + (positive & normalIsX);
		int z1 = z + (positive & normalIsZ);

		// If the normal is parallel to the other axis change the coordinate.
		int x2 = x1 + normalIsZ;
		int z2 = z1 + normalIsX;

		// Height
		int y1 = y, y2;

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x1 <<= shift;
		x2 <<= shift;
		y1 <<= shift;
		y2 = y1 + height;
		z1 <<= shift;
		z2 <<= shift;

		ubyte texture = calcTextureXZ(dec);

		if (height == VERTEX_SIZE_DIVISOR / 2) {
			if (positive) {
				emitHalfQuadAOXZP(x1, x2, y1, y2, z1, z2,
						  aoBL, aoBR, aoTL, aoTR,
						  texture, normal);
			} else {
				emitHalfQuadAOXZM(x1, x2, y1, y2, z1, z2,
						  aoBL, aoBR, aoTL, aoTR,
						  texture, normal);
			}
		} else {
			if (positive) {
				emitQuadMappedUVAOXZP(x1, x2, y1, y2, z1, z2,
						      aoBL, aoBR, aoTL, aoTR,
						      texture, normal,
						      0, 0, uvManip.NONE);
			} else {
				emitQuadMappedUVAOXZN(x1, x2, y1, y2, z1, z2,
						      aoBL, aoBR, aoTL, aoTR,
						      texture, normal,
						      0, 0, uvManip.NONE);
			}
		}
	}

	void makeHalfXYZ(BlockDescriptor *dec, uint x, uint y, uint z, int set,
			 uint height = VERTEX_SIZE_DIVISOR / 2)
	{
		if (set & sideMask.XN)
			makeHalfXZ(dec, x, y, z, sideNormal.XN, height);

		if (set & sideMask.XP)
			makeHalfXZ(dec, x, y, z, sideNormal.XP, height);

		if (set & sideMask.YN)
			makeY(dec, x, y, z, sideNormal.YN);

		if (set & sideMask.YP)
			makeHalfY(dec, x, y, z, height);

		if (set & sideMask.ZN)
			makeHalfXZ(dec, x, y, z, sideNormal.ZN, height);

		if (set & sideMask.ZP)
			makeHalfXZ(dec, x, y, z, sideNormal.ZP, height);
	}

	void makeFacedBlock(BlockDescriptor *dec, BlockDescriptor *decFace,
			    uint x, uint y, uint z, sideNormal faceNormal, int set)
	{

		if (set & sideMask.ZN)
			makeXZ((faceNormal == sideNormal.ZN) ? decFace : dec, x, y, z, sideNormal.ZN);
		if (set & sideMask.ZP)
			makeXZ((faceNormal == sideNormal.ZP) ? decFace : dec, x, y, z, sideNormal.ZP);
		if (set & sideMask.XN)
			makeXZ((faceNormal == sideNormal.XN) ? decFace : dec, x, y, z, sideNormal.XN);
		if (set & sideMask.XP)
			makeXZ((faceNormal == sideNormal.XP) ? decFace : dec, x, y, z, sideNormal.XP);
		if (set & sideMask.YN)
			makeY(dec, x, y, z, sideNormal.YN);
		if (set & sideMask.YP)
			makeY(dec, x, y, z, sideNormal.YP);
	}
}

/**
 * Dispatches blocks from a chunk.
 */
template BlockDispatcher()
{
	mixin QuadBuilder!();

	void solidDec(BlockDescriptor *dec, uint x, uint y, uint z) {
		int set = data.getSolidSet(x, y, z);

		/* all set */
		if (set == 0)
			return;

		makeXYZ(dec, x, y, z, set);
	}

	void solid(ubyte type, uint x, uint y, uint z) {
		auto dec = &tile[type];
		solidDec(dec, x, y, z);
	}

	void grass(int x, int y, int z) {
		int set = data.getSolidSet(x, y, z);
		auto grassDec = &tile[2];
		auto dirtDec = &tile[3];
		auto snowDec = &snowyGrassBlock;

		if (data.get(x, y + 1, z) == 78 /* snow */)
			makeXYZ(snowDec, x, y, z, set & ~sideMask.YN);
		else
			makeXYZ(grassDec, x, y, z, set & ~sideMask.YN);

		if (set & sideMask.YN)
			makeY(dirtDec, x, y, z, sideNormal.YN);
	}

	void water(int x, int y, int z) {
		int set = data.getSolidOrTypesSet(8, 9, x, y, z);
		auto dec = &tile[8];
		ubyte tex = calcTextureXZ(dec);
		
		int x1 = x, x2 = x+1;
		int z1 = z, z2 = z+1;

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x1 <<= shift;
		x2 <<= shift;
		z1 <<= shift;
		z2 <<= shift;

		int y1 = y, y2 = y + 1;
		y1 <<= shift;
		y2 <<= shift;

		auto aboveType = data.get(x, y+1, z);
		if (aboveType != 8 && aboveType != 9) {
			set |= sideMask.YP;
			y2 -= 2;
		}

		if (set & sideMask.XN)
			emitQuadXZN(x1, x1, y1, y2, z1, z2, tex, sideNormal.XN);
		if (set & sideMask.XP)
			emitQuadXZP(x2, x2, y1, y2, z1, z2, tex, sideNormal.XP);

		if (set & sideMask.YN)
			emitQuadYN(x1, x2, y1, z1, z2, tex, sideNormal.YN);
		if (set & sideMask.YP)
			emitQuadYP(x1, x2, y2, z1, z2, tex, sideNormal.YP);

		if (set & sideMask.ZN)
			emitQuadXZN(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZN);
		if (set & sideMask.ZP)
			emitQuadXZP(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZP);
	}

	void wood(int x, int y, int z) {
		auto dec = &woodTile[data.getDataUnsafe(x, y, z)];
		solidDec(dec, x, y, z);
	}

	void glass(uint x, uint y, uint z) {
		const type = 20;
		auto dec = &tile[type];
		int set = data.getSolidOrTypeSet(type, x, y, z);

		/* all set */
		if (set == 0)
			return;

		makeXYZ(dec, x, y, z, set);
	}

	void dispenser(int x, int y, int z) {
		auto dec = &tile[23];
		auto decFront = &dispenserFrontTile;
		int set = data.getSolidSet(x, y, z);
		auto d = data.getDataUnsafe(x, y, z);

		auto faceNormal = [sideNormal.ZN, sideNormal.ZP,
				   sideNormal.XN, sideNormal.XP][d-2];

		makeFacedBlock(dec, decFront, x, y, z, faceNormal, set);
	}

	void bed(int x, int y, int z) {
		int set = data.getSolidSet(x, y, z);
		ubyte d = data.getDataUnsafe(x, y, z);
		ubyte tex = 0;

		ubyte direction = d & 3;
		bool cushion = (d & 8) == 8;
		int dec_index = [0, 3][cushion];

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		int y1 = y, y2 = y + 8;
		int x1 = x, x2 = x + 16;
		int z1 = z, z2 = z + 16;

		uvManip rotation = [uvManip.ROT_90, uvManip.ROT_180,
				    uvManip.ROT_270, uvManip.NONE][direction];

		// use wood as bottom texture
		tex = calcTextureY(&tile[5]);
		emitQuadMappedUVYN(x1, x2, y1+4, z1, z2, tex, sideNormal.YN, 0, 0, rotation);

		// top
		tex = calcTextureY(&bedTile[dec_index]);
		emitQuadMappedUVYP(x1, x2, y2, z1, z2, tex, sideNormal.YP, 0, 0, rotation);

		// draw one side
		dec_index++;
		tex = calcTextureXZ(&bedTile[dec_index]);

		// direction % 2 is the axis the bed is facing (0 is X, 1 is Z)
		x2 = [x1, x2][direction % 2];
		z2 = [z2, z1][direction % 2];
		sideNormal side_normal = [sideNormal.XN, sideNormal.ZN][direction % 2];
		bool flip_tex = direction > 1;

		if (set & (1 << side_normal))
			emitQuadMappedUVXZN(x1, x2, y1, y2, z1, z2, tex, side_normal, 0, -8, flip_tex ? uvManip.FLIP_U : uvManip.NONE);

		// draw opposite side
		if (isNormalX(side_normal)) {
			side_normal = sideNormal.XP;
			x1 = x2 += 16;
		} else if (isNormalZ(side_normal)) {
			side_normal = sideNormal.ZP;
			z1 = z2 += 16;
		}

		if (set & (1 << side_normal)) {
			emitQuadMappedUVXZP(x1, x2, y1, y2, z1, z2, tex, side_normal, 0, -8, flip_tex ? uvManip.NONE : uvManip.FLIP_U);
		}

		// draw front
		auto params = [
			[x,    x+16, z,    z,    sideNormal.ZN],
			[x+16, x+16, z,    z+16, sideNormal.XP],
			[x,    x+16, z+16, z+16, sideNormal.ZP],
			[x,    x,    z,    z+16, sideNormal.XN]
		][(direction + cushion*2) % 4]; // offset array access by two for cushion part (equals a rotation by 180 degrees)
		sideNormal front_normal = cast(sideNormal)(params[4]);

		if (set & (1 << front_normal)) {
			dec_index++;
			tex = calcTextureXZ(&bedTile[dec_index]);

			auto emit = [&emitQuadMappedUVXZN, &emitQuadMappedUVXZP][isNormalPositive(front_normal)];
			emit(params[0], params[1], y1, y2, params[2], params[3], tex, front_normal, 0, -8, uvManip.NONE);
		}
	}

	void wool(int x, int y, int z) {
		auto dec = &woolTile[data.getDataUnsafe(x, y, z)];
		solidDec(dec, x, y, z);
	}

	void sapling(int x, int y, int z) {
		auto d = data.getDataUnsafe(x, y, z);
		auto dec = &saplingTile[d & 3];
		auto tex = calcTextureXZ(dec);

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		int x1 = x, x2 = x+16;
		int y1 = y, y2 = y+16;
		int z1 = z, z2 = z+16;

		emitDiagonalQuads(x1, x2, y1, y2, z1, z2, tex);
	}

	void plants(BlockDescriptor *dec, int x, int y, int z) {
		auto tex = calcTextureXZ(dec);

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		int x1 = x, x2 = x+16;
		int y1 = y, y2 = y+16;
		int z1 = z, z2 = z+16;

		emitDiagonalQuads(x1, x2, y1, y2, z1, z2, tex);
	}

	void slab(ubyte type, uint x, uint y, uint z) {
		int set = data.getSolidOrTypeSet(type, x, y, z);
		auto d = data.getDataUnsafe(x, y, z);

		auto dec = &slabTile[d];

		if (type == 44)
			makeHalfXYZ(dec, x, y, z, set | sideMask.YP);

		else if (set != 0) /* nothing to do */
			makeXYZ(dec, x, y, z, set);
	}

	void standing_torch(int x, int y, int z, ubyte tex) {
		// Renders a torch with its center at x,z in shifted coordinates.
		int x1 = x-8, x2 = x+8;
		int y1 = y,   y2 = y+16;
		int z1 = z+1, z2 = z-1;

		emitQuadXZN(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZN);
		emitQuadXZP(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZP);

		x1 = x+1; x2 = x-1;
		z1 = z-8; z2 = z+8;

		emitQuadXZN(x2, x2, y1, y2, z1, z2, tex, sideNormal.XN);
		emitQuadXZP(x1, x1, y1, y2, z1, z2, tex, sideNormal.XP);

		// Use center part of the texture as top.
		emitQuadMappedUVYP(x-1, x+1, y+10, z-1, z+1, tex, sideNormal.YP,
				   8 - x % 16, 8 - z % 16 -1, uvManip.NONE);
	}

	void torch(ubyte type, int x, int y, int z) {
		auto dec = &tile[type];
		ubyte tex = calcTextureXZ(dec);
		auto d = data.getDataUnsafe(x, y, z);

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		if (d >= 5)
			return standing_torch(x+8, y, z+8, tex);

		d--;

		int bxoff = [-8, +8,  0,  0][d];
		int txoff = bxoff / 4;
		int bzoff = [ 0,  0, -8, +8][d];
		int tzoff = bzoff / 4;

		int x1 = x,   x2 = x+16;
		int y1 = y+3, y2 = y+19;
		int z1 = z+9, z2 = z+7;

		emitTiltedQuadXZN(x1+bxoff, x2+bxoff, x1+txoff, x2+txoff, y1, y2,
				  z2+bzoff, z2+bzoff, z2+tzoff, z2+tzoff, tex, sideNormal.ZN);
		emitTiltedQuadXZP(x1+bxoff, x2+bxoff, x1+txoff, x2+txoff, y1, y2,
				  z1+bzoff, z1+bzoff, z1+tzoff, z1+tzoff, tex, sideNormal.ZP);

		x1 = x+9; x2 = x+7;
		z1 = z;   z2 = z+16;

		emitTiltedQuadXZN(x2+bxoff, x2+bxoff, x2+txoff, x2+txoff, y1, y2,
				  z1+bzoff, z2+bzoff, z1+tzoff, z2+tzoff, tex, sideNormal.XN);
		emitTiltedQuadXZP(x1+bxoff, x1+bxoff, x1+txoff, x1+txoff, y1, y2,
				  z1+bzoff, z2+bzoff, z1+tzoff, z2+tzoff, tex, sideNormal.XP);

		// Use center part of the texture as top.
		int xoff = [-4, +4,  0,  0][d];
		int zoff = [ 0,  0, -4, +4][d];
		int uoff = [+4, -4,  0,  0][d];
		int voff = [-1, -1, +3, -5][d];

		emitQuadMappedUVYP(x+7+xoff, x+9+xoff, y+13, z+7+zoff, z+9+zoff,
				   tex, sideNormal.YP, uoff, voff, uvManip.NONE);
	}

	void chest(int x, int y, int z) {
		const type = 54;
		auto dec = &chestTile[0];
		int set = data.getSolidSet(x, y, z);

		// Look for adjacent chests.
		ubyte north = data.get(x, y, z-1) == type;
		ubyte south = data.get(x, y, z+1) == type;
		ubyte east = data.get(x-1, y, z) == type;
		ubyte west = data.get(x+1, y, z) == type;

		// No chest around, render a single chest.
		if (!north && !south && !east && !west) {
			auto frontDec = &chestTile[1];
			return makeFacedBlock(dec, frontDec, x, y, z, sideNormal.ZP, set);
		}

		// Double chest along the z-axis will face west.
		if (north || south) {
			auto front_dec = (north) ? &chestTile[2] : &chestTile[3];
			auto back_dec = (north) ? &chestTile[5] : &chestTile[4];

			if (set & sideMask.ZN)
				makeXZ(dec, x, y, z, sideNormal.ZN);
			if (set & sideMask.ZP)
				makeXZ(dec, x, y, z, sideNormal.ZP);
			if (set & sideMask.XN)
				makeXZ(back_dec, x, y, z, sideNormal.XN);
			if (set & sideMask.XP)
				makeXZ(front_dec, x, y, z, sideNormal.XP);
		// Double chest along the x-axis will face south.
		} else {
			auto front_dec = (west) ? &chestTile[2] : &chestTile[3];
			auto back_dec = (west) ? &chestTile[5] : &chestTile[4];

			if (set & sideMask.ZN)
				makeXZ(back_dec, x, y, z, sideNormal.ZN);
			if (set & sideMask.ZP)
				makeXZ(front_dec, x, y, z, sideNormal.ZP);
			if (set & sideMask.XN)
				makeXZ(dec, x, y, z, sideNormal.XN);
			if (set & sideMask.XP)
				makeXZ(dec, x, y, z, sideNormal.XP);
		}

		if (set & sideMask.YN)
			makeY(dec, x, y, z, sideNormal.YN);
		if (set & sideMask.YP)
			makeY(dec, x, y, z, sideNormal.YP);
	}

	void redstone_wire(int x, int y, int z) {
		bool shouldLinkTo(ubyte type) {
			return type == 55 || type == 75 || type == 76;
		}

		auto d = data.getDataUnsafe(x, y, z);

		// Find all neighbours with either redstone wire or a torch.
		ubyte NORTH = data.get(x, y, z-1), NORTH_DOWN = data.get(x, y-1, z-1), NORTH_UP = data.get(x, y+1, z-1);
		ubyte SOUTH = data.get(x, y, z+1), SOUTH_DOWN = data.get(x, y-1, z+1), SOUTH_UP = data.get(x, y+1, z+1);
		ubyte EAST = data.get(x-1, y, z), EAST_DOWN = data.get(x-1, y-1, z), EAST_UP = data.get(x-1, y+1, z);
		ubyte WEST = data.get(x+1, y, z), WEST_DOWN = data.get(x+1, y-1, z), WEST_UP = data.get(x+1, y+1, z);

		auto north = shouldLinkTo(NORTH) || shouldLinkTo(NORTH_UP) || shouldLinkTo(NORTH_DOWN);
		auto south = shouldLinkTo(SOUTH) || shouldLinkTo(SOUTH_UP) || shouldLinkTo(SOUTH_DOWN);
		auto east = shouldLinkTo(EAST) || shouldLinkTo(EAST_UP) || shouldLinkTo(EAST_DOWN);
		auto west = shouldLinkTo(WEST) || shouldLinkTo(WEST_UP) || shouldLinkTo(WEST_DOWN);

		ubyte connection = north << 0 | south << 1 | east << 2 | west << 3;

		int x1=x, y1=y, z1=z;

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x1 <<= shift;
		y1 <<= shift;
		z1 <<= shift;

		struct WireMapping {
			RedstoneWireType type;
			uvManip manip;
		}

		// For every possible combination of redstone connections, get the needed tile
		// and necessary uv manipulations.
		const WireMapping mappings[] = [
			{RedstoneWireType.Crossover, 	uvManip.NONE},		// A single wire, no connections.
			{RedstoneWireType.Line,		uvManip.ROT_90},	// N
			{RedstoneWireType.Line,		uvManip.ROT_90},	// S
			{RedstoneWireType.Line,		uvManip.ROT_90},	// N+S
			{RedstoneWireType.Line,		uvManip.NONE},		// E
			{RedstoneWireType.Corner,    	uvManip.ROT_90},	// E+N
			{RedstoneWireType.Corner,    	uvManip.NONE},		// E+S
			{RedstoneWireType.Tjunction,   	uvManip.NONE},		// E+N+S
			{RedstoneWireType.Line,		uvManip.NONE},		// W
			{RedstoneWireType.Corner,    	uvManip.ROT_180},	// W+N
			{RedstoneWireType.Corner,    	uvManip.FLIP_U},	// W+S
			{RedstoneWireType.Tjunction,   	uvManip.FLIP_U},	// W+N+S
			{RedstoneWireType.Line,		uvManip.NONE},		// W+E
			{RedstoneWireType.Tjunction,   	uvManip.ROT_90},	// W+E+N
			{RedstoneWireType.Tjunction,   	uvManip.ROT_270},	// W+E+S
			{RedstoneWireType.Crossover,	uvManip.NONE}		// W+E+N+S
		];

		uint active = (d > 0) ? 1 : 0;
		WireMapping tile = mappings[connection];

		// Place wire on the ground.
		ubyte tex = calcTextureXZ(&redstoneWireTile[active][tile.type]);
		emitQuadYP(x1, x1+16, y1+1, z1, z1+16, tex, sideNormal.YP, tile.manip);

		// Place wire at the side of a block.
		tex = calcTextureXZ(&redstoneWireTile[active][RedstoneWireType.Line]);

		if (shouldLinkTo(NORTH_UP))
			emitQuadXZP(x1, x1+16, y1, y1+16, z1+1, z1+1, tex, sideNormal.ZP, uvManip.ROT_90);
		if (shouldLinkTo(SOUTH_UP))
			emitQuadXZN(x1, x1+16, y1, y1+16, z1+15, z1+15, tex, sideNormal.ZN, uvManip.ROT_90);
		if (shouldLinkTo(EAST_UP))
			emitQuadXZP(x1+1, x1+1, y1, y1+16, z1, z1+16, tex, sideNormal.XP, uvManip.ROT_90);
		if (shouldLinkTo(WEST_UP))
			emitQuadXZN(x1+15, x1+15, y1, y1+16, z1, z1+16, tex, sideNormal.XN, uvManip.ROT_90);
	}

	void craftingTable(uint x, uint y, uint z) {
		int set = data.getSolidSet(x, y, z);
		int setAlt = set & (1 << 0 | 1 << 4);
		auto dec = &tile[58];
		auto decAlt = &craftingTableAltTile;

		// Don't emit the same sides
		set &= ~setAlt;

		if (set != 0)
			makeXYZ(dec, x, y, z, set);

		if (setAlt != 0)
			makeXYZ(decAlt, x, y, z, setAlt);
	}

	void crops(int x, int y, int z) {
		auto dec = &cropsTile[data.getDataUnsafe(x, y, z)];
		ubyte tex = calcTextureXZ(dec);
		const int set = 51;

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		// TODO Crops should be offset 1/16 of a block.
		int x1 = x,    x2 = x+16;
		int y1 = y,    y2 = y+16;

		int z1 = z+4;
		emitQuadXZN(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZN);
		emitQuadXZP(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZP);
		int z2 = z+12;
		emitQuadXZN(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZN);
		emitQuadXZP(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZP);

		z1 = z; z2 = z+16;

		x1 = x+4;
		emitQuadXZN(x1, x1, y1, y2, z1, z2, tex, sideNormal.XN);
		emitQuadXZP(x1, x1, y1, y2, z1, z2, tex, sideNormal.XP);

		x2 = x+12;
		emitQuadXZN(x2, x2, y1, y2, z1, z2, tex, sideNormal.XN);
		emitQuadXZP(x2, x2, y1, y2, z1, z2, tex, sideNormal.XP);
	}

	void stair(ubyte type, int x, int y, int z) {
		auto dec = &tile[type];
		int set = data.getSolidSet(x, y, z);
		auto d = data.getDataUnsafe(x, y, z);
		ubyte tex = calcTextureXZ(dec);

		// Half front
		sideMask frontMask = [sideMask.XN, sideMask.XP, sideMask.ZN, sideMask.ZP][d];
		makeHalfXYZ(dec, x, y, z, frontMask & set);

		sideMask backMask = [sideMask.XP, sideMask.XN, sideMask.ZP, sideMask.ZN][d];
		makeXYZ(dec, x, y, z, (backMask | sideMask.YN) & set);

		sideNormal norm1 = [sideNormal.ZN, sideNormal.ZP, sideNormal.XN, sideNormal.XP][d];
		makeStairXZ(dec, x, y, z, norm1, d == 1 || d == 2);

		sideNormal norm2 = [sideNormal.ZP, sideNormal.ZN, sideNormal.XP, sideNormal.XN][d];
		makeStairXZ(dec, x, y, z, norm2, d == 1 || d == 2);

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		int X1 = x, XM = x + 8, X2 = x + 16;
		int Y1 = y, YM = y + 8, Y2 = y + 16;
		int Z1 = z, ZM = z + 8, Z2 = z + 16;

		// Midfront (top) and back
		sideMask midfront = [sideMask.XN, sideMask.XP, sideMask.ZN, sideMask.ZP][d];

		int x1 = [XM, X1, X1, X1][d];
		int x2 = [X2, XM, X2, X2][d];
		int z1 = [Z1, Z1, ZM, Z1][d];
		int z2 = [Z2, Z2, Z2, ZM][d];
		int ya = [YM, YM, YM, Y1][d];
		int yb = [YM, YM, Y1, YM][d];
		int yc = [YM, Y1, YM, YM][d];
		int yd = [Y1, YM, YM, YM][d];

		if (midfront & sideMask.ZN)
			emitQuadXZN(x1, x2, ya, Y2, z1, z1, tex, sideNormal.ZN, uvManip.HALF_V);
		if (midfront & sideMask.ZP)
			emitQuadXZP(x1, x2, yb, Y2, z2, z2, tex, sideNormal.ZP, uvManip.HALF_V);
		if (midfront & sideMask.XN)
			emitQuadXZN(x1, x1, yc, Y2, z1, z2, tex, sideNormal.XN, uvManip.HALF_V);
		if (midfront & sideMask.XP)
			emitQuadXZP(x2, x2, yd, Y2, z1, z2, tex, sideNormal.XP, uvManip.HALF_V);

		// Top
		uvManip manip = [uvManip.HALF_U, uvManip.HALF_U, uvManip.HALF_V, uvManip.HALF_V][d];

		if (set & sideMask.YP)
			emitQuadYP(x1, x2, Y2, z1, z2, tex, sideNormal.YP, manip);

		int x3 = [X1, XM, X1, X1][d];
		int x4 = [XM, X2, X2, X2][d];
		int z3 = [Z1, Z1, Z1, ZM][d];
		int z4 = [Z2, Z2, ZM, Z2][d];
		emitQuadYP(x3, x4, YM, z3, z4, tex, sideNormal.YP, manip);
	}

	void door(ubyte type, int x, int y, int z) {
		auto dec = &tile[type];
		int set = data.getSolidSet(x, y, z);
		auto d = data.getDataUnsafe(x, y, z);
		ubyte tex;
		if (d & 8)
			// top half
			tex = calcTextureXZ(dec);
		else
			// bottom half
			tex = calcTextureY(dec);

		bool flip = false;
		if (d & 4)
		{
			d += 1;
			flip = true;
		}

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		d &= 3;

		int x1 = [x,    x,    x+13, x   ][d];
		int x2 = [x+3,  x+16, x+16, x+16][d];
		int y1 = y;
		int y2 = y+16;
		int z1 = [z,    z,    z,    z+13][d];
		int z2 = [z+16, z+3,  z+16, z+16][d];

		if (flip) {
			if (set & sideMask.ZN || d == 3)
				emitQuadMappedUVXZN(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZN,
						    0, 0, (d == 1) ? uvManip.FLIP_U : uvManip.NONE);
			if (set & sideMask.ZP || d == 1)
				emitQuadMappedUVXZP(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZP,
						    0, 0, (d == 3) ? uvManip.FLIP_U : uvManip.NONE);
			if (set & sideMask.XN || d == 2)
				emitQuadMappedUVXZN(x1, x1, y1, y2, z1, z2, tex, sideNormal.XN,
						    0, 0, (d == 0) ? uvManip.FLIP_U : uvManip.NONE);
			if (set & sideMask.XP || d == 0)
				emitQuadMappedUVXZP(x2, x2, y1, y2, z1, z2, tex, sideNormal.XP,
						    0, 0, (d == 2) ? uvManip.FLIP_U : uvManip.NONE);
		} else {
			if (set & sideMask.ZN)
				emitQuadMappedUVXZN(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZN,
						    0, 0, (d == 3) ? uvManip.FLIP_U : uvManip.NONE);
			if (set & sideMask.ZP)
				emitQuadMappedUVXZP(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZP,
						    0, 0, (d != 3) ? uvManip.FLIP_U : uvManip.NONE);
			if (set & sideMask.XN)
				emitQuadMappedUVXZN(x1, x1, y1, y2, z1, z2, tex, sideNormal.XN,
						    0, 0, (d == 2) ? uvManip.FLIP_U : uvManip.NONE);
			if (set & sideMask.XP)
				emitQuadMappedUVXZP(x2, x2, y1, y2, z1, z2, tex, sideNormal.XP,
						    0, 0, (d != 2) ? uvManip.FLIP_U : uvManip.NONE);
		}

		tex = calcTextureY(dec);
		if (set & sideMask.YN)
			emitQuadMappedUVYN(x1, x2, y1, z1, z2, tex, sideNormal.YN);
		if (set & sideMask.YP)
			emitQuadMappedUVYP(x1, x2, y2, z1, z2, tex, sideNormal.YP);
	}

	void ladder(ubyte type, int x, int y, int z) {
		auto dec = &tile[type];
		auto d = data.getDataUnsafe(x, y, z);
		ubyte tex = calcTextureXZ(dec);

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		d -= 2;

		int x1 = [x,    x,    x+15, x+1 ][d];
		int x2 = [x+16, x+16, x+15, x+1 ][d];
		int y1 = y;
		int y2 = y+16;
		int z1 = [z+15, z+1,  z,    z   ][d];
		int z2 = [z+15, z+1,  z+16, z+16][d];
		sideNormal normal = [sideNormal.ZN, sideNormal.ZP,
				     sideNormal.XN, sideNormal.XP][d];
		bool positive = isNormalPositive(normal);

		if (positive)
			emitQuadXZP(x1, x2, y1, y2, z1, z2, tex, normal);
		else
			emitQuadXZN(x1, x2, y1, y2, z1, z2, tex, normal);
	}

	void rails(ubyte type, int x, int y, int z) {
		auto d = data.getDataUnsafe(x, y, z);
		int set = data.getSolidSet(x, y, z);
		ubyte tex = 0;
		uvManip manip = uvManip.NONE;

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		if (type == 28) {
			// detector rail
			tex = calcTextureY(&railTile[4]);
		} else if (type == 27) {
			// powered rail (on / off)
			tex = calcTextureY(&railTile[(d & 8) ? 3 : 2]);
			d = d & 7;
		} else {
			// regular rail (corner / line)
			tex = calcTextureY(&railTile[(d > 5) ? 0 : 1]);
		}

		if (d < 2 || d > 5) {
			// straight lines or corner pieces
			if (d < 2) {
				manip = (d == 0) ? uvManip.NONE : uvManip.ROT_90;
			} else {
				d -= 6;
				manip = cast(uvManip)([uvManip.NONE, uvManip.ROT_90,
						       uvManip.ROT_180, uvManip.ROT_270][d]);
			}

			emitQuadYP(x, x+16, y+1, z, z+16, tex, sideNormal.YP, manip);
			if (set & sideMask.YN)
				emitQuadYN(x, x+16, y+1, z, z+16, tex, sideNormal.YN, manip);
		} else {
			// ascending tracks
			d -= 2;
			auto direction = [sideNormal.XP, sideNormal.XN,
					  sideNormal.ZN, sideNormal.ZP][d];

			emitAscendingRailQuadYP(x, x+16, y+1, y+17, z, z+16, tex, direction);
			emitAscendingRailQuadYN(x, x+16, y+1, y+17, z, z+16, tex, direction);
		}
	}

	void leaves(int x, int y, int z) {
		auto d = data.getDataUnsafe(x, y, z);
		auto dec = &leavesTile[d & 3];
		solidDec(dec, x, y, z);
	}

	void farmland(int x, int y, int z) {
		auto d = data.getDataUnsafe(x, y, z);
		if (d > 0)
			d = 1;
		auto dec = &farmlandTile[d];
		solidDec(dec, x, y, z);
	}

	void furnace(ubyte type, int x, int y, int z) {
		auto dec = &tile[type];
		auto decFront = &furnaceFrontTile[type - 61];
		int set = data.getSolidSet(x, y, z);
		auto d = data.getDataUnsafe(x, y, z);

		auto faceNormal = [sideNormal.ZN, sideNormal.ZP,
				   sideNormal.XN, sideNormal.XP][d-2];

		makeFacedBlock(dec, decFront, x, y, z, faceNormal, set);
	}

	void signpost(int x, int y, int z) {
		auto dec = &tile[63];
		int set = data.getSolidSet(x, y, z);
		auto d = data.getDataUnsafe(x, y, z);
		ubyte tex = calcTextureXZ(dec);

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		int x1 = x+7, x2 = x+9;
		int z1 = z+7, z2 = z+9;
		int y1 = y, y2 = y+8;

		// Pole
		emitQuadXZN(x1, x1, y1, y2, z1, z2, tex, sideNormal.XN);
		emitQuadXZP(x2, x2, y1, y2, z1, z2, tex, sideNormal.XP);
		emitQuadXZN(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZN);
		emitQuadXZP(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZP);

		bool north = [ true,  true, false, false,
			      false, false,  true,  true,
			       true,  true, false, false,
			      false, false,  true,  true][d];
		// Sign
		if (north) {
			// North/South orientation
			z1 = z+7;
			z2 = z+9;
			x1 = x;
			x2 = x+16;
			y1 = y+8;
			y2 = y+16;
		} else {
			// West/East orientation
			x1 = x+7;
			x2 = x+9;
			z1 = z;
			z2 = z+16;
			y1 = y+8;
			y2 = y+16;
		}

		emitQuadXZN(x1, x1, y1, y2, z1, z2, tex, sideNormal.XN);
		emitQuadXZP(x2, x2, y1, y2, z1, z2, tex, sideNormal.XP);
		emitQuadYN(x1, x2, y1, z1, z2, tex, sideNormal.YN);
		emitQuadYP(x1, x2, y2, z1, z2, tex, sideNormal.YP);
		emitQuadXZN(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZN);
		emitQuadXZP(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZP);
	}

	void wallsign(int x, int y, int z) {
		auto dec = &tile[68];
		int set = data.getSolidSet(x, y, z);
		auto d = data.getDataUnsafe(x, y, z);
		ubyte tex = calcTextureXZ(dec);

		d -= 2;

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		int x1 = [x,    x,    x+14, x   ][d];
		int x2 = [x+16, x+16, x+16, x+2 ][d];
		int y1 = y+4;
		int y2 = y+12;
		int z1 = [z+14, z,    z,    z   ][d];
		int z2 = [z+16, z+2,  z+16, z+16][d];

		// Signs don't occupy a whole block, so the front face has to be shown, even
		// when a block is in front of it.
		if (set & sideMask.ZN || d == 0)
			emitQuadXZN(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZN);
		if (set & sideMask.ZP || d == 1)
			emitQuadXZP(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZP);
		if (set & sideMask.XN || d == 2)
			emitQuadXZN(x1, x1, y1, y2, z1, z2, tex, sideNormal.XN);
		if (set & sideMask.XP || d == 3)
			emitQuadXZP(x2, x2, y1, y2, z1, z2, tex, sideNormal.XP);

		emitQuadYN(x1, x2, y1, z1, z2, tex, sideNormal.YN);
		emitQuadYP(x1, x2, y2, z1, z2, tex, sideNormal.YP);
	}

	void stone_button(int x, int y, int z) {
		auto dec = &tile[77];
		int set = data.getSolidSet(x, y, z);
		auto d = data.getDataUnsafe(x, y, z);
		ubyte tex = calcTextureXZ(dec);

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		// Button pressed state.
		int depth = (d & 8) ? 1 : 2;

		d -= 1;
		d &= 3;

		int x1 = [x,       x+16-depth, x+5,     x+5       ][d];
		int x2 = [x+depth, x+16,       x+11,    x+11      ][d];
		int z1 = [z+5,     z+5,        z,       z+16-depth][d];
		int z2 = [z+11,    z+11,       z+depth, z+16      ][d];
		int y1 = y+6;
		int y2 = y+10;

		// Don't render the face where the button is attached to the block.
		if (set & sideMask.ZN || d != 2)
			emitQuadMappedUVXZN(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZN);
		if (set & sideMask.ZP || d != 3)
			emitQuadMappedUVXZP(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZP);
		if (set & sideMask.XN || d != 0)
			emitQuadMappedUVXZN(x1, x1, y1, y2, z1, z2, tex, sideNormal.XN);
		if (set & sideMask.XP || d != 1)
			emitQuadMappedUVXZP(x2, x2, y1, y2, z1, z2, tex, sideNormal.XP);

		emitQuadMappedUVYN(x1, x2, y1, z1, z2, tex, sideNormal.YN);
		emitQuadMappedUVYP(x1, x2, y2, z1, z2, tex, sideNormal.YP);
	}

	void pressure_plate(ubyte type, int x, int y, int z) {
		auto dec = &tile[type];
		ubyte tex = calcTextureXZ(dec);

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		int x1 = x+1, x2 = x+15;
		int z1 = z+1, z2 = z+15;
		int y1 = y, y2 = y+1;

		emitQuadMappedUVXZN(x1, x1, y1, y2, z1, z2, tex, sideNormal.XN);
		emitQuadMappedUVXZP(x2, x2, y1, y2, z1, z2, tex, sideNormal.XP);
		emitQuadMappedUVXZN(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZN);
		emitQuadMappedUVXZP(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZP);
		emitQuadMappedUVYP(x1, x2, y2, z1, z2, tex, sideNormal.YP);
	}

	void snow(int x, int y, int z) {
		const type = 78;
		auto dec = &tile[type];
		int set = data.getSolidOrTypeSet(type, x, y, z);

		/* all set */
		if (set == 0)
			return;

		set |= sideMask.YP;
		makeHalfXYZ(dec, x, y, z, set, 2);
	}

	void fence(int x, int y, int z) {
		const type = 85;
		auto dec = &tile[type];
		int set = data.getSolidSet(x, y, z);
		ubyte tex = calcTextureXZ(dec);

		// Look for nearby fences.
		auto north = data.get(x, y, z-1) == type;
		auto east = data.get(x-1, y, z) == type;

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		int x1 = x+6, x2 = x+10;
		int z1 = z+6, z2 = z+10;
		int y1 = y, y2 = y+16;

		// Pole.
		emitQuadMappedUVXZN(x1, x1, y1, y2, z1, z2, tex, sideNormal.XN);
		emitQuadMappedUVXZP(x2, x2, y1, y2, z1, z2, tex, sideNormal.XP);
		emitQuadMappedUVXZN(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZN);
		emitQuadMappedUVXZP(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZP);

		if (set & sideMask.YN)
			emitQuadMappedUVYN(x1, x2, y1, z1, z2, tex, sideNormal.YN);
		if (set & sideMask.YP)
			emitQuadMappedUVYP(x1, x2, y2, z1, z2, tex, sideNormal.YP);

		// Bars in north or east direction.
		if (north) {
			z1 = z-6;
			z2 = z+6;

			emitQuadMappedUVYP(x1+1, x2-1, y+15, z1, z2, tex, sideNormal.YP, 0, -8, uvManip.NONE);
			emitQuadMappedUVYN(x1+1, x2-1, y+12, z1, z2, tex, sideNormal.YN, 0, -8, uvManip.NONE);
			emitQuadMappedUVXZP(x2-1, x2-1, y+12, y+15, z1, z2, tex,sideNormal.XP, -8, 0, uvManip.NONE);
			emitQuadMappedUVXZN(x1+1, x1+1, y+12, y+15, z1, z2, tex,sideNormal.XN, 8, 0, uvManip.NONE);

			emitQuadMappedUVYP(x1+1, x2-1, y+9, z1, z2, tex, sideNormal.YP, 0, -8, uvManip.NONE);
			emitQuadMappedUVYN(x1+1, x2-1, y+6, z1, z2, tex, sideNormal.YN, 0, -8, uvManip.NONE);
			emitQuadMappedUVXZP(x2-1, x2-1, y+6, y+9, z1, z2, tex,sideNormal.XP, -8, 0, uvManip.NONE);
			emitQuadMappedUVXZN(x1+1, x1+1, y+6, y+9, z1, z2, tex,sideNormal.XN, 8, 0, uvManip.NONE);
		}

		if (east) {
			z1 = z+6,
			z2 = z+10;
			x1 = x-6;
			x2 = x+6;

			emitQuadMappedUVYP(x1, x2, y+15, z1+1, z2-1, tex, sideNormal.YP, -8, 0, uvManip.NONE);
			emitQuadMappedUVYN(x1, x2, y+12, z1+1, z2-1, tex, sideNormal.YN, -8, 0, uvManip.NONE);
			emitQuadMappedUVXZP(x1, x2, y+12, y+15, z2-1, z2-1, tex, sideNormal.ZP, -8, 0, uvManip.NONE);
			emitQuadMappedUVXZN(x1, x2, y+12, y+15, z1+1, z1+1, tex, sideNormal.ZN, 8, 0, uvManip.NONE);

			emitQuadMappedUVYP(x1, x2, y+9, z1+1, z2-1, tex, sideNormal.YP, -8, 0, uvManip.NONE);
			emitQuadMappedUVYN(x1, x2, y+6, z1+1, z2-1, tex, sideNormal.YN, -8, 0, uvManip.NONE);
			emitQuadMappedUVXZP(x1, x2, y+6, y+9, z2-1, z2-1, tex, sideNormal.ZP, -8, 0, uvManip.NONE);
			emitQuadMappedUVXZN(x1, x2, y+6, y+9, z1+1, z1+1, tex, sideNormal.ZN, 8,0, uvManip.NONE);
		}
	}

	void pumpkin(int x, int y, int z) {
		auto dec = &tile[86];
		auto decFront = &pumpkinFrontTile;
		int set = data.getSolidSet(x, y, z);
		auto d = data.getDataUnsafe(x, y, z);

		auto faceNormal = [sideNormal.ZN, sideNormal.XP,
				   sideNormal.ZP, sideNormal.XN][d];

		makeFacedBlock(dec, decFront, x, y, z, faceNormal, set);
	}

	void jack_o_lantern(int x, int y, int z) {
		auto dec = &tile[91];
		auto decFront = &jackolanternFrontTile;
		int set = data.getSolidSet(x, y, z);
		auto d = data.getDataUnsafe(x, y, z);

		auto faceNormal = [sideNormal.ZN, sideNormal.XP,
				   sideNormal.ZP, sideNormal.XN][d];

		makeFacedBlock(dec, decFront, x, y, z, faceNormal, set);
	}

	void cake(int x, int y, int z) {
		auto dec = &tile[92];
		int set = data.getSolidSet(x, y, z);
		auto d = data.getDataUnsafe(x, y, z);

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		ubyte top_tex = calcTextureY(dec);
		ubyte side_tex = calcTextureXZ(dec);
		ubyte tex = 0;

		// How much is missing from the cake.
		int width = 2*d + 1;

		emitQuadMappedUVYP(x+width, x+16, y+8, z, z+16, top_tex, sideNormal.YP);

		emitQuadMappedUVXZN(x+width, x+16, y, y+8, z+1,  z+1,  side_tex, sideNormal.ZN, 0, -8, uvManip.NONE);
		emitQuadMappedUVXZP(x+width, x+16, y, y+8, z+15, z+15, side_tex, sideNormal.ZP, 0, -8, uvManip.NONE);
		emitQuadMappedUVXZP(x+15,    x+15, y, y+8, z,    z+16, side_tex, sideNormal.XP, 0, -8, uvManip.NONE);

		// Render side where the cake was/will be cut.
		if (d > 0)
			tex = calcTextureXZ(&cakeTile[0]);
		else
			tex = side_tex;
		emitQuadMappedUVXZN(x+width, x+width, y, y+8, z, z+16, tex, sideNormal.XN, 0,-8, uvManip.NONE);

		if (set & sideMask.YN) {
			tex = calcTextureY(&cakeTile[1]);
			emitQuadMappedUVYN(x+width, x+16, y, z, z+16, tex, sideNormal.YN);
		}
	}

	void cactus(int x, int y, int z) {
		const type = 81;
		auto dec = &tile[type];
		ubyte tex = calcTextureXZ(dec);

		int x2 = x+1;
		int y2 = y+1;
		int z2 = z+1;

		if (!data.filledOrType(type, x, y+1, z))
			makeY(dec, x, y, z, sideNormal.YP);
		if (!data.filledOrType(type, x, y-1, z)) {
			dec = &cactusBottomTile;
			makeY(dec, x, y, z, sideNormal.YN);
		}

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		x2 <<= shift;
		y <<= shift;
		y2 <<= shift;
		z <<= shift;
		z2 <<= shift;

		emitQuadXZN(x, x2, y, y2, z+1, z+1, tex, sideNormal.ZN);
		emitQuadXZP(x, x2, y, y2, z+15, z+15, tex, sideNormal.ZP);
		emitQuadXZN(x+1, x+1, y, y2, z, z2, tex, sideNormal.XN);
		emitQuadXZP(x+15, x+15, y, y2, z, z2, tex, sideNormal.XP);
	}

	void redstone_repeater(ubyte type, int x, int y, int z) {
		auto dec = &tile[type];
		ubyte tex = calcTextureY(dec);
		auto d = data.getDataUnsafe(x, y, z);
		auto active = (type == 93);

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		int y1 = y,   x1 = x,    z1 = z;
		int y2 = y+2, x2 = x+16, z2 = z+16;

		// Sides
		emitQuadMappedUVXZN(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZN);
		emitQuadMappedUVXZP(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZP);
		emitQuadMappedUVXZN(x1, x1, y1, y2, z1, z2, tex, sideNormal.XN);
		emitQuadMappedUVXZP(x2, x2, y1, y2, z1, z2, tex, sideNormal.XP);

		// Top
		uvManip manip = [uvManip.NONE, uvManip.ROT_90, uvManip.ROT_180, uvManip.ROT_270][d & 3];
		emitQuadYP(x, x+16, y+2, z, z+16, tex, sideNormal.YP, manip);

		// Torches
		dec = &tile[(active) ? 75 : 76];
		tex = calcTextureXZ(dec);

		x1 = [x+8, x+13, x+8,  x+3][d & 3];
		z1 = [z+3, z+8,  z+13, z+8][d & 3];
		standing_torch(x1, y-3, z1, tex);

		// Moving torch, delay is position offset in pixels.
		auto delay = (d >> 2) * 2;

		// Offset by +1/-1 to move torch in default position.
		x2 = [x+8,       x+9-delay, x+8,       x+7+delay][d & 3];
		z2 = [z+7+delay, z+8,       z+9-delay, z+8      ][d & 3];
		standing_torch(x2, y-3, z2, tex);
	}

	void trapdoor(int x, int y, int z) {
		auto dec = &tile[96];
		ubyte tex = calcTextureY(dec);
		int set = data.getSolidSet(x, y, z);
		auto d = data.getDataUnsafe(x, y, z);

		const shift = VERTEX_SIZE_BIT_SHIFT;
		x <<= shift;
		y <<= shift;
		z <<= shift;

		auto closed = !(d & 4);
		d &= 3;

		int y1 = 0, y2 = 0, x1 = 0, x2 = 0, z1 = 0, z2 = 0;

		if (closed) {
			y1 = y;   x1 = x;    z1 = z;
			y2 = y+3; x2 = x+16; z2 = z+16;
		} else {
			x1 = [x,    x,    x+13, x   ][d];
			x2 = [x+16, x+16, x+16, x+3 ][d];
			z1 = [z+13, z,    z,    z   ][d];
			z2 = [z+16, z+3,  z+16, z+16][d];
			y1 = y;
			y2 = y+16;
		}

		if (set & sideMask.ZN)
			emitQuadMappedUVXZN(x1, x2, y1, y2, z1, z1, tex, sideNormal.ZN);
		if (set & sideMask.ZP)
			emitQuadMappedUVXZP(x1, x2, y1, y2, z2, z2, tex, sideNormal.ZP);
		if (set & sideMask.XN)
			emitQuadMappedUVXZN(x1, x1, y1, y2, z1, z2, tex, sideNormal.XN);
		if (set & sideMask.XP)
			emitQuadMappedUVXZP(x2, x2, y1, y2, z1, z2, tex, sideNormal.XP);

		if (set & sideMask.YN)
			emitQuadMappedUVYN(x1, x2, y1, z1, z2, tex, sideNormal.YN);
		if (set & sideMask.YP || closed)
			emitQuadMappedUVYP(x1, x2, y2, z1, z2, tex, sideNormal.YP);
	}

	void b(uint x, uint y, uint z) {
		static int count = 0;
		ubyte type = data.get(x, y, z);

		switch(type) {
			case 2:
				grass(x, y, z);
				break;
			case 8:
			case 9:
				water(x, y, z);
				break;
			case 17:
				wood(x, y, z);
				break;
			case 18:
				leaves(x, y, z);
				break;
			case 20:
				glass(x, y, z);
				break;
			case 23:
				dispenser(x, y, z);
				break;
			case 26:
				bed(x, y, z);
				break;
			case 35:
				wool(x, y, z);
				break;
			case 6:
				sapling(x, y, z);
				break;
			case 31:
				auto d = data.getDataUnsafe(x, y, z);
				plants(&tallGrassTile[d], x, y, z);
				break;
			case 32:
			case 37:
			case 38:
			case 39:
			case 40:
			case 83:
				plants(&tile[type], x, y, z);
				break;
			case 43:
			case 44:
				slab(type, x, y, z);
				break;
			case 50:
			case 75:
			case 76:
				torch(type, x, y, z);
				break;
			case 52:
				solid(52, x, y, z);
				break;
			case 54:
				chest(x, y, z);
				break;
			case 55:
				redstone_wire(x, y, z);
				break;
			case 58:
				craftingTable(x, y, z);
				break;
			case 59:
				crops(x, y, z);
				break;
			case 60:
				farmland(x, y, z);
				break;
			case 61:
			case 62:
				furnace(type, x, y, z);
				break;
			case 63:
				signpost(x, y, z);
				break;
			case 64:
			case 71:
				door(type, x, y, z);
				break;
			case 65:
				ladder(type, x, y, z);
				break;
			case 27:
			case 28:
			case 66:
				rails(type, x, y, z);
				break;
			case 53:
			case 67:
				stair(type, x, y, z);
				break;
			case 68:
				wallsign(x, y, z);
				break;
			case 70:
			case 72:
				pressure_plate(type, x, y, z);
				break;
			case 77:
				stone_button(x, y, z);
				break;
			case 78:
				snow(x, y, z);
				break;
			case 81:
				cactus(x, y, z);
				break;
			case 85:
				fence(x, y, z);
				break;
			case 86:
				pumpkin(x, y, z);
				break;
			case 91:
				jack_o_lantern(x, y, z);
				break;
			case 92:
				cake(x, y, z);
				break;
			case 93:
			case 94:
				redstone_repeater(type, x, y, z);
				break;
			case 96:
				trapdoor(x, y, z);
				break;
			default:
				if (tile[type].filled)
					solid(type, x, y, z);
		}
	}
}

/**
 * Builds a mesh packed with p from data in data.
 */
void doBuildMesh(WorkspaceData *data, Packer *p)
{
	mixin BlockDispatcher!();

	for (int x; x < 16; x++) {
		for (int y; y < 128; y++) {
			for (int z; z < 16; z++) {
				b(x, y, z);
			}
		}
	}
}

/**
 * Build a RigidMesh from a WorkspaceData.
 */
ChunkVBORigidMesh buildRigidMeshFromChunk(WorkspaceData *data,
					  int xPos, int yPos, int zPos,
					  int xOffArg, int yOffArg, int zOffArg)
{
/*
	XXX Disabled for now.
	auto mb = new RigidMeshBuilder(128*1024, 0, RigidMesh.Types.QUADS);
	auto prm = PackerRigidMesh.cAlloc(128*1024);
	scope(exit) {
		prm.cFree();
		delete mb;
	}

	prm.ctor(mb, xOffArg, yOffArg, zOffArg);

	doBuildMesh(data, &prm.base);

	// C memory freed above with scope(exit)
	return ChunkVBORigidMesh(mb, xPos, yPos, zPos);
*/
	return null;
}

/**
 * Build a CompactMesh from a WorkspaceData.
 */
ChunkVBOCompactMesh buildCompactMeshFromChunk(WorkspaceData *data,
					      int xPos, int yPos, int zPos,
					      int xOffArg, int yOffArg, int zOffArg)
{
	auto pc = PackerCompact.cAlloc(128 * 1024);
	scope(exit)
		pc.cFree();

	pc.ctor(xOffArg, yOffArg, zOffArg, false);

	doBuildMesh(data, &pc.base);

	// C memory freed above with scope(exit)
	auto verts = pc.getVerts();
	return ChunkVBOCompactMesh(verts, xPos, yPos, zPos);
}

/**
 * Build a indexed CompactMesh from a WorkspaceData.
 */
ChunkVBOCompactMesh buildCompactMeshIndexedFromChunk(WorkspaceData *data,
						     int xPos, int yPos, int zPos,
						     int xOffArg, int yOffArg, int zOffArg)
{
	auto pc = PackerCompact.cAlloc(128 * 1024);
	scope(exit)
		pc.cFree();

	pc.ctor(xOffArg, yOffArg, zOffArg, true);

	doBuildMesh(data, &pc.base);

	// C memory freed above with scope(exit)
	auto verts = pc.getVerts();
	return ChunkVBOCompactMesh(verts, xPos, yPos, zPos);
}


/*
 *
 * Offset helper functions
 *
 */


ChunkVBORigidMesh buildRigidMeshFromChunk(WorkspaceData *data,
					  int xPos, int yPos, int zPos)
{
	int xOff = xPos * (WorkspaceData.ws_width - 2);
	int yOff = yPos * (WorkspaceData.ws_height - 2);
	int zOff = zPos * (WorkspaceData.ws_depth - 2);

	return buildRigidMeshFromChunk(data, xPos, yPos, zPos, xOff, yOff, zOff);
}

ChunkVBOCompactMesh buildCompactMeshFromChunk(WorkspaceData *data,
					      int xPos, int yPos, int zPos)
{
	int xOff = xPos * (WorkspaceData.ws_width - 2);
	int yOff = yPos * (WorkspaceData.ws_height - 2);
	int zOff = zPos * (WorkspaceData.ws_depth - 2);

	return buildCompactMeshFromChunk(data, xPos, yPos, zPos, xOff, yOff, zOff);
}

ChunkVBOCompactMesh buildCompactMeshIndexedFromChunk(WorkspaceData *data,
						     int xPos, int yPos, int zPos)
{
	int xOff = xPos * (WorkspaceData.ws_width - 2);
	int yOff = yPos * (WorkspaceData.ws_height - 2);
	int zOff = zPos * (WorkspaceData.ws_depth - 2);

	return buildCompactMeshIndexedFromChunk(data, xPos, yPos, zPos, xOff, yOff, zOff);
}
