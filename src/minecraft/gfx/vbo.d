// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module minecraft.gfx.vbo;

import charge.math.box;
import minecraft.gfx.imports;


/**
 * ChunkVBO which is just the inbuilt RigidMeshVBO.
 */

class ChunkVBORigidMesh : public charge.gfx.vbo.RigidMeshVBO
{
public:
	static ChunkVBORigidMesh opCall(RigidMeshBuilder mb, int x, int z)
	{
		return new ChunkVBORigidMesh(charge.sys.resource.Pool(), mb, x, z);
	}

protected:
	this(charge.sys.resource.Pool p, RigidMeshBuilder mb, int x, int z)
	{
		auto name = std.string.format("mc/vbo/chunk.%s.%s.rigid", x, z);
		super(p, name, mb);
	}

}


/**
 * A slightly more compact version of ChunkVBORigidMesh.
 */
class ChunkVBOCompactMesh : public GfxVBO
{
public:
	static struct Vertex
	{
		float[3] position;
		struct {
			ubyte texture_u_or_index;
			ubyte texture_v_or_pad;
			ubyte normal;
			ubyte light;
		}
		struct {
			ubyte texture_u_offset;
			ubyte texture_v_offset;
			ubyte torch_light;
			ubyte sun_light;
		}
	}

	static ChunkVBOCompactMesh opCall(Vertex[] verts, int x, int z)
	{
		return new ChunkVBOCompactMesh(charge.sys.resource.Pool(), verts, x, z);
	}

protected:
	this(charge.sys.resource.Pool p, Vertex[] verts, int x, int z)
	{
		auto str = std.string.format("mc/vbo/chunk.%s.%s.compact-mesh", x, z);
		super(p, str, false, verts.ptr,
		      verts.length * Vertex.sizeof,
		      cast(uint)verts.length,
		      null, 0, 0);
	}

}

/**
 * A super compact VBO that packs all the data into 4 bytes.
 */
class ChunkVBOArray : public GfxVBO
{
protected:

public:
	static ChunkVBOArray opCall(int[] array, int x, int z)
	{
		return new ChunkVBOArray(charge.sys.resource.Pool(), array, x, z);
	}

protected:
	this(charge.sys.resource.Pool p, int[] array, int x, int z)
	{
		auto str = std.string.format("mc/vbo/chunk.%s.%s.compact", x, z);
		super(p, str, false, array.ptr,
		      array.length * int.sizeof,
		      cast(uint)array.length,// / 2,
		      null, 0, 0);
	}

}


/**
 * Base class for all Chunk VBO Groups, handles general managment.
 */
class ChunkVBOGroup : public GfxActor, public GfxRenderable
{
public:
	mixin SysLogging;

	Entry[] array;
	GfxMaterial m;
	ABox[] resultAABB;
	GfxVBO[] resultVBO;
	int result_num;

	static struct Entry {
		ABox aabb;
		GfxVBO vbo;
	};

	this(GfxWorld w) {
		super(w);
		pos = Point3d();
		rot = Quatd();
		m = GfxMaterialManager.getDefault();
	}

	~this()
	{
		delete m;
		m = null;
		delete array;
		delete resultVBO;
		delete resultAABB;
	}

	GfxMaterial getMaterial()
	{
		return m;
	}

	void setMaterial(GfxMaterial m)
	{
		this.m = m;
	}

	void add(GfxVBO vbo, int x, int z)
	{
		Entry e;
		e.aabb.min = Point3d(x * 16, -64, z * 16);
		e.aabb.max = Point3d((x+1) * 16, 64, (z+1) * 16);
		e.vbo = vbo;
		array ~= e;
	}

	void remove(GfxVBO vbo)
	{
		int i;
		foreach(e; array) {
			if (e.vbo is vbo)
				break;
			i++;
		}
		vbo.dereference();
		assert(i < array.length);
		array = array[0 .. i] ~ array[i+1 .. array.length];
	}

	void cullAndPush(GfxCull cull, GfxRenderQueue rq)
	{
		resultVBO.length = array.length;
		resultAABB.length = array.length;
		int i;
		foreach(vbo; array) {
			if (cull.f.check(vbo.aabb)) {
				resultVBO[i] = vbo.vbo;
				resultAABB[i++] = vbo.aabb;
			}
		}

		if (i == 0)
			return;

		result_num = i;
		rq.push(0.0, this);
	}

	abstract void drawFixed();

	abstract void drawAttrib();

	abstract void drawShader(GfxShader shader);
}

/**
 * Chunk group for RigidMesh VBO's.
 */
class ChunkVBOGroupRigidMesh : public ChunkVBOGroup
{
public:
	this(GfxWorld w)
	{
		super(w);
	}

	void drawFixed()
	{
		gluPushAndTransform(pos, rot);

		ChunkVBORigidMesh.drawArrayFixed(
			cast(ChunkVBORigidMesh[])resultVBO[0 .. result_num]);

		glPopMatrix();
	}

	void drawAttrib()
	{
		gluPushAndTransform(pos, rot);

		ChunkVBORigidMesh.drawArrayAttrib(
			cast(ChunkVBORigidMesh[])resultVBO[0 .. result_num]);

		glPopMatrix();
	}

	void drawShader(GfxShader shader)
	{

	}

}

/**
 * Chunk group for CompactMesh VBO's.
 */
class ChunkVBOGroupCompactMesh : public ChunkVBOGroup
{
public:
	this(GfxWorld w)
	{
		super(w);
	}

	void drawFixed()
	{

	}

	void drawAttrib()
	{
		const vertexSize = ChunkVBOCompactMesh.Vertex.sizeof;
		const void* vertOffset = null;
		const void* data1Offset = cast(void*)(3 * float.sizeof);
		const void* data2Offset = cast(void*)(4 * float.sizeof);

		gluPushAndTransform(pos, rot);

		auto vbos = cast(ChunkVBOCompactMesh[])resultVBO[0 .. result_num];

		glEnableVertexAttribArray(0); // pos
		glEnableVertexAttribArray(1); // data1
		glEnableVertexAttribArray(2); // data2

		foreach (vbo; vbos) {
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, vbo.vboVerts);

			/* Shame that we need to set up this binding on each draw */
			glVertexAttribPointer(0, 3, GL_FLOAT, false, vertexSize, vertOffset);  // pos
			glVertexAttribPointer(1, 4, GL_UNSIGNED_BYTE, false, vertexSize, data1Offset); // data1
			glVertexAttribPointer(2, 4, GL_BYTE, false, vertexSize, data2Offset); // data2
			glDrawArrays(GL_QUADS, 0, vbo.numVerts);
		}

		glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);

		glDisableVertexAttribArray(0); // pos
		glDisableVertexAttribArray(1); // data1
		glDisableVertexAttribArray(2); // data2

		glPopMatrix();
	}

	void drawShader(GfxShader shader)
	{

	}

}

/**
 * Chunk group for the super compact array VBO's.
 */
class ChunkVBOGroupArray : public ChunkVBOGroup
{
public:
	this(GfxWorld w)
	{
		super(w);
	}

	void drawFixed()
	{

	}

	void drawAttrib()
	{

	}

	void drawShader(GfxShader shader)
	{
		gluPushAndTransform(pos, rot);

		glEnableVertexAttribArray(0); // data

		for (int i; i < result_num; i++) {
			auto vbo = resultVBO[i];
			float offset[2];
			offset[0] = cast(float)resultAABB[i].min.x;
			offset[1] = cast(float)resultAABB[i].min.z;

			shader.float2("offset", offset);
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, vbo.vboVerts);
			glVertexAttribPointer(0, 2, GL_SHORT, false, int.sizeof, null);  // data
			glDrawArrays(GL_QUADS, 0, vbo.numVerts);
		}

		glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);

		glDisableVertexAttribArray(0); // data

		glPopMatrix();
	}

}
