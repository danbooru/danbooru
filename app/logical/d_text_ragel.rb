
# line 1 "d_text_ragel.rl"
require 'cgi'
require 'uri'
require 'stringio'


# line 374 "d_text_ragel.rl"


class DTextRagel
  
# line 14 "d_text_ragel.rb"
class << self
	attr_accessor :_dtext_actions
	private :_dtext_actions, :_dtext_actions=
end
self._dtext_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 5, 1, 6, 1, 
	11, 1, 12, 1, 13, 1, 14, 1, 
	15, 1, 16, 1, 17, 1, 18, 1, 
	19, 1, 20, 1, 21, 1, 22, 1, 
	23, 1, 24, 1, 25, 1, 26, 1, 
	27, 1, 28, 1, 29, 1, 30, 1, 
	31, 1, 32, 1, 33, 1, 34, 1, 
	35, 1, 36, 1, 37, 1, 38, 1, 
	39, 1, 40, 1, 41, 1, 42, 1, 
	43, 1, 44, 1, 45, 1, 46, 1, 
	47, 1, 48, 1, 49, 1, 50, 1, 
	51, 1, 52, 1, 55, 1, 56, 1, 
	57, 1, 58, 1, 61, 1, 62, 1, 
	63, 1, 64, 1, 65, 1, 66, 1, 
	67, 1, 68, 1, 69, 1, 70, 1, 
	71, 1, 72, 1, 73, 2, 0, 1, 
	2, 2, 3, 2, 6, 1, 2, 6, 
	7, 2, 6, 8, 2, 6, 9, 2, 
	6, 10, 2, 6, 53, 2, 6, 54, 
	2, 6, 60, 3, 6, 0, 1, 4, 
	6, 2, 3, 59
]

class << self
	attr_accessor :_dtext_key_offsets
	private :_dtext_key_offsets, :_dtext_key_offsets=
end
self._dtext_key_offsets = [
	0, 1, 2, 3, 4, 5, 6, 7, 
	8, 9, 11, 12, 13, 14, 15, 16, 
	17, 18, 19, 20, 21, 22, 23, 24, 
	25, 26, 30, 31, 32, 34, 35, 36, 
	37, 38, 40, 41, 42, 44, 47, 48, 
	49, 50, 51, 53, 54, 55, 57, 58, 
	65, 66, 67, 68, 69, 70, 71, 72, 
	73, 74, 75, 76, 77, 78, 80, 81, 
	82, 83, 84, 85, 86, 87, 88, 89, 
	91, 93, 94, 95, 96, 97, 98, 99, 
	101, 102, 103, 104, 105, 106, 107, 108, 
	109, 110, 111, 112, 113, 114, 115, 116, 
	118, 119, 120, 121, 122, 123, 124, 125, 
	127, 128, 129, 130, 131, 132, 134, 135, 
	136, 138, 139, 140, 142, 143, 144, 145, 
	146, 147, 148, 150, 151, 152, 153, 154, 
	155, 157, 158, 160, 162, 163, 164, 165, 
	167, 168, 169, 170, 172, 173, 174, 175, 
	176, 177, 179, 180, 182, 183, 184, 185, 
	186, 188, 189, 190, 191, 192, 193, 194, 
	195, 196, 201, 202, 206, 208, 212, 214, 
	232, 234, 236, 237, 239, 241, 253, 260, 
	261, 263, 264, 266, 267, 269, 270, 272, 
	273, 275, 277, 280, 282, 284, 286, 287, 
	290, 292, 293, 295, 296, 298, 299
]

class << self
	attr_accessor :_dtext_trans_keys
	private :_dtext_trans_keys, :_dtext_trans_keys=
end
self._dtext_trans_keys = [
	111, 100, 101, 93, 120, 112, 97, 110, 
	100, 61, 93, 93, 93, 117, 111, 116, 
	101, 93, 112, 111, 105, 108, 101, 114, 
	93, 46, 9, 32, 33, 126, 34, 58, 
	91, 104, 104, 116, 116, 112, 58, 115, 
	47, 47, 33, 126, 93, 33, 126, 58, 
	116, 116, 112, 58, 115, 47, 47, 33, 
	126, 58, 98, 101, 105, 113, 115, 116, 
	117, 93, 120, 112, 97, 110, 100, 93, 
	93, 117, 111, 116, 101, 93, 93, 112, 
	111, 105, 108, 101, 114, 93, 110, 93, 
	93, 93, 124, 93, 124, 93, 93, 93, 
	93, 93, 93, 93, 112, 111, 105, 108, 
	101, 114, 93, 110, 93, 93, 116, 105, 
	115, 116, 32, 35, 48, 57, 109, 109, 
	101, 110, 116, 32, 35, 48, 57, 114, 
	117, 109, 32, 35, 48, 57, 116, 112, 
	58, 115, 47, 47, 33, 126, 58, 115, 
	117, 101, 32, 35, 48, 57, 120, 105, 
	118, 32, 35, 48, 57, 112, 48, 57, 
	111, 115, 108, 32, 35, 48, 57, 116, 
	32, 35, 48, 57, 112, 105, 99, 32, 
	35, 48, 57, 112, 48, 57, 101, 114, 
	32, 35, 48, 57, 125, 125, 125, 99, 
	111, 100, 101, 93, 0, 10, 13, 91, 
	104, 10, 99, 101, 113, 115, 49, 54, 
	9, 32, 33, 126, 32, 126, 0, 10, 
	13, 34, 38, 60, 62, 64, 91, 97, 
	99, 102, 104, 105, 112, 116, 117, 123, 
	10, 13, 10, 13, 34, 33, 126, 33, 
	126, 33, 41, 44, 46, 61, 93, 34, 
	57, 58, 63, 64, 126, 47, 91, 98, 
	105, 115, 116, 117, 114, 48, 57, 111, 
	48, 57, 111, 48, 57, 116, 33, 126, 
	115, 48, 57, 105, 111, 47, 48, 57, 
	48, 57, 48, 57, 48, 57, 111, 47, 
	48, 57, 48, 57, 115, 48, 57, 123, 
	0, 91, 91, 47, 0
]

class << self
	attr_accessor :_dtext_single_lengths
	private :_dtext_single_lengths, :_dtext_single_lengths=
end
self._dtext_single_lengths = [
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 2, 1, 1, 2, 1, 1, 1, 
	1, 2, 1, 1, 0, 1, 1, 1, 
	1, 1, 2, 1, 1, 0, 1, 7, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	2, 1, 1, 1, 1, 1, 1, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 0, 
	1, 1, 1, 1, 1, 1, 1, 0, 
	1, 1, 1, 1, 1, 0, 1, 1, 
	2, 1, 1, 0, 1, 1, 1, 1, 
	1, 1, 0, 1, 1, 1, 1, 1, 
	0, 1, 0, 2, 1, 1, 1, 0, 
	1, 1, 1, 0, 1, 1, 1, 1, 
	1, 0, 1, 0, 1, 1, 1, 1, 
	0, 1, 1, 1, 1, 1, 1, 1, 
	1, 5, 1, 4, 0, 2, 0, 18, 
	2, 2, 1, 0, 0, 6, 7, 1, 
	0, 1, 0, 1, 0, 1, 0, 1, 
	0, 2, 1, 0, 0, 0, 1, 1, 
	0, 1, 0, 1, 2, 1, 1
]

class << self
	attr_accessor :_dtext_range_lengths
	private :_dtext_range_lengths, :_dtext_range_lengths=
end
self._dtext_range_lengths = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	1, 0, 1, 0, 0, 0, 0, 1, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 1, 0, 1, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 1, 1, 0, 
	0, 0, 0, 1, 1, 3, 0, 0, 
	1, 0, 1, 0, 1, 0, 1, 0, 
	1, 0, 1, 1, 1, 1, 0, 1, 
	1, 0, 1, 0, 0, 0, 0
]

class << self
	attr_accessor :_dtext_index_offsets
	private :_dtext_index_offsets, :_dtext_index_offsets=
end
self._dtext_index_offsets = [
	0, 2, 4, 6, 8, 10, 12, 14, 
	16, 18, 21, 23, 25, 27, 29, 31, 
	33, 35, 37, 39, 41, 43, 45, 47, 
	49, 51, 55, 57, 59, 62, 64, 66, 
	68, 70, 73, 75, 77, 79, 82, 84, 
	86, 88, 90, 93, 95, 97, 99, 101, 
	109, 111, 113, 115, 117, 119, 121, 123, 
	125, 127, 129, 131, 133, 135, 138, 140, 
	142, 144, 146, 148, 150, 152, 154, 156, 
	159, 162, 164, 166, 168, 170, 172, 174, 
	177, 179, 181, 183, 185, 187, 189, 191, 
	193, 195, 197, 199, 201, 203, 205, 207, 
	209, 211, 213, 215, 217, 219, 221, 223, 
	225, 227, 229, 231, 233, 235, 237, 239, 
	241, 244, 246, 248, 250, 252, 254, 256, 
	258, 260, 262, 264, 266, 268, 270, 272, 
	274, 276, 278, 280, 283, 285, 287, 289, 
	291, 293, 295, 297, 299, 301, 303, 305, 
	307, 309, 311, 313, 315, 317, 319, 321, 
	323, 325, 327, 329, 331, 333, 335, 337, 
	339, 341, 347, 349, 354, 356, 360, 362, 
	381, 384, 387, 389, 391, 393, 403, 411, 
	413, 415, 417, 419, 421, 423, 425, 427, 
	429, 431, 434, 437, 439, 441, 443, 445, 
	448, 450, 452, 454, 456, 459, 461
]

class << self
	attr_accessor :_dtext_trans_targs
	private :_dtext_trans_targs, :_dtext_trans_targs=
end
self._dtext_trans_targs = [
	1, 161, 2, 161, 3, 161, 161, 161, 
	5, 161, 6, 161, 7, 161, 8, 161, 
	9, 161, 10, 161, 161, 161, 11, 161, 
	11, 13, 161, 14, 161, 15, 161, 16, 
	161, 161, 161, 18, 161, 19, 161, 20, 
	161, 21, 161, 22, 161, 23, 161, 161, 
	161, 25, 161, 25, 165, 166, 161, 27, 
	26, 28, 167, 29, 39, 167, 30, 167, 
	31, 167, 32, 167, 33, 167, 34, 38, 
	167, 35, 167, 36, 167, 37, 167, 167, 
	37, 167, 34, 167, 40, 167, 41, 167, 
	42, 167, 43, 46, 167, 44, 167, 45, 
	167, 171, 167, 43, 167, 48, 49, 55, 
	56, 61, 68, 70, 167, 167, 167, 50, 
	167, 51, 167, 52, 167, 53, 167, 54, 
	167, 167, 167, 167, 167, 57, 167, 58, 
	167, 59, 167, 60, 167, 167, 167, 167, 
	62, 167, 63, 167, 64, 167, 65, 167, 
	66, 167, 67, 167, 167, 167, 69, 167, 
	167, 167, 167, 167, 167, 167, 72, 73, 
	74, 72, 167, 167, 167, 75, 76, 75, 
	167, 167, 167, 167, 167, 167, 167, 80, 
	167, 81, 167, 82, 167, 83, 167, 84, 
	167, 85, 167, 167, 167, 87, 167, 167, 
	167, 167, 167, 90, 167, 91, 167, 92, 
	167, 93, 167, 94, 167, 95, 167, 176, 
	167, 97, 167, 98, 167, 99, 167, 100, 
	167, 101, 167, 102, 167, 103, 167, 178, 
	167, 105, 167, 106, 167, 107, 167, 108, 
	167, 109, 167, 180, 167, 111, 167, 112, 
	167, 113, 116, 167, 114, 167, 115, 167, 
	182, 167, 113, 167, 118, 167, 119, 167, 
	120, 167, 121, 167, 122, 167, 184, 167, 
	124, 167, 125, 167, 126, 167, 127, 167, 
	128, 167, 186, 167, 130, 167, 187, 167, 
	132, 136, 167, 133, 167, 134, 167, 135, 
	167, 188, 167, 137, 167, 138, 167, 139, 
	167, 189, 167, 141, 167, 142, 167, 143, 
	167, 144, 167, 145, 167, 191, 167, 147, 
	167, 192, 167, 149, 167, 150, 167, 151, 
	167, 152, 167, 194, 167, 167, 154, 155, 
	154, 167, 167, 157, 196, 158, 196, 159, 
	196, 160, 196, 196, 196, 161, 161, 162, 
	163, 164, 161, 161, 161, 0, 4, 12, 
	17, 161, 24, 161, 25, 165, 166, 161, 
	166, 161, 167, 168, 169, 170, 167, 167, 
	167, 172, 174, 175, 177, 179, 181, 183, 
	185, 190, 193, 195, 167, 168, 168, 167, 
	168, 168, 167, 167, 26, 171, 167, 173, 
	167, 173, 173, 173, 173, 173, 173, 173, 
	173, 173, 167, 47, 71, 77, 78, 79, 
	86, 88, 167, 89, 167, 176, 167, 96, 
	167, 178, 167, 104, 167, 180, 167, 110, 
	167, 182, 167, 117, 167, 184, 167, 123, 
	131, 167, 129, 186, 167, 187, 167, 188, 
	167, 189, 167, 140, 167, 146, 191, 167, 
	192, 167, 148, 167, 194, 167, 153, 167, 
	197, 198, 197, 196, 197, 156, 196, 161, 
	161, 161, 161, 161, 161, 161, 161, 161, 
	161, 161, 161, 161, 161, 161, 161, 161, 
	161, 161, 161, 161, 161, 161, 161, 161, 
	161, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 196, 196, 196, 196, 196, 
	161, 161, 161, 161, 161, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 167, 167, 167, 167, 167, 167, 167, 
	167, 196, 196, 0
]

class << self
	attr_accessor :_dtext_trans_actions
	private :_dtext_trans_actions, :_dtext_trans_actions=
end
self._dtext_trans_actions = [
	0, 129, 0, 129, 0, 129, 111, 129, 
	0, 129, 0, 129, 0, 129, 0, 129, 
	0, 129, 0, 113, 129, 129, 133, 115, 
	3, 0, 129, 0, 129, 0, 129, 0, 
	129, 107, 129, 0, 129, 0, 129, 0, 
	129, 0, 129, 0, 129, 0, 129, 109, 
	129, 0, 129, 0, 167, 136, 131, 3, 
	0, 0, 95, 0, 5, 95, 5, 95, 
	0, 95, 0, 95, 0, 95, 0, 0, 
	95, 0, 95, 0, 95, 7, 95, 21, 
	7, 95, 0, 95, 0, 95, 0, 95, 
	0, 95, 0, 0, 95, 0, 95, 0, 
	95, 7, 95, 0, 95, 0, 0, 0, 
	0, 0, 0, 0, 95, 25, 95, 0, 
	95, 0, 95, 0, 95, 0, 95, 0, 
	95, 49, 95, 29, 95, 0, 95, 0, 
	95, 0, 95, 0, 95, 43, 95, 33, 
	0, 95, 0, 95, 0, 95, 0, 95, 
	0, 95, 0, 95, 47, 95, 0, 95, 
	41, 95, 37, 95, 95, 95, 133, 0, 
	0, 3, 17, 95, 95, 136, 0, 7, 
	19, 95, 23, 95, 27, 95, 31, 0, 
	95, 0, 95, 0, 95, 0, 95, 0, 
	95, 0, 95, 45, 95, 0, 95, 39, 
	95, 35, 95, 0, 95, 0, 95, 0, 
	95, 0, 95, 0, 95, 0, 95, 133, 
	95, 0, 95, 0, 95, 0, 95, 0, 
	95, 0, 95, 0, 95, 0, 95, 133, 
	95, 0, 95, 0, 95, 0, 95, 0, 
	95, 0, 95, 133, 95, 0, 95, 0, 
	95, 0, 0, 95, 0, 95, 0, 95, 
	0, 95, 0, 95, 0, 95, 0, 95, 
	0, 95, 0, 95, 0, 95, 133, 95, 
	0, 95, 0, 95, 0, 95, 0, 95, 
	0, 95, 163, 95, 0, 93, 136, 93, 
	0, 0, 95, 0, 95, 0, 95, 0, 
	95, 133, 95, 0, 95, 0, 95, 0, 
	95, 133, 95, 0, 95, 0, 95, 0, 
	95, 0, 95, 0, 95, 163, 95, 0, 
	91, 136, 91, 0, 95, 0, 95, 0, 
	95, 0, 95, 133, 95, 95, 133, 0, 
	3, 15, 95, 0, 103, 0, 103, 0, 
	103, 0, 103, 99, 103, 117, 119, 0, 
	13, 160, 121, 119, 125, 0, 0, 0, 
	0, 127, 133, 127, 0, 167, 136, 123, 
	7, 123, 57, 151, 0, 13, 51, 53, 
	55, 0, 13, 13, 13, 13, 13, 13, 
	13, 13, 13, 13, 59, 148, 148, 97, 
	148, 148, 87, 89, 1, 7, 83, 145, 
	89, 142, 142, 142, 142, 145, 142, 145, 
	142, 145, 97, 0, 0, 0, 0, 0, 
	0, 0, 89, 0, 89, 3, 75, 0, 
	89, 3, 69, 0, 89, 3, 63, 0, 
	89, 0, 85, 0, 89, 3, 77, 0, 
	0, 89, 0, 139, 79, 7, 81, 3, 
	71, 3, 61, 0, 89, 0, 139, 65, 
	7, 67, 0, 89, 3, 73, 0, 89, 
	154, 13, 157, 105, 157, 0, 101, 129, 
	129, 129, 129, 129, 129, 129, 129, 129, 
	129, 129, 129, 129, 129, 129, 129, 129, 
	129, 129, 129, 129, 129, 129, 129, 129, 
	131, 95, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	93, 93, 95, 95, 95, 95, 95, 95, 
	95, 95, 95, 95, 95, 95, 95, 95, 
	95, 91, 91, 95, 95, 95, 95, 95, 
	95, 95, 95, 103, 103, 103, 103, 103, 
	125, 127, 127, 123, 123, 97, 87, 89, 
	83, 89, 97, 89, 89, 75, 89, 69, 
	89, 63, 89, 85, 89, 77, 89, 79, 
	81, 71, 61, 89, 65, 67, 89, 73, 
	89, 105, 101, 0
]

class << self
	attr_accessor :_dtext_to_state_actions
	private :_dtext_to_state_actions, :_dtext_to_state_actions=
end
self._dtext_to_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 9, 0, 0, 0, 0, 0, 9, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 9, 0, 0
]

class << self
	attr_accessor :_dtext_from_state_actions
	private :_dtext_from_state_actions, :_dtext_from_state_actions=
end
self._dtext_from_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 11, 0, 0, 0, 0, 0, 11, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 11, 0, 0
]

class << self
	attr_accessor :_dtext_eof_trans
	private :_dtext_eof_trans, :_dtext_eof_trans=
end
self._dtext_eof_trans = [
	488, 488, 488, 488, 488, 488, 488, 488, 
	488, 488, 488, 488, 488, 488, 488, 488, 
	488, 488, 488, 488, 488, 488, 488, 488, 
	488, 489, 619, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 594, 594, 619, 619, 619, 619, 619, 
	619, 619, 619, 619, 619, 619, 619, 619, 
	619, 619, 611, 611, 619, 619, 619, 619, 
	619, 619, 619, 619, 624, 624, 624, 624, 
	624, 0, 625, 627, 627, 629, 629, 0, 
	635, 631, 657, 633, 657, 635, 657, 657, 
	638, 657, 640, 657, 642, 657, 644, 657, 
	646, 657, 648, 649, 650, 651, 657, 653, 
	654, 657, 656, 657, 0, 658, 659
]

class << self
	attr_accessor :dtext_start
end
self.dtext_start = 161;
class << self
	attr_accessor :dtext_first_final
end
self.dtext_first_final = 161;
class << self
	attr_accessor :dtext_error
end
self.dtext_error = -1;

class << self
	attr_accessor :dtext_en_inline
end
self.dtext_en_inline = 167;
class << self
	attr_accessor :dtext_en_code
end
self.dtext_en_code = 196;
class << self
	attr_accessor :dtext_en_main
end
self.dtext_en_main = 161;


# line 378 "d_text_ragel.rl"

  def self.h(x)
    CGI.escapeHTML(x)
  end

  def self.u(x)
    CGI.escape(x)
  end

  def self.close_stack(output, stack)
    while obj = stack.pop
      case obj
      when :p
        output << "</p>"

      when :inline_spoiler
        output << "</span>"

      when :block_spoiler
        output << "</div>"

      when :block_quote
        output << "</pre>"

      else
        raise SyntaxError.new("Invalid element #{obj}")
      end
    end
  end

  def self.parse(s)
    stack = []
    dstack = []
    output = StringIO.new
    data = s + "\0"
    eof = data.size
    flags = {}

    
# line 560 "d_text_ragel.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = dtext_start
	top = 0
	ts = nil
	te = nil
	act = 0
end

# line 417 "d_text_ragel.rl"
    
# line 573 "d_text_ragel.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	end
	if _goto_level <= _resume
	_acts = _dtext_from_state_actions[cs]
	_nacts = _dtext_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _dtext_actions[_acts - 1]
			when 5 then
# line 1 "NONE"
		begin
ts = p
		end
# line 603 "d_text_ragel.rb"
		end # from state action switch
	end
	if _trigger_goto
		next
	end
	_keys = _dtext_key_offsets[cs]
	_trans = _dtext_index_offsets[cs]
	_klen = _dtext_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _dtext_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _dtext_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _dtext_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _dtext_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _dtext_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	end
	if _goto_level <= _eof_trans
	cs = _dtext_trans_targs[_trans]
	if _dtext_trans_actions[_trans] != 0
		_acts = _dtext_trans_actions[_trans]
		_nacts = _dtext_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _dtext_actions[_acts - 1]
when 0 then
# line 14 "d_text_ragel.rl"
		begin

    a1 = p
  		end
when 1 then
# line 18 "d_text_ragel.rl"
		begin

    a2 = p
  		end
when 2 then
# line 22 "d_text_ragel.rl"
		begin

    b1 = p
  		end
when 3 then
# line 26 "d_text_ragel.rl"
		begin

    b2 = p
  		end
when 6 then
# line 1 "NONE"
		begin
te = p+1
		end
when 7 then
# line 149 "d_text_ragel.rl"
		begin
act = 18;		end
when 8 then
# line 154 "d_text_ragel.rl"
		begin
act = 19;		end
when 9 then
# line 261 "d_text_ragel.rl"
		begin
act = 37;		end
when 10 then
# line 266 "d_text_ragel.rl"
		begin
act = 38;		end
when 11 then
# line 115 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      tags = data[a1..a2]
      output << '<a rel="nofollow" href="/posts?tags=' + u(tags) + '">' + h(tags) + '</a>'
     end
		end
when 12 then
# line 120 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      name = data[a1..a2]
      title = name.tr(" ", "_").downcase
      output << '<a href="/wiki_pages/show_or_new?title=' + u(title) + '">' + h(name) + '</a>'
     end
		end
when 13 then
# line 126 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      name = data[b1..b2]
      title = data[a1..a2].tr(" ", "_").downcase
      output << '<a href="/wiki_pages/show_or_new?title=' + u(title) + '">' + h(name) + '</a>'
     end
		end
when 14 then
# line 138 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      text = data[a1..a2]
      url = data[b1..b2]
      output << '<a rel="nofollow" href="' + URI.parse(url).to_s + '">' + text + '</a>'
     end
		end
when 15 then
# line 159 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      dstack << :b
      output << '<strong>'
     end
		end
when 16 then
# line 164 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      raise SyntaxError.new("invalid [/b] tag") unless dstack[-1] == :b
      dstack.pop
      output << "</strong>"
     end
		end
when 17 then
# line 170 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      dstack << :i
      output << '<em>'
     end
		end
when 18 then
# line 175 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      raise ParseError.new("invalid [/i] tag") unless dstack[-1] == :i
      dstack.pop
      output << "</em>"
     end
		end
when 19 then
# line 181 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      dstack << :s
      output << "<s>"
     end
		end
when 20 then
# line 186 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      raise ParseError.new("invalid [/s] tag") unless dstack[-1] == :s
      dstack.pop
      output << "</s>"
     end
		end
when 21 then
# line 192 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      dstack << :u
      output << "<u>"
     end
		end
when 22 then
# line 197 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      raise ParseError.new("invalid [/u] tag") unless dstack[-1] == :u
      dstack.pop
      output << "</u>"
     end
		end
when 23 then
# line 203 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      dstack << :tn
      output << '<p class="tn">'
     end
		end
when 24 then
# line 208 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      raise ParseError.new("invalid [/tn] tag") unless dstack[-1] == :tn
      dstack.pop
      output << "</p>"
     end
		end
when 25 then
# line 214 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      raise ParseError.new("invalid [/quote] tag") unless dstack[-1] == :quote
      dstack.pop
      output << "</blockquote>"
      	begin
		top -= 1
		cs = stack[top]
		_trigger_goto = true
		_goto_level = _again
		break
	end

     end
		end
when 26 then
# line 221 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      dstack << :inline_spoiler
      output << '<span class="spoiler">'
     end
		end
when 27 then
# line 226 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      if dstack[-1] == :inline_spoiler
        output << "</span>"
        dstack.pop
      elsif dstack[-1] == :block_spoiler
        output << "</div>"
        dstack.pop
        	begin
		top -= 1
		cs = stack[top]
		_trigger_goto = true
		_goto_level = _again
		break
	end

      else
        raise SyntaxError.new("invalid [/spoiler] tag")
      end
     end
		end
when 28 then
# line 239 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      if dstack[-1] == :expand
        output << '</div></div>'
        dstack.pop
        	begin
		top -= 1
		cs = stack[top]
		_trigger_goto = true
		_goto_level = _again
		break
	end

      else
        raise SyntaxError.new("invalid [/expand] tag")
      end
     end
		end
when 29 then
# line 249 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      output << "&amp;"
     end
		end
when 30 then
# line 253 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      output << "&lt;"
     end
		end
when 31 then
# line 257 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      output << "&gt;"
     end
		end
when 32 then
# line 270 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      p = p - 1;
      	begin
		top -= 1
		cs = stack[top]
		_trigger_goto = true
		_goto_level = _again
		break
	end

     end
		end
when 33 then
# line 275 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      output << data[p]
     end
		end
when 34 then
# line 58 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      id = data[a1..a2]
      output << '<a href="/posts/' + id + '">post #' + id + '</a>'
     end
		end
when 35 then
# line 63 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      id = data[a1..a2]
      output << '<a href="/forum_posts/' + id + '">forum #' + id + '</a>'
     end
		end
when 36 then
# line 68 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      id = data[a1..a2]
      output << '<a href="/forum_topics/' + id + '">topic #' + id + '</a>'
     end
		end
when 37 then
# line 73 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      id = data[a1..a2]
      page = data[b1..b2]
      output << '<a href="/forum_topics/' + id + '?page=' + page + '">topic #' + id + '/p' + page + '</a>'
     end
		end
when 38 then
# line 79 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      id = data[a1..a2]
      output << '<a href="/comments/' + id + '">comment #' + id + '</a>'
     end
		end
when 39 then
# line 84 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      id = data[a1..a2]
      output << '<a href="/pools/' + id + '">pool #' + id + '</a>'
     end
		end
when 40 then
# line 89 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      id = data[a1..a2]
      output << '<a href="/users/' + id + '">user #' + id + '</a>'
     end
		end
when 41 then
# line 94 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      id = data[a1..a2]
      output << '<a href="/artists/' + id + '">artist #' + id + '</a>'
     end
		end
when 42 then
# line 99 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      id = data[a1..a2]
      output << '<a href="https://github.com/r888888888/danbooru/issues/' + id + '">issue #' + id + '</a>'
     end
		end
when 43 then
# line 104 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      id = data[a1..a2]
      output << '<a href="http://www.pixiv.net/member_illust.php?mode=medium&illust_id=' + id + '">pixiv #' + id + '</a>'
     end
		end
when 44 then
# line 109 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      id = data[a1..a2]
      page = data[b1..b2]
      output << '<a href="http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=' + id + '&page=' + page + '">pixiv #' + id + '/p' + page + '</a>'
     end
		end
when 45 then
# line 132 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      text = data[a1..a2]
      url = data[b1..b2]
      output << '<a rel="nofollow" href="' + URI.parse(url).to_s + '">' + text + '</a>'
     end
		end
when 46 then
# line 144 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      url = data[ts...te]
      output << '<a rel="nofollow" href="' + URI.parse(url).to_s + '">' + url + '</a>'
     end
		end
when 47 then
# line 266 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      output << "<br>"
     end
		end
when 48 then
# line 275 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      output << data[p]
     end
		end
when 49 then
# line 68 "d_text_ragel.rl"
		begin
 begin p = ((te))-1; end
 begin 
      id = data[a1..a2]
      output << '<a href="/forum_topics/' + id + '">topic #' + id + '</a>'
     end
		end
when 50 then
# line 104 "d_text_ragel.rl"
		begin
 begin p = ((te))-1; end
 begin 
      id = data[a1..a2]
      output << '<a href="http://www.pixiv.net/member_illust.php?mode=medium&illust_id=' + id + '">pixiv #' + id + '</a>'
     end
		end
when 51 then
# line 275 "d_text_ragel.rl"
		begin
 begin p = ((te))-1; end
 begin 
      output << data[p]
     end
		end
when 52 then
# line 1 "NONE"
		begin
	case act
	when 18 then
	begin begin p = ((te))-1; end

      name = data[ts+1...te-1]
      output << '<a rel="nofollow" href="/users?name=' + u(name) + '">@' + h(name) + '</a>' + data[p]
    end
	when 19 then
	begin begin p = ((te))-1; end

      name = data[ts+1...te]
      output << '<a rel="nofollow" href="/users?name=' + u(name) + '">@' + h(name) + '</a>'
    end
	when 37 then
	begin begin p = ((te))-1; end

      output << close_stack(output, dstack)
      	begin
		top -= 1
		cs = stack[top]
		_trigger_goto = true
		_goto_level = _again
		break
	end

    end
	when 38 then
	begin begin p = ((te))-1; end

      output << "<br>"
    end
end 
			end
when 53 then
# line 291 "d_text_ragel.rl"
		begin
act = 42;		end
when 54 then
# line 300 "d_text_ragel.rl"
		begin
act = 44;		end
when 55 then
# line 281 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      if dstack[-1] == :block_code
        dstack.pop
        output << "</pre>"
      else
        raise SyntaxError.new("invalid [/code] tag")
      end
      	begin
		top -= 1
		cs = stack[top]
		_trigger_goto = true
		_goto_level = _again
		break
	end

     end
		end
when 56 then
# line 296 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      output << "["
     end
		end
when 57 then
# line 296 "d_text_ragel.rl"
		begin
 begin p = ((te))-1; end
 begin 
      output << "["
     end
		end
when 58 then
# line 1 "NONE"
		begin
	case act
	when 42 then
	begin begin p = ((te))-1; end

      p = p - 1;
      	begin
		top -= 1
		cs = stack[top]
		_trigger_goto = true
		_goto_level = _again
		break
	end

    end
	when 44 then
	begin begin p = ((te))-1; end

      output << data[ts...te]
    end
end 
			end
when 59 then
# line 310 "d_text_ragel.rl"
		begin
act = 45;		end
when 60 then
# line 363 "d_text_ragel.rl"
		begin
act = 53;		end
when 61 then
# line 321 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      output << "<blockquote>"
      dstack << :quote
      	begin
		stack[top] = cs
		top+= 1
		cs = 167
		_trigger_goto = true
		_goto_level = _again
		break
	end

     end
		end
when 62 then
# line 327 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      output << '<div class="spoiler">'
      dstack << :block_spoiler
      	begin
		stack[top] = cs
		top+= 1
		cs = 167
		_trigger_goto = true
		_goto_level = _again
		break
	end

     end
		end
when 63 then
# line 333 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      output << '<pre>'
      dstack << :block_code
      	begin
		stack[top] = cs
		top+= 1
		cs = 196
		_trigger_goto = true
		_goto_level = _again
		break
	end

     end
		end
when 64 then
# line 339 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      output << '<div class="expandable"><div class="expandable-header">'
      output << '<input type="button" value="Show" class="expandable-button"/></div>'
      output << '<div class="expandable-content">'
      dstack << :expand
      	begin
		stack[top] = cs
		top+= 1
		cs = 167
		_trigger_goto = true
		_goto_level = _again
		break
	end

     end
		end
when 65 then
# line 347 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      msg = data[a1..a2]
      output <<'<div class="expandable"><div class="expandable-header">'
      output << '<span>' + h(msg) + '</span>'
      output << '<input type="button" value="Show" class="expandable-button"/></div>'
      output << '<div class="expandable-content">'
      dstack << :expand
      	begin
		stack[top] = cs
		top+= 1
		cs = 167
		_trigger_goto = true
		_goto_level = _again
		break
	end

     end
		end
when 66 then
# line 357 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      close_stack(output, dstack)
     end
		end
when 67 then
# line 361 "d_text_ragel.rl"
		begin
te = p+1
		end
when 68 then
# line 363 "d_text_ragel.rl"
		begin
te = p+1
 begin 
      p = p - 1;

      if dstack.empty?
        output << "<p>"
        dstack << :p
      end

      	begin
		stack[top] = cs
		top+= 1
		cs = 167
		_trigger_goto = true
		_goto_level = _again
		break
	end

     end
		end
when 69 then
# line 310 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      if flags[:inline]
        header = "6"
      else
        header = data[a1..a2]
      end

      text = data[b1..b2]
      output << '<h' + header + '>' + h(text) + '</h' + header + '>'
     end
		end
when 70 then
# line 361 "d_text_ragel.rl"
		begin
te = p
p = p - 1;		end
when 71 then
# line 363 "d_text_ragel.rl"
		begin
te = p
p = p - 1; begin 
      p = p - 1;

      if dstack.empty?
        output << "<p>"
        dstack << :p
      end

      	begin
		stack[top] = cs
		top+= 1
		cs = 167
		_trigger_goto = true
		_goto_level = _again
		break
	end

     end
		end
when 72 then
# line 363 "d_text_ragel.rl"
		begin
 begin p = ((te))-1; end
 begin 
      p = p - 1;

      if dstack.empty?
        output << "<p>"
        dstack << :p
      end

      	begin
		stack[top] = cs
		top+= 1
		cs = 167
		_trigger_goto = true
		_goto_level = _again
		break
	end

     end
		end
when 73 then
# line 1 "NONE"
		begin
	case act
	when 45 then
	begin begin p = ((te))-1; end

      if flags[:inline]
        header = "6"
      else
        header = data[a1..a2]
      end

      text = data[b1..b2]
      output << '<h' + header + '>' + h(text) + '</h' + header + '>'
    end
	when 53 then
	begin begin p = ((te))-1; end

      p = p - 1;

      if dstack.empty?
        output << "<p>"
        dstack << :p
      end

      	begin
		stack[top] = cs
		top+= 1
		cs = 167
		_trigger_goto = true
		_goto_level = _again
		break
	end

    end
end 
			end
# line 1479 "d_text_ragel.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	_acts = _dtext_to_state_actions[cs]
	_nacts = _dtext_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _dtext_actions[_acts - 1]
when 4 then
# line 1 "NONE"
		begin
ts = nil;		end
# line 1499 "d_text_ragel.rb"
		end # to state action switch
	end
	if _trigger_goto
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	if _dtext_eof_trans[cs] > 0
		_trans = _dtext_eof_trans[cs] - 1;
		_goto_level = _eof_trans
		next;
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 418 "d_text_ragel.rl"

    output.string
  end
end
