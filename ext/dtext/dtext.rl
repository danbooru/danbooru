#include <ruby.h>
#include <stdio.h>
#include <stdint.h>
#include "sds.h"

%%{
	machine dtext;

	main := |*
  		any => {
  			output = sdscatch(output, fc);
  			output = sdscatch(output, '-');
  		};
	*|;
}%%

%% write data;

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

	%% write init;
	%% write exec;

	VALUE ret = rb_str_new(output, sdslen(output));
	sdsfree(output);
	return ret;
}

void Init_dtext() {
	VALUE mDTextRagel = rb_define_module("DTextRagel");
	rb_define_singleton_method(mDTextRagel, "parse", parse, 1);
}
