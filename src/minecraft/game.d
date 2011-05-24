// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module minecraft.game;

import std.math;
import std.file;
import std.stdio;
import std.c.stdlib;

import lib.sdl.sdl;

import charge.charge;

import minecraft.importer;
import minecraft.runner;
import minecraft.lua.runner;
import minecraft.world;
import minecraft.viewer;
import minecraft.terrain.chunk;
import minecraft.terrain.vol;
import minecraft.gfx.renderer;



class Game : public GameSimpleApp, public Router
{
private:
	/* program args */
	char[] level;
	bool build_all;

	charge.game.app.TimeKeeper luaTime;
	charge.game.app.TimeKeeper buildTime;

	RenderManager rm;
	GfxDefaultTarget defaultTarget;

	ScriptRunner sr;
	Runner runner;

	Runner[] deleteRunner;
	Runner nextRunner;

	bool built; /**< Have we built a chunk */

	int ticks;
	int start;
	int num_frames;


	GfxDraw d;
	GfxDynamicTexture debugText;
	GfxDynamicTexture cameraText;
	GfxTextureTarget infoTexture;

public:
	mixin SysLogging;

	this(char[][] args)
	{
		super(args);

		running = true;

		parseArgs(args);

		if (!running)
			return;

		rm = new RenderManager();
		defaultTarget = GfxDefaultTarget();

		guessLevel();

		if (!checkLevel(level))
			throw new Exception("Invalid level");

		nextRunner = loadLevel(level);

		manageRunners();

		start = SDL_GetTicks();

 		d = new GfxDraw();
		debugText = new GfxDynamicTexture("mc/debugText");
		cameraText = new GfxDynamicTexture("mc/cameraText");

		makeInfoTexture();
	}

	~this()
	{
		if (runner !is null)
			deleteMe(runner);

		manageRunners();

		delete rm;
		delete d;

		if (infoTexture !is null)
			infoTexture.dereference();
		if (debugText !is null)
			debugText.dereference();
		if (cameraText !is null)
			cameraText.dereference();
	}

protected:
	void parseArgs(char[][] args)
	{
		for(int i = 1; i < args.length; i++) {
			switch(args[i]) {
			case "-l":
			case "-level":
			case "--level":
				if (++i < args.length) {
					level = args[i];
					break;
				}
				writefln("Expected argument to level switch");
				throw new Exception("");
			case "-a":
			case "-all":
			case "--all":
				build_all = true;
				break;


			default:
				writefln("Unknown argument %s", args[i]);
			case "-h":
			case "-help":
			case "--help":
				writefln("   -a, --all             - build all chunks near the camera on start");
				writefln("   -l, --level <level>   - to specify level directory");
				writefln("       --license         - print licenses");
				running = false;
				break;
			}
		}
	}

	bool checkLevel(char[] level)
	{
		auto ni = checkMinecraftLevel(level);

		if (ni is null) {
			l.fatal("Could not find level.dat in the level directory");
			l.fatal("This probably isn't a level, exiting the viewer.");
			l.fatal("looked in this folder %s", level);
			return false;
		}

		if (!ni.beta) {
			l.fatal("Could not find the region folder in the level directory");
			l.fatal("This probably isn't a beta level, exiting the viewer.");
			l.fatal("looked in this folder %s", level);
			return false;
		}

		return true;
	}

	void guessLevel()
	{
		version(darwin) {
			if (level !is null)
				return getMinecraftSaveFolder() ~ "/World1";
		}

		if (level !is null)
			return;

		auto dir = getMinecraftSaveFolder();
		auto levels = scanForLevels(dir);

		// Randomly pick the last level - http://xkcd.com/221/
		foreach (l; levels) {
			if (!l.beta)
				continue;

			level = l.dir;
		}

		if (level is null) {
			l.warn("Could not find any Minecraft saves");
			l.warn("Looked here %s", dir);
		}
	}

	/*
	 *
	 * Callback functions
	 *
	 */

	void resize(uint w, uint h)
	{
		super.resize(w, h);

		if (runner !is null)
			runner.resize(w, h);
	}

	void logic()
	{
		// Delete and switch runners.
		manageRunners();

		// If we have no runner stop running.
		if (runner is null) {
			running = false;
			return;
		}

		// This make sure we at least always
		// builds at least one chunk per frame.
		built = false;

		// Special case lua runner.
		if (sr !is null) {
			logicTime.stop();
			luaTime.start();
			sr.logic();
			luaTime.stop();
			logicTime.start();
		} else if (runner !is null) {
			runner.logic();
		}

		ticks++;

		auto elapsed = SDL_GetTicks() - start;
		if (elapsed > 1000) {
			const double MB = 1024 * 1024;
			char[] info = std.string.format(
				"Charge%7.1fFPS\n"
				"\n"
				"Memory:\n"
				"   VBO%7.1fMB\n"
				" Chunk%7.1fMB\n"
				"\n"
				"Time:\n"
				"\tgfx   %5.1f%%\n\tctl   %5.1f%%\n"
				"\tnet   %5.1f%%\n\tgame  %5.1f%%\n"
				"\tlua   %5.1f%%\n\tbuild %5.1f%%\n"
				"\tidle  %5.1f%%",
				cast(double)num_frames / (cast(double)elapsed / 1000.0),
				charge.gfx.vbo.VBO.used / MB,
				Chunk.used_mem / MB,
				renderTime.calc(elapsed), inputTime.calc(elapsed),
				networkTime.calc(elapsed), logicTime.calc(elapsed),
				luaTime.calc(elapsed), buildTime.calc(elapsed),
				idleTime.calc(elapsed));

			GfxFont.render(debugText, info);

			num_frames = 0;
			start = elapsed + start;
		}
	}

	void render()
	{
		if (ticks < 2)
			return;
		ticks = 0;

		num_frames++;

		auto rt = defaultTarget;

		runner.render(rt);

		{
			d.target = rt;
			d.start();

			// TODO: Disabled for now
			if (false)
				d.blit(infoTexture,
				       (rt.width - infoTexture.width) / 2,
				       (rt.height - infoTexture.height) / 2);

			auto w = debugText.width + 16;
			auto h = debugText.height + 16;
			auto x = rt.width - debugText.width - 16 - 8;
			d.fill(Color4f(0, 0, 0, .8), true, x, 8, w, h);
			d.blit(debugText, x+8, 16);

			auto grd = cast(GameRunnerBase)runner;
			if (grd !is null) {
				auto p = grd.cam.position;
				char[] info = std.string.format("Camera (%.1f, %.1f, %.1f)", p.x, p.y, p.z);
				GfxFont.render(cameraText, info);

				w = cameraText.width + 16;
				h = cameraText.height + 16;
				d.fill(Color4f(0, 0, 0, .8), true, 8, 8, w, h);
				d.blit(cameraText, 16, 16);
			}

			d.stop();
		}

		rt.swap();
	}

	void idle(long time)
	{
		// If we have built at least one chunk this frame and have very little
		// time left don't build again. But we always build one each frame.
		if (built && time < 10)
			return super.idle(time);

		// Account this time for build instead of idle
		idleTime.stop();
		buildTime.start();

		// Do the build
		built = runner.build();

		// Delete unused resources
		charge.sys.resource.Pool().collect();

		// Switch back to idle
		buildTime.stop();
		idleTime.start();

		// Didn't build anything, just sleep.
		if (!built)
			super.idle(time);
	}

	void network()
	{
	}

	void close()
	{
	}

	/*
	 *
	 * Managing runners functions.
	 *
	 */

	void switchTo(GameRunner gr)
	{
		auto r = cast(Runner)gr;
		assert(r !is null);

		nextRunner = r;
	}

	void deleteMe(GameRunner gr)
	{
		auto r = cast(Runner)gr;
		assert(r !is null);

		deleteRunner ~= r;
	}

	Runner loadLevel(char[] dir)
	{
		Runner r;
		World w;

		w = new World(dir, rm);

		auto scriptName = "res/script.lua";
		try {
			r = new ScriptRunner(this, w, rm, scriptName);
		} catch (Exception e) {
			l.fatal("Could not find or run \"%s\" (%s)", scriptName, e);
			r = new ViewerRunner(this, w, rm);
		}

		// No other place to put it.
		if (build_all) {
			l.fatal("Building all, please wait...");
			auto t1 = SDL_GetTicks();
			w.vt.buildAll();
			auto t2 = SDL_GetTicks();
			l.fatal("Build time: %s seconds", (t2 - t1) / 1000.0);
		}

		return r;
	}

	void manageRunners()
	{
		// Delete any pending runners.
		if (deleteRunner.length) {
			foreach(r; deleteRunner) {
				if (r is runner)
					runner = null;
				if (r is sr)
					sr = null;
				delete r;
			}
			deleteRunner = null;
		}

		// Do the switch of runners.
		if (nextRunner !is null) {
			if (runner !is null)
				runner.dropControl();

			runner = nextRunner;
			sr = cast(ScriptRunner)runner;

			runner.assumeControl();

			nextRunner = null;
		}
	}

	/*
	 *
	 * Intro text functions.
	 *
	 */

	void makeInfoTexture(/*GfxRenderTarget rt*/)
	{
		auto introText = new GfxDynamicTexture("mc/introText");
		auto headerText = new GfxDynamicTexture("mc/headerText");

		GfxFont.render(headerText, headerTextChars);
		GfxFont.render(introText, introTextChars);

		int width = 8 + cast(int)fmax(4 + headerText.width * 2 + 4, introText.width) + 8;
		int height = 8 + 4 + headerText.height * 2 + 4 + 8 + introText.height + 8;

		int center = width / 2;
		int maxWidth = cast(int)fmax(headerText.width*2+8, introText.width) + 16;
		int maxHeight = 8 + 4 + headerText.height*2 + 4 + 8 + introText.height + 8;

		if (infoTexture !is null)
			infoTexture.dereference();
		infoTexture = GfxTextureTarget("mc/infoText", width, height);

		auto d = new GfxDraw();
		d.target = infoTexture;
		d.start();

		// Background
		d.fill(Color4f(0, 0, 0, .8), false, 0, 0, width, height);

		// Title bar background
		d.fill(Color4f(0, 0, 1.0, 0.8), false,
		       8, 8, maxWidth-16, headerText.height*2+8);

		// Header text
		d.blit(headerText, Color4f.White, true,
		       0, 0,                                         // srcX, srcY
		       headerText.width, headerText.height,          // srcW, srcH
		       center - headerText.width, 8 + 4,             // dstX, dstY
		       headerText.width * 2, headerText.height * 2); // dstW, dstH

		// Intro text
		d.blit(introText, center - introText.width / 2, 8+4+headerText.height*2+4+8);

		d.stop();

		introText.dereference();
		headerText.dereference();

		// Make sure the target is unbound.
		auto rt = GfxDefaultTarget();
		rt.setTarget();
	}

	const char[] headerTextChars = `Charged Miners`;

	const char[] introTextChars =
`Welcome to charged miners, I see that this is the
first time that you are running this application.



            Press any key to continue.
`;
}
