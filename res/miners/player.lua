-- Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
-- See copyright notice in src/charge/charge.d (GPLv2 only).

local _G = _G
local require = _G.require
module(...)


----
-- This script holds functions related to the player.
--

require "input"
require "miners"
require "physics"

local math = _G.math;
local move = _G.input.move
local doPlayerPhysics = _G.physics.doPlayerPhysics

local Point = _G.charge.Point
local Vector = _G.charge.Vector
local Quat = _G.charge.Quat

local OtherPlayer = _G.miners.OtherPlayer
local camera = _G.camera
local world = _G.world

local ticksPerSeconds = _G.ticksPerSeconds
local playerMaxGroundSpeed = 0.1
local playerMaxAirSpeed = 1
local playerAirAcceleration = 0.04 / ticksPerSeconds
local playerGroundAcceleration = 4.2 / ticksPerSeconds
local playerJumpAcceleration = 0.13


----
-- The player object.
--

local player = {
	pos = Point(),
	vel = Vector(),
	op = OtherPlayer(world),
	headHeight = Vector(0, 1.505, 0),
	ground = false,
}
_G.player = player


----
--
-- This function is called each logic step
--
function player:logic()

	local ground = self.ground
	local vec = Vector()
	self.heading = move.heading
	self.pitch = move.pitch

	if move.forward then vec = vec + Vector(0, 0, -1) end
	if move.backward then vec = vec + Vector(0, 0, 1) end
	if move.right then vec = vec + Vector(1, 0, 0) end
	if move.left then vec = vec + Vector(-1, 0, 0) end

	vec = Quat(move.heading, 0, 0) * vec

	if vec:lengthSqrd() ~= 0 then

		vec:normalize()

		local v = playerAirAcceleration
		if move.speed then v = 0.6 end
		if ground then v = playerGroundAcceleration end

		vec:scale(v)
	end

	local vel = self.vel
	local maxSpeed

	if ground then
		vel.y = 0

		local l = vel:lengthSqrd()
		if l ~= 0 then
			l = math.max(0, l - playerGroundAcceleration)
			l = math.sqrt(l)
			vel:normalize()
			vel:scale(l)
		end

		if move.jump then
			vel.y = playerJumpAcceleration

			-- We are going to go air borne
			maxSpeed = playerMaxAirSpeed
		else
			maxSpeed = playerMaxGroundSpeed
		end
	else
		maxSpeed = playerMaxAirSpeed
	end

	vel = vec + vel

	local l = vel:lengthSqrd()
	l = math.min(l, maxSpeed)
	l = math.sqrt(l)
	vel:normalize()
	vel:scale(l)

	self.vel = vel

	self.pos, self.vel, self.ground = doPlayerPhysics(self)

	camera.position = player.pos + player.headHeight
	camera.rotation = Quat(move.heading, move.pitch, 0)
	self.op:update(player.pos, move.heading, move.pitch);
end
