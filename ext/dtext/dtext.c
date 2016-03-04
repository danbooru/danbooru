
#line 1 "ext/dtext/dtext.rl"
#include <ruby.h>
#include <stdio.h>
#include <stdint.h>
#include "sds.h"


#line 15 "ext/dtext/dtext.rl"



#line 14 "ext/dtext/dtext.c"
static const char _dtext_actions[] = {
	0, 1, 0, 1, 1, 1, 2
};

static const char _dtext_key_offsets[] = {
	0
};

static const char _dtext_trans_keys[] = {
	0
};

static const char _dtext_single_lengths[] = {
	0
};

static const char _dtext_range_lengths[] = {
	0
};

static const char _dtext_index_offsets[] = {
	0
};

static const char _dtext_trans_targs[] = {
	0, 0
};

static const char _dtext_trans_actions[] = {
	5, 0
};

static const char _dtext_to_state_actions[] = {
	1
};

static const char _dtext_from_state_actions[] = {
	3
};

static const int dtext_start = 0;
static const int dtext_first_final = 0;
static const int dtext_error = -1;

static const int dtext_en_main = 0;


#line 18 "ext/dtext/dtext.rl"

/* Append a single character pointed by 't' to the
 * end of the specified sds string 's'.
 *
 * After the call, the passed sds string is no longer valid and all the
 * references must be substituted with the new pointer returned by the call. */
sds sdscatch(sds s, char t) {
    size_t curlen = sdslen(s);

    s = sdsMakeRoomFor(s,1);
    if (s == NULL) return NULL;
    sdssetlen(s, curlen+1);
    s[curlen] = t;
    s[curlen+1] = '\0';
    return s;
}

static sds init_output(VALUE input) {
	sds output = sdsempty();
	size_t output_length = RSTRING_LEN(input);
	if (output_length < (INT16_MAX / 2)) {
		output_length *= 2;
	}
	output = sdsMakeRoomFor(output, output_length);	
	return output;
}

static VALUE parse(VALUE self, VALUE input) {
	sds output = init_output(input);
	const char * p = RSTRING_PTR(input);
	const char * pe = p + RSTRING_LEN(input);
	const char * ts = NULL;
	const char * te = NULL;
	int cs, act;

	
#line 99 "ext/dtext/dtext.c"
	{
	cs = dtext_start;
	ts = 0;
	te = 0;
	act = 0;
	}

#line 54 "ext/dtext/dtext.rl"
	
#line 109 "ext/dtext/dtext.c"
	{
	int _klen;
	unsigned int _trans;
	const char *_acts;
	unsigned int _nacts;
	const char *_keys;

	if ( p == pe )
		goto _test_eof;
_resume:
	_acts = _dtext_actions + _dtext_from_state_actions[cs];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 ) {
		switch ( *_acts++ ) {
	case 1:
#line 1 "NONE"
	{ts = p;}
	break;
#line 128 "ext/dtext/dtext.c"
		}
	}

	_keys = _dtext_trans_keys + _dtext_key_offsets[cs];
	_trans = _dtext_index_offsets[cs];

	_klen = _dtext_single_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + _klen - 1;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( (*p) < *_mid )
				_upper = _mid - 1;
			else if ( (*p) > *_mid )
				_lower = _mid + 1;
			else {
				_trans += (unsigned int)(_mid - _keys);
				goto _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _dtext_range_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + (_klen<<1) - 2;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( (*p) < _mid[0] )
				_upper = _mid - 2;
			else if ( (*p) > _mid[1] )
				_lower = _mid + 2;
			else {
				_trans += (unsigned int)((_mid - _keys)>>1);
				goto _match;
			}
		}
		_trans += _klen;
	}

_match:
	cs = _dtext_trans_targs[_trans];

	if ( _dtext_trans_actions[_trans] == 0 )
		goto _again;

	_acts = _dtext_actions + _dtext_trans_actions[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
	{
		switch ( *_acts++ )
		{
	case 2:
#line 10 "ext/dtext/dtext.rl"
	{te = p+1;{
  			output = sdscatch(output, (*p));
  			output = sdscatch(output, '-');
  		}}
	break;
#line 199 "ext/dtext/dtext.c"
		}
	}

_again:
	_acts = _dtext_actions + _dtext_to_state_actions[cs];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 ) {
		switch ( *_acts++ ) {
	case 0:
#line 1 "NONE"
	{ts = 0;}
	break;
#line 212 "ext/dtext/dtext.c"
		}
	}

	if ( ++p != pe )
		goto _resume;
	_test_eof: {}
	}

#line 55 "ext/dtext/dtext.rl"

	VALUE ret = rb_str_new(output, sdslen(output));
	sdsfree(output);
	return ret;
}

void Init_dtext() {
	VALUE mDTextRagel = rb_define_module("DTextRagel");
	rb_define_singleton_method(mDTextRagel, "parse", parse, 1);
}
