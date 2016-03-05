
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

static const int MAX_STACK_DEPTH = 256;
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


#line 690 "ext/dtext/dtext.rl"



#line 57 "ext/dtext/dtext.c"
static const char _dtext_actions[] = {
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 6, 1, 7, 1, 
	8, 1, 13, 1, 14, 1, 15, 1, 
	18, 1, 19, 1, 20, 1, 21, 1, 
	22, 1, 23, 1, 24, 1, 25, 1, 
	26, 1, 27, 1, 28, 1, 29, 1, 
	30, 1, 31, 1, 32, 1, 33, 1, 
	34, 1, 35, 1, 36, 1, 37, 1, 
	50, 1, 52, 1, 53, 1, 54, 1, 
	55, 1, 56, 1, 57, 1, 58, 1, 
	59, 1, 60, 1, 61, 1, 62, 1, 
	63, 1, 64, 1, 65, 1, 66, 1, 
	67, 1, 68, 1, 69, 1, 70, 1, 
	71, 1, 72, 1, 73, 1, 74, 1, 
	75, 1, 76, 1, 77, 1, 78, 1, 
	79, 1, 80, 1, 81, 1, 82, 1, 
	85, 1, 86, 1, 87, 1, 88, 1, 
	90, 1, 91, 1, 92, 1, 93, 1, 
	94, 1, 95, 1, 96, 1, 97, 1, 
	98, 1, 100, 1, 101, 1, 102, 1, 
	103, 2, 1, 38, 2, 1, 39, 2, 
	1, 40, 2, 1, 42, 2, 1, 43, 
	2, 1, 44, 2, 1, 45, 2, 1, 
	46, 2, 1, 47, 2, 1, 51, 2, 
	1, 57, 2, 1, 89, 2, 3, 16, 
	2, 3, 41, 2, 3, 48, 2, 3, 
	49, 2, 3, 99, 2, 8, 0, 2, 
	8, 9, 2, 8, 10, 2, 8, 11, 
	2, 8, 12, 2, 8, 84, 3, 1, 
	5, 17, 3, 8, 2, 83
};

static const short _dtext_key_offsets[] = {
	0, 1, 2, 3, 4, 5, 6, 7, 
	8, 9, 11, 12, 13, 14, 15, 16, 
	17, 18, 19, 20, 21, 22, 23, 24, 
	25, 26, 27, 28, 29, 30, 31, 32, 
	34, 35, 36, 37, 38, 39, 40, 44, 
	45, 46, 48, 49, 50, 51, 52, 54, 
	55, 56, 58, 61, 62, 63, 64, 65, 
	67, 68, 69, 71, 72, 79, 80, 81, 
	82, 83, 84, 85, 86, 87, 88, 89, 
	90, 91, 92, 94, 95, 96, 97, 98, 
	99, 100, 102, 103, 104, 105, 107, 109, 
	110, 111, 112, 113, 114, 115, 116, 117, 
	118, 119, 120, 121, 122, 123, 124, 125, 
	126, 127, 128, 129, 130, 131, 132, 133, 
	135, 136, 137, 138, 139, 140, 141, 142, 
	143, 144, 145, 146, 147, 148, 149, 150, 
	152, 153, 154, 155, 156, 157, 158, 159, 
	161, 162, 163, 164, 165, 166, 168, 169, 
	170, 172, 173, 174, 176, 177, 178, 179, 
	180, 181, 182, 184, 185, 186, 187, 188, 
	189, 191, 192, 194, 196, 197, 198, 199, 
	201, 202, 203, 204, 206, 207, 208, 209, 
	210, 211, 213, 214, 216, 217, 218, 219, 
	220, 222, 223, 224, 225, 226, 227, 228, 
	229, 230, 231, 232, 233, 234, 235, 236, 
	237, 238, 239, 243, 244, 245, 246, 247, 
	248, 249, 250, 251, 252, 253, 254, 255, 
	256, 260, 261, 262, 263, 264, 265, 266, 
	267, 268, 269, 270, 278, 279, 285, 287, 
	291, 293, 308, 310, 312, 313, 315, 317, 
	322, 326, 336, 337, 339, 340, 342, 343, 
	345, 346, 348, 349, 351, 353, 356, 358, 
	360, 362, 363, 366, 368, 369, 371, 372, 
	374, 375, 380, 381, 383
};

static const char _dtext_trans_keys[] = {
	111, 100, 101, 93, 120, 112, 97, 110, 
	100, 61, 93, 93, 93, 111, 100, 116, 
	101, 120, 116, 93, 117, 111, 116, 101, 
	93, 112, 111, 105, 108, 101, 114, 93, 
	97, 110, 98, 108, 101, 93, 93, 46, 
	9, 32, 33, 126, 34, 58, 91, 104, 
	104, 116, 116, 112, 58, 115, 47, 47, 
	33, 126, 93, 33, 126, 58, 116, 116, 
	112, 58, 115, 47, 47, 33, 126, 58, 
	98, 101, 105, 113, 115, 116, 117, 93, 
	120, 112, 97, 110, 100, 93, 93, 117, 
	111, 116, 101, 93, 93, 112, 111, 105, 
	108, 101, 114, 93, 100, 110, 93, 93, 
	93, 93, 124, 93, 124, 93, 93, 93, 
	93, 93, 120, 112, 97, 110, 100, 93, 
	93, 111, 100, 116, 101, 120, 116, 93, 
	117, 111, 116, 101, 93, 93, 112, 111, 
	105, 108, 101, 114, 93, 110, 93, 93, 
	116, 105, 115, 116, 32, 35, 48, 57, 
	109, 109, 101, 110, 116, 32, 35, 48, 
	57, 114, 117, 109, 32, 35, 48, 57, 
	116, 112, 58, 115, 47, 47, 33, 126, 
	58, 115, 117, 101, 32, 35, 48, 57, 
	120, 105, 118, 32, 35, 48, 57, 112, 
	48, 57, 111, 115, 108, 32, 35, 48, 
	57, 116, 32, 35, 48, 57, 112, 105, 
	99, 32, 35, 48, 57, 112, 48, 57, 
	101, 114, 32, 35, 48, 57, 125, 125, 
	125, 99, 111, 100, 101, 93, 110, 111, 
	100, 116, 101, 120, 116, 93, 116, 97, 
	98, 104, 114, 98, 108, 101, 93, 111, 
	100, 121, 93, 101, 97, 100, 93, 93, 
	98, 100, 104, 114, 111, 100, 121, 93, 
	93, 101, 97, 100, 93, 93, 0, 10, 
	13, 38, 60, 62, 91, 104, 10, 99, 
	101, 110, 113, 115, 116, 49, 54, 9, 
	32, 33, 126, 32, 126, 0, 10, 13, 
	34, 64, 91, 97, 99, 102, 104, 105, 
	112, 116, 117, 123, 10, 13, 10, 13, 
	34, 33, 126, 33, 126, 58, 63, 64, 
	33, 126, 58, 63, 33, 126, 47, 91, 
	98, 101, 105, 110, 113, 115, 116, 117, 
	114, 48, 57, 111, 48, 57, 111, 48, 
	57, 116, 33, 126, 115, 48, 57, 105, 
	111, 47, 48, 57, 48, 57, 48, 57, 
	48, 57, 111, 47, 48, 57, 48, 57, 
	115, 48, 57, 123, 0, 91, 47, 0, 
	38, 60, 62, 91, 47, 0, 91, 47, 
	116, 0
};

static const char _dtext_single_lengths[] = {
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	1, 1, 1, 1, 1, 1, 2, 1, 
	1, 2, 1, 1, 1, 1, 2, 1, 
	1, 0, 1, 1, 1, 1, 1, 2, 
	1, 1, 0, 1, 7, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 2, 1, 1, 1, 1, 1, 
	1, 2, 1, 1, 1, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 2, 
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
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 4, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	4, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 8, 1, 6, 0, 2, 
	0, 15, 2, 2, 1, 0, 0, 3, 
	2, 10, 1, 0, 1, 0, 1, 0, 
	1, 0, 1, 0, 2, 1, 0, 0, 
	0, 1, 1, 0, 1, 0, 1, 2, 
	1, 5, 1, 2, 2
};

static const char _dtext_range_lengths[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 1, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 1, 
	1, 0, 0, 0, 0, 1, 1, 1, 
	1, 0, 0, 1, 0, 1, 0, 1, 
	0, 1, 0, 1, 0, 1, 1, 1, 
	1, 0, 1, 1, 0, 1, 0, 0, 
	0, 0, 0, 0, 0
};

static const short _dtext_index_offsets[] = {
	0, 2, 4, 6, 8, 10, 12, 14, 
	16, 18, 21, 23, 25, 27, 29, 31, 
	33, 35, 37, 39, 41, 43, 45, 47, 
	49, 51, 53, 55, 57, 59, 61, 63, 
	66, 68, 70, 72, 74, 76, 78, 82, 
	84, 86, 89, 91, 93, 95, 97, 100, 
	102, 104, 106, 109, 111, 113, 115, 117, 
	120, 122, 124, 126, 128, 136, 138, 140, 
	142, 144, 146, 148, 150, 152, 154, 156, 
	158, 160, 162, 165, 167, 169, 171, 173, 
	175, 177, 180, 182, 184, 186, 189, 192, 
	194, 196, 198, 200, 202, 204, 206, 208, 
	210, 212, 214, 216, 218, 220, 222, 224, 
	226, 228, 230, 232, 234, 236, 238, 240, 
	243, 245, 247, 249, 251, 253, 255, 257, 
	259, 261, 263, 265, 267, 269, 271, 273, 
	275, 277, 279, 281, 283, 285, 287, 289, 
	291, 293, 295, 297, 299, 301, 303, 305, 
	307, 310, 312, 314, 316, 318, 320, 322, 
	324, 326, 328, 330, 332, 334, 336, 338, 
	340, 342, 344, 346, 349, 351, 353, 355, 
	357, 359, 361, 363, 365, 367, 369, 371, 
	373, 375, 377, 379, 381, 383, 385, 387, 
	389, 391, 393, 395, 397, 399, 401, 403, 
	405, 407, 409, 411, 413, 415, 417, 419, 
	421, 423, 425, 430, 432, 434, 436, 438, 
	440, 442, 444, 446, 448, 450, 452, 454, 
	456, 461, 463, 465, 467, 469, 471, 473, 
	475, 477, 479, 481, 490, 492, 499, 501, 
	505, 507, 523, 526, 529, 531, 533, 535, 
	540, 544, 555, 557, 559, 561, 563, 565, 
	567, 569, 571, 573, 575, 578, 581, 583, 
	585, 587, 589, 592, 594, 596, 598, 600, 
	603, 605, 611, 613, 616
};

static const short _dtext_trans_targs[] = {
	1, 227, 2, 227, 3, 227, 227, 227, 
	5, 227, 6, 227, 7, 227, 8, 227, 
	9, 227, 10, 227, 227, 227, 11, 227, 
	11, 13, 227, 14, 227, 15, 227, 16, 
	227, 17, 227, 18, 227, 227, 227, 20, 
	227, 21, 227, 22, 227, 23, 227, 227, 
	227, 25, 227, 26, 227, 27, 227, 28, 
	227, 29, 227, 30, 227, 227, 227, 32, 
	36, 227, 33, 227, 34, 227, 35, 227, 
	227, 227, 227, 227, 38, 227, 38, 231, 
	232, 227, 40, 39, 41, 233, 42, 52, 
	233, 43, 233, 44, 233, 45, 233, 46, 
	233, 47, 51, 233, 48, 233, 49, 233, 
	50, 233, 233, 50, 233, 47, 233, 53, 
	233, 54, 233, 55, 233, 56, 59, 233, 
	57, 233, 58, 233, 237, 233, 56, 233, 
	61, 62, 68, 69, 74, 81, 84, 233, 
	233, 233, 63, 233, 64, 233, 65, 233, 
	66, 233, 67, 233, 233, 233, 233, 233, 
	70, 233, 71, 233, 72, 233, 73, 233, 
	233, 233, 233, 75, 233, 76, 233, 77, 
	233, 78, 233, 79, 233, 80, 233, 233, 
	233, 82, 83, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 86, 87, 88, 86, 
	233, 233, 233, 89, 90, 89, 233, 233, 
	233, 233, 93, 233, 94, 233, 95, 233, 
	96, 233, 97, 233, 233, 233, 233, 233, 
	100, 233, 101, 233, 102, 233, 103, 233, 
	104, 233, 105, 233, 233, 233, 107, 233, 
	108, 233, 109, 233, 110, 233, 233, 233, 
	233, 112, 233, 113, 233, 114, 233, 115, 
	233, 116, 233, 117, 233, 233, 233, 119, 
	233, 233, 233, 233, 233, 122, 233, 123, 
	233, 124, 233, 125, 233, 126, 233, 127, 
	233, 243, 233, 129, 233, 130, 233, 131, 
	233, 132, 233, 133, 233, 134, 233, 135, 
	233, 245, 233, 137, 233, 138, 233, 139, 
	233, 140, 233, 141, 233, 247, 233, 143, 
	233, 144, 233, 145, 148, 233, 146, 233, 
	147, 233, 249, 233, 145, 233, 150, 233, 
	151, 233, 152, 233, 153, 233, 154, 233, 
	251, 233, 156, 233, 157, 233, 158, 233, 
	159, 233, 160, 233, 253, 233, 162, 233, 
	254, 233, 164, 168, 233, 165, 233, 166, 
	233, 167, 233, 255, 233, 169, 233, 170, 
	233, 171, 233, 256, 233, 173, 233, 174, 
	233, 175, 233, 176, 233, 177, 233, 258, 
	233, 179, 233, 259, 233, 181, 233, 182, 
	233, 183, 233, 184, 233, 261, 233, 233, 
	186, 187, 186, 233, 233, 189, 263, 190, 
	263, 191, 263, 192, 263, 263, 263, 194, 
	265, 195, 265, 196, 265, 197, 265, 198, 
	265, 199, 265, 200, 265, 265, 265, 202, 
	267, 203, 207, 211, 215, 267, 204, 267, 
	205, 267, 206, 267, 267, 267, 208, 267, 
	209, 267, 210, 267, 267, 267, 212, 267, 
	213, 267, 214, 267, 267, 267, 267, 267, 
	217, 221, 222, 226, 267, 218, 267, 219, 
	267, 220, 267, 267, 267, 267, 267, 223, 
	267, 224, 267, 225, 267, 267, 267, 267, 
	267, 227, 227, 228, 227, 227, 227, 229, 
	230, 227, 227, 227, 0, 4, 12, 19, 
	24, 31, 227, 37, 227, 38, 231, 232, 
	227, 232, 227, 233, 234, 235, 236, 238, 
	241, 242, 244, 246, 248, 250, 252, 257, 
	260, 262, 233, 234, 234, 233, 234, 234, 
	233, 233, 39, 237, 233, 239, 233, 233, 
	233, 240, 240, 233, 233, 233, 240, 233, 
	60, 85, 91, 92, 98, 99, 106, 111, 
	118, 120, 233, 121, 233, 243, 233, 128, 
	233, 245, 233, 136, 233, 247, 233, 142, 
	233, 249, 233, 149, 233, 251, 233, 155, 
	163, 233, 161, 253, 233, 254, 233, 255, 
	233, 256, 233, 172, 233, 178, 258, 233, 
	259, 233, 180, 233, 261, 233, 185, 233, 
	263, 264, 263, 188, 263, 265, 265, 265, 
	265, 266, 265, 193, 265, 267, 268, 267, 
	201, 216, 267, 227, 227, 227, 227, 227, 
	227, 227, 227, 227, 227, 227, 227, 227, 
	227, 227, 227, 227, 227, 227, 227, 227, 
	227, 227, 227, 227, 227, 227, 227, 227, 
	227, 227, 227, 227, 227, 227, 227, 227, 
	227, 227, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 263, 
	263, 263, 263, 263, 265, 265, 265, 265, 
	265, 265, 265, 265, 267, 267, 267, 267, 
	267, 267, 267, 267, 267, 267, 267, 267, 
	267, 267, 267, 267, 267, 267, 267, 267, 
	267, 267, 267, 267, 267, 267, 227, 227, 
	227, 227, 227, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	233, 233, 233, 233, 233, 233, 233, 233, 
	263, 265, 267, 0
};

static const unsigned char _dtext_trans_actions[] = {
	0, 157, 0, 157, 0, 157, 131, 157, 
	0, 157, 0, 157, 0, 157, 0, 157, 
	0, 157, 0, 133, 157, 157, 1, 194, 
	0, 0, 157, 0, 157, 0, 157, 0, 
	157, 0, 157, 0, 157, 135, 157, 0, 
	157, 0, 157, 0, 157, 0, 157, 127, 
	157, 0, 157, 0, 157, 0, 157, 0, 
	157, 0, 157, 0, 157, 129, 157, 0, 
	0, 157, 0, 157, 0, 157, 0, 157, 
	137, 157, 139, 157, 3, 157, 0, 234, 
	5, 159, 3, 0, 0, 73, 0, 5, 
	73, 5, 73, 0, 73, 0, 73, 0, 
	73, 0, 0, 73, 0, 73, 0, 73, 
	0, 73, 197, 0, 73, 0, 73, 0, 
	73, 0, 73, 0, 73, 0, 0, 73, 
	0, 73, 0, 73, 0, 73, 0, 73, 
	0, 0, 0, 0, 0, 0, 0, 73, 
	25, 73, 0, 73, 0, 73, 0, 73, 
	0, 73, 0, 73, 53, 73, 29, 73, 
	0, 73, 0, 73, 0, 73, 0, 73, 
	45, 73, 33, 0, 73, 0, 73, 0, 
	73, 0, 73, 0, 73, 0, 73, 49, 
	73, 0, 0, 73, 57, 73, 41, 73, 
	37, 73, 73, 73, 1, 3, 3, 0, 
	19, 73, 73, 5, 7, 0, 21, 73, 
	23, 73, 0, 73, 0, 73, 0, 73, 
	0, 73, 0, 73, 51, 73, 27, 73, 
	0, 73, 0, 73, 0, 73, 0, 73, 
	0, 73, 0, 73, 55, 73, 0, 73, 
	0, 73, 0, 73, 0, 73, 43, 73, 
	31, 0, 73, 0, 73, 0, 73, 0, 
	73, 0, 73, 0, 73, 47, 73, 0, 
	73, 39, 73, 35, 73, 0, 73, 0, 
	73, 0, 73, 0, 73, 0, 73, 0, 
	73, 1, 73, 0, 73, 0, 73, 0, 
	73, 0, 73, 0, 73, 0, 73, 0, 
	73, 1, 73, 0, 73, 0, 73, 0, 
	73, 0, 73, 0, 73, 1, 73, 0, 
	73, 0, 73, 0, 0, 73, 0, 73, 
	0, 73, 0, 73, 0, 73, 0, 73, 
	0, 73, 0, 73, 0, 73, 0, 73, 
	1, 73, 0, 73, 0, 73, 0, 73, 
	0, 73, 0, 73, 212, 73, 0, 71, 
	5, 71, 0, 0, 73, 0, 73, 0, 
	73, 0, 73, 1, 73, 0, 73, 0, 
	73, 0, 73, 1, 73, 0, 73, 0, 
	73, 0, 73, 0, 73, 0, 73, 212, 
	73, 0, 69, 5, 69, 0, 73, 0, 
	73, 0, 73, 0, 73, 1, 73, 73, 
	1, 3, 0, 17, 73, 0, 85, 0, 
	85, 0, 85, 0, 85, 77, 85, 0, 
	101, 0, 101, 0, 101, 0, 101, 0, 
	101, 0, 101, 0, 101, 87, 101, 0, 
	125, 0, 0, 0, 0, 125, 0, 125, 
	0, 125, 0, 125, 117, 125, 0, 125, 
	0, 125, 0, 125, 109, 125, 0, 125, 
	0, 125, 0, 125, 105, 125, 113, 125, 
	0, 0, 0, 0, 125, 0, 125, 0, 
	125, 0, 125, 107, 125, 115, 125, 0, 
	125, 0, 125, 0, 125, 103, 125, 111, 
	125, 147, 149, 0, 141, 143, 145, 15, 
	227, 151, 149, 153, 0, 0, 0, 0, 
	0, 0, 155, 1, 155, 0, 234, 5, 
	209, 0, 209, 59, 224, 0, 15, 9, 
	15, 15, 15, 15, 15, 15, 15, 15, 
	15, 15, 61, 221, 221, 75, 221, 221, 
	65, 67, 1, 0, 206, 1, 67, 230, 
	230, 215, 218, 188, 230, 230, 218, 191, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 67, 0, 67, 0, 179, 0, 
	67, 0, 170, 0, 67, 0, 164, 0, 
	67, 0, 63, 0, 67, 0, 182, 0, 
	0, 67, 3, 15, 185, 0, 203, 0, 
	173, 0, 161, 0, 67, 3, 15, 167, 
	0, 200, 0, 67, 0, 176, 0, 67, 
	79, 15, 81, 0, 83, 95, 89, 91, 
	93, 15, 97, 0, 99, 119, 15, 121, 
	0, 0, 123, 157, 157, 157, 157, 157, 
	157, 157, 157, 157, 157, 157, 157, 157, 
	157, 157, 157, 157, 157, 157, 157, 157, 
	157, 157, 157, 157, 157, 157, 157, 157, 
	157, 157, 157, 157, 157, 157, 157, 157, 
	157, 159, 73, 73, 73, 73, 73, 73, 
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
	73, 73, 73, 73, 71, 71, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 69, 69, 73, 
	73, 73, 73, 73, 73, 73, 73, 85, 
	85, 85, 85, 85, 101, 101, 101, 101, 
	101, 101, 101, 101, 125, 125, 125, 125, 
	125, 125, 125, 125, 125, 125, 125, 125, 
	125, 125, 125, 125, 125, 125, 125, 125, 
	125, 125, 125, 125, 125, 125, 153, 155, 
	155, 209, 209, 75, 65, 67, 206, 67, 
	188, 191, 67, 67, 179, 67, 170, 67, 
	164, 67, 63, 67, 182, 67, 185, 203, 
	173, 161, 67, 167, 200, 67, 176, 67, 
	83, 99, 123, 0
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
	0, 0, 0, 11, 0, 0, 0, 0, 
	0, 11, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 11, 
	0, 11, 0, 11, 0
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
	0, 0, 0, 13, 0, 0, 0, 0, 
	0, 13, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 13, 
	0, 13, 0, 13, 0
};

static const short _dtext_eof_trans[] = {
	657, 657, 657, 657, 657, 657, 657, 657, 
	657, 657, 657, 657, 657, 657, 657, 657, 
	657, 657, 657, 657, 657, 657, 657, 657, 
	657, 657, 657, 657, 657, 657, 657, 657, 
	657, 657, 657, 657, 657, 657, 658, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 782, 782, 807, 807, 807, 807, 807, 
	807, 807, 807, 807, 807, 807, 807, 807, 
	807, 807, 799, 799, 807, 807, 807, 807, 
	807, 807, 807, 807, 812, 812, 812, 812, 
	812, 820, 820, 820, 820, 820, 820, 820, 
	820, 846, 846, 846, 846, 846, 846, 846, 
	846, 846, 846, 846, 846, 846, 846, 846, 
	846, 846, 846, 846, 846, 846, 846, 846, 
	846, 846, 846, 0, 847, 849, 849, 851, 
	851, 0, 852, 853, 880, 855, 880, 857, 
	858, 880, 880, 861, 880, 863, 880, 865, 
	880, 867, 880, 869, 880, 871, 872, 873, 
	874, 880, 876, 877, 880, 879, 880, 0, 
	881, 0, 882, 0, 883
};

static const int dtext_start = 227;
static const int dtext_first_final = 227;
static const int dtext_error = -1;

static const int dtext_en_inline = 233;
static const int dtext_en_code = 263;
static const int dtext_en_nodtext = 265;
static const int dtext_en_table = 267;
static const int dtext_en_main = 227;


#line 693 "ext/dtext/dtext.rl"

static inline void underscore_string(char * str, size_t len) {
  for (int i=0; i<len; ++i) {
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
  if (top && *top == expected_element) {
    return true;
  } else {
    return false;
  }
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
  free(sm);
}

static VALUE parse(VALUE self, VALUE input) {
  StateMachine * sm = (StateMachine *)malloc(sizeof(StateMachine));
  init_machine(sm, input);

  
#line 823 "ext/dtext/dtext.c"
	{
	 sm->cs = dtext_start;
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 874 "ext/dtext/dtext.rl"
  
#line 834 "ext/dtext/dtext.c"
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
#line 853 "ext/dtext/dtext.c"
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
#line 100 "ext/dtext/dtext.rl"
	{sm->boundary = false;}
	break;
	case 5:
#line 100 "ext/dtext/dtext.rl"
	{sm->boundary = true;}
	break;
	case 8:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	break;
	case 9:
#line 283 "ext/dtext/dtext.rl"
	{( sm->act) = 18;}
	break;
	case 10:
#line 287 "ext/dtext/dtext.rl"
	{( sm->act) = 19;}
	break;
	case 11:
#line 450 "ext/dtext/dtext.rl"
	{( sm->act) = 39;}
	break;
	case 12:
#line 455 "ext/dtext/dtext.rl"
	{( sm->act) = 40;}
	break;
	case 13:
#line 224 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a rel=\"nofollow\" href=\"/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 14:
#line 232 "ext/dtext/dtext.rl"
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
#line 245 "ext/dtext/dtext.rl"
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
#line 266 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a rel=\"nofollow\" href=\"");
    append_segment_uri_escaped(sm, sm->b1, sm->b2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 17:
#line 287 "ext/dtext/dtext.rl"
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
#line 299 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_B);
    append(sm, "<strong>");
  }}
	break;
	case 19:
#line 304 "ext/dtext/dtext.rl"
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
#line 313 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_I);
    append(sm, "<em>");
  }}
	break;
	case 21:
#line 318 "ext/dtext/dtext.rl"
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
#line 327 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_S);
    append(sm, "<s>");
  }}
	break;
	case 23:
#line 332 "ext/dtext/dtext.rl"
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
#line 341 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_U);
    append(sm, "<u>");
  }}
	break;
	case 25:
#line 346 "ext/dtext/dtext.rl"
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
#line 355 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_TN);
    append(sm, "<span class=\"tn\">");
  }}
	break;
	case 27:
#line 360 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TN)) {
      dstack_pop(sm);
      append(sm, "</p>");
      { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
    } else if (dstack_check(sm, INLINE_TN)) {
      dstack_pop(sm);
      append(sm, "</span>");
    } else {
      append(sm, "[/tn]");
    }
  }}
	break;
	case 28:
#line 375 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
    {( sm->p) = (( sm->p - 7))-1;}
    { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
  }}
	break;
	case 29:
#line 381 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_P)) {
      dstack_pop(sm);
      append_block(sm, "</p>");
    } 

    if (dstack_check(sm, BLOCK_QUOTE)) {
      dstack_pop(sm);
      append_block(sm, "</blockquote>");
      { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/quote]");
    }
  }}
	break;
	case 30:
#line 396 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_SPOILER);
    append(sm, "<span class=\"spoiler\">");
  }}
	break;
	case 31:
#line 401 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_SPOILER)) {
      dstack_pop(sm);
      append(sm, "</span>");
    } else if (dstack_check(sm, BLOCK_SPOILER)) {
      dstack_pop(sm);
      append_block(sm, "</p></div>");
      { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/spoiler]");
    }
  }}
	break;
	case 32:
#line 414 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
    {( sm->p) = (((sm->p - 8)))-1;}
    { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
  }}
	break;
	case 33:
#line 420 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_EXPAND)) {
      append_block(sm, "</div></div>");
      dstack_pop(sm);
      { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/expand]");
    }
  }}
	break;
	case 34:
#line 430 "ext/dtext/dtext.rl"
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 265; goto _again;}}
  }}
	break;
	case 35:
#line 435 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TD)) {
      dstack_pop(sm);
      append_block(sm, "</td>");
      { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/td]");
    }
  }}
	break;
	case 36:
#line 445 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
  }}
	break;
	case 37:
#line 459 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 38:
#line 128 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/posts/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">post #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 39:
#line 136 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_posts/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">forum #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 40:
#line 144 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 41:
#line 152 "ext/dtext/dtext.rl"
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
#line 164 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/comments/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">comment #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 43:
#line 172 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/pools/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pool #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 44:
#line 180 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/users/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">user #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 45:
#line 188 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/artists/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">artist #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 46:
#line 196 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"https://github.com/r888888888/danbooru/issues/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">issue #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 47:
#line 204 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 48:
#line 212 "ext/dtext/dtext.rl"
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
#line 258 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a rel=\"nofollow\" href=\"");
    append_segment_uri_escaped(sm, sm->b1, sm->b2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 50:
#line 274 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a rel=\"nofollow\" href=\"");
    append_segment_uri_escaped(sm, sm->ts, sm->te - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
    append(sm, "</a>");
  }}
	break;
	case 51:
#line 287 "ext/dtext/dtext.rl"
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
#line 455 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_block(sm, "<br>");
  }}
	break;
	case 53:
#line 459 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 54:
#line 144 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 55:
#line 204 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	break;
	case 56:
#line 459 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 57:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 18:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment(sm, sm->ts - 1, sm->te - 1);
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
	case 39:
	{{( sm->p) = ((( sm->te)))-1;}
    dstack_close(sm);
    { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
  }
	break;
	case 40:
	{{( sm->p) = ((( sm->te)))-1;}
    append_block(sm, "<br>");
  }
	break;
	}
	}
	break;
	case 58:
#line 465 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_CODE)) {
      dstack_pop(sm);
      append_block(sm, "</pre>");
    } else {
      append(sm, "[/code]");
    }
    { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
  }}
	break;
	case 59:
#line 475 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
  }}
	break;
	case 60:
#line 480 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 61:
#line 480 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 62:
#line 480 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 63:
#line 486 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_NODTEXT)) {
      dstack_pop(sm);
      append_block(sm, "</p>");
      { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
    } else if (dstack_check(sm, INLINE_NODTEXT)) {
      dstack_pop(sm);
      { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/nodtext]");
    }
  }}
	break;
	case 64:
#line 499 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&amp;");
  }}
	break;
	case 65:
#line 503 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&lt;");
  }}
	break;
	case 66:
#line 507 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&gt;");
  }}
	break;
	case 67:
#line 511 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
  }}
	break;
	case 68:
#line 516 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 69:
#line 516 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 70:
#line 516 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c(sm, (*( sm->p)));
  }}
	break;
	case 71:
#line 522 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_THEAD);
    append_block(sm, "<thead>");
  }}
	break;
	case 72:
#line 527 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_THEAD)) {
      dstack_pop(sm);
      append_block(sm, "</thead>");
    } else {
      append(sm, "[/thead]");
    }
  }}
	break;
	case 73:
#line 536 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TBODY);
    append_block(sm, "<tbody>");
  }}
	break;
	case 74:
#line 541 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TBODY)) {
      dstack_pop(sm);
      append_block(sm, "</tbody>");
    } else {
      append(sm, "[/tbody]");
    }
  }}
	break;
	case 75:
#line 550 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TR);
    append_block(sm, "<tr>");
  }}
	break;
	case 76:
#line 555 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TR)) {
      dstack_pop(sm);
      append_block(sm, "</tr>");
    } else {
      append(sm, "[/tr]");
    }
  }}
	break;
	case 77:
#line 564 "ext/dtext/dtext.rl"
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 233; goto _again;}}
  }}
	break;
	case 78:
#line 570 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TABLE)) {
      dstack_pop(sm);
      append_block(sm, "</table>");
      { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
    } else {
      append(sm, "[/table]");
    }
  }}
	break;
	case 79:
#line 580 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( sm->stack->data)[--( sm->top)]; goto _again;}
  }}
	break;
	case 80:
#line 585 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	break;
	case 81:
#line 585 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	break;
	case 82:
#line 585 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	case 83:
#line 589 "ext/dtext/dtext.rl"
	{( sm->act) = 61;}
	break;
	case 84:
#line 678 "ext/dtext/dtext.rl"
	{( sm->act) = 75;}
	break;
	case 85:
#line 605 "ext/dtext/dtext.rl"
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 233; goto _again;}}
  }}
	break;
	case 86:
#line 611 "ext/dtext/dtext.rl"
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 233; goto _again;}}
  }}
	break;
	case 87:
#line 617 "ext/dtext/dtext.rl"
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 263; goto _again;}}
  }}
	break;
	case 88:
#line 623 "ext/dtext/dtext.rl"
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 233; goto _again;}}
  }}
	break;
	case 89:
#line 631 "ext/dtext/dtext.rl"
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 233; goto _again;}}
  }}
	break;
	case 90:
#line 642 "ext/dtext/dtext.rl"
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 265; goto _again;}}
  }}
	break;
	case 91:
#line 648 "ext/dtext/dtext.rl"
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 267; goto _again;}}
  }}
	break;
	case 92:
#line 654 "ext/dtext/dtext.rl"
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 233; goto _again;}}
  }}
	break;
	case 93:
#line 660 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&amp;");
  }}
	break;
	case 94:
#line 664 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&lt;");
  }}
	break;
	case 95:
#line 668 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&gt;");
  }}
	break;
	case 96:
#line 672 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
  }}
	break;
	case 97:
#line 676 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	break;
	case 98:
#line 678 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
      append(sm, "<p>");
      dstack_push(sm, &BLOCK_P);
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 233; goto _again;}}
  }}
	break;
	case 99:
#line 589 "ext/dtext/dtext.rl"
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
	case 100:
#line 676 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	break;
	case 101:
#line 678 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
      append(sm, "<p>");
      dstack_push(sm, &BLOCK_P);
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 233; goto _again;}}
  }}
	break;
	case 102:
#line 678 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
      append(sm, "<p>");
      dstack_push(sm, &BLOCK_P);
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 233; goto _again;}}
  }}
	break;
	case 103:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 61:
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
	case 75:
	{{( sm->p) = ((( sm->te)))-1;}
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
      append(sm, "<p>");
      dstack_push(sm, &BLOCK_P);
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
{( sm->stack->data)[( sm->top)++] =  sm->cs;  sm->cs = 233; goto _again;}}
  }
	break;
	}
	}
	break;
#line 1997 "ext/dtext/dtext.c"
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
#line 2010 "ext/dtext/dtext.c"
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

#line 875 "ext/dtext/dtext.rl"

  dstack_close(sm);

  VALUE ret = rb_str_new(sm->output->str, sm->output->len);
  free_machine(sm);

  return ret;
}

void Init_dtext() {
  VALUE mDTextRagel = rb_define_module("DTextRagel");
  rb_define_singleton_method(mDTextRagel, "parse", parse, 1);
}
