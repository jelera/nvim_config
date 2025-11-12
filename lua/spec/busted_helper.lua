-- Busted helper file - loaded automatically before running tests
-- This file sets up the Lua module path so tests can find spec.spec_helper

-- Add lua/ directory to Lua module path
package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path
