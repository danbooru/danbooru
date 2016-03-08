
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
  GString * output;
  GArray * stack;
  GQueue * dstack;
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


#line 701 "ext/dtext/dtext.rl"



#line 57 "ext/dtext/dtext.c"
static const char _dtext_actions[] = {
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 6, 1, 7, 1, 
	8, 1, 15, 1, 16, 1, 17, 1, 
	20, 1, 21, 1, 22, 1, 23, 1, 
	24, 1, 25, 1, 26, 1, 27, 1, 
	28, 1, 29, 1, 30, 1, 31, 1, 
	32, 1, 33, 1, 34, 1, 35, 1, 
	36, 1, 37, 1, 38, 1, 39, 1, 
	52, 1, 54, 1, 55, 1, 56, 1, 
	57, 1, 58, 1, 59, 1, 60, 1, 
	61, 1, 62, 1, 63, 1, 64, 1, 
	65, 1, 66, 1, 67, 1, 68, 1, 
	69, 1, 70, 1, 71, 1, 72, 1, 
	73, 1, 74, 1, 75, 1, 76, 1, 
	77, 1, 78, 1, 79, 1, 80, 1, 
	81, 1, 82, 1, 83, 1, 84, 1, 
	85, 1, 88, 1, 89, 1, 90, 1, 
	91, 1, 93, 1, 94, 1, 95, 1, 
	96, 1, 97, 1, 98, 1, 99, 1, 
	100, 1, 101, 1, 102, 1, 104, 1, 
	105, 1, 106, 1, 107, 2, 1, 40, 
	2, 1, 41, 2, 1, 42, 2, 1, 
	44, 2, 1, 45, 2, 1, 46, 2, 
	1, 47, 2, 1, 48, 2, 1, 49, 
	2, 1, 53, 2, 1, 60, 2, 1, 
	92, 2, 1, 103, 2, 3, 18, 2, 
	3, 43, 2, 3, 50, 2, 3, 51, 
	2, 8, 0, 2, 8, 9, 2, 8, 
	10, 2, 8, 11, 2, 8, 12, 2, 
	8, 13, 2, 8, 14, 2, 8, 86, 
	2, 8, 87, 3, 1, 5, 19, 3, 
	8, 3, 11, 3, 8, 3, 86, 4, 
	8, 2, 3, 11, 4, 8, 2, 3, 
	86
};

static const short _dtext_key_offsets[] = {
	0, 1, 2, 3, 4, 5, 6, 7, 
	8, 9, 11, 12, 13, 14, 15, 16, 
	17, 18, 19, 20, 21, 22, 23, 24, 
	25, 26, 27, 28, 29, 30, 31, 32, 
	34, 35, 36, 37, 38, 39, 40, 44, 
	46, 50, 51, 52, 54, 55, 56, 57, 
	58, 60, 61, 62, 64, 67, 68, 69, 
	70, 71, 73, 74, 75, 77, 78, 85, 
	86, 87, 88, 89, 90, 91, 92, 93, 
	94, 95, 96, 97, 98, 100, 101, 102, 
	103, 104, 105, 106, 108, 109, 110, 111, 
	113, 115, 116, 117, 118, 119, 120, 121, 
	122, 123, 124, 125, 126, 127, 128, 129, 
	130, 131, 132, 133, 134, 135, 136, 137, 
	138, 139, 141, 142, 143, 144, 145, 146, 
	147, 148, 149, 150, 151, 152, 153, 154, 
	155, 156, 158, 159, 160, 161, 162, 163, 
	164, 165, 167, 168, 169, 170, 171, 172, 
	174, 175, 179, 181, 185, 186, 187, 189, 
	190, 191, 193, 194, 195, 196, 197, 198, 
	199, 201, 202, 203, 204, 205, 206, 208, 
	209, 211, 213, 214, 215, 216, 218, 219, 
	220, 221, 223, 224, 225, 226, 227, 228, 
	230, 231, 233, 234, 235, 236, 237, 239, 
	240, 241, 242, 243, 244, 245, 246, 247, 
	248, 249, 250, 251, 252, 253, 254, 255, 
	256, 260, 261, 262, 263, 264, 265, 266, 
	267, 268, 269, 270, 271, 272, 273, 277, 
	278, 279, 280, 281, 282, 283, 284, 285, 
	286, 287, 296, 297, 298, 304, 306, 308, 
	308, 309, 324, 326, 328, 329, 331, 333, 
	338, 342, 352, 353, 355, 356, 358, 359, 
	361, 364, 366, 366, 367, 369, 370, 372, 
	374, 377, 379, 381, 383, 384, 387, 389, 
	390, 392, 393, 395, 396, 401, 402, 404
};

static const char _dtext_trans_keys[] = {
	111, 100, 101, 93, 120, 112, 97, 110, 
	100, 61, 93, 93, 93, 111, 100, 116, 
	101, 120, 116, 93, 117, 111, 116, 101, 
	93, 112, 111, 105, 108, 101, 114, 93, 
	97, 110, 98, 108, 101, 93, 93, 46, 
	9, 10, 13, 32, 10, 13, 9, 10, 
	13, 32, 34, 58, 91, 104, 104, 116, 
	116, 112, 58, 115, 47, 47, 33, 126, 
	93, 33, 126, 58, 116, 116, 112, 58, 
	115, 47, 47, 33, 126, 58, 98, 101, 
	105, 113, 115, 116, 117, 93, 120, 112, 
	97, 110, 100, 93, 93, 117, 111, 116, 
	101, 93, 93, 112, 111, 105, 108, 101, 
	114, 93, 100, 110, 93, 93, 93, 93, 
	124, 93, 124, 93, 93, 93, 93, 93, 
	120, 112, 97, 110, 100, 93, 93, 111, 
	100, 116, 101, 120, 116, 93, 117, 111, 
	116, 101, 93, 93, 112, 111, 105, 108, 
	101, 114, 93, 110, 93, 93, 116, 105, 
	115, 116, 32, 35, 48, 57, 109, 109, 
	101, 110, 116, 32, 35, 48, 57, 114, 
	117, 109, 32, 35, 48, 57, 46, 9, 
	10, 13, 32, 10, 13, 9, 10, 13, 
	32, 116, 112, 58, 115, 47, 47, 33, 
	126, 58, 115, 117, 101, 32, 35, 48, 
	57, 120, 105, 118, 32, 35, 48, 57, 
	112, 48, 57, 111, 115, 108, 32, 35, 
	48, 57, 116, 32, 35, 48, 57, 112, 
	105, 99, 32, 35, 48, 57, 112, 48, 
	57, 101, 114, 32, 35, 48, 57, 125, 
	125, 125, 99, 111, 100, 101, 93, 110, 
	111, 100, 116, 101, 120, 116, 93, 116, 
	97, 98, 104, 114, 98, 108, 101, 93, 
	111, 100, 121, 93, 101, 97, 100, 93, 
	93, 98, 100, 104, 114, 111, 100, 121, 
	93, 93, 101, 97, 100, 93, 93, 0, 
	10, 13, 38, 42, 60, 62, 91, 104, 
	10, 42, 99, 101, 110, 113, 115, 116, 
	49, 54, 10, 13, 10, 0, 10, 13, 
	34, 64, 91, 97, 99, 102, 104, 105, 
	112, 116, 117, 123, 10, 13, 10, 13, 
	34, 33, 126, 33, 126, 58, 63, 64, 
	33, 126, 58, 63, 33, 126, 47, 91, 
	98, 101, 105, 110, 113, 115, 116, 117, 
	114, 48, 57, 111, 48, 57, 111, 48, 
	57, 116, 49, 54, 10, 13, 10, 33, 
	126, 115, 48, 57, 105, 111, 47, 48, 
	57, 48, 57, 48, 57, 48, 57, 111, 
	47, 48, 57, 48, 57, 115, 48, 57, 
	123, 0, 91, 47, 0, 38, 60, 62, 
	91, 47, 0, 91, 47, 116, 0
};

static const char _dtext_single_lengths[] = {
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	1, 1, 1, 1, 1, 1, 4, 2, 
	4, 1, 1, 2, 1, 1, 1, 1, 
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
	1, 4, 2, 4, 1, 1, 2, 1, 
	1, 0, 1, 1, 1, 1, 1, 1, 
	0, 1, 1, 1, 1, 1, 0, 1, 
	0, 2, 1, 1, 1, 0, 1, 1, 
	1, 0, 1, 1, 1, 1, 1, 0, 
	1, 0, 1, 1, 1, 1, 0, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	4, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 4, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 9, 1, 1, 6, 0, 2, 0, 
	1, 15, 2, 2, 1, 0, 0, 3, 
	2, 10, 1, 0, 1, 0, 1, 0, 
	1, 2, 0, 1, 0, 1, 0, 2, 
	1, 0, 0, 0, 1, 1, 0, 1, 
	0, 1, 2, 1, 5, 1, 2, 2
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 1, 0, 
	1, 0, 0, 0, 0, 1, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 1, 
	0, 1, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 1, 1, 1, 
	1, 0, 0, 1, 0, 1, 0, 1, 
	1, 0, 0, 0, 1, 0, 1, 0, 
	1, 1, 1, 1, 0, 1, 1, 0, 
	1, 0, 0, 0, 0, 0, 0, 0
};

static const short _dtext_index_offsets[] = {
	0, 2, 4, 6, 8, 10, 12, 14, 
	16, 18, 21, 23, 25, 27, 29, 31, 
	33, 35, 37, 39, 41, 43, 45, 47, 
	49, 51, 53, 55, 57, 59, 61, 63, 
	66, 68, 70, 72, 74, 76, 78, 83, 
	86, 91, 93, 95, 98, 100, 102, 104, 
	106, 109, 111, 113, 115, 118, 120, 122, 
	124, 126, 129, 131, 133, 135, 137, 145, 
	147, 149, 151, 153, 155, 157, 159, 161, 
	163, 165, 167, 169, 171, 174, 176, 178, 
	180, 182, 184, 186, 189, 191, 193, 195, 
	198, 201, 203, 205, 207, 209, 211, 213, 
	215, 217, 219, 221, 223, 225, 227, 229, 
	231, 233, 235, 237, 239, 241, 243, 245, 
	247, 249, 252, 254, 256, 258, 260, 262, 
	264, 266, 268, 270, 272, 274, 276, 278, 
	280, 282, 284, 286, 288, 290, 292, 294, 
	296, 298, 300, 302, 304, 306, 308, 310, 
	312, 314, 319, 322, 327, 329, 331, 334, 
	336, 338, 340, 342, 344, 346, 348, 350, 
	352, 354, 356, 358, 360, 362, 364, 366, 
	368, 370, 373, 375, 377, 379, 381, 383, 
	385, 387, 389, 391, 393, 395, 397, 399, 
	401, 403, 405, 407, 409, 411, 413, 415, 
	417, 419, 421, 423, 425, 427, 429, 431, 
	433, 435, 437, 439, 441, 443, 445, 447, 
	449, 454, 456, 458, 460, 462, 464, 466, 
	468, 470, 472, 474, 476, 478, 480, 485, 
	487, 489, 491, 493, 495, 497, 499, 501, 
	503, 505, 515, 517, 519, 526, 528, 531, 
	532, 534, 550, 553, 556, 558, 560, 562, 
	567, 571, 582, 584, 586, 588, 590, 592, 
	594, 597, 600, 601, 603, 605, 607, 609, 
	612, 615, 617, 619, 621, 623, 626, 628, 
	630, 632, 634, 637, 639, 645, 647, 650
};

static const short _dtext_trans_targs[] = {
	1, 233, 2, 233, 3, 233, 233, 233, 
	5, 233, 6, 233, 7, 233, 8, 233, 
	9, 233, 10, 233, 233, 233, 11, 233, 
	11, 13, 233, 14, 233, 15, 233, 16, 
	233, 17, 233, 18, 233, 233, 233, 20, 
	233, 21, 233, 22, 233, 23, 233, 233, 
	233, 25, 233, 26, 233, 27, 233, 28, 
	233, 29, 233, 30, 233, 233, 233, 32, 
	36, 233, 33, 233, 34, 233, 35, 233, 
	233, 233, 233, 233, 38, 233, 40, 239, 
	240, 40, 39, 238, 238, 39, 40, 238, 
	238, 40, 39, 42, 41, 43, 241, 44, 
	54, 241, 45, 241, 46, 241, 47, 241, 
	48, 241, 49, 53, 241, 50, 241, 51, 
	241, 52, 241, 241, 52, 241, 49, 241, 
	55, 241, 56, 241, 57, 241, 58, 61, 
	241, 59, 241, 60, 241, 245, 241, 58, 
	241, 63, 64, 70, 71, 76, 83, 86, 
	241, 241, 241, 65, 241, 66, 241, 67, 
	241, 68, 241, 69, 241, 241, 241, 241, 
	241, 72, 241, 73, 241, 74, 241, 75, 
	241, 241, 241, 241, 77, 241, 78, 241, 
	79, 241, 80, 241, 81, 241, 82, 241, 
	241, 241, 84, 85, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 88, 89, 90, 
	88, 241, 241, 241, 91, 92, 91, 241, 
	241, 241, 241, 95, 241, 96, 241, 97, 
	241, 98, 241, 99, 241, 241, 241, 241, 
	241, 102, 241, 103, 241, 104, 241, 105, 
	241, 106, 241, 107, 241, 241, 241, 109, 
	241, 110, 241, 111, 241, 112, 241, 241, 
	241, 241, 114, 241, 115, 241, 116, 241, 
	117, 241, 118, 241, 119, 241, 241, 241, 
	121, 241, 241, 241, 241, 241, 124, 241, 
	125, 241, 126, 241, 127, 241, 128, 241, 
	129, 241, 251, 241, 131, 241, 132, 241, 
	133, 241, 134, 241, 135, 241, 136, 241, 
	137, 241, 253, 241, 139, 241, 140, 241, 
	141, 241, 142, 241, 143, 241, 255, 241, 
	145, 241, 147, 258, 259, 147, 146, 257, 
	257, 146, 147, 257, 257, 147, 146, 149, 
	241, 150, 241, 151, 154, 241, 152, 241, 
	153, 241, 260, 241, 151, 241, 156, 241, 
	157, 241, 158, 241, 159, 241, 160, 241, 
	262, 241, 162, 241, 163, 241, 164, 241, 
	165, 241, 166, 241, 264, 241, 168, 241, 
	265, 241, 170, 174, 241, 171, 241, 172, 
	241, 173, 241, 266, 241, 175, 241, 176, 
	241, 177, 241, 267, 241, 179, 241, 180, 
	241, 181, 241, 182, 241, 183, 241, 269, 
	241, 185, 241, 270, 241, 187, 241, 188, 
	241, 189, 241, 190, 241, 272, 241, 241, 
	192, 193, 192, 241, 241, 195, 274, 196, 
	274, 197, 274, 198, 274, 274, 274, 200, 
	276, 201, 276, 202, 276, 203, 276, 204, 
	276, 205, 276, 206, 276, 276, 276, 208, 
	278, 209, 213, 217, 221, 278, 210, 278, 
	211, 278, 212, 278, 278, 278, 214, 278, 
	215, 278, 216, 278, 278, 278, 218, 278, 
	219, 278, 220, 278, 278, 278, 278, 278, 
	223, 227, 228, 232, 278, 224, 278, 225, 
	278, 226, 278, 278, 278, 278, 278, 229, 
	278, 230, 278, 231, 278, 278, 278, 278, 
	278, 233, 233, 234, 233, 235, 233, 233, 
	236, 237, 233, 233, 233, 235, 233, 0, 
	4, 12, 19, 24, 31, 233, 37, 233, 
	238, 238, 39, 39, 239, 39, 241, 242, 
	243, 244, 246, 249, 250, 252, 254, 256, 
	261, 263, 268, 271, 273, 241, 242, 242, 
	241, 242, 242, 241, 241, 41, 245, 241, 
	247, 241, 241, 241, 248, 248, 241, 241, 
	241, 248, 241, 62, 87, 93, 94, 100, 
	101, 108, 113, 120, 122, 241, 123, 241, 
	251, 241, 130, 241, 253, 241, 138, 241, 
	255, 241, 148, 144, 241, 257, 257, 146, 
	146, 258, 146, 260, 241, 155, 241, 262, 
	241, 161, 169, 241, 167, 264, 241, 265, 
	241, 266, 241, 267, 241, 178, 241, 184, 
	269, 241, 270, 241, 186, 241, 272, 241, 
	191, 241, 274, 275, 274, 194, 274, 276, 
	276, 276, 276, 277, 276, 199, 276, 278, 
	279, 278, 207, 222, 278, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 274, 
	274, 274, 274, 274, 276, 276, 276, 276, 
	276, 276, 276, 276, 278, 278, 278, 278, 
	278, 278, 278, 278, 278, 278, 278, 278, 
	278, 278, 278, 278, 278, 278, 278, 278, 
	278, 278, 278, 278, 278, 278, 233, 233, 
	233, 233, 233, 233, 233, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 241, 241, 241, 
	241, 241, 241, 241, 241, 274, 276, 278, 
	0
};

static const short _dtext_trans_actions[] = {
	0, 161, 0, 161, 0, 161, 133, 161, 
	0, 161, 0, 161, 0, 161, 0, 161, 
	0, 161, 0, 135, 161, 161, 1, 198, 
	0, 0, 161, 0, 161, 0, 161, 0, 
	161, 0, 161, 0, 161, 137, 161, 0, 
	161, 0, 161, 0, 161, 0, 161, 129, 
	161, 0, 161, 0, 161, 0, 161, 0, 
	161, 0, 161, 0, 161, 131, 161, 0, 
	0, 161, 0, 161, 0, 161, 0, 161, 
	139, 161, 141, 161, 3, 161, 5, 260, 
	260, 5, 5, 251, 251, 0, 5, 260, 
	260, 5, 5, 3, 0, 0, 75, 0, 
	5, 75, 5, 75, 0, 75, 0, 75, 
	0, 75, 0, 0, 75, 0, 75, 0, 
	75, 0, 75, 204, 0, 75, 0, 75, 
	0, 75, 0, 75, 0, 75, 0, 0, 
	75, 0, 75, 0, 75, 0, 75, 0, 
	75, 0, 0, 0, 0, 0, 0, 0, 
	75, 25, 75, 0, 75, 0, 75, 0, 
	75, 0, 75, 0, 75, 53, 75, 29, 
	75, 0, 75, 0, 75, 0, 75, 0, 
	75, 45, 75, 33, 0, 75, 0, 75, 
	0, 75, 0, 75, 0, 75, 0, 75, 
	49, 75, 0, 0, 75, 57, 75, 41, 
	75, 37, 75, 75, 75, 1, 3, 3, 
	0, 19, 75, 75, 5, 7, 0, 21, 
	75, 23, 75, 0, 75, 0, 75, 0, 
	75, 0, 75, 0, 75, 51, 75, 27, 
	75, 0, 75, 0, 75, 0, 75, 0, 
	75, 0, 75, 0, 75, 55, 75, 0, 
	75, 0, 75, 0, 75, 0, 75, 43, 
	75, 31, 0, 75, 0, 75, 0, 75, 
	0, 75, 0, 75, 0, 75, 47, 75, 
	0, 75, 39, 75, 35, 75, 0, 75, 
	0, 75, 0, 75, 0, 75, 0, 75, 
	0, 75, 1, 75, 0, 75, 0, 75, 
	0, 75, 0, 75, 0, 75, 0, 75, 
	0, 75, 1, 75, 0, 75, 0, 75, 
	0, 75, 0, 75, 0, 75, 1, 75, 
	3, 75, 5, 255, 255, 5, 5, 247, 
	247, 0, 5, 255, 255, 5, 5, 0, 
	75, 0, 75, 0, 0, 75, 0, 75, 
	0, 75, 0, 75, 0, 75, 0, 75, 
	0, 75, 0, 75, 0, 75, 0, 75, 
	1, 75, 0, 75, 0, 75, 0, 75, 
	0, 75, 0, 75, 216, 75, 0, 73, 
	5, 73, 0, 0, 75, 0, 75, 0, 
	75, 0, 75, 1, 75, 0, 75, 0, 
	75, 0, 75, 1, 75, 0, 75, 0, 
	75, 0, 75, 0, 75, 0, 75, 216, 
	75, 0, 71, 5, 71, 0, 75, 0, 
	75, 0, 75, 0, 75, 1, 75, 75, 
	1, 3, 0, 17, 75, 0, 87, 0, 
	87, 0, 87, 0, 87, 79, 87, 0, 
	103, 0, 103, 0, 103, 0, 103, 0, 
	103, 0, 103, 0, 103, 89, 103, 0, 
	127, 0, 0, 0, 0, 127, 0, 127, 
	0, 127, 0, 127, 119, 127, 0, 127, 
	0, 127, 0, 127, 111, 127, 0, 127, 
	0, 127, 0, 127, 107, 127, 115, 127, 
	0, 0, 0, 0, 127, 0, 127, 0, 
	127, 0, 127, 109, 127, 117, 127, 0, 
	127, 0, 127, 0, 127, 105, 127, 113, 
	127, 149, 151, 0, 143, 1, 145, 147, 
	15, 240, 153, 151, 157, 0, 201, 0, 
	0, 0, 0, 0, 0, 159, 1, 159, 
	251, 251, 0, 0, 237, 0, 59, 231, 
	0, 15, 9, 15, 15, 15, 15, 234, 
	15, 15, 15, 15, 15, 61, 228, 228, 
	77, 228, 228, 67, 69, 1, 0, 213, 
	1, 69, 243, 243, 219, 222, 192, 243, 
	243, 222, 195, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 69, 0, 69, 
	0, 183, 0, 69, 0, 174, 0, 69, 
	0, 168, 0, 1, 69, 247, 247, 0, 
	0, 225, 0, 0, 63, 0, 69, 0, 
	186, 0, 0, 69, 3, 15, 189, 0, 
	210, 0, 177, 0, 165, 0, 69, 3, 
	15, 171, 0, 207, 0, 69, 0, 180, 
	0, 69, 81, 15, 83, 0, 85, 97, 
	91, 93, 95, 15, 99, 0, 101, 121, 
	15, 123, 0, 0, 125, 161, 161, 161, 
	161, 161, 161, 161, 161, 161, 161, 161, 
	161, 161, 161, 161, 161, 161, 161, 161, 
	161, 161, 161, 161, 161, 161, 161, 161, 
	161, 161, 161, 161, 161, 161, 161, 161, 
	161, 161, 161, 161, 163, 161, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 77, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 73, 73, 75, 75, 
	75, 75, 75, 75, 75, 75, 75, 75, 
	75, 75, 75, 75, 75, 71, 71, 75, 
	75, 75, 75, 75, 75, 75, 75, 87, 
	87, 87, 87, 87, 103, 103, 103, 103, 
	103, 103, 103, 103, 127, 127, 127, 127, 
	127, 127, 127, 127, 127, 127, 127, 127, 
	127, 127, 127, 127, 127, 127, 127, 127, 
	127, 127, 127, 127, 127, 127, 157, 201, 
	159, 159, 155, 155, 155, 77, 67, 69, 
	213, 69, 192, 195, 69, 69, 183, 69, 
	174, 69, 168, 69, 65, 65, 65, 63, 
	69, 186, 69, 189, 210, 177, 165, 69, 
	171, 207, 69, 180, 69, 85, 101, 125, 
	0
};

static const short _dtext_to_state_actions[] = {
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
	0, 11, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 11, 0, 11, 0, 11, 0
};

static const short _dtext_from_state_actions[] = {
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
	0, 13, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 13, 0, 13, 0, 13, 0
};

static const short _dtext_eof_trans[] = {
	694, 694, 694, 694, 694, 694, 694, 694, 
	694, 694, 694, 694, 694, 694, 694, 694, 
	694, 694, 694, 694, 694, 694, 694, 694, 
	694, 694, 694, 694, 694, 694, 694, 694, 
	694, 694, 694, 694, 694, 694, 694, 693, 
	694, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 894, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 822, 
	822, 847, 847, 847, 847, 847, 847, 847, 
	847, 847, 847, 847, 847, 847, 847, 847, 
	839, 839, 847, 847, 847, 847, 847, 847, 
	847, 847, 852, 852, 852, 852, 852, 860, 
	860, 860, 860, 860, 860, 860, 860, 886, 
	886, 886, 886, 886, 886, 886, 886, 886, 
	886, 886, 886, 886, 886, 886, 886, 886, 
	886, 886, 886, 886, 886, 886, 886, 886, 
	886, 0, 887, 888, 890, 890, 893, 893, 
	893, 0, 894, 895, 925, 897, 925, 899, 
	900, 925, 925, 903, 925, 905, 925, 907, 
	925, 911, 911, 911, 912, 925, 914, 925, 
	916, 917, 918, 919, 925, 921, 922, 925, 
	924, 925, 0, 926, 0, 927, 0, 928
};

static const int dtext_start = 233;
static const int dtext_first_final = 233;
static const int dtext_error = -1;

static const int dtext_en_inline = 241;
static const int dtext_en_code = 274;
static const int dtext_en_nodtext = 276;
static const int dtext_en_table = 278;
static const int dtext_en_main = 233;


#line 704 "ext/dtext/dtext.rl"

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
        append_block(sm, "</p>");
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
        append_block(sm, "</p>");
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
        append_block(sm, "</p>");
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
  sm->stack = g_array_sized_new(FALSE, TRUE, sizeof(int), 128);
  sm->dstack = g_queue_new();
}

static void free_machine(StateMachine * sm) {
  g_string_free(sm->output, TRUE);
  g_array_free(sm->stack, FALSE);
  g_queue_free(sm->dstack);
  g_free(sm);
}

static VALUE parse(VALUE self, VALUE input) {
  StateMachine * sm = (StateMachine *)g_malloc0(sizeof(StateMachine));
  input = rb_str_cat(input, "\0", 1);
  init_machine(sm, input);

  
#line 853 "ext/dtext/dtext.c"
	{
	 sm->cs = dtext_start;
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 890 "ext/dtext/dtext.rl"
  
#line 864 "ext/dtext/dtext.c"
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
#line 883 "ext/dtext/dtext.c"
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
#line 75 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	break;
	case 1:
#line 79 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	break;
	case 2:
#line 83 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	break;
	case 3:
#line 87 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
	break;
	case 4:
#line 101 "ext/dtext/dtext.rl"
	{sm->boundary = false;}
	break;
	case 5:
#line 101 "ext/dtext/dtext.rl"
	{sm->boundary = true;}
	break;
	case 8:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	break;
	case 9:
#line 286 "ext/dtext/dtext.rl"
	{( sm->act) = 18;}
	break;
	case 10:
#line 290 "ext/dtext/dtext.rl"
	{( sm->act) = 19;}
	break;
	case 11:
#line 378 "ext/dtext/dtext.rl"
	{( sm->act) = 30;}
	break;
	case 12:
#line 459 "ext/dtext/dtext.rl"
	{( sm->act) = 40;}
	break;
	case 13:
#line 464 "ext/dtext/dtext.rl"
	{( sm->act) = 41;}
	break;
	case 14:
#line 466 "ext/dtext/dtext.rl"
	{( sm->act) = 42;}
	break;
	case 15:
#line 227 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a rel=\"nofollow\" href=\"/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 16:
#line 235 "ext/dtext/dtext.rl"
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
	case 17:
#line 248 "ext/dtext/dtext.rl"
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
	case 18:
#line 269 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a rel=\"nofollow\" href=\"");
    append_segment_uri_escaped(sm, sm->b1, sm->b2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 19:
#line 290 "ext/dtext/dtext.rl"
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
	case 20:
#line 302 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_B);
    append(sm, "<strong>");
  }}
	break;
	case 21:
#line 307 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_B)) {
      dstack_pop(sm);
      append(sm, "</strong>");
    } else {
      append(sm, "[/b]");
    }
  }}
	break;
	case 22:
#line 316 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_I);
    append(sm, "<em>");
  }}
	break;
	case 23:
#line 321 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_I)) {
      dstack_pop(sm);
      append(sm, "</em>");
    } else {
      append(sm, "[/i]");
    }
  }}
	break;
	case 24:
#line 330 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_S);
    append(sm, "<s>");
  }}
	break;
	case 25:
#line 335 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_S)) {
      dstack_pop(sm);
      append(sm, "</s>");
    } else {
      append(sm, "[/s]");
    }
  }}
	break;
	case 26:
#line 344 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_U);
    append(sm, "<u>");
  }}
	break;
	case 27:
#line 349 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_U)) {
      dstack_pop(sm);
      append(sm, "</u>");
    } else {
      append(sm, "[/u]");
    }
  }}
	break;
	case 28:
#line 358 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_TN);
    append(sm, "<span class=\"tn\">");
  }}
	break;
	case 29:
#line 363 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TN)) {
      dstack_pop(sm);
      append(sm, "</p>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else if (dstack_check(sm, INLINE_TN)) {
      dstack_pop(sm);
      append(sm, "</span>");
    } else {
      append(sm, "[/tn]");
    }
  }}
	break;
	case 30:
#line 384 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
    {( sm->p) = (( sm->p - 7))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 31:
#line 390 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_P)) {
      dstack_pop(sm);
      append_block(sm, "</p>");
    } 

    if (dstack_check(sm, BLOCK_QUOTE)) {
      dstack_pop(sm);
      append_block(sm, "</blockquote>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/quote]");
    }
  }}
	break;
	case 32:
#line 405 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_SPOILER);
    append(sm, "<span class=\"spoiler\">");
  }}
	break;
	case 33:
#line 410 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_SPOILER)) {
      dstack_pop(sm);
      append(sm, "</span>");
    } else if (dstack_check(sm, BLOCK_SPOILER)) {
      dstack_pop(sm);
      append_block(sm, "</p></div>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/spoiler]");
    }
  }}
	break;
	case 34:
#line 423 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
    {( sm->p) = (((sm->p - 8)))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 35:
#line 429 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_EXPAND)) {
      append_block(sm, "</div></div>");
      dstack_pop(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/expand]");
    }
  }}
	break;
	case 36:
#line 439 "ext/dtext/dtext.rl"
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
	case 37:
#line 444 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TD)) {
      dstack_pop(sm);
      append_block(sm, "</td>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/td]");
    }
  }}
	break;
	case 38:
#line 454 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 39:
#line 466 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 40:
#line 131 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/posts/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">post #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 41:
#line 139 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_posts/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">forum #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 42:
#line 147 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 43:
#line 155 "ext/dtext/dtext.rl"
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
	case 44:
#line 167 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/comments/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">comment #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 45:
#line 175 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/pools/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pool #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 46:
#line 183 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/users/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">user #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 47:
#line 191 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/artists/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">artist #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 48:
#line 199 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"https://github.com/r888888888/danbooru/issues/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">issue #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 49:
#line 207 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 50:
#line 215 "ext/dtext/dtext.rl"
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
	case 51:
#line 261 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a rel=\"nofollow\" href=\"");
    append_segment_uri_escaped(sm, sm->b1, sm->b2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 52:
#line 277 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a rel=\"nofollow\" href=\"");
    append_segment_uri_escaped(sm, sm->ts, sm->te - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
    append(sm, "</a>");
  }}
	break;
	case 53:
#line 290 "ext/dtext/dtext.rl"
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
	case 54:
#line 378 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close(sm);
    {( sm->p) = (( sm->a1 - 1))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 55:
#line 464 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	break;
	case 56:
#line 466 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 57:
#line 147 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 58:
#line 207 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 59:
#line 466 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 60:
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
	case 30:
	{{( sm->p) = ((( sm->te)))-1;}
    dstack_close(sm);
    {( sm->p) = (( sm->a1 - 1))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }
	break;
	case 40:
	{{( sm->p) = ((( sm->te)))-1;}
    dstack_close(sm);
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }
	break;
	case 42:
	{{( sm->p) = ((( sm->te)))-1;}
    append_c(sm, (*( sm->p)));
  }
	break;
	default:
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	}
	}
	break;
	case 61:
#line 472 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_CODE)) {
      dstack_pop(sm);
      append_block(sm, "</pre>");
    } else {
      append(sm, "[/code]");
    }
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 62:
#line 482 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 63:
#line 487 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 64:
#line 487 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 65:
#line 487 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 66:
#line 493 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_NODTEXT)) {
      dstack_pop(sm);
      append_block(sm, "</p>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else if (dstack_check(sm, INLINE_NODTEXT)) {
      dstack_pop(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/nodtext]");
    }
  }}
	break;
	case 67:
#line 506 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&amp;");
  }}
	break;
	case 68:
#line 510 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&lt;");
  }}
	break;
	case 69:
#line 514 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&gt;");
  }}
	break;
	case 70:
#line 518 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 71:
#line 523 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 72:
#line 523 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 73:
#line 523 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 74:
#line 529 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_THEAD);
    append_block(sm, "<thead>");
  }}
	break;
	case 75:
#line 534 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_THEAD)) {
      dstack_pop(sm);
      append_block(sm, "</thead>");
    } else {
      append(sm, "[/thead]");
    }
  }}
	break;
	case 76:
#line 543 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TBODY);
    append_block(sm, "<tbody>");
  }}
	break;
	case 77:
#line 548 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TBODY)) {
      dstack_pop(sm);
      append_block(sm, "</tbody>");
    } else {
      append(sm, "[/tbody]");
    }
  }}
	break;
	case 78:
#line 557 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TR);
    append_block(sm, "<tr>");
  }}
	break;
	case 79:
#line 562 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TR)) {
      dstack_pop(sm);
      append_block(sm, "</tr>");
    } else {
      append(sm, "[/tr]");
    }
  }}
	break;
	case 80:
#line 571 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TD);
    append_block(sm, "<td>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 241; goto _again;}}
  }}
	break;
	case 81:
#line 577 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TABLE)) {
      dstack_pop(sm);
      append_block(sm, "</table>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/table]");
    }
  }}
	break;
	case 82:
#line 587 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)]; goto _again;}
  }}
	break;
	case 83:
#line 592 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	break;
	case 84:
#line 592 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	break;
	case 85:
#line 592 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	case 86:
#line 596 "ext/dtext/dtext.rl"
	{( sm->act) = 62;}
	break;
	case 87:
#line 689 "ext/dtext/dtext.rl"
	{( sm->act) = 77;}
	break;
	case 88:
#line 612 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_QUOTE);
    append_block(sm, "<blockquote>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 241; goto _again;}}
  }}
	break;
	case 89:
#line 618 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_SPOILER);
    append_block(sm, "<div class=\"spoiler\"><p>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 241; goto _again;}}
  }}
	break;
	case 90:
#line 624 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_CODE);
    append_block(sm, "<pre>");
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
	case 91:
#line 630 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 241; goto _again;}}
  }}
	break;
	case 92:
#line 638 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append(sm, "<span>");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</span>");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 241; goto _again;}}
  }}
	break;
	case 93:
#line 649 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_NODTEXT);
    append_block(sm, "<p>");
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
	case 94:
#line 655 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TABLE);
    append_block(sm, "<table class=\"striped\">");
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
	case 95:
#line 661 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TN);
    append_block(sm, "<p class=\"tn\">");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 241; goto _again;}}
  }}
	break;
	case 96:
#line 671 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&amp;");
  }}
	break;
	case 97:
#line 675 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&lt;");
  }}
	break;
	case 98:
#line 679 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&gt;");
  }}
	break;
	case 99:
#line 683 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
  }}
	break;
	case 100:
#line 687 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	break;
	case 101:
#line 689 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
      dstack_push(sm, &BLOCK_P);
      append_block(sm, "<p>");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 241; goto _again;}}
  }}
	break;
	case 102:
#line 596 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;

    if (sm->f_inline) {
      header = '6';
    }

    append(sm, "<h");
    append_c(sm, header);
    append_c(sm, '>');
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "</h");
    append_c(sm, header);
    append_c(sm, '>');
  }}
	break;
	case 103:
#line 667 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{

  }}
	break;
	case 104:
#line 687 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	break;
	case 105:
#line 689 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
      dstack_push(sm, &BLOCK_P);
      append_block(sm, "<p>");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 241; goto _again;}}
  }}
	break;
	case 106:
#line 689 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
      dstack_push(sm, &BLOCK_P);
      append_block(sm, "<p>");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 241; goto _again;}}
  }}
	break;
	case 107:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 62:
	{{( sm->p) = ((( sm->te)))-1;}
    char header = *sm->a1;

    if (sm->f_inline) {
      header = '6';
    }

    append(sm, "<h");
    append_c(sm, header);
    append_c(sm, '>');
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "</h");
    append_c(sm, header);
    append_c(sm, '>');
  }
	break;
	case 77:
	{{( sm->p) = ((( sm->te)))-1;}
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
      dstack_push(sm, &BLOCK_P);
      append_block(sm, "<p>");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 241; goto _again;}}
  }
	break;
	}
	}
	break;
#line 2057 "ext/dtext/dtext.c"
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
#line 2070 "ext/dtext/dtext.c"
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

#line 891 "ext/dtext/dtext.rl"

  dstack_close(sm);

  VALUE ret = rb_str_new(sm->output->str, sm->output->len);
  free_machine(sm);

  return ret;
}

void Init_dtext() {
  VALUE mDTextRagel = rb_define_module("DTextRagel");
  rb_define_singleton_method(mDTextRagel, "parse", parse, 1);
}
