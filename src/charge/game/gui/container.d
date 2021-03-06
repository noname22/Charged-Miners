// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module charge.game.gui.container;

import charge.util.vector;
import charge.gfx.draw;
import charge.gfx.texture;
import charge.game.gui.component;

alias int Event;

bool collidesWith(Component c, int x, int y, uint w, uint h)
{
	int xw = x + w;
	int yw = y + h;

	int x2 = c.x;
	int y2 = c.y;
	int xw2 = x2 + c.w;
	int yw2 = y2 + c.h;

	if (x < xw2 && x2 < xw)
		if (y < yw2 && y2 < yw)
			return true;

	return false;
}

class Container : public Component
{
protected:
	Vector!(Component) children;

public:
	this(Container c, int x, int y, uint w, uint h)
	{
		super(c, x, y, w, h);
	}

	~this()
	{
		foreach(c; children.adup)
			delete c;
	}

	Component[] getChildren()
	{
		return children.adup;
	}

	Component at(int x, int y, inout int absX, inout int absY)
	{
		absX += this.x;
		absY += this.y;

		foreach(c; children.adup.reverse) {
			if (!collidesWith(c, x, y, 1, 1))
				continue;

			return c.at(x - c.x, y - c.y, absX, absY);
		}

		if (x < 0 || y < 0 || x >= w || y >= h)
			return null;

		return this;
	}

	/**
	 * Remove this component from this container.
	 */
	bool remove(Component c)
	{
		if (c is null)
			return false;

		if (c.parent !is this) {
			return false;
		}

		auto n = find(c);

		// If we are its parent then it should be among the children.
		assert(n >= 0);
		if (n < 0)
			return false;

		children.remove(c);

		disownChild(c);
		return true;
	}

	/**
	 * Add a unparented component as a child of this component.
	 */
	bool add(Component c)
	{
		if (c is null || c.parent !is null)
			return false;

		children ~= c;

		becomeParent(c);
		return true;
	}

	/**
	 * Find the location of this component in the list of children.
	 */
	int find(Component c)
	{
		foreach(int i, child; children.adup)
			if (child is c)
				return i;

		return -1;
	}

	void paint(Draw d)
	{
		paintBackground(d);
		paintComponents(d);
		paintForeground(d);
	}

protected:
	void paintBackground(Draw d)
	{

	}

	void paintComponents(Draw d)
	{
		foreach(c; children) {
			d.save();
			d.translate(c.x, c.y);
			c.paint(d);
			d.restore();
		}
	}

	void paintForeground(Draw d)
	{

	}
}

class TextureContainer : public Container
{
public:
	TextureTarget tt;

public:
	this(Container c, int x, int y, uint w, uint h)
	{
		super(c, x, y, w, h);
	}

	~this()
	{
		if (tt !is null)
			tt.dereference();
	}

	/**
	 * Return the current texture target, referenced.
	 */
	TextureTarget getTarget()
	{
		if (tt !is null)
			tt.reference();
		return tt;
	}

	/**
	 * Paint this container to the current texture target.
	 *
	 * Create a new one if size differs or if none is attached.
	 */
	void paint()
	{
		if (tt !is null && (tt.width != w || tt.height != h)) {
			tt.dereference();
			tt = null;
		}

		if (tt is null)
			tt = TextureTarget("charge/game/gui/container", w, h);

		auto d = new Draw();
		d.target = tt;
		d.start();

		super.paint(d);

		d.stop();

		delete d;
	}
}
