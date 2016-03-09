
#line 1 "ext/dtext/dtext.rl"
#include <ruby.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <glib.h>

typedef struct StateMachine {
  int top;
  int cs;
  int act;
  const char * p;
  const char * pe;
  const char * eof;
  const char * ts;
  const char * te;

  const char * a1;
  const char * a2;
  const char * b1;
  const char * b2;
  bool f_inline;
  bool boundary;
  bool list_mode;
  GString * output;
  GArray * stack;
  GQueue * dstack;
  GQueue * list_stack;
  int list_nest;
} StateMachine;

static const int MAX_STACK_DEPTH = 512;
static const int BLOCK_P = 1;
static const int INLINE_SPOILER = 2;
static const int BLOCK_SPOILER = 3;
static const int BLOCK_QUOTE = 4;
static const int BLOCK_EXPAND = 5;
static const int BLOCK_NODTEXT = 6;
static const int BLOCK_CODE = 7;
static const int BLOCK_TD = 8;
static const int INLINE_NODTEXT = 9;
static const int INLINE_B = 10;
static const int INLINE_I = 11;
static const int INLINE_U = 12;
static const int INLINE_S = 13;
static const int INLINE_TN = 14;
static const int BLOCK_TN = 15;
static const int BLOCK_TABLE = 16;
static const int BLOCK_THEAD = 17;
static const int BLOCK_TBODY = 18;
static const int BLOCK_TR = 19;
static const int BLOCK_UL = 20;
static const int BLOCK_LI = 21;


#line 764 "ext/dtext/dtext.rl"



#line 62 "ext/dtext/dtext.c"
static const char _dtext_actions[] = {
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 6, 1, 7, 1, 
	8, 1, 13, 1, 14, 1, 15, 1, 
	18, 1, 19, 1, 20, 1, 21, 1, 
	22, 1, 23, 1, 24, 1, 25, 1, 
	26, 1, 27, 1, 28, 1, 29, 1, 
	30, 1, 31, 1, 32, 1, 33, 1, 
	34, 1, 35, 1, 36, 1, 37, 1, 
	50, 1, 53, 1, 54, 1, 55, 1, 
	56, 1, 57, 1, 58, 1, 59, 1, 
	60, 1, 61, 1, 62, 1, 63, 1, 
	64, 1, 65, 1, 66, 1, 67, 1, 
	68, 1, 69, 1, 70, 1, 71, 1, 
	72, 1, 73, 1, 74, 1, 75, 1, 
	76, 1, 77, 1, 78, 1, 79, 1, 
	80, 1, 81, 1, 82, 1, 83, 1, 
	86, 1, 87, 1, 89, 1, 90, 1, 
	91, 1, 92, 1, 93, 1, 94, 1, 
	95, 1, 96, 1, 98, 1, 99, 1, 
	100, 1, 101, 1, 102, 1, 103, 1, 
	104, 1, 105, 1, 106, 1, 109, 1, 
	110, 1, 111, 2, 1, 38, 2, 1, 
	39, 2, 1, 40, 2, 1, 42, 2, 
	1, 43, 2, 1, 44, 2, 1, 45, 
	2, 1, 46, 2, 1, 47, 2, 1, 
	51, 2, 1, 58, 2, 1, 97, 2, 
	3, 16, 2, 3, 41, 2, 3, 48, 
	2, 3, 49, 2, 3, 52, 2, 3, 
	88, 2, 3, 107, 2, 3, 108, 2, 
	8, 0, 2, 8, 9, 2, 8, 10, 
	2, 8, 11, 2, 8, 12, 2, 8, 
	84, 2, 8, 85, 3, 1, 5, 17
	
};

static const short _dtext_key_offsets[] = {
	0, 5, 8, 9, 10, 11, 12, 13, 
	14, 15, 16, 17, 19, 20, 21, 22, 
	23, 24, 25, 26, 27, 28, 29, 30, 
	31, 32, 33, 34, 35, 36, 37, 38, 
	39, 40, 42, 43, 44, 45, 46, 47, 
	48, 53, 54, 55, 57, 58, 59, 60, 
	61, 63, 64, 65, 67, 70, 71, 72, 
	73, 74, 76, 77, 78, 80, 81, 88, 
	89, 90, 91, 92, 93, 94, 95, 96, 
	97, 98, 99, 100, 101, 103, 104, 105, 
	106, 107, 108, 109, 111, 112, 113, 114, 
	116, 118, 119, 120, 121, 122, 123, 124, 
	125, 126, 127, 128, 129, 130, 131, 132, 
	133, 134, 135, 136, 137, 138, 139, 140, 
	141, 142, 144, 145, 146, 147, 148, 149, 
	150, 151, 152, 153, 154, 155, 156, 157, 
	158, 159, 161, 162, 163, 164, 165, 166, 
	167, 168, 170, 171, 172, 173, 174, 175, 
	177, 178, 183, 184, 185, 187, 188, 189, 
	191, 192, 193, 194, 195, 196, 197, 199, 
	200, 201, 202, 203, 204, 206, 207, 209, 
	211, 212, 213, 214, 216, 217, 218, 219, 
	221, 222, 223, 224, 225, 226, 228, 229, 
	231, 232, 233, 234, 235, 237, 238, 239, 
	240, 241, 242, 243, 244, 245, 246, 247, 
	248, 249, 250, 251, 252, 253, 254, 258, 
	259, 260, 261, 262, 263, 264, 265, 266, 
	267, 268, 269, 270, 271, 275, 276, 277, 
	278, 279, 280, 281, 282, 283, 284, 285, 
	290, 293, 302, 303, 306, 309, 314, 320, 
	322, 325, 330, 345, 347, 349, 350, 352, 
	354, 359, 363, 373, 374, 376, 377, 379, 
	380, 382, 385, 388, 393, 395, 396, 398, 
	400, 403, 405, 407, 409, 410, 413, 415, 
	416, 418, 419, 421, 422, 427, 428, 430, 
	432, 436, 438, 440, 443, 446
};

static const char _dtext_trans_keys[] = {
	0, 9, 10, 13, 32, 9, 32, 42, 
	111, 100, 101, 93, 120, 112, 97, 110, 
	100, 61, 93, 93, 93, 111, 100, 116, 
	101, 120, 116, 93, 117, 111, 116, 101, 
	93, 112, 111, 105, 108, 101, 114, 93, 
	97, 110, 98, 108, 101, 93, 93, 46, 
	0, 9, 10, 13, 32, 34, 58, 91, 
	104, 104, 116, 116, 112, 58, 115, 47, 
	47, 33, 126, 93, 33, 126, 58, 116, 
	116, 112, 58, 115, 47, 47, 33, 126, 
	58, 98, 101, 105, 113, 115, 116, 117, 
	93, 120, 112, 97, 110, 100, 93, 93, 
	117, 111, 116, 101, 93, 93, 112, 111, 
	105, 108, 101, 114, 93, 100, 110, 93, 
	93, 93, 93, 124, 93, 124, 93, 93, 
	93, 93, 93, 120, 112, 97, 110, 100, 
	93, 93, 111, 100, 116, 101, 120, 116, 
	93, 117, 111, 116, 101, 93, 93, 112, 
	111, 105, 108, 101, 114, 93, 110, 93, 
	93, 116, 105, 115, 116, 32, 35, 48, 
	57, 109, 109, 101, 110, 116, 32, 35, 
	48, 57, 114, 117, 109, 32, 35, 48, 
	57, 46, 0, 9, 10, 13, 32, 116, 
	112, 58, 115, 47, 47, 33, 126, 58, 
	115, 117, 101, 32, 35, 48, 57, 120, 
	105, 118, 32, 35, 48, 57, 112, 48, 
	57, 111, 115, 108, 32, 35, 48, 57, 
	116, 32, 35, 48, 57, 112, 105, 99, 
	32, 35, 48, 57, 112, 48, 57, 101, 
	114, 32, 35, 48, 57, 125, 125, 125, 
	99, 111, 100, 101, 93, 110, 111, 100, 
	116, 101, 120, 116, 93, 116, 97, 98, 
	104, 114, 98, 108, 101, 93, 111, 100, 
	121, 93, 101, 97, 100, 93, 93, 98, 
	100, 104, 114, 111, 100, 121, 93, 93, 
	101, 97, 100, 93, 93, 0, 9, 10, 
	13, 32, 9, 32, 42, 0, 10, 13, 
	38, 42, 60, 62, 91, 104, 10, 9, 
	32, 42, 0, 10, 13, 0, 9, 10, 
	13, 32, 99, 101, 110, 113, 115, 116, 
	49, 54, 0, 10, 13, 0, 9, 10, 
	13, 32, 0, 10, 13, 34, 64, 91, 
	97, 99, 102, 104, 105, 112, 116, 117, 
	123, 10, 13, 10, 13, 34, 33, 126, 
	33, 126, 58, 63, 64, 33, 126, 58, 
	63, 33, 126, 47, 91, 98, 101, 105, 
	110, 113, 115, 116, 117, 114, 48, 57, 
	111, 48, 57, 111, 48, 57, 116, 49, 
	54, 0, 10, 13, 0, 9, 10, 13, 
	32, 33, 126, 115, 48, 57, 105, 111, 
	47, 48, 57, 48, 57, 48, 57, 48, 
	57, 111, 47, 48, 57, 48, 57, 115, 
	48, 57, 123, 0, 91, 47, 0, 38, 
	60, 62, 91, 47, 0, 91, 47, 116, 
	0, 10, 13, 42, 10, 13, 10, 13, 
	9, 32, 42, 0, 10, 13, 0, 9, 
	10, 13, 32, 0
};

static const char _dtext_single_lengths[] = {
	5, 3, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 2, 1, 1, 1, 1, 1, 1, 
	5, 1, 1, 2, 1, 1, 1, 1, 
	2, 1, 1, 0, 1, 1, 1, 1, 
	1, 2, 1, 1, 0, 1, 7, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 2, 1, 1, 1, 
	1, 1, 1, 2, 1, 1, 1, 2, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 0, 1, 1, 1, 1, 1, 1, 
	1, 0, 1, 1, 1, 1, 1, 0, 
	1, 5, 1, 1, 2, 1, 1, 0, 
	1, 1, 1, 1, 1, 1, 0, 1, 
	1, 1, 1, 1, 0, 1, 0, 2, 
	1, 1, 1, 0, 1, 1, 1, 0, 
	1, 1, 1, 1, 1, 0, 1, 0, 
	1, 1, 1, 1, 0, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 4, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 4, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 5, 
	3, 9, 1, 3, 3, 5, 6, 0, 
	3, 5, 15, 2, 2, 1, 0, 0, 
	3, 2, 10, 1, 0, 1, 0, 1, 
	0, 1, 3, 5, 0, 1, 0, 2, 
	1, 0, 0, 0, 1, 1, 0, 1, 
	0, 1, 2, 1, 5, 1, 2, 2, 
	4, 2, 2, 3, 3, 5
};

static const char _dtext_range_lengths[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 1, 0, 1, 0, 
	0, 0, 0, 1, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 1, 0, 1, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 0, 1, 1, 
	1, 1, 0, 0, 1, 0, 1, 0, 
	1, 1, 0, 0, 1, 0, 1, 0, 
	1, 1, 1, 1, 0, 1, 1, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0
};

static const short _dtext_index_offsets[] = {
	0, 6, 10, 12, 14, 16, 18, 20, 
	22, 24, 26, 28, 31, 33, 35, 37, 
	39, 41, 43, 45, 47, 49, 51, 53, 
	55, 57, 59, 61, 63, 65, 67, 69, 
	71, 73, 76, 78, 80, 82, 84, 86, 
	88, 94, 96, 98, 101, 103, 105, 107, 
	109, 112, 114, 116, 118, 121, 123, 125, 
	127, 129, 132, 134, 136, 138, 140, 148, 
	150, 152, 154, 156, 158, 160, 162, 164, 
	166, 168, 170, 172, 174, 177, 179, 181, 
	183, 185, 187, 189, 192, 194, 196, 198, 
	201, 204, 206, 208, 210, 212, 214, 216, 
	218, 220, 222, 224, 226, 228, 230, 232, 
	234, 236, 238, 240, 242, 244, 246, 248, 
	250, 252, 255, 257, 259, 261, 263, 265, 
	267, 269, 271, 273, 275, 277, 279, 281, 
	283, 285, 287, 289, 291, 293, 295, 297, 
	299, 301, 303, 305, 307, 309, 311, 313, 
	315, 317, 323, 325, 327, 330, 332, 334, 
	336, 338, 340, 342, 344, 346, 348, 350, 
	352, 354, 356, 358, 360, 362, 364, 366, 
	369, 371, 373, 375, 377, 379, 381, 383, 
	385, 387, 389, 391, 393, 395, 397, 399, 
	401, 403, 405, 407, 409, 411, 413, 415, 
	417, 419, 421, 423, 425, 427, 429, 431, 
	433, 435, 437, 439, 441, 443, 445, 450, 
	452, 454, 456, 458, 460, 462, 464, 466, 
	468, 470, 472, 474, 476, 481, 483, 485, 
	487, 489, 491, 493, 495, 497, 499, 501, 
	507, 511, 521, 523, 527, 531, 537, 544, 
	546, 550, 556, 572, 575, 578, 580, 582, 
	584, 589, 593, 604, 606, 608, 610, 612, 
	614, 616, 619, 623, 629, 631, 633, 635, 
	638, 641, 643, 645, 647, 649, 652, 654, 
	656, 658, 660, 663, 665, 671, 673, 676, 
	679, 684, 687, 690, 694, 698
};

static const short _dtext_trans_targs[] = {
	233, 237, 233, 233, 237, 236, 0, 0, 
	1, 233, 3, 233, 4, 233, 5, 233, 
	233, 233, 7, 233, 8, 233, 9, 233, 
	10, 233, 11, 233, 12, 233, 233, 233, 
	13, 233, 13, 15, 233, 16, 233, 17, 
	233, 18, 233, 19, 233, 20, 233, 233, 
	233, 22, 233, 23, 233, 24, 233, 25, 
	233, 233, 233, 27, 233, 28, 233, 29, 
	233, 30, 233, 31, 233, 32, 233, 233, 
	233, 34, 38, 233, 35, 233, 36, 233, 
	37, 233, 233, 233, 233, 233, 40, 233, 
	233, 241, 233, 233, 241, 240, 42, 41, 
	43, 242, 44, 54, 242, 45, 242, 46, 
	242, 47, 242, 48, 242, 49, 53, 242, 
	50, 242, 51, 242, 52, 242, 242, 52, 
	242, 49, 242, 55, 242, 56, 242, 57, 
	242, 58, 61, 242, 59, 242, 60, 242, 
	246, 242, 58, 242, 63, 64, 70, 71, 
	76, 83, 86, 242, 242, 242, 65, 242, 
	66, 242, 67, 242, 68, 242, 69, 242, 
	242, 242, 242, 242, 72, 242, 73, 242, 
	74, 242, 75, 242, 242, 242, 242, 77, 
	242, 78, 242, 79, 242, 80, 242, 81, 
	242, 82, 242, 242, 242, 84, 85, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	88, 89, 90, 88, 242, 242, 242, 91, 
	92, 91, 242, 242, 242, 242, 95, 242, 
	96, 242, 97, 242, 98, 242, 99, 242, 
	242, 242, 242, 242, 102, 242, 103, 242, 
	104, 242, 105, 242, 106, 242, 107, 242, 
	242, 242, 109, 242, 110, 242, 111, 242, 
	112, 242, 242, 242, 242, 114, 242, 115, 
	242, 116, 242, 117, 242, 118, 242, 119, 
	242, 242, 242, 121, 242, 242, 242, 242, 
	242, 124, 242, 125, 242, 126, 242, 127, 
	242, 128, 242, 129, 242, 252, 242, 131, 
	242, 132, 242, 133, 242, 134, 242, 135, 
	242, 136, 242, 137, 242, 254, 242, 139, 
	242, 140, 242, 141, 242, 142, 242, 143, 
	242, 256, 242, 145, 242, 242, 259, 242, 
	242, 259, 258, 147, 242, 148, 242, 149, 
	152, 242, 150, 242, 151, 242, 260, 242, 
	149, 242, 154, 242, 155, 242, 156, 242, 
	157, 242, 158, 242, 262, 242, 160, 242, 
	161, 242, 162, 242, 163, 242, 164, 242, 
	264, 242, 166, 242, 265, 242, 168, 172, 
	242, 169, 242, 170, 242, 171, 242, 266, 
	242, 173, 242, 174, 242, 175, 242, 267, 
	242, 177, 242, 178, 242, 179, 242, 180, 
	242, 181, 242, 269, 242, 183, 242, 270, 
	242, 185, 242, 186, 242, 187, 242, 188, 
	242, 272, 242, 242, 190, 191, 190, 242, 
	242, 193, 274, 194, 274, 195, 274, 196, 
	274, 274, 274, 198, 276, 199, 276, 200, 
	276, 201, 276, 202, 276, 203, 276, 204, 
	276, 276, 276, 206, 278, 207, 211, 215, 
	219, 278, 208, 278, 209, 278, 210, 278, 
	278, 278, 212, 278, 213, 278, 214, 278, 
	278, 278, 216, 278, 217, 278, 218, 278, 
	278, 278, 278, 278, 221, 225, 226, 230, 
	278, 222, 278, 223, 278, 224, 278, 278, 
	278, 278, 278, 227, 278, 228, 278, 229, 
	278, 278, 278, 278, 278, 280, 285, 280, 
	280, 285, 284, 231, 231, 232, 280, 233, 
	233, 234, 233, 235, 233, 233, 238, 239, 
	233, 233, 233, 0, 0, 1, 233, 233, 
	233, 233, 236, 233, 237, 233, 233, 237, 
	236, 2, 6, 14, 21, 26, 33, 233, 
	39, 233, 233, 233, 233, 240, 233, 241, 
	233, 233, 241, 240, 242, 243, 244, 245, 
	247, 250, 251, 253, 255, 257, 261, 263, 
	268, 271, 273, 242, 243, 243, 242, 243, 
	243, 242, 242, 41, 246, 242, 248, 242, 
	242, 242, 249, 249, 242, 242, 242, 249, 
	242, 62, 87, 93, 94, 100, 101, 108, 
	113, 120, 122, 242, 123, 242, 252, 242, 
	130, 242, 254, 242, 138, 242, 256, 242, 
	146, 144, 242, 242, 242, 242, 258, 242, 
	259, 242, 242, 259, 258, 260, 242, 153, 
	242, 262, 242, 159, 167, 242, 165, 264, 
	242, 265, 242, 266, 242, 267, 242, 176, 
	242, 182, 269, 242, 270, 242, 184, 242, 
	272, 242, 189, 242, 274, 275, 274, 192, 
	274, 276, 276, 276, 276, 277, 276, 197, 
	276, 278, 279, 278, 205, 220, 278, 280, 
	281, 282, 283, 280, 281, 281, 280, 281, 
	281, 280, 231, 231, 232, 280, 280, 280, 
	280, 284, 280, 285, 280, 280, 285, 284, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	274, 274, 274, 274, 274, 276, 276, 276, 
	276, 276, 276, 276, 276, 278, 278, 278, 
	278, 278, 278, 278, 278, 278, 278, 278, 
	278, 278, 278, 278, 278, 278, 278, 278, 
	278, 278, 278, 278, 278, 278, 278, 280, 
	280, 233, 233, 233, 233, 233, 233, 233, 
	233, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	242, 242, 242, 242, 242, 242, 242, 242, 
	274, 276, 278, 280, 280, 280, 280, 280, 
	0
};

static const unsigned char _dtext_trans_actions[] = {
	169, 5, 169, 169, 5, 5, 3, 3, 
	0, 169, 0, 169, 0, 169, 0, 169, 
	143, 169, 0, 169, 0, 169, 0, 169, 
	0, 169, 0, 169, 0, 145, 169, 169, 
	1, 204, 0, 0, 169, 0, 169, 0, 
	169, 0, 169, 0, 169, 0, 169, 147, 
	169, 0, 169, 0, 169, 0, 169, 0, 
	169, 139, 169, 0, 169, 0, 169, 0, 
	169, 0, 169, 0, 169, 0, 169, 141, 
	169, 0, 0, 169, 0, 169, 0, 169, 
	0, 169, 149, 169, 151, 169, 3, 169, 
	169, 5, 169, 169, 5, 5, 3, 0, 
	0, 73, 0, 5, 73, 5, 73, 0, 
	73, 0, 73, 0, 73, 0, 0, 73, 
	0, 73, 0, 73, 0, 73, 207, 0, 
	73, 0, 73, 0, 73, 0, 73, 0, 
	73, 0, 0, 73, 0, 73, 0, 73, 
	0, 73, 0, 73, 0, 0, 0, 0, 
	0, 0, 0, 73, 25, 73, 0, 73, 
	0, 73, 0, 73, 0, 73, 0, 73, 
	53, 73, 29, 73, 0, 73, 0, 73, 
	0, 73, 0, 73, 45, 73, 33, 0, 
	73, 0, 73, 0, 73, 0, 73, 0, 
	73, 0, 73, 49, 73, 0, 0, 73, 
	57, 73, 41, 73, 37, 73, 73, 73, 
	1, 3, 3, 0, 19, 73, 73, 5, 
	7, 0, 21, 73, 23, 73, 0, 73, 
	0, 73, 0, 73, 0, 73, 0, 73, 
	51, 73, 27, 73, 0, 73, 0, 73, 
	0, 73, 0, 73, 0, 73, 0, 73, 
	55, 73, 0, 73, 0, 73, 0, 73, 
	0, 73, 43, 73, 31, 0, 73, 0, 
	73, 0, 73, 0, 73, 0, 73, 0, 
	73, 47, 73, 0, 73, 39, 73, 35, 
	73, 0, 73, 0, 73, 0, 73, 0, 
	73, 0, 73, 0, 73, 1, 73, 0, 
	73, 0, 73, 0, 73, 0, 73, 0, 
	73, 0, 73, 0, 73, 1, 73, 0, 
	73, 0, 73, 0, 73, 0, 73, 0, 
	73, 1, 73, 3, 73, 73, 5, 73, 
	73, 5, 5, 0, 73, 0, 73, 0, 
	0, 73, 0, 73, 0, 73, 0, 73, 
	0, 73, 0, 73, 0, 73, 0, 73, 
	0, 73, 0, 73, 1, 73, 0, 73, 
	0, 73, 0, 73, 0, 73, 0, 73, 
	231, 73, 0, 71, 5, 71, 0, 0, 
	73, 0, 73, 0, 73, 0, 73, 1, 
	73, 0, 73, 0, 73, 0, 73, 1, 
	73, 0, 73, 0, 73, 0, 73, 0, 
	73, 0, 73, 231, 73, 0, 69, 5, 
	69, 0, 73, 0, 73, 0, 73, 0, 
	73, 1, 73, 73, 1, 3, 0, 17, 
	73, 0, 85, 0, 85, 0, 85, 0, 
	85, 77, 85, 0, 101, 0, 101, 0, 
	101, 0, 101, 0, 101, 0, 101, 0, 
	101, 87, 101, 0, 125, 0, 0, 0, 
	0, 125, 0, 125, 0, 125, 0, 125, 
	117, 125, 0, 125, 0, 125, 0, 125, 
	109, 125, 0, 125, 0, 125, 0, 125, 
	105, 125, 113, 125, 0, 0, 0, 0, 
	125, 0, 125, 0, 125, 0, 125, 107, 
	125, 115, 125, 0, 125, 0, 125, 0, 
	125, 103, 125, 111, 125, 135, 5, 135, 
	135, 5, 5, 3, 3, 0, 135, 159, 
	161, 0, 153, 231, 155, 157, 15, 15, 
	163, 161, 165, 3, 3, 0, 167, 228, 
	228, 228, 0, 228, 5, 228, 228, 5, 
	5, 0, 0, 0, 0, 0, 0, 167, 
	1, 167, 225, 225, 225, 0, 225, 5, 
	225, 225, 5, 5, 59, 243, 0, 15, 
	9, 15, 15, 15, 15, 15, 15, 15, 
	15, 15, 15, 61, 240, 240, 75, 240, 
	240, 65, 67, 1, 0, 216, 1, 67, 
	252, 252, 234, 237, 198, 252, 252, 237, 
	201, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 67, 0, 67, 0, 189, 
	0, 67, 0, 180, 0, 67, 0, 174, 
	0, 1, 67, 219, 219, 219, 0, 219, 
	5, 219, 219, 5, 5, 0, 63, 0, 
	67, 0, 192, 0, 0, 67, 3, 15, 
	195, 0, 213, 0, 183, 0, 171, 0, 
	67, 3, 15, 177, 0, 210, 0, 67, 
	0, 186, 0, 67, 79, 15, 81, 0, 
	83, 95, 89, 91, 93, 15, 97, 0, 
	99, 119, 15, 121, 0, 0, 123, 127, 
	249, 0, 231, 129, 246, 246, 137, 246, 
	246, 131, 3, 3, 0, 133, 222, 222, 
	222, 0, 222, 5, 222, 222, 5, 5, 
	169, 169, 169, 169, 169, 169, 169, 169, 
	169, 169, 169, 169, 169, 169, 169, 169, 
	169, 169, 169, 169, 169, 169, 169, 169, 
	169, 169, 169, 169, 169, 169, 169, 169, 
	169, 169, 169, 169, 169, 169, 169, 169, 
	169, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 71, 71, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 69, 69, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	85, 85, 85, 85, 85, 101, 101, 101, 
	101, 101, 101, 101, 101, 125, 125, 125, 
	125, 125, 125, 125, 125, 125, 125, 125, 
	125, 125, 125, 125, 125, 125, 125, 125, 
	125, 125, 125, 125, 125, 125, 125, 135, 
	135, 165, 167, 228, 228, 167, 167, 225, 
	225, 75, 65, 67, 216, 67, 198, 201, 
	67, 67, 189, 67, 180, 67, 174, 67, 
	219, 219, 63, 67, 192, 67, 195, 213, 
	183, 171, 67, 177, 210, 67, 186, 67, 
	83, 99, 123, 137, 131, 133, 222, 222, 
	0
};

static const unsigned char _dtext_to_state_actions[] = {
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 11, 0, 0, 0, 0, 0, 0, 
	0, 0, 11, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 11, 0, 11, 0, 11, 0, 
	11, 0, 0, 0, 0, 0
};

static const unsigned char _dtext_from_state_actions[] = {
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 13, 0, 0, 0, 0, 0, 0, 
	0, 0, 13, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 13, 0, 13, 0, 13, 0, 
	13, 0, 0, 0, 0, 0
};

static const short _dtext_eof_trans[] = {
	745, 745, 745, 745, 745, 745, 745, 745, 
	745, 745, 745, 745, 745, 745, 745, 745, 
	745, 745, 745, 745, 745, 745, 745, 745, 
	745, 745, 745, 745, 745, 745, 745, 745, 
	745, 745, 745, 745, 745, 745, 745, 745, 
	745, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 871, 871, 896, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	896, 896, 896, 896, 896, 896, 888, 888, 
	896, 896, 896, 896, 896, 896, 896, 896, 
	901, 901, 901, 901, 901, 909, 909, 909, 
	909, 909, 909, 909, 909, 935, 935, 935, 
	935, 935, 935, 935, 935, 935, 935, 935, 
	935, 935, 935, 935, 935, 935, 935, 935, 
	935, 935, 935, 935, 935, 935, 935, 937, 
	937, 0, 938, 943, 941, 941, 943, 943, 
	945, 945, 0, 946, 947, 976, 949, 976, 
	951, 952, 976, 976, 955, 976, 957, 976, 
	959, 976, 962, 962, 963, 976, 965, 976, 
	967, 968, 969, 970, 976, 972, 973, 976, 
	975, 976, 0, 977, 0, 978, 0, 979, 
	0, 980, 981, 982, 984, 984
};

static const int dtext_start = 233;
static const int dtext_first_final = 233;
static const int dtext_error = -1;

static const int dtext_en_inline = 242;
static const int dtext_en_code = 274;
static const int dtext_en_nodtext = 276;
static const int dtext_en_table = 278;
static const int dtext_en_list = 280;
static const int dtext_en_main = 233;


#line 767 "ext/dtext/dtext.rl"

static inline void underscore_string(char * str, size_t len) {
  for (size_t i=0; i<len; ++i) {
    if (str[i] == ' ') {
      str[i] = '_';
    }
  }
}

static inline void append(StateMachine * sm, const char * s) {
  sm->output = g_string_append(sm->output, s);
}

static inline void append_c(StateMachine * sm, char s) {
  sm->output = g_string_append_c(sm->output, s);
}

static inline void append_segment(StateMachine * sm, const char * a, const char * b) {
  sm->output = g_string_append_len(sm->output, a, b - a + 1);
}

static inline void append_segment_uri_escaped(StateMachine * sm, const char * a, const char * b) {
  GString * segment = g_string_new_len(a, b - a + 1);
  sm->output = g_string_append_uri_escaped(sm->output, segment->str, ":/?&=", TRUE);
  g_string_free(segment, TRUE);
}

static inline void append_segment_html_escaped(StateMachine * sm, const char * a, const char * b) {
  gchar * segment = g_markup_escape_text(a, b - a + 1);
  sm->output = g_string_append(sm->output, segment);
  g_free(segment);
}

static inline void append_block(StateMachine * sm, const char * s) {
  if (sm->f_inline) {
    sm->output = g_string_append_c(sm->output, ' ');
  } else {
    sm->output = g_string_append(sm->output, s);
  }
}

static inline void dstack_push(StateMachine * sm, const int * element) {
  g_queue_push_tail(sm->dstack, (gpointer)element);
}

static inline int * dstack_pop(StateMachine * sm) {
  return g_queue_pop_tail(sm->dstack);
}

static inline int * dstack_peek(StateMachine * sm) {
  return g_queue_peek_tail(sm->dstack);
}

static inline bool dstack_check(StateMachine * sm, int expected_element) {
  int * top = dstack_peek(sm);
  return top && *top == expected_element;
}

static void dstack_print_element(gpointer data, gpointer user_data) {
  printf("%i\n", *(int *)data);
}

static void dstack_dump(StateMachine * sm) {
  g_queue_foreach(sm->dstack, dstack_print_element, NULL);
}

static void dstack_close(StateMachine * sm) {
  while (dstack_peek(sm) != NULL) {
    int * top = dstack_pop(sm);

    switch (*top) {
      case BLOCK_P:
        append_block(sm, "</p>\n");
        break;

      case INLINE_SPOILER:
        append(sm, "</span>");
        break;

      case BLOCK_SPOILER:
        append_block(sm, "</div>");
        break;

      case BLOCK_QUOTE:
        append_block(sm, "</blockquote>");
        break;

      case BLOCK_EXPAND:
        append_block(sm, "</div></div>");
        break;

      case BLOCK_NODTEXT:
        append_block(sm, "</p>\n");
        break;

      case BLOCK_CODE:
        append_block(sm, "</pre>");
        break;

      case BLOCK_TD:
        append_block(sm, "</td>");
        break;

      case INLINE_NODTEXT:
        break;

      case INLINE_B:
        append(sm, "</strong>");
        break;

      case INLINE_I:
        append(sm, "</em>");
        break;

      case INLINE_U:
        append(sm, "</u>");
        break;

      case INLINE_S:
        append(sm, "</s>");
        break;

      case INLINE_TN:
        append(sm, "</span>");
        break;

      case BLOCK_TN:
        append_block(sm, "</p>\n");
        break;

      case BLOCK_TABLE:
        append_block(sm, "</table>");
        break;

      case BLOCK_THEAD:
        append_block(sm, "</thead>");
        break;

      case BLOCK_TBODY:
        append_block(sm, "</tbody>");
        break;

      case BLOCK_TR:
        append_block(sm, "</tr>");
        break;

      case BLOCK_UL:
        append_block(sm, "</ul>\n");
        break;

      case BLOCK_LI:
        append_block(sm, "</li>\n");
        break;
    }
  }
}

static void init_machine(StateMachine * sm, VALUE input) {
  sm->p = RSTRING_PTR(input);
  sm->pe = sm->p + RSTRING_LEN(input);
  sm->eof = sm->pe;
  sm->ts = NULL;
  sm->te = NULL;
  sm->cs = 0;
  sm->act = 0;
  sm->top = 0;
  size_t output_length = RSTRING_LEN(input);
  if (output_length < (INT16_MAX / 2)) {
    output_length *= 2;
  }
  sm->output = g_string_sized_new(output_length);
  sm->a1 = NULL;
  sm->a2 = NULL;
  sm->b1 = NULL;
  sm->b2 = NULL;
  sm->f_inline = false;
  sm->boundary = false;
  sm->stack = g_array_sized_new(FALSE, TRUE, sizeof(int), 16);
  sm->dstack = g_queue_new();
  sm->list_stack = g_queue_new();
  sm->list_nest = 0;
  sm->list_mode = false;
}

static void free_machine(StateMachine * sm) {
  g_string_free(sm->output, TRUE);
  g_array_free(sm->stack, FALSE);
  g_queue_free(sm->dstack);
  g_queue_free(sm->list_stack);
  g_free(sm);
}

static VALUE parse(VALUE self, VALUE input) {
  StateMachine * sm = (StateMachine *)g_malloc0(sizeof(StateMachine));
  input = rb_str_cat(input, "\0", 1);
  init_machine(sm, input);

  
#line 897 "ext/dtext/dtext.c"
	{
	 sm->cs = dtext_start;
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 965 "ext/dtext/dtext.rl"
  
#line 908 "ext/dtext/dtext.c"
	{
	int _klen;
	unsigned int _trans;
	const char *_acts;
	unsigned int _nacts;
	const char *_keys;

	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
_resume:
	_acts = _dtext_actions + _dtext_from_state_actions[ sm->cs];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 ) {
		switch ( *_acts++ ) {
	case 7:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
	break;
#line 927 "ext/dtext/dtext.c"
		}
	}

	_keys = _dtext_trans_keys + _dtext_key_offsets[ sm->cs];
	_trans = _dtext_index_offsets[ sm->cs];

	_klen = _dtext_single_lengths[ sm->cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + _klen - 1;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( (*( sm->p)) < *_mid )
				_upper = _mid - 1;
			else if ( (*( sm->p)) > *_mid )
				_lower = _mid + 1;
			else {
				_trans += (unsigned int)(_mid - _keys);
				goto _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _dtext_range_lengths[ sm->cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + (_klen<<1) - 2;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( (*( sm->p)) < _mid[0] )
				_upper = _mid - 2;
			else if ( (*( sm->p)) > _mid[1] )
				_lower = _mid + 2;
			else {
				_trans += (unsigned int)((_mid - _keys)>>1);
				goto _match;
			}
		}
		_trans += _klen;
	}

_match:
_eof_trans:
	 sm->cs = _dtext_trans_targs[_trans];

	if ( _dtext_trans_actions[_trans] == 0 )
		goto _again;

	_acts = _dtext_actions + _dtext_trans_actions[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
	{
		switch ( *_acts++ )
		{
	case 0:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	break;
	case 1:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	break;
	case 2:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	break;
	case 3:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
	break;
	case 4:
#line 106 "ext/dtext/dtext.rl"
	{sm->boundary = false;}
	break;
	case 5:
#line 106 "ext/dtext/dtext.rl"
	{sm->boundary = true;}
	break;
	case 8:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	break;
	case 9:
#line 291 "ext/dtext/dtext.rl"
	{( sm->act) = 18;}
	break;
	case 10:
#line 295 "ext/dtext/dtext.rl"
	{( sm->act) = 19;}
	break;
	case 11:
#line 464 "ext/dtext/dtext.rl"
	{( sm->act) = 40;}
	break;
	case 12:
#line 470 "ext/dtext/dtext.rl"
	{( sm->act) = 41;}
	break;
	case 13:
#line 232 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a rel=\"nofollow\" href=\"/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 14:
#line 240 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    GString * segment = g_string_new_len(sm->a1, sm->a2 - sm->a1 + 1);
    underscore_string(segment->str, segment->len);

    append(sm, "<a href=\"/wiki_pages/show_or_new?title=");
    append_segment_uri_escaped(sm, segment->str, segment->str + segment->len - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");

    g_string_free(segment, TRUE);
  }}
	break;
	case 15:
#line 253 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    GString * segment = g_string_new_len(sm->a1, sm->a2 - sm->a1 + 1);
    underscore_string(segment->str, segment->len);

    append(sm, "<a href=\"/wiki_pages/show_or_new?title=");
    append_segment_uri_escaped(sm, segment->str, segment->str + segment->len - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->b1, sm->b2);
    append(sm, "</a>");

    g_string_free(segment, TRUE);
  }}
	break;
	case 16:
#line 274 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a rel=\"nofollow\" href=\"");
    append_segment_uri_escaped(sm, sm->b1, sm->b2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 17:
#line 295 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a rel=\"nofollow\" href=\"/users?name=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2);
    append(sm, "\">@");
    append_segment_html_escaped(sm, sm->a2, sm->a2);
    append(sm, "</a>");
    if (sm->boundary) {
      append_c(sm, (*( sm->p)));
      sm->boundary = false;
    }
  }}
	break;
	case 18:
#line 307 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_B);
    append(sm, "<strong>");
  }}
	break;
	case 19:
#line 312 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_B)) {
      dstack_pop(sm);
      append(sm, "</strong>");
    } else {
      append(sm, "[/b]");
    }
  }}
	break;
	case 20:
#line 321 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_I);
    append(sm, "<em>");
  }}
	break;
	case 21:
#line 326 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_I)) {
      dstack_pop(sm);
      append(sm, "</em>");
    } else {
      append(sm, "[/i]");
    }
  }}
	break;
	case 22:
#line 335 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_S);
    append(sm, "<s>");
  }}
	break;
	case 23:
#line 340 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_S)) {
      dstack_pop(sm);
      append(sm, "</s>");
    } else {
      append(sm, "[/s]");
    }
  }}
	break;
	case 24:
#line 349 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_U);
    append(sm, "<u>");
  }}
	break;
	case 25:
#line 354 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_U)) {
      dstack_pop(sm);
      append(sm, "</u>");
    } else {
      append(sm, "[/u]");
    }
  }}
	break;
	case 26:
#line 363 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_TN);
    append(sm, "<span class=\"tn\">");
  }}
	break;
	case 27:
#line 368 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TN)) {
      dstack_pop(sm);
      append(sm, "</p>\n");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else if (dstack_check(sm, INLINE_TN)) {
      dstack_pop(sm);
      append(sm, "</span>");
    } else {
      append(sm, "[/tn]");
    }
  }}
	break;
	case 28:
#line 389 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
    {( sm->p) = (( sm->p - 7))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 29:
#line 395 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_P)) {
      dstack_pop(sm);
      append_block(sm, "</p>\n");
    } 

    if (dstack_check(sm, BLOCK_QUOTE)) {
      dstack_pop(sm);
      append_block(sm, "\n</blockquote>\n\n");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/quote]");
    }
  }}
	break;
	case 30:
#line 410 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_SPOILER);
    append(sm, "<span class=\"spoiler\">");
  }}
	break;
	case 31:
#line 415 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_SPOILER)) {
      dstack_pop(sm);
      append(sm, "</span>");
    } else if (dstack_check(sm, BLOCK_SPOILER)) {
      dstack_pop(sm);
      append_block(sm, "\n</p></div>\n\n");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/spoiler]");
    }
  }}
	break;
	case 32:
#line 428 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
    {( sm->p) = (((sm->p - 8)))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 33:
#line 434 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_EXPAND)) {
      append_block(sm, "\n</div></div>\n\n");
      dstack_pop(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/expand]");
    }
  }}
	break;
	case 34:
#line 444 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_NODTEXT);
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 276; goto _again;}}
  }}
	break;
	case 35:
#line 449 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TD)) {
      dstack_pop(sm);
      append_block(sm, "\n</td>\n");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/td]");
    }
  }}
	break;
	case 36:
#line 459 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 37:
#line 483 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 38:
#line 136 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/posts/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">post #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 39:
#line 144 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_posts/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">forum #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 40:
#line 152 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 41:
#line 160 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "?page=");
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "/p");
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "</a>");
  }}
	break;
	case 42:
#line 172 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/comments/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">comment #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 43:
#line 180 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/pools/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pool #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 44:
#line 188 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/users/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">user #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 45:
#line 196 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/artists/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">artist #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 46:
#line 204 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"https://github.com/r888888888/danbooru/issues/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">issue #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 47:
#line 212 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 48:
#line 220 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "&page=");
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "/p");
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "</a>");
  }}
	break;
	case 49:
#line 266 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a rel=\"nofollow\" href=\"");
    append_segment_uri_escaped(sm, sm->b1, sm->b2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 50:
#line 282 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a rel=\"nofollow\" href=\"");
    append_segment_uri_escaped(sm, sm->ts, sm->te - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
    append(sm, "</a>");
  }}
	break;
	case 51:
#line 295 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a rel=\"nofollow\" href=\"/users?name=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2);
    append(sm, "\">@");
    append_segment_html_escaped(sm, sm->a2, sm->a2);
    append(sm, "</a>");
    if (sm->boundary) {
      append_c(sm, (*( sm->p)));
      sm->boundary = false;
    }
  }}
	break;
	case 52:
#line 383 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close(sm);
    {( sm->p) = (( sm->a1 - 1))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 53:
#line 470 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (sm->list_mode) {
      if (dstack_check(sm, BLOCK_LI)) {
        dstack_pop(sm);
        append_block(sm, "</li>\n");
      }
      ( sm->p)--;
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "<br>\n");
    }
  }}
	break;
	case 54:
#line 483 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 55:
#line 152 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 56:
#line 212 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 57:
#line 483 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 58:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 18:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment(sm, sm->ts, sm->te - 1);
  }
	break;
	case 19:
	{{( sm->p) = ((( sm->te)))-1;}
    append(sm, "<a rel=\"nofollow\" href=\"/users?name=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2);
    append(sm, "\">@");
    append_segment_html_escaped(sm, sm->a2, sm->a2);
    append(sm, "</a>");
    if (sm->boundary) {
      append_c(sm, (*( sm->p)));
      sm->boundary = false;
    }
  }
	break;
	case 40:
	{{( sm->p) = ((( sm->te)))-1;}
    dstack_close(sm);
    sm->list_mode = false;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }
	break;
	case 41:
	{{( sm->p) = ((( sm->te)))-1;}
    if (sm->list_mode) {
      if (dstack_check(sm, BLOCK_LI)) {
        dstack_pop(sm);
        append_block(sm, "</li>\n");
      }
      ( sm->p)--;
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "<br>\n");
    }
  }
	break;
	}
	}
	break;
	case 59:
#line 489 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_CODE)) {
      dstack_pop(sm);
      append_block(sm, "\n</pre>\n\n");
    } else {
      append(sm, "[/code]");
    }
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 60:
#line 499 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 61:
#line 504 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 62:
#line 504 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 63:
#line 504 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 64:
#line 510 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_NODTEXT)) {
      dstack_pop(sm);
      append_block(sm, "\n</p>\n\n");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else if (dstack_check(sm, INLINE_NODTEXT)) {
      dstack_pop(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/nodtext]");
    }
  }}
	break;
	case 65:
#line 523 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&amp;");
  }}
	break;
	case 66:
#line 527 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&lt;");
  }}
	break;
	case 67:
#line 531 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&gt;");
  }}
	break;
	case 68:
#line 535 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 69:
#line 540 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 70:
#line 540 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 71:
#line 540 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 72:
#line 546 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_THEAD);
    append_block(sm, "\n<thead>\n");
  }}
	break;
	case 73:
#line 551 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_THEAD)) {
      dstack_pop(sm);
      append_block(sm, "\n</thead>\n");
    } else {
      append(sm, "[/thead]");
    }
  }}
	break;
	case 74:
#line 560 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TBODY);
    append_block(sm, "\n<tbody>\n");
  }}
	break;
	case 75:
#line 565 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TBODY)) {
      dstack_pop(sm);
      append_block(sm, "\n</tbody>\n");
    } else {
      append(sm, "[/tbody]");
    }
  }}
	break;
	case 76:
#line 574 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TR);
    append_block(sm, "\n<tr>\n");
  }}
	break;
	case 77:
#line 579 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TR)) {
      dstack_pop(sm);
      append_block(sm, "\n</tr>\n");
    } else {
      append(sm, "[/tr]");
    }
  }}
	break;
	case 78:
#line 588 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TD);
    append_block(sm, "\n<td>\n");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 242; goto _again;}}
  }}
	break;
	case 79:
#line 594 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TABLE)) {
      dstack_pop(sm);
      append_block(sm, "\n</table>\n\n");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/table]");
    }
  }}
	break;
	case 80:
#line 604 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 81:
#line 609 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	break;
	case 82:
#line 609 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	break;
	case 83:
#line 609 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	case 84:
#line 640 "ext/dtext/dtext.rl"
	{( sm->act) = 63;}
	break;
	case 85:
#line 645 "ext/dtext/dtext.rl"
	{( sm->act) = 64;}
	break;
	case 86:
#line 640 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 87:
#line 647 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 88:
#line 613 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    int prev_nest = sm->list_nest;
    sm->list_mode = true;
    sm->list_nest = sm->a2 - sm->a1;
    {( sm->p) = (( sm->b1))-1;}

    if (sm->list_nest > prev_nest) {
      for (int i=prev_nest; i<sm->list_nest; ++i) {
        append_block(sm, "<ul>\n");
        dstack_push(sm, &BLOCK_UL);
      }
    } else if (sm->list_nest < prev_nest) {
      for (int i=sm->list_nest; i<prev_nest; ++i) {
        if (dstack_check(sm, BLOCK_UL)) {
          dstack_pop(sm);
          append_block(sm, "</ul>\n");
        }
      }
    }

    append_block(sm, "<li>");
    dstack_push(sm, &BLOCK_LI);

    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 242; goto _again;}}
  }}
	break;
	case 89:
#line 645 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	break;
	case 90:
#line 647 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 91:
#line 647 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_close(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 92:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 63:
	{{( sm->p) = ((( sm->te)))-1;}
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }
	break;
	default:
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	}
	}
	break;
	case 93:
#line 671 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_QUOTE);
    append_block(sm, "\n\n<blockquote>\n");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 242; goto _again;}}
  }}
	break;
	case 94:
#line 677 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_SPOILER);
    append_block(sm, "\n\n<div class=\"spoiler\"><p>\n");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 242; goto _again;}}
  }}
	break;
	case 95:
#line 683 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_CODE);
    append_block(sm, "\n\n<pre>\n");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 274; goto _again;}}
  }}
	break;
	case 96:
#line 689 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "\n\n<div class=\"expandable\"><div class=\"expandable-header\">");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">\n");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 242; goto _again;}}
  }}
	break;
	case 97:
#line 697 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "\n\n<div class=\"expandable\"><div class=\"expandable-header\">");
    append(sm, "<span>");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</span>");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">\n");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 242; goto _again;}}
  }}
	break;
	case 98:
#line 708 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_NODTEXT);
    append_block(sm, "\n<p>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 276; goto _again;}}
  }}
	break;
	case 99:
#line 714 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TABLE);
    append_block(sm, "\n\n<table class=\"striped\">");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 278; goto _again;}}
  }}
	break;
	case 100:
#line 720 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TN);
    append_block(sm, "\n\n<p class=\"tn\">");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 242; goto _again;}}
  }}
	break;
	case 101:
#line 734 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&amp;");
  }}
	break;
	case 102:
#line 738 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&lt;");
  }}
	break;
	case 103:
#line 742 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&gt;");
  }}
	break;
	case 104:
#line 746 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
  }}
	break;
	case 105:
#line 750 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	break;
	case 106:
#line 752 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
      dstack_push(sm, &BLOCK_P);
      append_block(sm, "\n<p>");
    }

    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 242; goto _again;}}
  }}
	break;
	case 107:
#line 655 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;

    if (sm->f_inline) {
      header = '6';
    }

    append(sm, "\n\n<h");
    append_c(sm, header);
    append_c(sm, '>');
    append_segment(sm, sm->b1, sm->b2 - 1);
    append(sm, "</h");
    append_c(sm, header);
    append(sm, ">\n\n");
  }}
	break;
	case 108:
#line 726 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    sm->list_nest = 0;
    sm->list_mode = true;
    dstack_close(sm);
    {( sm->p) = (( sm->ts))-1;}
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 280; goto _again;}}
  }}
	break;
	case 109:
#line 750 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	break;
	case 110:
#line 752 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
      dstack_push(sm, &BLOCK_P);
      append_block(sm, "\n<p>");
    }

    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 242; goto _again;}}
  }}
	break;
	case 111:
#line 752 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
      dstack_push(sm, &BLOCK_P);
      append_block(sm, "\n<p>");
    }

    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 242; goto _again;}}
  }}
	break;
#line 2162 "ext/dtext/dtext.c"
		}
	}

_again:
	_acts = _dtext_actions + _dtext_to_state_actions[ sm->cs];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 ) {
		switch ( *_acts++ ) {
	case 6:
#line 1 "NONE"
	{( sm->ts) = 0;}
	break;
#line 2175 "ext/dtext/dtext.c"
		}
	}

	if ( ++( sm->p) != ( sm->pe) )
		goto _resume;
	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	if ( _dtext_eof_trans[ sm->cs] > 0 ) {
		_trans = _dtext_eof_trans[ sm->cs] - 1;
		goto _eof_trans;
	}
	}

	}

#line 966 "ext/dtext/dtext.rl"

  dstack_close(sm);

  VALUE ret = rb_str_new(sm->output->str, sm->output->len);
  free_machine(sm);

  return ret;
}

void Init_dtext() {
  VALUE mDTextRagel = rb_define_module("DTextRagel");
  rb_define_singleton_method(mDTextRagel, "parse", parse, 1);
}
