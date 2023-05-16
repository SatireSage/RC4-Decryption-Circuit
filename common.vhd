-- Authors:
-- Lab Group 11:
-- Sahaj Singh Student#: 301437700
-- Bryce Leung Student#: 301421630 
-- Sukha Lee 	Student#: 301380632

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package common is 
	-- Setting up the common package array to be used in the top level and decryption cores
	Type outputBuffer is array (31 downto 0) of std_logic_vector(7 downto 0);
end common;