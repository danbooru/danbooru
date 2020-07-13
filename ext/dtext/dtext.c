#line 1 "ext/dtext/dtext.rl"
#include "dtext.h"

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>

static const size_t MAX_STACK_DEPTH = 512;

typedef enum element_t {
	QUEUE_EMPTY = 0,
	BLOCK_P = 1,
	INLINE_SPOILER = 2,
	BLOCK_SPOILER = 3,
	BLOCK_QUOTE = 4,
	BLOCK_EXPAND = 5,
	BLOCK_NODTEXT = 6,
	BLOCK_CODE = 7,
	BLOCK_TD = 8,
	INLINE_NODTEXT = 9,
	INLINE_B = 10,
	INLINE_I = 11,
	INLINE_U = 12,
	INLINE_S = 13,
	INLINE_TN = 14,
	BLOCK_TN = 15,
	BLOCK_TABLE = 16,
	BLOCK_THEAD = 17,
	BLOCK_TBODY = 18,
	BLOCK_TR = 19,
	BLOCK_UL = 20,
	BLOCK_LI = 21,
	BLOCK_TH = 22,
	BLOCK_H1 = 23,
	BLOCK_H2 = 24,
	BLOCK_H3 = 25,
	BLOCK_H4 = 26,
	BLOCK_H5 = 27,
	BLOCK_H6 = 28,
	INLINE_CODE = 29,
} element_t;


#line 822 "ext/dtext/dtext.rl"



#line 52 "ext/dtext/dtext.c"
static const signed char _dtext_to_state_actions[] = {
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
	0, 0, 0, 0, 0, 0, 0, 76,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	76, 0, 0, 76, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 76, 0, 0, 76, 0, 0,
	76, 0, 0, 76, 0, 0, 0, 0,
	0, 0
};

static const int dtext_start = 687;
static const int dtext_first_final = 687;
static const int dtext_error = -1;

static const int dtext_en_basic_inline = 704;
static const int dtext_en_inline = 707;
static const int dtext_en_code = 778;
static const int dtext_en_nodtext = 781;
static const int dtext_en_table = 784;
static const int dtext_en_list = 787;
static const int dtext_en_main = 687;


#line 824 "ext/dtext/dtext.rl"


static inline void dstack_push(StateMachine * sm, element_t element) {
	g_queue_push_tail(sm->dstack, GINT_TO_POINTER(element));
}

static inline element_t dstack_pop(StateMachine * sm) {
	return GPOINTER_TO_INT(g_queue_pop_tail(sm->dstack));
}

static inline element_t dstack_peek(const StateMachine * sm) {
	return GPOINTER_TO_INT(g_queue_peek_tail(sm->dstack));
}

static inline bool dstack_check(const StateMachine * sm, element_t expected_element) {
	return dstack_peek(sm) == expected_element;
}

static inline bool dstack_check2(const StateMachine * sm, element_t expected_element) {
	if (sm->dstack->length < 2) {
		return false;
	}
	
	element_t top2 = GPOINTER_TO_INT(g_queue_peek_nth(sm->dstack, sm->dstack->length - 2));
	return top2 == expected_element;
}

static inline void append(StateMachine * sm, const char * s) {
	sm->output = g_string_append(sm->output, s);
}

static inline void append_c(StateMachine * sm, char s) {
	sm->output = g_string_append_c(sm->output, s);
}

static inline void append_c_html_escaped(StateMachine * sm, char s) {
	switch (s) {
		case '<':
		sm->output = g_string_append(sm->output, "&lt;");
		break;
		
		case '>':
		sm->output = g_string_append(sm->output, "&gt;");
		break;
		
		case '&':
		sm->output = g_string_append(sm->output, "&amp;");
		break;
		
		case '"':
		sm->output = g_string_append(sm->output, "&quot;");
		break;
		
		default:
		sm->output = g_string_append_c(sm->output, s);
		break;
	}
}

static inline void append_segment(StateMachine * sm, const char * a, const char * b) {
	sm->output = g_string_append_len(sm->output, a, b - a + 1);
}

static inline void append_segment_uri_escaped(StateMachine * sm, const char * a, const char * b) {
	g_autofree char * segment1 = NULL;
	g_autofree char * segment2 = NULL;
	g_autoptr(GString) segment_string = g_string_new_len(a, b - a + 1);
	
	segment1 = g_uri_escape_string(segment_string->str, NULL, TRUE);
	segment2 = g_markup_escape_text(segment1, -1);
	sm->output = g_string_append(sm->output, segment2);
}

static inline void append_segment_html_escaped(StateMachine * sm, const char * a, const char * b) {
	g_autofree gchar * segment = g_markup_escape_text(a, b - a + 1);
	sm->output = g_string_append(sm->output, segment);
}

static inline void append_id_link(StateMachine * sm, const char * title, const char * id_name, const char * url) {
	if (url[0] == '/') {
		append(sm, "<a class=\"dtext-link dtext-id-link dtext-");
	} else {
		append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-");
	}
	
	append(sm, id_name);
	append(sm, "-id-link\" href=\"");
	append(sm, url);
	append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
	append(sm, "\">");
	append(sm, title);
	append(sm, " #");
	append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
	append(sm, "</a>");
}

static inline void append_url(StateMachine * sm, const char * url_start, const char * url_end, const char * title_start, const char * title_end) {
	append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link\" href=\"");
	append_segment_html_escaped(sm, url_start, url_end);
	append(sm, "\">");
	append_segment_html_escaped(sm, title_start, title_end);
	append(sm, "</a>");
}

static inline bool append_named_url(StateMachine * sm, const char * url_start, const char * url_end, const char * title_start, const char * title_end) {
	g_autoptr(GString) parsed_title = parse_basic_inline(title_start, title_end - title_start);
	
	if (!parsed_title) {
		return false;
	}
	
	if (url_start[0] == '/' || url_start[0] == '#') {
		append(sm, "<a class=\"dtext-link\" href=\"");
	} else {
		append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link dtext-named-external-link\" href=\"");
	}
	
	append_segment_html_escaped(sm, url_start, url_end);
	append(sm, "\">");
	append_segment(sm, parsed_title->str, parsed_title->str + parsed_title->len - 1);
	append(sm, "</a>");
	
	return true;
}

static inline void append_wiki_link(StateMachine * sm, const char * tag_segment, const size_t tag_len, const char * title_segment, const size_t title_len, const char * prefix_segment, const size_t prefix_len, const char * suffix_segment, const size_t suffix_len) {
	g_autofree gchar* lowercased_tag = g_utf8_strdown(tag_segment, tag_len);
	g_autoptr(GString) normalized_tag = g_string_new(g_strdelimit(lowercased_tag, " ", '_'));
	g_autoptr(GString) title_string = g_string_new_len(title_segment, title_len);
	
	if (g_regex_match_simple("^[0-9]+$", normalized_tag->str, 0, 0)) {
		g_string_prepend(normalized_tag, "~");
	}
	
	/* handle pipe trick: [[Kaga (Kantai Collection)|]] -> [[kaga_(kantai_collection)|Kaga]] */
	if (title_string->len == 0) {
		g_string_append_len(title_string, tag_segment, tag_len);
		
		/* strip qualifier from tag: "kaga (kantai collection)" -> "kaga" */
		g_autoptr(GRegex) qualifier_regex = g_regex_new("[ _]\\([^)]+?\\)$", 0, 0, NULL);
		g_autofree gchar* stripped_string = g_regex_replace_literal(qualifier_regex, title_string->str, title_string->len, 0, "", 0, NULL);
		
		g_string_assign(title_string, stripped_string);
	}
	
	g_string_prepend_len(title_string, prefix_segment, prefix_len);
	g_string_append_len(title_string, suffix_segment, suffix_len);
	
	append(sm, "<a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/");
	append_segment_uri_escaped(sm, normalized_tag->str, normalized_tag->str + normalized_tag->len - 1);
	append(sm, "\">");
	append_segment_html_escaped(sm, title_string->str, title_string->str + title_string->len - 1);
	append(sm, "</a>");
}

static inline void append_paged_link(StateMachine * sm, const char * title, const char * ahref, const char * param) {
	append(sm, ahref);
	append_segment(sm, sm->a1, sm->a2 - 1);
	append(sm, param);
	append_segment(sm, sm->b1, sm->b2 - 1);
	append(sm, "\">");
	append(sm, title);
	append_segment(sm, sm->a1, sm->a2 - 1);
	append(sm, "/p");
	append_segment(sm, sm->b1, sm->b2 - 1);
	append(sm, "</a>");
}

static inline void append_dmail_key_link(StateMachine * sm) {
	append(sm, "<a class=\"dtext-link dtext-id-link dtext-dmail-id-link\" href=\"/dmails/");
	append_segment(sm, sm->a1, sm->a2 - 1);
	append(sm, "?key=");
	append_segment_uri_escaped(sm, sm->b1, sm->b2 - 1);
	append(sm, "\">");
	append(sm, "dmail #");
	append_segment(sm, sm->a1, sm->a2 - 1);
	append(sm, "</a>");
}

static inline void append_block_segment(StateMachine * sm, const char * a, const char * b) {
	if (!sm->f_inline) {
		sm->output = g_string_append_len(sm->output, a, b - a + 1);
	}
}

static inline void append_block(StateMachine * sm, const char * s) {
	append_block_segment(sm, s, s + strlen(s) - 1);
}

static void append_closing_p(StateMachine * sm) {
	size_t i = sm->output->len;
	
	if (i > 4 && !strncmp(sm->output->str + i - 4, "<br>", 4)) {
		sm->output = g_string_truncate(sm->output, sm->output->len - 4);
	}
	
	if (i > 3 && !strncmp(sm->output->str + i - 3, "<p>", 3)) {
		sm->output = g_string_truncate(sm->output, sm->output->len - 3);
		return;
	}
	
	append_block(sm, "</p>");
}

static void append_closing_p_if(StateMachine * sm) {
	if (!dstack_check(sm, BLOCK_P)) {
		return;
	}
	
	dstack_pop(sm);
	append_closing_p(sm);
}

static void dstack_open_inline(StateMachine * sm, element_t type, const char * html) {
	g_debug("push inline element [%d]: %s", type, html);
	
	dstack_push(sm, type);
	append(sm, html);
}

static void dstack_open_block(StateMachine * sm, element_t type, const char * html) {
	g_debug("push block element [%d]: %s", type, html);
	
	dstack_push(sm, type);
	append_block(sm, html);
}

static void dstack_close_inline(StateMachine * sm, element_t type, const char * close_html) {
	if (dstack_check(sm, type)) {
		g_debug("pop inline element [%d]: %s", type, close_html);
		
		dstack_pop(sm);
		append(sm, close_html);
	} else {
		g_debug("ignored out-of-order closing inline tag [%d]", type);
		
		append_segment(sm, sm->ts, sm->te - 1);
	}
}

static bool dstack_close_block(StateMachine * sm, element_t type, const char * close_html) {
	if (dstack_check(sm, type)) {
		g_debug("pop block element [%d]: %s", type, close_html);
		
		dstack_pop(sm);
		append_block(sm, close_html);
		return true;
	} else {
		g_debug("ignored out-of-order closing block tag [%d]", type);
		
		append_block_segment(sm, sm->ts, sm->te - 1);
		return false;
	}
}

static void dstack_rewind(StateMachine * sm) {
	element_t element = dstack_pop(sm);
	
	switch(element) {
		case BLOCK_P: append_closing_p(sm); break;
		case INLINE_SPOILER: append(sm, "</span>"); break;
		case BLOCK_SPOILER: append_block(sm, "</div>"); break;
		case BLOCK_QUOTE: append_block(sm, "</blockquote>"); break;
		case BLOCK_EXPAND: append_block(sm, "</div></div>"); break;
		case BLOCK_NODTEXT: append_closing_p(sm); break;
		case BLOCK_CODE: append_block(sm, "</pre>"); break;
		case BLOCK_TD: append_block(sm, "</td>"); break;
		case BLOCK_TH: append_block(sm, "</th>"); break;
		
		case INLINE_NODTEXT: break;
		case INLINE_B: append(sm, "</strong>"); break;
		case INLINE_I: append(sm, "</em>"); break;
		case INLINE_U: append(sm, "</u>"); break;
		case INLINE_S: append(sm, "</s>"); break;
		case INLINE_TN: append(sm, "</span>"); break;
		case INLINE_CODE: append(sm, "</code>"); break;
		
		case BLOCK_TN: append_closing_p(sm); break;
		case BLOCK_TABLE: append_block(sm, "</table>"); break;
		case BLOCK_THEAD: append_block(sm, "</thead>"); break;
		case BLOCK_TBODY: append_block(sm, "</tbody>"); break;
		case BLOCK_TR: append_block(sm, "</tr>"); break;
		case BLOCK_UL: append_block(sm, "</ul>"); break;
		case BLOCK_LI: append_block(sm, "</li>"); break;
		case BLOCK_H6: append_block(sm, "</h6>"); break;
		case BLOCK_H5: append_block(sm, "</h5>"); break;
		case BLOCK_H4: append_block(sm, "</h4>"); break;
		case BLOCK_H3: append_block(sm, "</h3>"); break;
		case BLOCK_H2: append_block(sm, "</h2>"); break;
		case BLOCK_H1: append_block(sm, "</h1>"); break;
		
		case QUEUE_EMPTY: break;
	} 
}

static void dstack_close_before_block(StateMachine * sm) {
	while (1) {
		if (dstack_check(sm, BLOCK_P)) {
			dstack_pop(sm);
			append_closing_p(sm);
		} else if (dstack_check(sm, BLOCK_LI) || dstack_check(sm, BLOCK_UL)) {
			dstack_rewind(sm);
		} else {
			return;
		}
	}
}

static void dstack_close(StateMachine * sm) {
	while (!g_queue_is_empty(sm->dstack)) {
		dstack_rewind(sm);
	}
}

static void dstack_close_list(StateMachine * sm) {
	while (dstack_check(sm, BLOCK_LI) || dstack_check(sm, BLOCK_UL)) {
		dstack_rewind(sm);
	}
	
	sm->list_mode = false;
	sm->list_nest = 0;
}

// Returns the preceding non-boundary character if `c` is a boundary character.
// Otherwise, returns `c` if `c` is not a boundary character. Boundary characters
// are trailing punctuation characters that should not be part of the matched text.
static inline const char* find_boundary_c(const char* c) {
	gunichar ch = g_utf8_get_char(g_utf8_prev_char(c + 1));
	int offset = 0;
	
	// Close punctuation: http://www.fileformat.info/info/unicode/category/Pe/list.htm
	// U+3000 - U+303F: http://www.fileformat.info/info/unicode/block/cjk_symbols_and_punctuation/list.htm
	if (g_unichar_type(ch) == G_UNICODE_CLOSE_PUNCTUATION || (ch >= 0x3000 && ch <= 0x303F)) {
		offset = g_unichar_to_utf8(ch, NULL);
	}
	
	switch (*c) {
		case ':':
		case ';':
		case '.':
		case ',':
		case '!':
		case '?':
		case ')':
		case ']':
		case '<':
		case '>':
		offset = 1;
	}
	
	return c - offset;
}

StateMachine* init_machine(const char * src, size_t len, bool f_inline, bool f_mentions) {
	size_t output_length = 0;
	StateMachine* sm = (StateMachine *)g_malloc0(sizeof(StateMachine));
	
	sm->p = src;
	sm->pb = sm->p;
	sm->pe = sm->p + len;
	sm->eof = sm->pe;
	sm->ts = NULL;
	sm->te = NULL;
	sm->cs = dtext_start;
	sm->act = 0;
	sm->top = 0;
	output_length = len;
	if (output_length < (INT16_MAX / 2)) {
		output_length *= 2;
	}
	sm->output = g_string_sized_new(output_length);
	sm->a1 = NULL;
	sm->a2 = NULL;
	sm->b1 = NULL;
	sm->b2 = NULL;
	sm->c1 = NULL;
	sm->c2 = NULL;
	sm->d1 = NULL;
	sm->d2 = NULL;
	sm->f_inline = f_inline;
	sm->f_mentions = f_mentions;
	sm->stack = g_array_sized_new(FALSE, TRUE, sizeof(int), 16);
	sm->dstack = g_queue_new();
	sm->error = NULL;
	sm->list_nest = 0;
	sm->list_mode = false;
	sm->header_mode = false;
	
	return sm;
}

void free_machine(StateMachine * sm) {
	g_string_free(sm->output, TRUE);
	g_array_unref(sm->stack);
	g_queue_free(sm->dstack);
	g_clear_error(&sm->error);
	g_free(sm);
}

GQuark dtext_parse_error_quark() {
	return g_quark_from_static_string("dtext-parse-error-quark");
}

GString* parse_basic_inline(const char* dtext, const ssize_t length) {
	GString* output = NULL;
	StateMachine* sm = init_machine(dtext, length, true, false);
	sm->cs = dtext_en_basic_inline;
	
	if (parse_helper(sm)) {
		output = g_string_new(sm->output->str);
	} else {
		g_debug("parse_basic_inline failed");
	}
	
	free_machine(sm);
	return output;
}

gboolean parse_helper(StateMachine* sm) {
	const gchar* end = NULL;
	
	g_debug("start\n");
	
	if (!g_utf8_validate(sm->pb, sm->pe - sm->pb, &end)) {
		g_set_error(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_INVALID_UTF8, "invalid utf8 starting at byte %td", end - sm->pb + 1);
		return FALSE;
	}
	
	
#line 599 "ext/dtext/dtext.c"
	{
		( sm->top) = 0;
		( sm->ts) = 0;
		( sm->te) = 0;
		( sm->act) = 0;
	}
	
#line 1252 "ext/dtext/dtext.rl"
	
	
#line 610 "ext/dtext/dtext.c"
	{
		
		_resume: {}
		if ( ( sm->p) == ( sm->pe) && ( sm->p) != ( sm->eof) )
			goto _out;
		switch ( sm->cs ) {
			case 687:
			{
#line 1 "NONE"
				{( sm->ts) = ( sm->p);}}
			
#line 622 "ext/dtext/dtext.c"
			
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr730;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr732;
					}
					case 13: {
						goto _ctr733;
					}
					case 42: {
						goto _ctr734;
					}
					case 60: {
						goto _ctr735;
					}
					case 72: {
						goto _ctr736;
					}
					case 91: {
						goto _ctr737;
					}
					case 104: {
						goto _ctr736;
					}
				}
				goto _ctr731;
			}
			case 688:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr0;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr1;
					}
					case 13: {
						goto _ctr738;
					}
				}
				goto _ctr0;
			}
			case 0:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr0;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 10 ) {
					goto _ctr1;
				}
				goto _ctr0;
			}
			case 689:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr739;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 10 ) {
					goto _ctr732;
				}
				goto _ctr739;
			}
			case 690:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr739;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr5;
					}
					case 32: {
						goto _ctr5;
					}
					case 42: {
						goto _ctr6;
					}
				}
				goto _ctr739;
			}
			case 1:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr4;
					}
					case 10: {
						goto _ctr2;
					}
					case 13: {
						goto _ctr2;
					}
					case 32: {
						goto _ctr4;
					}
				}
				goto _ctr3;
			}
			case 691:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr740;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr740;
					}
					case 13: {
						goto _ctr740;
					}
				}
				goto _ctr741;
			}
			case 692:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr740;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr4;
					}
					case 10: {
						goto _ctr740;
					}
					case 13: {
						goto _ctr740;
					}
					case 32: {
						goto _ctr4;
					}
				}
				goto _ctr3;
			}
			case 2:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr5;
					}
					case 32: {
						goto _ctr5;
					}
					case 42: {
						goto _ctr6;
					}
				}
				goto _ctr2;
			}
			case 693:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr739;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 47: {
						goto _ctr742;
					}
					case 66: {
						goto _ctr743;
					}
					case 67: {
						goto _ctr744;
					}
					case 69: {
						goto _ctr745;
					}
					case 78: {
						goto _ctr746;
					}
					case 81: {
						goto _ctr20;
					}
					case 83: {
						goto _ctr747;
					}
					case 84: {
						goto _ctr748;
					}
					case 98: {
						goto _ctr743;
					}
					case 99: {
						goto _ctr744;
					}
					case 101: {
						goto _ctr745;
					}
					case 110: {
						goto _ctr746;
					}
					case 113: {
						goto _ctr20;
					}
					case 115: {
						goto _ctr747;
					}
					case 116: {
						goto _ctr748;
					}
				}
				goto _ctr739;
			}
			case 3:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 83: {
						goto _ctr7;
					}
					case 115: {
						goto _ctr7;
					}
				}
				goto _ctr2;
			}
			case 4:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr8;
					}
					case 112: {
						goto _ctr8;
					}
				}
				goto _ctr2;
			}
			case 5:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr9;
					}
					case 111: {
						goto _ctr9;
					}
				}
				goto _ctr2;
			}
			case 6:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr10;
					}
					case 105: {
						goto _ctr10;
					}
				}
				goto _ctr2;
			}
			case 7:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr11;
					}
					case 108: {
						goto _ctr11;
					}
				}
				goto _ctr2;
			}
			case 8:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr12;
					}
					case 101: {
						goto _ctr12;
					}
				}
				goto _ctr2;
			}
			case 9:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr13;
					}
					case 114: {
						goto _ctr13;
					}
				}
				goto _ctr2;
			}
			case 10:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 62: {
						goto _ctr14;
					}
					case 83: {
						goto _ctr15;
					}
					case 115: {
						goto _ctr15;
					}
				}
				goto _ctr2;
			}
			case 11:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr14;
				}
				goto _ctr2;
			}
			case 12:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr16;
					}
					case 108: {
						goto _ctr16;
					}
				}
				goto _ctr2;
			}
			case 13:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr17;
					}
					case 111: {
						goto _ctr17;
					}
				}
				goto _ctr2;
			}
			case 14:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 67: {
						goto _ctr18;
					}
					case 99: {
						goto _ctr18;
					}
				}
				goto _ctr2;
			}
			case 15:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 75: {
						goto _ctr19;
					}
					case 107: {
						goto _ctr19;
					}
				}
				goto _ctr2;
			}
			case 16:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 81: {
						goto _ctr20;
					}
					case 113: {
						goto _ctr20;
					}
				}
				goto _ctr2;
			}
			case 17:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 85: {
						goto _ctr21;
					}
					case 117: {
						goto _ctr21;
					}
				}
				goto _ctr2;
			}
			case 18:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr22;
					}
					case 111: {
						goto _ctr22;
					}
				}
				goto _ctr2;
			}
			case 19:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr23;
					}
					case 116: {
						goto _ctr23;
					}
				}
				goto _ctr2;
			}
			case 20:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr24;
					}
					case 101: {
						goto _ctr24;
					}
				}
				goto _ctr2;
			}
			case 21:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr25;
				}
				goto _ctr2;
			}
			case 694:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr749;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 32 ) {
					goto _ctr25;
				}
				if ( 9 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 13 ) {
					goto _ctr25;
				}
				goto _ctr749;
			}
			case 22:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr26;
					}
					case 111: {
						goto _ctr26;
					}
				}
				goto _ctr2;
			}
			case 23:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr27;
					}
					case 100: {
						goto _ctr27;
					}
				}
				goto _ctr2;
			}
			case 24:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr28;
					}
					case 101: {
						goto _ctr28;
					}
				}
				goto _ctr2;
			}
			case 25:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr29;
				}
				goto _ctr2;
			}
			case 695:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr750;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 32 ) {
					goto _ctr29;
				}
				if ( 9 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 13 ) {
					goto _ctr29;
				}
				goto _ctr750;
			}
			case 26:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 88: {
						goto _ctr30;
					}
					case 120: {
						goto _ctr30;
					}
				}
				goto _ctr2;
			}
			case 27:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr31;
					}
					case 112: {
						goto _ctr31;
					}
				}
				goto _ctr2;
			}
			case 28:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr32;
					}
					case 97: {
						goto _ctr32;
					}
				}
				goto _ctr2;
			}
			case 29:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr33;
					}
					case 110: {
						goto _ctr33;
					}
				}
				goto _ctr2;
			}
			case 30:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr34;
					}
					case 100: {
						goto _ctr34;
					}
				}
				goto _ctr2;
			}
			case 31:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr35;
				}
				goto _ctr2;
			}
			case 696:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr751;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 32 ) {
					goto _ctr35;
				}
				if ( 9 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 13 ) {
					goto _ctr35;
				}
				goto _ctr751;
			}
			case 32:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr36;
					}
					case 111: {
						goto _ctr36;
					}
				}
				goto _ctr2;
			}
			case 33:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr37;
					}
					case 100: {
						goto _ctr37;
					}
				}
				goto _ctr2;
			}
			case 34:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr38;
					}
					case 116: {
						goto _ctr38;
					}
				}
				goto _ctr2;
			}
			case 35:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr39;
					}
					case 101: {
						goto _ctr39;
					}
				}
				goto _ctr2;
			}
			case 36:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 88: {
						goto _ctr40;
					}
					case 120: {
						goto _ctr40;
					}
				}
				goto _ctr2;
			}
			case 37:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr41;
					}
					case 116: {
						goto _ctr41;
					}
				}
				goto _ctr2;
			}
			case 38:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr42;
				}
				goto _ctr2;
			}
			case 697:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr752;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 32 ) {
					goto _ctr42;
				}
				if ( 9 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 13 ) {
					goto _ctr42;
				}
				goto _ctr752;
			}
			case 39:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr43;
					}
					case 112: {
						goto _ctr43;
					}
				}
				goto _ctr2;
			}
			case 40:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr44;
					}
					case 111: {
						goto _ctr44;
					}
				}
				goto _ctr2;
			}
			case 41:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr45;
					}
					case 105: {
						goto _ctr45;
					}
				}
				goto _ctr2;
			}
			case 42:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr46;
					}
					case 108: {
						goto _ctr46;
					}
				}
				goto _ctr2;
			}
			case 43:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr47;
					}
					case 101: {
						goto _ctr47;
					}
				}
				goto _ctr2;
			}
			case 44:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr48;
					}
					case 114: {
						goto _ctr48;
					}
				}
				goto _ctr2;
			}
			case 45:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 62: {
						goto _ctr49;
					}
					case 83: {
						goto _ctr50;
					}
					case 115: {
						goto _ctr50;
					}
				}
				goto _ctr2;
			}
			case 698:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr753;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 32 ) {
					goto _ctr49;
				}
				if ( 9 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 13 ) {
					goto _ctr49;
				}
				goto _ctr753;
			}
			case 46:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr49;
				}
				goto _ctr2;
			}
			case 47:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr51;
					}
					case 78: {
						goto _ctr52;
					}
					case 97: {
						goto _ctr51;
					}
					case 110: {
						goto _ctr52;
					}
				}
				goto _ctr2;
			}
			case 48:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 66: {
						goto _ctr53;
					}
					case 98: {
						goto _ctr53;
					}
				}
				goto _ctr2;
			}
			case 49:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr54;
					}
					case 108: {
						goto _ctr54;
					}
				}
				goto _ctr2;
			}
			case 50:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr55;
					}
					case 101: {
						goto _ctr55;
					}
				}
				goto _ctr2;
			}
			case 51:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr56;
				}
				goto _ctr2;
			}
			case 52:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr57;
				}
				goto _ctr2;
			}
			case 699:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr739;	goto _again;
			}
			else {
				if ( 49 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 54 ) {
					goto _ctr754;
				}
				goto _ctr739;
			}
			case 53:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 35: {
						goto _ctr58;
					}
					case 46: {
						goto _ctr59;
					}
				}
				goto _ctr2;
			}
			case 54:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 33 ) {
					goto _ctr60;
				}
				if ( ( (*( ( sm->p)))) > 45 ) {
					if ( 47 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
						goto _ctr60;
					}
				} else if ( ( (*( ( sm->p)))) >= 35 ) {
					goto _ctr60;
				}
				goto _ctr2;
			}
			case 55:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 33: {
						goto _ctr61;
					}
					case 46: {
						goto _ctr62;
					}
				}
				if ( 35 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
					goto _ctr61;
				}
				goto _ctr2;
			}
			case 700:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr755;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr756;
					}
					case 32: {
						goto _ctr756;
					}
				}
				goto _ctr755;
			}
			case 701:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr757;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr758;
					}
					case 32: {
						goto _ctr758;
					}
				}
				goto _ctr757;
			}
			case 702:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr739;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 47: {
						goto _ctr759;
					}
					case 67: {
						goto _ctr760;
					}
					case 69: {
						goto _ctr761;
					}
					case 78: {
						goto _ctr762;
					}
					case 81: {
						goto _ctr763;
					}
					case 83: {
						goto _ctr764;
					}
					case 84: {
						goto _ctr765;
					}
					case 99: {
						goto _ctr760;
					}
					case 101: {
						goto _ctr761;
					}
					case 110: {
						goto _ctr762;
					}
					case 113: {
						goto _ctr763;
					}
					case 115: {
						goto _ctr764;
					}
					case 116: {
						goto _ctr765;
					}
				}
				goto _ctr739;
			}
			case 56:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 83: {
						goto _ctr63;
					}
					case 115: {
						goto _ctr63;
					}
				}
				goto _ctr2;
			}
			case 57:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr64;
					}
					case 112: {
						goto _ctr64;
					}
				}
				goto _ctr2;
			}
			case 58:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr65;
					}
					case 111: {
						goto _ctr65;
					}
				}
				goto _ctr2;
			}
			case 59:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr66;
					}
					case 105: {
						goto _ctr66;
					}
				}
				goto _ctr2;
			}
			case 60:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr67;
					}
					case 108: {
						goto _ctr67;
					}
				}
				goto _ctr2;
			}
			case 61:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr68;
					}
					case 101: {
						goto _ctr68;
					}
				}
				goto _ctr2;
			}
			case 62:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr69;
					}
					case 114: {
						goto _ctr69;
					}
				}
				goto _ctr2;
			}
			case 63:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 83: {
						goto _ctr70;
					}
					case 93: {
						goto _ctr14;
					}
					case 115: {
						goto _ctr70;
					}
				}
				goto _ctr2;
			}
			case 64:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr14;
				}
				goto _ctr2;
			}
			case 65:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr71;
					}
					case 111: {
						goto _ctr71;
					}
				}
				goto _ctr2;
			}
			case 66:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr72;
					}
					case 100: {
						goto _ctr72;
					}
				}
				goto _ctr2;
			}
			case 67:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr73;
					}
					case 101: {
						goto _ctr73;
					}
				}
				goto _ctr2;
			}
			case 68:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr29;
				}
				goto _ctr2;
			}
			case 69:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 88: {
						goto _ctr74;
					}
					case 120: {
						goto _ctr74;
					}
				}
				goto _ctr2;
			}
			case 70:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr75;
					}
					case 112: {
						goto _ctr75;
					}
				}
				goto _ctr2;
			}
			case 71:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr76;
					}
					case 97: {
						goto _ctr76;
					}
				}
				goto _ctr2;
			}
			case 72:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr77;
					}
					case 110: {
						goto _ctr77;
					}
				}
				goto _ctr2;
			}
			case 73:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr78;
					}
					case 100: {
						goto _ctr78;
					}
				}
				goto _ctr2;
			}
			case 74:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 61: {
						goto _ctr79;
					}
					case 93: {
						goto _ctr35;
					}
				}
				goto _ctr2;
			}
			case 75:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr2;
				}
				goto _ctr80;
			}
			case 76:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr82;
				}
				goto _ctr81;
			}
			case 703:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr766;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 32 ) {
					goto _ctr767;
				}
				if ( 9 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 13 ) {
					goto _ctr767;
				}
				goto _ctr766;
			}
			case 77:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr83;
					}
					case 111: {
						goto _ctr83;
					}
				}
				goto _ctr2;
			}
			case 78:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr84;
					}
					case 100: {
						goto _ctr84;
					}
				}
				goto _ctr2;
			}
			case 79:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr85;
					}
					case 116: {
						goto _ctr85;
					}
				}
				goto _ctr2;
			}
			case 80:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr86;
					}
					case 101: {
						goto _ctr86;
					}
				}
				goto _ctr2;
			}
			case 81:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 88: {
						goto _ctr87;
					}
					case 120: {
						goto _ctr87;
					}
				}
				goto _ctr2;
			}
			case 82:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr88;
					}
					case 116: {
						goto _ctr88;
					}
				}
				goto _ctr2;
			}
			case 83:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr42;
				}
				goto _ctr2;
			}
			case 84:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 85: {
						goto _ctr89;
					}
					case 117: {
						goto _ctr89;
					}
				}
				goto _ctr2;
			}
			case 85:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr90;
					}
					case 111: {
						goto _ctr90;
					}
				}
				goto _ctr2;
			}
			case 86:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr91;
					}
					case 116: {
						goto _ctr91;
					}
				}
				goto _ctr2;
			}
			case 87:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr92;
					}
					case 101: {
						goto _ctr92;
					}
				}
				goto _ctr2;
			}
			case 88:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr25;
				}
				goto _ctr2;
			}
			case 89:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr93;
					}
					case 112: {
						goto _ctr93;
					}
				}
				goto _ctr2;
			}
			case 90:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr94;
					}
					case 111: {
						goto _ctr94;
					}
				}
				goto _ctr2;
			}
			case 91:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr95;
					}
					case 105: {
						goto _ctr95;
					}
				}
				goto _ctr2;
			}
			case 92:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr96;
					}
					case 108: {
						goto _ctr96;
					}
				}
				goto _ctr2;
			}
			case 93:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr97;
					}
					case 101: {
						goto _ctr97;
					}
				}
				goto _ctr2;
			}
			case 94:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr98;
					}
					case 114: {
						goto _ctr98;
					}
				}
				goto _ctr2;
			}
			case 95:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 83: {
						goto _ctr99;
					}
					case 93: {
						goto _ctr49;
					}
					case 115: {
						goto _ctr99;
					}
				}
				goto _ctr2;
			}
			case 96:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr49;
				}
				goto _ctr2;
			}
			case 97:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr100;
					}
					case 78: {
						goto _ctr101;
					}
					case 97: {
						goto _ctr100;
					}
					case 110: {
						goto _ctr101;
					}
				}
				goto _ctr2;
			}
			case 98:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 66: {
						goto _ctr102;
					}
					case 98: {
						goto _ctr102;
					}
				}
				goto _ctr2;
			}
			case 99:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr103;
					}
					case 108: {
						goto _ctr103;
					}
				}
				goto _ctr2;
			}
			case 100:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr104;
					}
					case 101: {
						goto _ctr104;
					}
				}
				goto _ctr2;
			}
			case 101:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr56;
				}
				goto _ctr2;
			}
			case 102:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr2;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr57;
				}
				goto _ctr2;
			}
			case 704:
			{
#line 1 "NONE"
				{( sm->ts) = ( sm->p);}}
			
#line 2450 "ext/dtext/dtext.c"
			
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr768;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 60: {
						goto _ctr770;
					}
					case 91: {
						goto _ctr771;
					}
				}
				goto _ctr769;
			}
			case 705:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr772;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 47: {
						goto _ctr773;
					}
					case 66: {
						goto _ctr127;
					}
					case 69: {
						goto _ctr774;
					}
					case 73: {
						goto _ctr120;
					}
					case 83: {
						goto _ctr775;
					}
					case 85: {
						goto _ctr776;
					}
					case 98: {
						goto _ctr127;
					}
					case 101: {
						goto _ctr774;
					}
					case 105: {
						goto _ctr120;
					}
					case 115: {
						goto _ctr775;
					}
					case 117: {
						goto _ctr776;
					}
				}
				goto _ctr772;
			}
			case 103:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 66: {
						goto _ctr106;
					}
					case 69: {
						goto _ctr107;
					}
					case 73: {
						goto _ctr108;
					}
					case 83: {
						goto _ctr109;
					}
					case 85: {
						goto _ctr110;
					}
					case 98: {
						goto _ctr106;
					}
					case 101: {
						goto _ctr107;
					}
					case 105: {
						goto _ctr108;
					}
					case 115: {
						goto _ctr109;
					}
					case 117: {
						goto _ctr110;
					}
				}
				goto _ctr105;
			}
			case 104:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr111;
				}
				goto _ctr105;
			}
			case 105:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 77: {
						goto _ctr108;
					}
					case 109: {
						goto _ctr108;
					}
				}
				goto _ctr105;
			}
			case 106:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr112;
				}
				goto _ctr105;
			}
			case 107:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 62: {
						goto _ctr113;
					}
					case 84: {
						goto _ctr114;
					}
					case 116: {
						goto _ctr114;
					}
				}
				goto _ctr105;
			}
			case 108:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr115;
					}
					case 114: {
						goto _ctr115;
					}
				}
				goto _ctr105;
			}
			case 109:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr116;
					}
					case 111: {
						goto _ctr116;
					}
				}
				goto _ctr105;
			}
			case 110:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr117;
					}
					case 110: {
						goto _ctr117;
					}
				}
				goto _ctr105;
			}
			case 111:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 71: {
						goto _ctr106;
					}
					case 103: {
						goto _ctr106;
					}
				}
				goto _ctr105;
			}
			case 112:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr118;
				}
				goto _ctr105;
			}
			case 113:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr119;
				}
				goto _ctr105;
			}
			case 114:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 77: {
						goto _ctr120;
					}
					case 109: {
						goto _ctr120;
					}
				}
				goto _ctr105;
			}
			case 115:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr121;
				}
				goto _ctr105;
			}
			case 116:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 62: {
						goto _ctr122;
					}
					case 84: {
						goto _ctr123;
					}
					case 116: {
						goto _ctr123;
					}
				}
				goto _ctr105;
			}
			case 117:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr124;
					}
					case 114: {
						goto _ctr124;
					}
				}
				goto _ctr105;
			}
			case 118:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr125;
					}
					case 111: {
						goto _ctr125;
					}
				}
				goto _ctr105;
			}
			case 119:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr126;
					}
					case 110: {
						goto _ctr126;
					}
				}
				goto _ctr105;
			}
			case 120:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 71: {
						goto _ctr127;
					}
					case 103: {
						goto _ctr127;
					}
				}
				goto _ctr105;
			}
			case 121:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr128;
				}
				goto _ctr105;
			}
			case 706:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr772;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 47: {
						goto _ctr777;
					}
					case 66: {
						goto _ctr778;
					}
					case 73: {
						goto _ctr779;
					}
					case 83: {
						goto _ctr780;
					}
					case 85: {
						goto _ctr781;
					}
					case 98: {
						goto _ctr778;
					}
					case 105: {
						goto _ctr779;
					}
					case 115: {
						goto _ctr780;
					}
					case 117: {
						goto _ctr781;
					}
				}
				goto _ctr772;
			}
			case 122:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 66: {
						goto _ctr129;
					}
					case 73: {
						goto _ctr130;
					}
					case 83: {
						goto _ctr131;
					}
					case 85: {
						goto _ctr132;
					}
					case 98: {
						goto _ctr129;
					}
					case 105: {
						goto _ctr130;
					}
					case 115: {
						goto _ctr131;
					}
					case 117: {
						goto _ctr132;
					}
				}
				goto _ctr105;
			}
			case 123:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr111;
				}
				goto _ctr105;
			}
			case 124:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr112;
				}
				goto _ctr105;
			}
			case 125:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr113;
				}
				goto _ctr105;
			}
			case 126:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr118;
				}
				goto _ctr105;
			}
			case 127:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr119;
				}
				goto _ctr105;
			}
			case 128:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr121;
				}
				goto _ctr105;
			}
			case 129:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr122;
				}
				goto _ctr105;
			}
			case 130:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr105;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr128;
				}
				goto _ctr105;
			}
			case 707:
			{
#line 1 "NONE"
				{( sm->ts) = ( sm->p);}}
			
#line 2947 "ext/dtext/dtext.c"
			
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr782;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr784;
					}
					case 13: {
						goto _ctr785;
					}
					case 34: {
						goto _ctr786;
					}
					case 60: {
						goto _ctr788;
					}
					case 64: {
						goto _ctr789;
					}
					case 65: {
						goto _ctr790;
					}
					case 66: {
						goto _ctr791;
					}
					case 67: {
						goto _ctr792;
					}
					case 68: {
						goto _ctr793;
					}
					case 70: {
						goto _ctr794;
					}
					case 71: {
						goto _ctr795;
					}
					case 73: {
						goto _ctr796;
					}
					case 77: {
						goto _ctr797;
					}
					case 78: {
						goto _ctr798;
					}
					case 80: {
						goto _ctr799;
					}
					case 83: {
						goto _ctr800;
					}
					case 84: {
						goto _ctr801;
					}
					case 85: {
						goto _ctr802;
					}
					case 87: {
						goto _ctr803;
					}
					case 89: {
						goto _ctr804;
					}
					case 91: {
						goto _ctr805;
					}
					case 97: {
						goto _ctr790;
					}
					case 98: {
						goto _ctr791;
					}
					case 99: {
						goto _ctr792;
					}
					case 100: {
						goto _ctr793;
					}
					case 102: {
						goto _ctr794;
					}
					case 103: {
						goto _ctr795;
					}
					case 104: {
						goto _ctr806;
					}
					case 105: {
						goto _ctr796;
					}
					case 109: {
						goto _ctr797;
					}
					case 110: {
						goto _ctr798;
					}
					case 112: {
						goto _ctr799;
					}
					case 115: {
						goto _ctr800;
					}
					case 116: {
						goto _ctr801;
					}
					case 117: {
						goto _ctr802;
					}
					case 119: {
						goto _ctr803;
					}
					case 121: {
						goto _ctr804;
					}
					case 123: {
						goto _ctr807;
					}
				}
				if ( ( (*( ( sm->p)))) < 69 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr787;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 101 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr787;
					}
				} else {
					goto _ctr787;
				}
				goto _ctr783;
			}
			case 708:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr808;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr134;
					}
					case 13: {
						goto _ctr809;
					}
					case 42: {
						goto _ctr810;
					}
				}
				goto _ctr808;
			}
			case 709:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr811;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr134;
					}
					case 13: {
						goto _ctr809;
					}
				}
				goto _ctr811;
			}
			case 131:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr133;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 10 ) {
					goto _ctr134;
				}
				goto _ctr133;
			}
			case 132:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr135;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr136;
					}
					case 32: {
						goto _ctr136;
					}
					case 42: {
						goto _ctr137;
					}
				}
				goto _ctr135;
			}
			case 133:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr135;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr139;
					}
					case 10: {
						goto _ctr135;
					}
					case 13: {
						goto _ctr135;
					}
					case 32: {
						goto _ctr139;
					}
				}
				goto _ctr138;
			}
			case 710:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr812;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr812;
					}
					case 13: {
						goto _ctr812;
					}
				}
				goto _ctr813;
			}
			case 711:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr812;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr139;
					}
					case 10: {
						goto _ctr812;
					}
					case 13: {
						goto _ctr812;
					}
					case 32: {
						goto _ctr139;
					}
				}
				goto _ctr138;
			}
			case 712:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr814;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 10 ) {
					goto _ctr784;
				}
				goto _ctr814;
			}
			case 713:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 34 ) {
					goto _ctr815;
				}
				goto _ctr816;
			}
			case 134:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 34 ) {
					goto _ctr142;
				}
				goto _ctr141;
			}
			case 135:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 58 ) {
					goto _ctr143;
				}
				goto _ctr140;
			}
			case 136:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 35: {
						goto _ctr144;
					}
					case 47: {
						goto _ctr144;
					}
					case 91: {
						goto _ctr145;
					}
					case 104: {
						goto _ctr146;
					}
				}
				goto _ctr140;
			}
			case 137:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr147;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr150;
						}
					} else {
						goto _ctr149;
					}
				} else {
					goto _ctr148;
				}
				goto _ctr140;
			}
			case 138:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr133;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr150;
				}
				goto _ctr133;
			}
			case 714:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr817;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr147;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr150;
						}
					} else {
						goto _ctr149;
					}
				} else {
					goto _ctr148;
				}
				goto _ctr817;
			}
			case 139:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr133;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr147;
				}
				goto _ctr133;
			}
			case 140:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr133;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr148;
				}
				goto _ctr133;
			}
			case 141:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 35: {
						goto _ctr151;
					}
					case 47: {
						goto _ctr151;
					}
					case 104: {
						goto _ctr152;
					}
				}
				goto _ctr140;
			}
			case 142:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr153;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr156;
						}
					} else {
						goto _ctr155;
					}
				} else {
					goto _ctr154;
				}
				goto _ctr140;
			}
			case 143:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr156;
				}
				goto _ctr140;
			}
			case 144:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr157;
				}
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr153;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr156;
						}
					} else {
						goto _ctr155;
					}
				} else {
					goto _ctr154;
				}
				goto _ctr140;
			}
			case 145:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr153;
				}
				goto _ctr140;
			}
			case 146:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr154;
				}
				goto _ctr140;
			}
			case 147:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 116 ) {
					goto _ctr158;
				}
				goto _ctr140;
			}
			case 148:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 116 ) {
					goto _ctr159;
				}
				goto _ctr140;
			}
			case 149:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 112 ) {
					goto _ctr160;
				}
				goto _ctr140;
			}
			case 150:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 58: {
						goto _ctr161;
					}
					case 115: {
						goto _ctr162;
					}
				}
				goto _ctr140;
			}
			case 151:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr163;
				}
				goto _ctr140;
			}
			case 152:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr164;
				}
				goto _ctr140;
			}
			case 153:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 58 ) {
					goto _ctr161;
				}
				goto _ctr140;
			}
			case 154:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 116 ) {
					goto _ctr165;
				}
				goto _ctr140;
			}
			case 155:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 116 ) {
					goto _ctr166;
				}
				goto _ctr140;
			}
			case 156:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 112 ) {
					goto _ctr167;
				}
				goto _ctr140;
			}
			case 157:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 58: {
						goto _ctr168;
					}
					case 115: {
						goto _ctr169;
					}
				}
				goto _ctr140;
			}
			case 158:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr170;
				}
				goto _ctr140;
			}
			case 159:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr171;
				}
				goto _ctr140;
			}
			case 160:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 58 ) {
					goto _ctr168;
				}
				goto _ctr140;
			}
			case 715:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 91 ) {
					goto _ctr173;
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 161:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 91 ) {
					goto _ctr173;
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 162:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 91 ) {
					goto _ctr174;
				}
				goto _ctr140;
			}
			case 163:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 93: {
						goto _ctr140;
					}
					case 124: {
						goto _ctr176;
					}
				}
				goto _ctr175;
			}
			case 164:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 93: {
						goto _ctr178;
					}
					case 124: {
						goto _ctr179;
					}
				}
				goto _ctr177;
			}
			case 165:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr180;
				}
				goto _ctr140;
			}
			case 716:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr818;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr819;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr819;
					}
				} else {
					goto _ctr819;
				}
				goto _ctr818;
			}
			case 717:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr820;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr821;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr821;
					}
				} else {
					goto _ctr821;
				}
				goto _ctr820;
			}
			case 166:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 93: {
						goto _ctr182;
					}
					case 124: {
						goto _ctr140;
					}
				}
				goto _ctr181;
			}
			case 167:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 93: {
						goto _ctr184;
					}
					case 124: {
						goto _ctr140;
					}
				}
				goto _ctr183;
			}
			case 168:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr185;
				}
				goto _ctr140;
			}
			case 718:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr822;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr823;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr823;
					}
				} else {
					goto _ctr823;
				}
				goto _ctr822;
			}
			case 719:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr824;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr825;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr825;
					}
				} else {
					goto _ctr825;
				}
				goto _ctr824;
			}
			case 169:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 93: {
						goto _ctr178;
					}
					case 124: {
						goto _ctr140;
					}
				}
				goto _ctr186;
			}
			case 720:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 47: {
						goto _ctr826;
					}
					case 64: {
						goto _ctr827;
					}
					case 65: {
						goto _ctr828;
					}
					case 66: {
						goto _ctr829;
					}
					case 67: {
						goto _ctr830;
					}
					case 69: {
						goto _ctr831;
					}
					case 73: {
						goto _ctr284;
					}
					case 78: {
						goto _ctr832;
					}
					case 81: {
						goto _ctr274;
					}
					case 83: {
						goto _ctr833;
					}
					case 84: {
						goto _ctr834;
					}
					case 85: {
						goto _ctr835;
					}
					case 97: {
						goto _ctr828;
					}
					case 98: {
						goto _ctr829;
					}
					case 99: {
						goto _ctr830;
					}
					case 101: {
						goto _ctr831;
					}
					case 104: {
						goto _ctr836;
					}
					case 105: {
						goto _ctr284;
					}
					case 110: {
						goto _ctr832;
					}
					case 113: {
						goto _ctr274;
					}
					case 115: {
						goto _ctr833;
					}
					case 116: {
						goto _ctr834;
					}
					case 117: {
						goto _ctr835;
					}
				}
				goto _ctr815;
			}
			case 170:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 66: {
						goto _ctr187;
					}
					case 69: {
						goto _ctr188;
					}
					case 73: {
						goto _ctr189;
					}
					case 81: {
						goto _ctr190;
					}
					case 83: {
						goto _ctr191;
					}
					case 84: {
						goto _ctr192;
					}
					case 85: {
						goto _ctr193;
					}
					case 98: {
						goto _ctr187;
					}
					case 101: {
						goto _ctr188;
					}
					case 105: {
						goto _ctr189;
					}
					case 113: {
						goto _ctr190;
					}
					case 115: {
						goto _ctr191;
					}
					case 116: {
						goto _ctr192;
					}
					case 117: {
						goto _ctr193;
					}
				}
				goto _ctr140;
			}
			case 171:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 62: {
						goto _ctr194;
					}
					case 76: {
						goto _ctr195;
					}
					case 108: {
						goto _ctr195;
					}
				}
				goto _ctr140;
			}
			case 172:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr196;
					}
					case 111: {
						goto _ctr196;
					}
				}
				goto _ctr140;
			}
			case 173:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 67: {
						goto _ctr197;
					}
					case 99: {
						goto _ctr197;
					}
				}
				goto _ctr140;
			}
			case 174:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 75: {
						goto _ctr198;
					}
					case 107: {
						goto _ctr198;
					}
				}
				goto _ctr140;
			}
			case 175:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 81: {
						goto _ctr190;
					}
					case 113: {
						goto _ctr190;
					}
				}
				goto _ctr140;
			}
			case 176:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 85: {
						goto _ctr199;
					}
					case 117: {
						goto _ctr199;
					}
				}
				goto _ctr140;
			}
			case 177:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr200;
					}
					case 111: {
						goto _ctr200;
					}
				}
				goto _ctr140;
			}
			case 178:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr201;
					}
					case 116: {
						goto _ctr201;
					}
				}
				goto _ctr140;
			}
			case 179:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr202;
					}
					case 101: {
						goto _ctr202;
					}
				}
				goto _ctr140;
			}
			case 180:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr203;
				}
				goto _ctr140;
			}
			case 721:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr837;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 32 ) {
					goto _ctr203;
				}
				if ( 9 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 13 ) {
					goto _ctr203;
				}
				goto _ctr837;
			}
			case 181:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 77: {
						goto _ctr189;
					}
					case 88: {
						goto _ctr204;
					}
					case 109: {
						goto _ctr189;
					}
					case 120: {
						goto _ctr204;
					}
				}
				goto _ctr140;
			}
			case 182:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr205;
				}
				goto _ctr140;
			}
			case 183:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr206;
					}
					case 112: {
						goto _ctr206;
					}
				}
				goto _ctr140;
			}
			case 184:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr207;
					}
					case 97: {
						goto _ctr207;
					}
				}
				goto _ctr140;
			}
			case 185:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr208;
					}
					case 110: {
						goto _ctr208;
					}
				}
				goto _ctr140;
			}
			case 186:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr209;
					}
					case 100: {
						goto _ctr209;
					}
				}
				goto _ctr140;
			}
			case 187:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr210;
				}
				goto _ctr140;
			}
			case 188:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 62: {
						goto _ctr211;
					}
					case 80: {
						goto _ctr212;
					}
					case 84: {
						goto _ctr213;
					}
					case 112: {
						goto _ctr212;
					}
					case 116: {
						goto _ctr213;
					}
				}
				goto _ctr140;
			}
			case 189:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr214;
					}
					case 111: {
						goto _ctr214;
					}
				}
				goto _ctr140;
			}
			case 190:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr215;
					}
					case 105: {
						goto _ctr215;
					}
				}
				goto _ctr140;
			}
			case 191:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr216;
					}
					case 108: {
						goto _ctr216;
					}
				}
				goto _ctr140;
			}
			case 192:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr217;
					}
					case 101: {
						goto _ctr217;
					}
				}
				goto _ctr140;
			}
			case 193:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr218;
					}
					case 114: {
						goto _ctr218;
					}
				}
				goto _ctr140;
			}
			case 194:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 62: {
						goto _ctr219;
					}
					case 83: {
						goto _ctr220;
					}
					case 115: {
						goto _ctr220;
					}
				}
				goto _ctr140;
			}
			case 195:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr219;
				}
				goto _ctr140;
			}
			case 196:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr221;
					}
					case 114: {
						goto _ctr221;
					}
				}
				goto _ctr140;
			}
			case 197:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr222;
					}
					case 111: {
						goto _ctr222;
					}
				}
				goto _ctr140;
			}
			case 198:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr223;
					}
					case 110: {
						goto _ctr223;
					}
				}
				goto _ctr140;
			}
			case 199:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 71: {
						goto _ctr224;
					}
					case 103: {
						goto _ctr224;
					}
				}
				goto _ctr140;
			}
			case 200:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr194;
				}
				goto _ctr140;
			}
			case 201:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr225;
					}
					case 72: {
						goto _ctr226;
					}
					case 78: {
						goto _ctr227;
					}
					case 100: {
						goto _ctr225;
					}
					case 104: {
						goto _ctr226;
					}
					case 110: {
						goto _ctr227;
					}
				}
				goto _ctr140;
			}
			case 202:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr228;
				}
				goto _ctr140;
			}
			case 203:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr229;
				}
				goto _ctr140;
			}
			case 204:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr230;
				}
				goto _ctr140;
			}
			case 205:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr231;
				}
				goto _ctr140;
			}
			case 206:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr232;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr235;
						}
					} else {
						goto _ctr234;
					}
				} else {
					goto _ctr233;
				}
				goto _ctr140;
			}
			case 207:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr236;
				}
				goto _ctr140;
			}
			case 208:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr240;
				}
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr237;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr236;
						}
					} else {
						goto _ctr239;
					}
				} else {
					goto _ctr238;
				}
				goto _ctr140;
			}
			case 209:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr237;
				}
				goto _ctr140;
			}
			case 210:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr238;
				}
				goto _ctr140;
			}
			case 211:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 32 ) {
					goto _ctr241;
				}
				if ( 9 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 13 ) {
					goto _ctr241;
				}
				goto _ctr140;
			}
			case 212:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr241;
					}
					case 72: {
						goto _ctr242;
					}
					case 104: {
						goto _ctr242;
					}
				}
				if ( 9 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 13 ) {
					goto _ctr241;
				}
				goto _ctr140;
			}
			case 213:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr243;
					}
					case 114: {
						goto _ctr243;
					}
				}
				goto _ctr140;
			}
			case 214:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr244;
					}
					case 101: {
						goto _ctr244;
					}
				}
				goto _ctr140;
			}
			case 215:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 70: {
						goto _ctr245;
					}
					case 102: {
						goto _ctr245;
					}
				}
				goto _ctr140;
			}
			case 216:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 61 ) {
					goto _ctr246;
				}
				goto _ctr140;
			}
			case 217:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 34 ) {
					goto _ctr247;
				}
				goto _ctr140;
			}
			case 218:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 35: {
						goto _ctr248;
					}
					case 47: {
						goto _ctr248;
					}
					case 104: {
						goto _ctr249;
					}
				}
				goto _ctr140;
			}
			case 219:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr250;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr253;
						}
					} else {
						goto _ctr252;
					}
				} else {
					goto _ctr251;
				}
				goto _ctr140;
			}
			case 220:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr253;
				}
				goto _ctr140;
			}
			case 221:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 34 ) {
					goto _ctr254;
				}
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr250;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr253;
						}
					} else {
						goto _ctr252;
					}
				} else {
					goto _ctr251;
				}
				goto _ctr140;
			}
			case 222:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr250;
				}
				goto _ctr140;
			}
			case 223:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr251;
				}
				goto _ctr140;
			}
			case 224:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 34: {
						goto _ctr254;
					}
					case 62: {
						goto _ctr255;
					}
				}
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr250;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr253;
						}
					} else {
						goto _ctr252;
					}
				} else {
					goto _ctr251;
				}
				goto _ctr140;
			}
			case 225:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr140;
					}
					case 13: {
						goto _ctr140;
					}
				}
				goto _ctr256;
			}
			case 226:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr140;
					}
					case 13: {
						goto _ctr140;
					}
					case 60: {
						goto _ctr258;
					}
				}
				goto _ctr257;
			}
			case 227:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr140;
					}
					case 13: {
						goto _ctr140;
					}
					case 47: {
						goto _ctr259;
					}
					case 60: {
						goto _ctr258;
					}
				}
				goto _ctr257;
			}
			case 228:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr140;
					}
					case 13: {
						goto _ctr140;
					}
					case 60: {
						goto _ctr258;
					}
					case 65: {
						goto _ctr260;
					}
					case 97: {
						goto _ctr260;
					}
				}
				goto _ctr257;
			}
			case 229:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr140;
					}
					case 13: {
						goto _ctr140;
					}
					case 60: {
						goto _ctr258;
					}
					case 62: {
						goto _ctr261;
					}
				}
				goto _ctr257;
			}
			case 230:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 116 ) {
					goto _ctr262;
				}
				goto _ctr140;
			}
			case 231:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 116 ) {
					goto _ctr263;
				}
				goto _ctr140;
			}
			case 232:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 112 ) {
					goto _ctr264;
				}
				goto _ctr140;
			}
			case 233:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 58: {
						goto _ctr265;
					}
					case 115: {
						goto _ctr266;
					}
				}
				goto _ctr140;
			}
			case 234:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr267;
				}
				goto _ctr140;
			}
			case 235:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr268;
				}
				goto _ctr140;
			}
			case 236:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 58 ) {
					goto _ctr265;
				}
				goto _ctr140;
			}
			case 237:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 62: {
						goto _ctr269;
					}
					case 76: {
						goto _ctr270;
					}
					case 108: {
						goto _ctr270;
					}
				}
				goto _ctr140;
			}
			case 238:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr271;
					}
					case 111: {
						goto _ctr271;
					}
				}
				goto _ctr140;
			}
			case 239:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 67: {
						goto _ctr272;
					}
					case 99: {
						goto _ctr272;
					}
				}
				goto _ctr140;
			}
			case 240:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 75: {
						goto _ctr273;
					}
					case 107: {
						goto _ctr273;
					}
				}
				goto _ctr140;
			}
			case 241:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 81: {
						goto _ctr274;
					}
					case 113: {
						goto _ctr274;
					}
				}
				goto _ctr140;
			}
			case 242:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 85: {
						goto _ctr275;
					}
					case 117: {
						goto _ctr275;
					}
				}
				goto _ctr140;
			}
			case 243:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr276;
					}
					case 111: {
						goto _ctr276;
					}
				}
				goto _ctr140;
			}
			case 244:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr277;
					}
					case 116: {
						goto _ctr277;
					}
				}
				goto _ctr140;
			}
			case 245:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr278;
					}
					case 101: {
						goto _ctr278;
					}
				}
				goto _ctr140;
			}
			case 246:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr279;
				}
				goto _ctr140;
			}
			case 247:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr280;
					}
					case 111: {
						goto _ctr280;
					}
				}
				goto _ctr140;
			}
			case 248:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr281;
					}
					case 100: {
						goto _ctr281;
					}
				}
				goto _ctr140;
			}
			case 249:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr282;
					}
					case 101: {
						goto _ctr282;
					}
				}
				goto _ctr140;
			}
			case 250:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr283;
				}
				goto _ctr140;
			}
			case 251:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 77: {
						goto _ctr284;
					}
					case 88: {
						goto _ctr285;
					}
					case 109: {
						goto _ctr284;
					}
					case 120: {
						goto _ctr285;
					}
				}
				goto _ctr140;
			}
			case 252:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr286;
				}
				goto _ctr140;
			}
			case 253:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr287;
					}
					case 112: {
						goto _ctr287;
					}
				}
				goto _ctr140;
			}
			case 254:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr288;
					}
					case 97: {
						goto _ctr288;
					}
				}
				goto _ctr140;
			}
			case 255:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr289;
					}
					case 110: {
						goto _ctr289;
					}
				}
				goto _ctr140;
			}
			case 256:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr290;
					}
					case 100: {
						goto _ctr290;
					}
				}
				goto _ctr140;
			}
			case 257:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr291;
				}
				goto _ctr140;
			}
			case 258:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr292;
					}
					case 111: {
						goto _ctr292;
					}
				}
				goto _ctr140;
			}
			case 259:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr293;
					}
					case 100: {
						goto _ctr293;
					}
				}
				goto _ctr140;
			}
			case 260:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr294;
					}
					case 116: {
						goto _ctr294;
					}
				}
				goto _ctr140;
			}
			case 261:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr295;
					}
					case 101: {
						goto _ctr295;
					}
				}
				goto _ctr140;
			}
			case 262:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 88: {
						goto _ctr296;
					}
					case 120: {
						goto _ctr296;
					}
				}
				goto _ctr140;
			}
			case 263:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr297;
					}
					case 116: {
						goto _ctr297;
					}
				}
				goto _ctr140;
			}
			case 264:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr298;
				}
				goto _ctr140;
			}
			case 265:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 62: {
						goto _ctr299;
					}
					case 80: {
						goto _ctr300;
					}
					case 84: {
						goto _ctr301;
					}
					case 112: {
						goto _ctr300;
					}
					case 116: {
						goto _ctr301;
					}
				}
				goto _ctr140;
			}
			case 266:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr302;
					}
					case 111: {
						goto _ctr302;
					}
				}
				goto _ctr140;
			}
			case 267:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr303;
					}
					case 105: {
						goto _ctr303;
					}
				}
				goto _ctr140;
			}
			case 268:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr304;
					}
					case 108: {
						goto _ctr304;
					}
				}
				goto _ctr140;
			}
			case 269:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr305;
					}
					case 101: {
						goto _ctr305;
					}
				}
				goto _ctr140;
			}
			case 270:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr306;
					}
					case 114: {
						goto _ctr306;
					}
				}
				goto _ctr140;
			}
			case 271:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 62: {
						goto _ctr307;
					}
					case 83: {
						goto _ctr308;
					}
					case 115: {
						goto _ctr308;
					}
				}
				goto _ctr140;
			}
			case 272:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr307;
				}
				goto _ctr140;
			}
			case 273:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr309;
					}
					case 114: {
						goto _ctr309;
					}
				}
				goto _ctr140;
			}
			case 274:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr310;
					}
					case 111: {
						goto _ctr310;
					}
				}
				goto _ctr140;
			}
			case 275:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr311;
					}
					case 110: {
						goto _ctr311;
					}
				}
				goto _ctr140;
			}
			case 276:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 71: {
						goto _ctr312;
					}
					case 103: {
						goto _ctr312;
					}
				}
				goto _ctr140;
			}
			case 277:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr269;
				}
				goto _ctr140;
			}
			case 278:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr313;
					}
					case 110: {
						goto _ctr313;
					}
				}
				goto _ctr140;
			}
			case 279:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr314;
				}
				goto _ctr140;
			}
			case 280:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr315;
				}
				goto _ctr140;
			}
			case 281:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 116 ) {
					goto _ctr316;
				}
				goto _ctr140;
			}
			case 282:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 116 ) {
					goto _ctr317;
				}
				goto _ctr140;
			}
			case 283:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 112 ) {
					goto _ctr318;
				}
				goto _ctr140;
			}
			case 284:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 58: {
						goto _ctr319;
					}
					case 115: {
						goto _ctr320;
					}
				}
				goto _ctr140;
			}
			case 285:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr321;
				}
				goto _ctr140;
			}
			case 286:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr322;
				}
				goto _ctr140;
			}
			case 287:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr323;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr326;
						}
					} else {
						goto _ctr325;
					}
				} else {
					goto _ctr324;
				}
				goto _ctr140;
			}
			case 288:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr326;
				}
				goto _ctr140;
			}
			case 289:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr327;
				}
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr323;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr326;
						}
					} else {
						goto _ctr325;
					}
				} else {
					goto _ctr324;
				}
				goto _ctr140;
			}
			case 290:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr323;
				}
				goto _ctr140;
			}
			case 291:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr324;
				}
				goto _ctr140;
			}
			case 292:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 58 ) {
					goto _ctr319;
				}
				goto _ctr140;
			}
			case 722:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr838;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr841;
						}
					} else {
						goto _ctr840;
					}
				} else {
					goto _ctr839;
				}
				goto _ctr815;
			}
			case 293:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr133;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr328;
				}
				goto _ctr133;
			}
			case 723:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr842;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr329;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr328;
						}
					} else {
						goto _ctr843;
					}
				} else {
					goto _ctr330;
				}
				goto _ctr842;
			}
			case 294:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr133;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr329;
				}
				goto _ctr133;
			}
			case 295:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr133;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr330;
				}
				goto _ctr133;
			}
			case 724:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr844;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 64 ) {
					goto _ctr845;
				}
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr329;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr328;
						}
					} else {
						goto _ctr843;
					}
				} else {
					goto _ctr330;
				}
				goto _ctr844;
			}
			case 725:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr846;
					}
					case 80: {
						goto _ctr847;
					}
					case 82: {
						goto _ctr848;
					}
					case 91: {
						goto _ctr173;
					}
					case 108: {
						goto _ctr846;
					}
					case 112: {
						goto _ctr847;
					}
					case 114: {
						goto _ctr848;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 296:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr331;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr331;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 297:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr332;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr332;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 298:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 83: {
						goto _ctr333;
					}
					case 91: {
						goto _ctr173;
					}
					case 115: {
						goto _ctr333;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 299:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr334;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 300:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr335;
				}
				goto _ctr140;
			}
			case 301:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr336;
				}
				goto _ctr140;
			}
			case 726:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr849;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr850;
				}
				goto _ctr849;
			}
			case 302:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr337;
					}
					case 91: {
						goto _ctr173;
					}
					case 112: {
						goto _ctr337;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 303:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr338;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr338;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 304:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr339;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr339;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 305:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr340;
					}
					case 91: {
						goto _ctr173;
					}
					case 108: {
						goto _ctr340;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 306:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr341;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 307:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr342;
				}
				goto _ctr140;
			}
			case 308:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr343;
				}
				goto _ctr140;
			}
			case 727:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr851;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr852;
				}
				goto _ctr851;
			}
			case 309:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr344;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr344;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 310:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr345;
					}
					case 83: {
						goto _ctr346;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr345;
					}
					case 115: {
						goto _ctr346;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 311:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 83: {
						goto _ctr347;
					}
					case 91: {
						goto _ctr173;
					}
					case 115: {
						goto _ctr347;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 312:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr348;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr348;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 313:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr349;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 314:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr350;
				}
				goto _ctr140;
			}
			case 315:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr351;
				}
				goto _ctr140;
			}
			case 728:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr853;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr854;
				}
				goto _ctr853;
			}
			case 316:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr352;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr352;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 317:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr353;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr353;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 318:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr354;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr354;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 319:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr355;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr355;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 320:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr356;
					}
					case 91: {
						goto _ctr173;
					}
					case 111: {
						goto _ctr356;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 321:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr357;
					}
					case 91: {
						goto _ctr173;
					}
					case 110: {
						goto _ctr357;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 322:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr358;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 323:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr359;
				}
				goto _ctr140;
			}
			case 324:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr360;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr360;
					}
				} else {
					goto _ctr360;
				}
				goto _ctr140;
			}
			case 729:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr855;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr856;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr856;
					}
				} else {
					goto _ctr856;
				}
				goto _ctr855;
			}
			case 730:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr857;
					}
					case 85: {
						goto _ctr858;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr857;
					}
					case 117: {
						goto _ctr858;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 325:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr361;
					}
					case 91: {
						goto _ctr173;
					}
					case 110: {
						goto _ctr361;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 326:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr362;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 327:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr363;
				}
				goto _ctr140;
			}
			case 328:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr364;
				}
				goto _ctr140;
			}
			case 731:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr859;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr860;
				}
				goto _ctr859;
			}
			case 329:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr365;
					}
					case 91: {
						goto _ctr173;
					}
					case 114: {
						goto _ctr365;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 330:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr366;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 331:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr367;
				}
				goto _ctr140;
			}
			case 332:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr368;
				}
				goto _ctr140;
			}
			case 732:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr861;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr862;
				}
				goto _ctr861;
			}
			case 733:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr863;
					}
					case 91: {
						goto _ctr173;
					}
					case 111: {
						goto _ctr863;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 333:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 77: {
						goto _ctr369;
					}
					case 91: {
						goto _ctr173;
					}
					case 109: {
						goto _ctr369;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 334:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 77: {
						goto _ctr370;
					}
					case 91: {
						goto _ctr173;
					}
					case 109: {
						goto _ctr370;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 335:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr371;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr371;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 336:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr372;
					}
					case 91: {
						goto _ctr173;
					}
					case 110: {
						goto _ctr372;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 337:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr373;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr373;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 338:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr374;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 339:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr375;
				}
				goto _ctr140;
			}
			case 340:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr376;
				}
				goto _ctr140;
			}
			case 734:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr864;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr865;
				}
				goto _ctr864;
			}
			case 735:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr866;
					}
					case 77: {
						goto _ctr867;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr866;
					}
					case 109: {
						goto _ctr867;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 341:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 86: {
						goto _ctr377;
					}
					case 91: {
						goto _ctr173;
					}
					case 118: {
						goto _ctr377;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 342:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr378;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr378;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 343:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr379;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr379;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 344:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr380;
					}
					case 91: {
						goto _ctr173;
					}
					case 110: {
						goto _ctr380;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 345:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr381;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr381;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 346:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr382;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr382;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 347:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr383;
					}
					case 91: {
						goto _ctr173;
					}
					case 114: {
						goto _ctr383;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 348:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr384;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr384;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 349:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr385;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 350:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr386;
				}
				goto _ctr140;
			}
			case 351:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr387;
				}
				goto _ctr140;
			}
			case 736:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr868;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr869;
				}
				goto _ctr868;
			}
			case 352:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr388;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr388;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 353:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr389;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr389;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 354:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr390;
					}
					case 91: {
						goto _ctr173;
					}
					case 108: {
						goto _ctr390;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 355:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr391;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 356:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr392;
				}
				goto _ctr140;
			}
			case 357:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr393;
				}
				goto _ctr140;
			}
			case 737:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr870;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr871;
				}
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr872;
				}
				goto _ctr870;
			}
			case 358:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr394;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 45: {
						goto _ctr395;
					}
					case 61: {
						goto _ctr395;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr395;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr395;
					}
				} else {
					goto _ctr395;
				}
				goto _ctr394;
			}
			case 738:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr873;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 45: {
						goto _ctr874;
					}
					case 61: {
						goto _ctr874;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr874;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr874;
					}
				} else {
					goto _ctr874;
				}
				goto _ctr873;
			}
			case 739:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr875;
					}
					case 69: {
						goto _ctr876;
					}
					case 76: {
						goto _ctr877;
					}
					case 79: {
						goto _ctr878;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr875;
					}
					case 101: {
						goto _ctr876;
					}
					case 108: {
						goto _ctr877;
					}
					case 111: {
						goto _ctr878;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 359:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 86: {
						goto _ctr396;
					}
					case 91: {
						goto _ctr173;
					}
					case 118: {
						goto _ctr396;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 360:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 71: {
						goto _ctr397;
					}
					case 91: {
						goto _ctr173;
					}
					case 103: {
						goto _ctr397;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 361:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr398;
					}
					case 91: {
						goto _ctr173;
					}
					case 114: {
						goto _ctr398;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 362:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr399;
					}
					case 91: {
						goto _ctr173;
					}
					case 111: {
						goto _ctr399;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 363:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 85: {
						goto _ctr400;
					}
					case 91: {
						goto _ctr173;
					}
					case 117: {
						goto _ctr400;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 364:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr401;
					}
					case 91: {
						goto _ctr173;
					}
					case 112: {
						goto _ctr401;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 365:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr402;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 366:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr403;
				}
				goto _ctr140;
			}
			case 367:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr404;
				}
				goto _ctr140;
			}
			case 740:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr879;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr880;
				}
				goto _ctr879;
			}
			case 368:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr405;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr405;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 369:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr406;
					}
					case 91: {
						goto _ctr173;
					}
					case 100: {
						goto _ctr406;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 370:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 66: {
						goto _ctr407;
					}
					case 91: {
						goto _ctr173;
					}
					case 98: {
						goto _ctr407;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 371:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr408;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr408;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 372:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 67: {
						goto _ctr409;
					}
					case 91: {
						goto _ctr173;
					}
					case 99: {
						goto _ctr409;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 373:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 75: {
						goto _ctr410;
					}
					case 91: {
						goto _ctr173;
					}
					case 107: {
						goto _ctr410;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 374:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr411;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 375:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr412;
				}
				goto _ctr140;
			}
			case 376:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr413;
				}
				goto _ctr140;
			}
			case 741:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr881;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr882;
				}
				goto _ctr881;
			}
			case 377:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr414;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr414;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 378:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 71: {
						goto _ctr415;
					}
					case 91: {
						goto _ctr173;
					}
					case 103: {
						goto _ctr415;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 379:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr416;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 380:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr417;
				}
				goto _ctr140;
			}
			case 381:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr418;
				}
				goto _ctr140;
			}
			case 742:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr883;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr884;
				}
				goto _ctr883;
			}
			case 382:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr419;
					}
					case 91: {
						goto _ctr173;
					}
					case 114: {
						goto _ctr419;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 383:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 85: {
						goto _ctr420;
					}
					case 91: {
						goto _ctr173;
					}
					case 117: {
						goto _ctr420;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 384:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 77: {
						goto _ctr421;
					}
					case 91: {
						goto _ctr173;
					}
					case 109: {
						goto _ctr421;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 385:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr422;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 386:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr423;
				}
				goto _ctr140;
			}
			case 387:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr424;
				}
				goto _ctr140;
			}
			case 743:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr885;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr886;
				}
				goto _ctr885;
			}
			case 744:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr887;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr887;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 388:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr425;
					}
					case 91: {
						goto _ctr173;
					}
					case 108: {
						goto _ctr425;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 389:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 66: {
						goto _ctr426;
					}
					case 91: {
						goto _ctr173;
					}
					case 98: {
						goto _ctr426;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 390:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr427;
					}
					case 91: {
						goto _ctr173;
					}
					case 111: {
						goto _ctr427;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 391:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr428;
					}
					case 91: {
						goto _ctr173;
					}
					case 111: {
						goto _ctr428;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 392:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr429;
					}
					case 91: {
						goto _ctr173;
					}
					case 114: {
						goto _ctr429;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 393:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 85: {
						goto _ctr430;
					}
					case 91: {
						goto _ctr173;
					}
					case 117: {
						goto _ctr430;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 394:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr431;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 395:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr432;
				}
				goto _ctr140;
			}
			case 396:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr433;
				}
				goto _ctr140;
			}
			case 745:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr888;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr889;
				}
				goto _ctr888;
			}
			case 746:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 77: {
						goto _ctr890;
					}
					case 83: {
						goto _ctr891;
					}
					case 91: {
						goto _ctr173;
					}
					case 109: {
						goto _ctr890;
					}
					case 115: {
						goto _ctr891;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 397:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr434;
					}
					case 91: {
						goto _ctr173;
					}
					case 112: {
						goto _ctr434;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 398:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr435;
					}
					case 91: {
						goto _ctr173;
					}
					case 108: {
						goto _ctr435;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 399:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr436;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr436;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 400:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 67: {
						goto _ctr437;
					}
					case 91: {
						goto _ctr173;
					}
					case 99: {
						goto _ctr437;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 401:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr438;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr438;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 402:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr439;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr439;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 403:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr440;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr440;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 404:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr441;
					}
					case 91: {
						goto _ctr173;
					}
					case 111: {
						goto _ctr441;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 405:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr442;
					}
					case 91: {
						goto _ctr173;
					}
					case 110: {
						goto _ctr442;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 406:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr443;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 407:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr444;
				}
				goto _ctr140;
			}
			case 408:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr445;
				}
				goto _ctr140;
			}
			case 747:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr892;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr893;
				}
				goto _ctr892;
			}
			case 409:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 83: {
						goto _ctr446;
					}
					case 91: {
						goto _ctr173;
					}
					case 115: {
						goto _ctr446;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 410:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 85: {
						goto _ctr447;
					}
					case 91: {
						goto _ctr173;
					}
					case 117: {
						goto _ctr447;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 411:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr448;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr448;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 412:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr449;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 413:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr450;
				}
				goto _ctr140;
			}
			case 414:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr451;
				}
				goto _ctr140;
			}
			case 748:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr894;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr895;
				}
				goto _ctr894;
			}
			case 749:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr896;
					}
					case 91: {
						goto _ctr173;
					}
					case 111: {
						goto _ctr896;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 415:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr452;
					}
					case 91: {
						goto _ctr173;
					}
					case 100: {
						goto _ctr452;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 416:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr453;
					}
					case 82: {
						goto _ctr454;
					}
					case 91: {
						goto _ctr173;
					}
					case 114: {
						goto _ctr454;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 417:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr455;
					}
					case 97: {
						goto _ctr455;
					}
				}
				goto _ctr140;
			}
			case 418:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 67: {
						goto _ctr456;
					}
					case 99: {
						goto _ctr456;
					}
				}
				goto _ctr140;
			}
			case 419:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr457;
					}
					case 116: {
						goto _ctr457;
					}
				}
				goto _ctr140;
			}
			case 420:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr458;
					}
					case 105: {
						goto _ctr458;
					}
				}
				goto _ctr140;
			}
			case 421:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr459;
					}
					case 111: {
						goto _ctr459;
					}
				}
				goto _ctr140;
			}
			case 422:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr460;
					}
					case 110: {
						goto _ctr460;
					}
				}
				goto _ctr140;
			}
			case 423:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 32 ) {
					goto _ctr461;
				}
				goto _ctr140;
			}
			case 424:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr462;
				}
				goto _ctr140;
			}
			case 425:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr463;
				}
				goto _ctr140;
			}
			case 750:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr897;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr898;
				}
				goto _ctr897;
			}
			case 426:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr464;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr464;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 427:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr465;
					}
					case 91: {
						goto _ctr173;
					}
					case 112: {
						goto _ctr465;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 428:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr466;
					}
					case 91: {
						goto _ctr173;
					}
					case 111: {
						goto _ctr466;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 429:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr467;
					}
					case 91: {
						goto _ctr173;
					}
					case 114: {
						goto _ctr467;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 430:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr468;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr468;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 431:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr469;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 432:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr470;
				}
				goto _ctr140;
			}
			case 433:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr471;
				}
				goto _ctr140;
			}
			case 751:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr899;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr900;
				}
				goto _ctr899;
			}
			case 752:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr901;
					}
					case 79: {
						goto _ctr902;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr901;
					}
					case 111: {
						goto _ctr902;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 434:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 74: {
						goto _ctr472;
					}
					case 91: {
						goto _ctr173;
					}
					case 106: {
						goto _ctr472;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 435:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr473;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr473;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 436:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr474;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr474;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 437:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr475;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 438:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr476;
				}
				goto _ctr140;
			}
			case 439:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr477;
				}
				goto _ctr140;
			}
			case 753:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr903;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr904;
				}
				goto _ctr903;
			}
			case 440:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr478;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr478;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 441:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr479;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr479;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 442:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr480;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 443:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr481;
				}
				goto _ctr140;
			}
			case 444:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr482;
				}
				goto _ctr140;
			}
			case 754:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr905;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr906;
				}
				goto _ctr905;
			}
			case 755:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr907;
					}
					case 73: {
						goto _ctr908;
					}
					case 79: {
						goto _ctr909;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr907;
					}
					case 105: {
						goto _ctr908;
					}
					case 111: {
						goto _ctr909;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 445:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 87: {
						goto _ctr483;
					}
					case 91: {
						goto _ctr173;
					}
					case 119: {
						goto _ctr483;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 446:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr484;
					}
					case 91: {
						goto _ctr173;
					}
					case 111: {
						goto _ctr484;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 447:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr485;
					}
					case 91: {
						goto _ctr173;
					}
					case 111: {
						goto _ctr485;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 448:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr486;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 449:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr487;
				}
				goto _ctr140;
			}
			case 450:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr488;
				}
				goto _ctr140;
			}
			case 756:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr910;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr911;
				}
				goto _ctr910;
			}
			case 451:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 88: {
						goto _ctr489;
					}
					case 91: {
						goto _ctr173;
					}
					case 120: {
						goto _ctr489;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 452:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr490;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr490;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 453:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 86: {
						goto _ctr491;
					}
					case 91: {
						goto _ctr173;
					}
					case 118: {
						goto _ctr491;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 454:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr492;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 455:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr493;
				}
				goto _ctr140;
			}
			case 456:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr494;
				}
				goto _ctr140;
			}
			case 757:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr912;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr913;
				}
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr914;
				}
				goto _ctr912;
			}
			case 457:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr495;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr496;
					}
					case 112: {
						goto _ctr496;
					}
				}
				goto _ctr495;
			}
			case 458:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr495;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr497;
				}
				goto _ctr495;
			}
			case 758:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr915;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr916;
				}
				goto _ctr915;
			}
			case 459:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr498;
					}
					case 83: {
						goto _ctr499;
					}
					case 91: {
						goto _ctr173;
					}
					case 111: {
						goto _ctr498;
					}
					case 115: {
						goto _ctr499;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 460:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr500;
					}
					case 91: {
						goto _ctr173;
					}
					case 108: {
						goto _ctr500;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 461:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr501;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 462:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr502;
				}
				goto _ctr140;
			}
			case 463:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr503;
				}
				goto _ctr140;
			}
			case 759:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr917;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr918;
				}
				goto _ctr917;
			}
			case 464:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr504;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr504;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 465:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr505;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 466:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr506;
				}
				goto _ctr140;
			}
			case 467:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr507;
				}
				goto _ctr140;
			}
			case 760:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr919;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr920;
				}
				goto _ctr919;
			}
			case 761:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr921;
					}
					case 69: {
						goto _ctr922;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr921;
					}
					case 101: {
						goto _ctr922;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 468:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr508;
					}
					case 91: {
						goto _ctr173;
					}
					case 110: {
						goto _ctr508;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 469:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 75: {
						goto _ctr509;
					}
					case 91: {
						goto _ctr173;
					}
					case 107: {
						goto _ctr509;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 470:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr510;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr510;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 471:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 75: {
						goto _ctr511;
					}
					case 91: {
						goto _ctr173;
					}
					case 107: {
						goto _ctr511;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 472:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 85: {
						goto _ctr512;
					}
					case 91: {
						goto _ctr173;
					}
					case 117: {
						goto _ctr512;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 473:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr513;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 474:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr514;
				}
				goto _ctr140;
			}
			case 475:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr515;
				}
				goto _ctr140;
			}
			case 762:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr923;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr924;
				}
				goto _ctr923;
			}
			case 476:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr516;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr516;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 477:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 71: {
						goto _ctr517;
					}
					case 91: {
						goto _ctr173;
					}
					case 103: {
						goto _ctr517;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 478:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr518;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr518;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 479:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr519;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 480:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr520;
				}
				goto _ctr140;
			}
			case 481:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr521;
				}
				goto _ctr140;
			}
			case 763:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr925;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr926;
				}
				goto _ctr925;
			}
			case 764:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr927;
					}
					case 87: {
						goto _ctr928;
					}
					case 91: {
						goto _ctr173;
					}
					case 111: {
						goto _ctr927;
					}
					case 119: {
						goto _ctr928;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 482:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr522;
					}
					case 91: {
						goto _ctr173;
					}
					case 112: {
						goto _ctr522;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 483:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr523;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr523;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 484:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 67: {
						goto _ctr524;
					}
					case 91: {
						goto _ctr173;
					}
					case 99: {
						goto _ctr524;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 485:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr525;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 486:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr526;
				}
				goto _ctr140;
			}
			case 487:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr527;
				}
				goto _ctr140;
			}
			case 765:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr929;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr930;
				}
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr931;
				}
				goto _ctr929;
			}
			case 488:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr528;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr529;
					}
					case 112: {
						goto _ctr529;
					}
				}
				goto _ctr528;
			}
			case 489:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr528;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr530;
				}
				goto _ctr528;
			}
			case 766:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr932;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr933;
				}
				goto _ctr932;
			}
			case 490:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr531;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr531;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 491:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr532;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr532;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 492:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr533;
					}
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr533;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 493:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr534;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr534;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 494:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr535;
					}
					case 91: {
						goto _ctr173;
					}
					case 114: {
						goto _ctr535;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 495:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr536;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 496:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr537;
				}
				goto _ctr140;
			}
			case 497:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr538;
				}
				goto _ctr140;
			}
			case 767:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr934;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr935;
				}
				goto _ctr934;
			}
			case 768:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 83: {
						goto _ctr936;
					}
					case 91: {
						goto _ctr173;
					}
					case 115: {
						goto _ctr936;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 498:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr539;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr539;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 499:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr540;
					}
					case 91: {
						goto _ctr173;
					}
					case 114: {
						goto _ctr540;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 500:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr541;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 501:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr542;
				}
				goto _ctr140;
			}
			case 502:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr543;
				}
				goto _ctr140;
			}
			case 769:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr937;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr938;
				}
				goto _ctr937;
			}
			case 770:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr939;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr939;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 503:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 75: {
						goto _ctr544;
					}
					case 91: {
						goto _ctr173;
					}
					case 107: {
						goto _ctr544;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 504:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr545;
					}
					case 91: {
						goto _ctr173;
					}
					case 105: {
						goto _ctr545;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 505:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr546;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 506:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr547;
				}
				goto _ctr140;
			}
			case 507:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr548;
				}
				goto _ctr140;
			}
			case 771:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr940;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr941;
				}
				goto _ctr940;
			}
			case 772:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr942;
					}
					case 91: {
						goto _ctr173;
					}
					case 97: {
						goto _ctr942;
					}
				}
				if ( ( (*( ( sm->p)))) < 66 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 98 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 508:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr549;
					}
					case 91: {
						goto _ctr173;
					}
					case 110: {
						goto _ctr549;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 509:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr550;
					}
					case 91: {
						goto _ctr173;
					}
					case 100: {
						goto _ctr550;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 510:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr551;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr551;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 511:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr552;
					}
					case 91: {
						goto _ctr173;
					}
					case 114: {
						goto _ctr552;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 512:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr553;
					}
					case 91: {
						goto _ctr173;
					}
					case 101: {
						goto _ctr553;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 513:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 32: {
						goto _ctr554;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 514:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 35 ) {
					goto _ctr555;
				}
				goto _ctr140;
			}
			case 515:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr556;
				}
				goto _ctr140;
			}
			case 773:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr943;	goto _again;
			}
			else {
				if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
					goto _ctr944;
				}
				goto _ctr943;
			}
			case 774:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 47: {
						goto _ctr945;
					}
					case 66: {
						goto _ctr946;
					}
					case 67: {
						goto _ctr947;
					}
					case 69: {
						goto _ctr948;
					}
					case 73: {
						goto _ctr949;
					}
					case 78: {
						goto _ctr950;
					}
					case 81: {
						goto _ctr951;
					}
					case 83: {
						goto _ctr952;
					}
					case 84: {
						goto _ctr953;
					}
					case 85: {
						goto _ctr954;
					}
					case 91: {
						goto _ctr174;
					}
					case 98: {
						goto _ctr946;
					}
					case 99: {
						goto _ctr947;
					}
					case 101: {
						goto _ctr948;
					}
					case 104: {
						goto _ctr955;
					}
					case 105: {
						goto _ctr949;
					}
					case 110: {
						goto _ctr950;
					}
					case 113: {
						goto _ctr951;
					}
					case 115: {
						goto _ctr952;
					}
					case 116: {
						goto _ctr953;
					}
					case 117: {
						goto _ctr954;
					}
				}
				goto _ctr815;
			}
			case 516:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 66: {
						goto _ctr557;
					}
					case 69: {
						goto _ctr558;
					}
					case 73: {
						goto _ctr559;
					}
					case 81: {
						goto _ctr560;
					}
					case 83: {
						goto _ctr561;
					}
					case 84: {
						goto _ctr562;
					}
					case 85: {
						goto _ctr563;
					}
					case 98: {
						goto _ctr557;
					}
					case 101: {
						goto _ctr558;
					}
					case 105: {
						goto _ctr559;
					}
					case 113: {
						goto _ctr560;
					}
					case 115: {
						goto _ctr561;
					}
					case 116: {
						goto _ctr562;
					}
					case 117: {
						goto _ctr563;
					}
				}
				goto _ctr140;
			}
			case 517:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr194;
				}
				goto _ctr140;
			}
			case 518:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 88: {
						goto _ctr564;
					}
					case 120: {
						goto _ctr564;
					}
				}
				goto _ctr140;
			}
			case 519:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr565;
					}
					case 112: {
						goto _ctr565;
					}
				}
				goto _ctr140;
			}
			case 520:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr566;
					}
					case 97: {
						goto _ctr566;
					}
				}
				goto _ctr140;
			}
			case 521:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr567;
					}
					case 110: {
						goto _ctr567;
					}
				}
				goto _ctr140;
			}
			case 522:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr568;
					}
					case 100: {
						goto _ctr568;
					}
				}
				goto _ctr140;
			}
			case 523:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr210;
				}
				goto _ctr140;
			}
			case 524:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr205;
				}
				goto _ctr140;
			}
			case 525:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 85: {
						goto _ctr569;
					}
					case 117: {
						goto _ctr569;
					}
				}
				goto _ctr140;
			}
			case 526:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr570;
					}
					case 111: {
						goto _ctr570;
					}
				}
				goto _ctr140;
			}
			case 527:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr571;
					}
					case 116: {
						goto _ctr571;
					}
				}
				goto _ctr140;
			}
			case 528:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr572;
					}
					case 101: {
						goto _ctr572;
					}
				}
				goto _ctr140;
			}
			case 529:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr203;
				}
				goto _ctr140;
			}
			case 530:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr573;
					}
					case 93: {
						goto _ctr211;
					}
					case 112: {
						goto _ctr573;
					}
				}
				goto _ctr140;
			}
			case 531:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr574;
					}
					case 111: {
						goto _ctr574;
					}
				}
				goto _ctr140;
			}
			case 532:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr575;
					}
					case 105: {
						goto _ctr575;
					}
				}
				goto _ctr140;
			}
			case 533:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr576;
					}
					case 108: {
						goto _ctr576;
					}
				}
				goto _ctr140;
			}
			case 534:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr577;
					}
					case 101: {
						goto _ctr577;
					}
				}
				goto _ctr140;
			}
			case 535:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr578;
					}
					case 114: {
						goto _ctr578;
					}
				}
				goto _ctr140;
			}
			case 536:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 83: {
						goto _ctr579;
					}
					case 93: {
						goto _ctr219;
					}
					case 115: {
						goto _ctr579;
					}
				}
				goto _ctr140;
			}
			case 537:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr219;
				}
				goto _ctr140;
			}
			case 538:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr580;
					}
					case 72: {
						goto _ctr581;
					}
					case 78: {
						goto _ctr582;
					}
					case 100: {
						goto _ctr580;
					}
					case 104: {
						goto _ctr581;
					}
					case 110: {
						goto _ctr582;
					}
				}
				goto _ctr140;
			}
			case 539:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr228;
				}
				goto _ctr140;
			}
			case 540:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr229;
				}
				goto _ctr140;
			}
			case 541:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr230;
				}
				goto _ctr140;
			}
			case 542:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr231;
				}
				goto _ctr140;
			}
			case 543:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr269;
				}
				goto _ctr140;
			}
			case 544:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr583;
					}
					case 111: {
						goto _ctr583;
					}
				}
				goto _ctr140;
			}
			case 545:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr584;
					}
					case 100: {
						goto _ctr584;
					}
				}
				goto _ctr140;
			}
			case 546:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr585;
					}
					case 101: {
						goto _ctr585;
					}
				}
				goto _ctr140;
			}
			case 547:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr283;
				}
				goto _ctr140;
			}
			case 548:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 88: {
						goto _ctr586;
					}
					case 120: {
						goto _ctr586;
					}
				}
				goto _ctr140;
			}
			case 549:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr587;
					}
					case 112: {
						goto _ctr587;
					}
				}
				goto _ctr140;
			}
			case 550:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr588;
					}
					case 97: {
						goto _ctr588;
					}
				}
				goto _ctr140;
			}
			case 551:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr589;
					}
					case 110: {
						goto _ctr589;
					}
				}
				goto _ctr140;
			}
			case 552:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr590;
					}
					case 100: {
						goto _ctr590;
					}
				}
				goto _ctr140;
			}
			case 553:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr291;
				}
				goto _ctr140;
			}
			case 554:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr286;
				}
				goto _ctr140;
			}
			case 555:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr591;
					}
					case 111: {
						goto _ctr591;
					}
				}
				goto _ctr140;
			}
			case 556:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr592;
					}
					case 100: {
						goto _ctr592;
					}
				}
				goto _ctr140;
			}
			case 557:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr593;
					}
					case 116: {
						goto _ctr593;
					}
				}
				goto _ctr140;
			}
			case 558:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr594;
					}
					case 101: {
						goto _ctr594;
					}
				}
				goto _ctr140;
			}
			case 559:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 88: {
						goto _ctr595;
					}
					case 120: {
						goto _ctr595;
					}
				}
				goto _ctr140;
			}
			case 560:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr596;
					}
					case 116: {
						goto _ctr596;
					}
				}
				goto _ctr140;
			}
			case 561:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr298;
				}
				goto _ctr140;
			}
			case 562:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 85: {
						goto _ctr597;
					}
					case 117: {
						goto _ctr597;
					}
				}
				goto _ctr140;
			}
			case 563:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr598;
					}
					case 111: {
						goto _ctr598;
					}
				}
				goto _ctr140;
			}
			case 564:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr599;
					}
					case 116: {
						goto _ctr599;
					}
				}
				goto _ctr140;
			}
			case 565:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr600;
					}
					case 101: {
						goto _ctr600;
					}
				}
				goto _ctr140;
			}
			case 566:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr279;
				}
				goto _ctr140;
			}
			case 567:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 80: {
						goto _ctr601;
					}
					case 93: {
						goto _ctr299;
					}
					case 112: {
						goto _ctr601;
					}
				}
				goto _ctr140;
			}
			case 568:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr602;
					}
					case 111: {
						goto _ctr602;
					}
				}
				goto _ctr140;
			}
			case 569:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 73: {
						goto _ctr603;
					}
					case 105: {
						goto _ctr603;
					}
				}
				goto _ctr140;
			}
			case 570:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr604;
					}
					case 108: {
						goto _ctr604;
					}
				}
				goto _ctr140;
			}
			case 571:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr605;
					}
					case 101: {
						goto _ctr605;
					}
				}
				goto _ctr140;
			}
			case 572:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 82: {
						goto _ctr606;
					}
					case 114: {
						goto _ctr606;
					}
				}
				goto _ctr140;
			}
			case 573:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 83: {
						goto _ctr607;
					}
					case 93: {
						goto _ctr307;
					}
					case 115: {
						goto _ctr607;
					}
				}
				goto _ctr140;
			}
			case 574:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr307;
				}
				goto _ctr140;
			}
			case 575:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr608;
					}
					case 110: {
						goto _ctr608;
					}
				}
				goto _ctr140;
			}
			case 576:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr314;
				}
				goto _ctr140;
			}
			case 577:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr315;
				}
				goto _ctr140;
			}
			case 578:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 116 ) {
					goto _ctr609;
				}
				goto _ctr140;
			}
			case 579:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 116 ) {
					goto _ctr610;
				}
				goto _ctr140;
			}
			case 580:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 112 ) {
					goto _ctr611;
				}
				goto _ctr140;
			}
			case 581:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 58: {
						goto _ctr612;
					}
					case 115: {
						goto _ctr613;
					}
				}
				goto _ctr140;
			}
			case 582:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr614;
				}
				goto _ctr140;
			}
			case 583:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr615;
				}
				goto _ctr140;
			}
			case 584:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr616;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr619;
						}
					} else {
						goto _ctr618;
					}
				} else {
					goto _ctr617;
				}
				goto _ctr140;
			}
			case 585:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr619;
				}
				goto _ctr140;
			}
			case 586:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr620;
				}
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr616;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr619;
						}
					} else {
						goto _ctr618;
					}
				} else {
					goto _ctr617;
				}
				goto _ctr140;
			}
			case 587:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr616;
				}
				goto _ctr140;
			}
			case 588:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr617;
				}
				goto _ctr140;
			}
			case 589:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 40: {
						goto _ctr621;
					}
					case 93: {
						goto _ctr620;
					}
				}
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr616;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr619;
						}
					} else {
						goto _ctr618;
					}
				} else {
					goto _ctr617;
				}
				goto _ctr140;
			}
			case 590:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 41 ) {
					goto _ctr140;
				}
				goto _ctr622;
			}
			case 591:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 41 ) {
					goto _ctr624;
				}
				goto _ctr623;
			}
			case 592:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 58 ) {
					goto _ctr612;
				}
				goto _ctr140;
			}
			case 775:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr956;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr815;
			}
			case 593:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 91: {
						goto _ctr173;
					}
					case 116: {
						goto _ctr625;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 594:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 91: {
						goto _ctr173;
					}
					case 112: {
						goto _ctr626;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 595:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 58: {
						goto _ctr627;
					}
					case 91: {
						goto _ctr173;
					}
					case 115: {
						goto _ctr628;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 596:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr629;
				}
				goto _ctr140;
			}
			case 597:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr630;
				}
				goto _ctr140;
			}
			case 598:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr631;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr634;
						}
					} else {
						goto _ctr633;
					}
				} else {
					goto _ctr632;
				}
				goto _ctr140;
			}
			case 599:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr133;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr634;
				}
				goto _ctr133;
			}
			case 776:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr957;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) < -32 ) {
					if ( -62 <= ( (*( ( sm->p)))) ) {
						goto _ctr631;
					}
				} else if ( ( (*( ( sm->p)))) > -17 ) {
					if ( ( (*( ( sm->p)))) > -12 ) {
						if ( 33 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 126 ) {
							goto _ctr634;
						}
					} else {
						goto _ctr633;
					}
				} else {
					goto _ctr632;
				}
				goto _ctr957;
			}
			case 600:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr133;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr631;
				}
				goto _ctr133;
			}
			case 601:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr133;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) <= -65 ) {
					goto _ctr632;
				}
				goto _ctr133;
			}
			case 602:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 58: {
						goto _ctr627;
					}
					case 91: {
						goto _ctr173;
					}
				}
				if ( ( (*( ( sm->p)))) < 65 ) {
					if ( 48 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 57 ) {
						goto _ctr172;
					}
				} else if ( ( (*( ( sm->p)))) > 90 ) {
					if ( 97 <= ( (*( ( sm->p)))) && ( (*( ( sm->p)))) <= 122 ) {
						goto _ctr172;
					}
				} else {
					goto _ctr172;
				}
				goto _ctr140;
			}
			case 777:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr815;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 123 ) {
					goto _ctr958;
				}
				goto _ctr815;
			}
			case 603:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 125 ) {
					goto _ctr140;
				}
				goto _ctr635;
			}
			case 604:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 125 ) {
					goto _ctr637;
				}
				goto _ctr636;
			}
			case 605:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr140;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 125 ) {
					goto _ctr638;
				}
				goto _ctr140;
			}
			case 778:
			{
#line 1 "NONE"
				{( sm->ts) = ( sm->p);}}
			
#line 13111 "ext/dtext/dtext.c"
			
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr959;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 60: {
						goto _ctr961;
					}
					case 91: {
						goto _ctr962;
					}
				}
				goto _ctr960;
			}
			case 779:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr963;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr964;
				}
				goto _ctr963;
			}
			case 606:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr639;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 67: {
						goto _ctr640;
					}
					case 99: {
						goto _ctr640;
					}
				}
				goto _ctr639;
			}
			case 607:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr639;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr641;
					}
					case 111: {
						goto _ctr641;
					}
				}
				goto _ctr639;
			}
			case 608:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr639;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr642;
					}
					case 100: {
						goto _ctr642;
					}
				}
				goto _ctr639;
			}
			case 609:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr639;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr643;
					}
					case 101: {
						goto _ctr643;
					}
				}
				goto _ctr639;
			}
			case 610:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr639;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr644;
				}
				goto _ctr639;
			}
			case 780:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr963;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr965;
				}
				goto _ctr963;
			}
			case 611:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr639;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 67: {
						goto _ctr645;
					}
					case 99: {
						goto _ctr645;
					}
				}
				goto _ctr639;
			}
			case 612:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr639;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr646;
					}
					case 111: {
						goto _ctr646;
					}
				}
				goto _ctr639;
			}
			case 613:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr639;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr647;
					}
					case 100: {
						goto _ctr647;
					}
				}
				goto _ctr639;
			}
			case 614:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr639;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr648;
					}
					case 101: {
						goto _ctr648;
					}
				}
				goto _ctr639;
			}
			case 615:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr639;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr644;
				}
				goto _ctr639;
			}
			case 781:
			{
#line 1 "NONE"
				{( sm->ts) = ( sm->p);}}
			
#line 13292 "ext/dtext/dtext.c"
			
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr966;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 60: {
						goto _ctr968;
					}
					case 91: {
						goto _ctr969;
					}
				}
				goto _ctr967;
			}
			case 782:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr970;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr971;
				}
				goto _ctr970;
			}
			case 616:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr650;
					}
					case 110: {
						goto _ctr650;
					}
				}
				goto _ctr649;
			}
			case 617:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr651;
					}
					case 111: {
						goto _ctr651;
					}
				}
				goto _ctr649;
			}
			case 618:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr652;
					}
					case 100: {
						goto _ctr652;
					}
				}
				goto _ctr649;
			}
			case 619:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr653;
					}
					case 116: {
						goto _ctr653;
					}
				}
				goto _ctr649;
			}
			case 620:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr654;
					}
					case 101: {
						goto _ctr654;
					}
				}
				goto _ctr649;
			}
			case 621:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 88: {
						goto _ctr655;
					}
					case 120: {
						goto _ctr655;
					}
				}
				goto _ctr649;
			}
			case 622:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr656;
					}
					case 116: {
						goto _ctr656;
					}
				}
				goto _ctr649;
			}
			case 623:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr657;
				}
				goto _ctr649;
			}
			case 783:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr970;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 47 ) {
					goto _ctr972;
				}
				goto _ctr970;
			}
			case 624:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 78: {
						goto _ctr658;
					}
					case 110: {
						goto _ctr658;
					}
				}
				goto _ctr649;
			}
			case 625:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr659;
					}
					case 111: {
						goto _ctr659;
					}
				}
				goto _ctr649;
			}
			case 626:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr660;
					}
					case 100: {
						goto _ctr660;
					}
				}
				goto _ctr649;
			}
			case 627:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr661;
					}
					case 116: {
						goto _ctr661;
					}
				}
				goto _ctr649;
			}
			case 628:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr662;
					}
					case 101: {
						goto _ctr662;
					}
				}
				goto _ctr649;
			}
			case 629:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 88: {
						goto _ctr663;
					}
					case 120: {
						goto _ctr663;
					}
				}
				goto _ctr649;
			}
			case 630:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr664;
					}
					case 116: {
						goto _ctr664;
					}
				}
				goto _ctr649;
			}
			case 631:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr649;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr657;
				}
				goto _ctr649;
			}
			case 784:
			{
#line 1 "NONE"
				{( sm->ts) = ( sm->p);}}
			
#line 13563 "ext/dtext/dtext.c"
			
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr973;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 60: {
						goto _ctr975;
					}
					case 91: {
						goto _ctr976;
					}
				}
				goto _ctr974;
			}
			case 785:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr977;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 47: {
						goto _ctr978;
					}
					case 84: {
						goto _ctr979;
					}
					case 116: {
						goto _ctr979;
					}
				}
				goto _ctr977;
			}
			case 632:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr666;
					}
					case 116: {
						goto _ctr666;
					}
				}
				goto _ctr665;
			}
			case 633:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr667;
					}
					case 66: {
						goto _ctr668;
					}
					case 72: {
						goto _ctr669;
					}
					case 82: {
						goto _ctr670;
					}
					case 97: {
						goto _ctr667;
					}
					case 98: {
						goto _ctr668;
					}
					case 104: {
						goto _ctr669;
					}
					case 114: {
						goto _ctr670;
					}
				}
				goto _ctr665;
			}
			case 634:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 66: {
						goto _ctr671;
					}
					case 98: {
						goto _ctr671;
					}
				}
				goto _ctr665;
			}
			case 635:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr672;
					}
					case 108: {
						goto _ctr672;
					}
				}
				goto _ctr665;
			}
			case 636:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr673;
					}
					case 101: {
						goto _ctr673;
					}
				}
				goto _ctr665;
			}
			case 637:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr674;
				}
				goto _ctr665;
			}
			case 638:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr675;
					}
					case 111: {
						goto _ctr675;
					}
				}
				goto _ctr665;
			}
			case 639:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr676;
					}
					case 100: {
						goto _ctr676;
					}
				}
				goto _ctr665;
			}
			case 640:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 89: {
						goto _ctr677;
					}
					case 121: {
						goto _ctr677;
					}
				}
				goto _ctr665;
			}
			case 641:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr678;
				}
				goto _ctr665;
			}
			case 642:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr679;
					}
					case 101: {
						goto _ctr679;
					}
				}
				goto _ctr665;
			}
			case 643:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr680;
					}
					case 97: {
						goto _ctr680;
					}
				}
				goto _ctr665;
			}
			case 644:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr681;
					}
					case 100: {
						goto _ctr681;
					}
				}
				goto _ctr665;
			}
			case 645:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr682;
				}
				goto _ctr665;
			}
			case 646:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr683;
				}
				goto _ctr665;
			}
			case 647:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 66: {
						goto _ctr684;
					}
					case 68: {
						goto _ctr685;
					}
					case 72: {
						goto _ctr686;
					}
					case 82: {
						goto _ctr687;
					}
					case 98: {
						goto _ctr684;
					}
					case 100: {
						goto _ctr685;
					}
					case 104: {
						goto _ctr686;
					}
					case 114: {
						goto _ctr687;
					}
				}
				goto _ctr665;
			}
			case 648:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr688;
					}
					case 111: {
						goto _ctr688;
					}
				}
				goto _ctr665;
			}
			case 649:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr689;
					}
					case 100: {
						goto _ctr689;
					}
				}
				goto _ctr665;
			}
			case 650:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 89: {
						goto _ctr690;
					}
					case 121: {
						goto _ctr690;
					}
				}
				goto _ctr665;
			}
			case 651:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr691;
				}
				goto _ctr665;
			}
			case 652:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr692;
				}
				goto _ctr665;
			}
			case 653:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 62: {
						goto _ctr693;
					}
					case 69: {
						goto _ctr694;
					}
					case 101: {
						goto _ctr694;
					}
				}
				goto _ctr665;
			}
			case 654:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr695;
					}
					case 97: {
						goto _ctr695;
					}
				}
				goto _ctr665;
			}
			case 655:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr696;
					}
					case 100: {
						goto _ctr696;
					}
				}
				goto _ctr665;
			}
			case 656:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr697;
				}
				goto _ctr665;
			}
			case 657:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 62 ) {
					goto _ctr698;
				}
				goto _ctr665;
			}
			case 786:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr977;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 47: {
						goto _ctr980;
					}
					case 84: {
						goto _ctr981;
					}
					case 116: {
						goto _ctr981;
					}
				}
				goto _ctr977;
			}
			case 658:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 84: {
						goto _ctr699;
					}
					case 116: {
						goto _ctr699;
					}
				}
				goto _ctr665;
			}
			case 659:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr700;
					}
					case 66: {
						goto _ctr701;
					}
					case 72: {
						goto _ctr702;
					}
					case 82: {
						goto _ctr703;
					}
					case 97: {
						goto _ctr700;
					}
					case 98: {
						goto _ctr701;
					}
					case 104: {
						goto _ctr702;
					}
					case 114: {
						goto _ctr703;
					}
				}
				goto _ctr665;
			}
			case 660:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 66: {
						goto _ctr704;
					}
					case 98: {
						goto _ctr704;
					}
				}
				goto _ctr665;
			}
			case 661:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 76: {
						goto _ctr705;
					}
					case 108: {
						goto _ctr705;
					}
				}
				goto _ctr665;
			}
			case 662:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr706;
					}
					case 101: {
						goto _ctr706;
					}
				}
				goto _ctr665;
			}
			case 663:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr674;
				}
				goto _ctr665;
			}
			case 664:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr707;
					}
					case 111: {
						goto _ctr707;
					}
				}
				goto _ctr665;
			}
			case 665:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr708;
					}
					case 100: {
						goto _ctr708;
					}
				}
				goto _ctr665;
			}
			case 666:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 89: {
						goto _ctr709;
					}
					case 121: {
						goto _ctr709;
					}
				}
				goto _ctr665;
			}
			case 667:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr678;
				}
				goto _ctr665;
			}
			case 668:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr710;
					}
					case 101: {
						goto _ctr710;
					}
				}
				goto _ctr665;
			}
			case 669:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr711;
					}
					case 97: {
						goto _ctr711;
					}
				}
				goto _ctr665;
			}
			case 670:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr712;
					}
					case 100: {
						goto _ctr712;
					}
				}
				goto _ctr665;
			}
			case 671:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr682;
				}
				goto _ctr665;
			}
			case 672:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr683;
				}
				goto _ctr665;
			}
			case 673:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 66: {
						goto _ctr713;
					}
					case 68: {
						goto _ctr714;
					}
					case 72: {
						goto _ctr715;
					}
					case 82: {
						goto _ctr716;
					}
					case 98: {
						goto _ctr713;
					}
					case 100: {
						goto _ctr714;
					}
					case 104: {
						goto _ctr715;
					}
					case 114: {
						goto _ctr716;
					}
				}
				goto _ctr665;
			}
			case 674:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 79: {
						goto _ctr717;
					}
					case 111: {
						goto _ctr717;
					}
				}
				goto _ctr665;
			}
			case 675:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr718;
					}
					case 100: {
						goto _ctr718;
					}
				}
				goto _ctr665;
			}
			case 676:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 89: {
						goto _ctr719;
					}
					case 121: {
						goto _ctr719;
					}
				}
				goto _ctr665;
			}
			case 677:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr691;
				}
				goto _ctr665;
			}
			case 678:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr692;
				}
				goto _ctr665;
			}
			case 679:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 69: {
						goto _ctr720;
					}
					case 93: {
						goto _ctr693;
					}
					case 101: {
						goto _ctr720;
					}
				}
				goto _ctr665;
			}
			case 680:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 65: {
						goto _ctr721;
					}
					case 97: {
						goto _ctr721;
					}
				}
				goto _ctr665;
			}
			case 681:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 68: {
						goto _ctr722;
					}
					case 100: {
						goto _ctr722;
					}
				}
				goto _ctr665;
			}
			case 682:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr697;
				}
				goto _ctr665;
			}
			case 683:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr665;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 93 ) {
					goto _ctr698;
				}
				goto _ctr665;
			}
			case 787:
			{
#line 1 "NONE"
				{( sm->ts) = ( sm->p);}}
			
#line 14398 "ext/dtext/dtext.c"
			
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr982;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr984;
					}
					case 13: {
						goto _ctr985;
					}
					case 42: {
						goto _ctr986;
					}
				}
				goto _ctr983;
			}
			case 788:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr723;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr724;
					}
					case 13: {
						goto _ctr987;
					}
				}
				goto _ctr723;
			}
			case 684:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr723;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 10 ) {
					goto _ctr724;
				}
				goto _ctr723;
			}
			case 789:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr988;	goto _again;
			}
			else {
				if ( ( (*( ( sm->p)))) == 10 ) {
					goto _ctr984;
				}
				goto _ctr988;
			}
			case 790:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr988;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr728;
					}
					case 32: {
						goto _ctr728;
					}
					case 42: {
						goto _ctr729;
					}
				}
				goto _ctr988;
			}
			case 685:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr725;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr727;
					}
					case 10: {
						goto _ctr725;
					}
					case 13: {
						goto _ctr725;
					}
					case 32: {
						goto _ctr727;
					}
				}
				goto _ctr726;
			}
			case 791:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr989;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 10: {
						goto _ctr989;
					}
					case 13: {
						goto _ctr989;
					}
				}
				goto _ctr990;
			}
			case 792:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr989;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr727;
					}
					case 10: {
						goto _ctr989;
					}
					case 13: {
						goto _ctr989;
					}
					case 32: {
						goto _ctr727;
					}
				}
				goto _ctr726;
			}
			case 686:
			if ( ( sm->p) == ( sm->eof) ) {
				goto _ctr725;	goto _again;
			}
			else {
				switch( ( (*( ( sm->p)))) ) {
					case 9: {
						goto _ctr728;
					}
					case 32: {
						goto _ctr728;
					}
					case 42: {
						goto _ctr729;
					}
				}
				goto _ctr725;
			}
		}
		
		_ctr738: sm->cs = 0; goto _again;
		_ctr5: sm->cs = 1; goto f4;
		_ctr6: sm->cs = 2; goto _again;
		_ctr742: sm->cs = 3; goto _again;
		_ctr7: sm->cs = 4; goto _again;
		_ctr8: sm->cs = 5; goto _again;
		_ctr9: sm->cs = 6; goto _again;
		_ctr10: sm->cs = 7; goto _again;
		_ctr11: sm->cs = 8; goto _again;
		_ctr12: sm->cs = 9; goto _again;
		_ctr13: sm->cs = 10; goto _again;
		_ctr15: sm->cs = 11; goto _again;
		_ctr743: sm->cs = 12; goto _again;
		_ctr16: sm->cs = 13; goto _again;
		_ctr17: sm->cs = 14; goto _again;
		_ctr18: sm->cs = 15; goto _again;
		_ctr19: sm->cs = 16; goto _again;
		_ctr20: sm->cs = 17; goto _again;
		_ctr21: sm->cs = 18; goto _again;
		_ctr22: sm->cs = 19; goto _again;
		_ctr23: sm->cs = 20; goto _again;
		_ctr24: sm->cs = 21; goto _again;
		_ctr744: sm->cs = 22; goto _again;
		_ctr26: sm->cs = 23; goto _again;
		_ctr27: sm->cs = 24; goto _again;
		_ctr28: sm->cs = 25; goto _again;
		_ctr745: sm->cs = 26; goto _again;
		_ctr30: sm->cs = 27; goto _again;
		_ctr31: sm->cs = 28; goto _again;
		_ctr32: sm->cs = 29; goto _again;
		_ctr33: sm->cs = 30; goto _again;
		_ctr34: sm->cs = 31; goto _again;
		_ctr746: sm->cs = 32; goto _again;
		_ctr36: sm->cs = 33; goto _again;
		_ctr37: sm->cs = 34; goto _again;
		_ctr38: sm->cs = 35; goto _again;
		_ctr39: sm->cs = 36; goto _again;
		_ctr40: sm->cs = 37; goto _again;
		_ctr41: sm->cs = 38; goto _again;
		_ctr747: sm->cs = 39; goto _again;
		_ctr43: sm->cs = 40; goto _again;
		_ctr44: sm->cs = 41; goto _again;
		_ctr45: sm->cs = 42; goto _again;
		_ctr46: sm->cs = 43; goto _again;
		_ctr47: sm->cs = 44; goto _again;
		_ctr48: sm->cs = 45; goto _again;
		_ctr50: sm->cs = 46; goto _again;
		_ctr748: sm->cs = 47; goto _again;
		_ctr51: sm->cs = 48; goto _again;
		_ctr53: sm->cs = 49; goto _again;
		_ctr54: sm->cs = 50; goto _again;
		_ctr55: sm->cs = 51; goto _again;
		_ctr52: sm->cs = 52; goto _again;
		_ctr754: sm->cs = 53; goto f9;
		_ctr58: sm->cs = 54; goto f4;
		_ctr61: sm->cs = 55; goto _again;
		_ctr60: sm->cs = 55; goto f3;
		_ctr759: sm->cs = 56; goto _again;
		_ctr63: sm->cs = 57; goto _again;
		_ctr64: sm->cs = 58; goto _again;
		_ctr65: sm->cs = 59; goto _again;
		_ctr66: sm->cs = 60; goto _again;
		_ctr67: sm->cs = 61; goto _again;
		_ctr68: sm->cs = 62; goto _again;
		_ctr69: sm->cs = 63; goto _again;
		_ctr70: sm->cs = 64; goto _again;
		_ctr760: sm->cs = 65; goto _again;
		_ctr71: sm->cs = 66; goto _again;
		_ctr72: sm->cs = 67; goto _again;
		_ctr73: sm->cs = 68; goto _again;
		_ctr761: sm->cs = 69; goto _again;
		_ctr74: sm->cs = 70; goto _again;
		_ctr75: sm->cs = 71; goto _again;
		_ctr76: sm->cs = 72; goto _again;
		_ctr77: sm->cs = 73; goto _again;
		_ctr78: sm->cs = 74; goto _again;
		_ctr79: sm->cs = 75; goto _again;
		_ctr81: sm->cs = 76; goto _again;
		_ctr80: sm->cs = 76; goto f9;
		_ctr762: sm->cs = 77; goto _again;
		_ctr83: sm->cs = 78; goto _again;
		_ctr84: sm->cs = 79; goto _again;
		_ctr85: sm->cs = 80; goto _again;
		_ctr86: sm->cs = 81; goto _again;
		_ctr87: sm->cs = 82; goto _again;
		_ctr88: sm->cs = 83; goto _again;
		_ctr763: sm->cs = 84; goto _again;
		_ctr89: sm->cs = 85; goto _again;
		_ctr90: sm->cs = 86; goto _again;
		_ctr91: sm->cs = 87; goto _again;
		_ctr92: sm->cs = 88; goto _again;
		_ctr764: sm->cs = 89; goto _again;
		_ctr93: sm->cs = 90; goto _again;
		_ctr94: sm->cs = 91; goto _again;
		_ctr95: sm->cs = 92; goto _again;
		_ctr96: sm->cs = 93; goto _again;
		_ctr97: sm->cs = 94; goto _again;
		_ctr98: sm->cs = 95; goto _again;
		_ctr99: sm->cs = 96; goto _again;
		_ctr765: sm->cs = 97; goto _again;
		_ctr100: sm->cs = 98; goto _again;
		_ctr102: sm->cs = 99; goto _again;
		_ctr103: sm->cs = 100; goto _again;
		_ctr104: sm->cs = 101; goto _again;
		_ctr101: sm->cs = 102; goto _again;
		_ctr773: sm->cs = 103; goto _again;
		_ctr106: sm->cs = 104; goto _again;
		_ctr107: sm->cs = 105; goto _again;
		_ctr108: sm->cs = 106; goto _again;
		_ctr109: sm->cs = 107; goto _again;
		_ctr114: sm->cs = 108; goto _again;
		_ctr115: sm->cs = 109; goto _again;
		_ctr116: sm->cs = 110; goto _again;
		_ctr117: sm->cs = 111; goto _again;
		_ctr110: sm->cs = 112; goto _again;
		_ctr127: sm->cs = 113; goto _again;
		_ctr774: sm->cs = 114; goto _again;
		_ctr120: sm->cs = 115; goto _again;
		_ctr775: sm->cs = 116; goto _again;
		_ctr123: sm->cs = 117; goto _again;
		_ctr124: sm->cs = 118; goto _again;
		_ctr125: sm->cs = 119; goto _again;
		_ctr126: sm->cs = 120; goto _again;
		_ctr776: sm->cs = 121; goto _again;
		_ctr777: sm->cs = 122; goto _again;
		_ctr129: sm->cs = 123; goto _again;
		_ctr130: sm->cs = 124; goto _again;
		_ctr131: sm->cs = 125; goto _again;
		_ctr132: sm->cs = 126; goto _again;
		_ctr778: sm->cs = 127; goto _again;
		_ctr779: sm->cs = 128; goto _again;
		_ctr780: sm->cs = 129; goto _again;
		_ctr781: sm->cs = 130; goto _again;
		_ctr809: sm->cs = 131; goto _again;
		_ctr137: sm->cs = 132; goto _again;
		_ctr810: sm->cs = 132; goto f9;
		_ctr136: sm->cs = 133; goto f4;
		_ctr141: sm->cs = 134; goto _again;
		_ctr816: sm->cs = 134; goto f9;
		_ctr142: sm->cs = 135; goto f4;
		_ctr143: sm->cs = 136; goto _again;
		_ctr171: sm->cs = 137; goto _again;
		_ctr144: sm->cs = 137; goto f3;
		_ctr147: sm->cs = 138; goto _again;
		_ctr148: sm->cs = 139; goto _again;
		_ctr149: sm->cs = 140; goto _again;
		_ctr145: sm->cs = 141; goto _again;
		_ctr164: sm->cs = 142; goto _again;
		_ctr151: sm->cs = 142; goto f3;
		_ctr153: sm->cs = 143; goto _again;
		_ctr156: sm->cs = 144; goto f8;
		_ctr154: sm->cs = 145; goto _again;
		_ctr155: sm->cs = 146; goto _again;
		_ctr152: sm->cs = 147; goto f3;
		_ctr158: sm->cs = 148; goto _again;
		_ctr159: sm->cs = 149; goto _again;
		_ctr160: sm->cs = 150; goto _again;
		_ctr161: sm->cs = 151; goto _again;
		_ctr163: sm->cs = 152; goto _again;
		_ctr162: sm->cs = 153; goto _again;
		_ctr146: sm->cs = 154; goto f3;
		_ctr165: sm->cs = 155; goto _again;
		_ctr166: sm->cs = 156; goto _again;
		_ctr167: sm->cs = 157; goto _again;
		_ctr168: sm->cs = 158; goto _again;
		_ctr170: sm->cs = 159; goto _again;
		_ctr169: sm->cs = 160; goto _again;
		_ctr172: sm->cs = 161; goto _again;
		_ctr173: sm->cs = 162; goto f4;
		_ctr174: sm->cs = 163; goto _again;
		_ctr177: sm->cs = 164; goto _again;
		_ctr175: sm->cs = 164; goto f3;
		_ctr178: sm->cs = 165; goto f8;
		_ctr179: sm->cs = 166; goto f8;
		_ctr183: sm->cs = 167; goto _again;
		_ctr181: sm->cs = 167; goto f25;
		_ctr182: sm->cs = 168; goto f26;
		_ctr184: sm->cs = 168; goto f27;
		_ctr186: sm->cs = 169; goto _again;
		_ctr176: sm->cs = 169; goto f3;
		_ctr826: sm->cs = 170; goto _again;
		_ctr187: sm->cs = 171; goto _again;
		_ctr195: sm->cs = 172; goto _again;
		_ctr196: sm->cs = 173; goto _again;
		_ctr197: sm->cs = 174; goto _again;
		_ctr198: sm->cs = 175; goto _again;
		_ctr190: sm->cs = 176; goto _again;
		_ctr199: sm->cs = 177; goto _again;
		_ctr200: sm->cs = 178; goto _again;
		_ctr201: sm->cs = 179; goto _again;
		_ctr202: sm->cs = 180; goto _again;
		_ctr188: sm->cs = 181; goto _again;
		_ctr189: sm->cs = 182; goto _again;
		_ctr204: sm->cs = 183; goto _again;
		_ctr206: sm->cs = 184; goto _again;
		_ctr207: sm->cs = 185; goto _again;
		_ctr208: sm->cs = 186; goto _again;
		_ctr209: sm->cs = 187; goto _again;
		_ctr191: sm->cs = 188; goto _again;
		_ctr212: sm->cs = 189; goto _again;
		_ctr214: sm->cs = 190; goto _again;
		_ctr215: sm->cs = 191; goto _again;
		_ctr216: sm->cs = 192; goto _again;
		_ctr217: sm->cs = 193; goto _again;
		_ctr218: sm->cs = 194; goto _again;
		_ctr220: sm->cs = 195; goto _again;
		_ctr213: sm->cs = 196; goto _again;
		_ctr221: sm->cs = 197; goto _again;
		_ctr222: sm->cs = 198; goto _again;
		_ctr223: sm->cs = 199; goto _again;
		_ctr224: sm->cs = 200; goto _again;
		_ctr192: sm->cs = 201; goto _again;
		_ctr225: sm->cs = 202; goto _again;
		_ctr226: sm->cs = 203; goto _again;
		_ctr227: sm->cs = 204; goto _again;
		_ctr193: sm->cs = 205; goto _again;
		_ctr827: sm->cs = 206; goto _again;
		_ctr237: sm->cs = 207; goto _again;
		_ctr232: sm->cs = 207; goto f9;
		_ctr236: sm->cs = 208; goto _again;
		_ctr235: sm->cs = 208; goto f9;
		_ctr238: sm->cs = 209; goto _again;
		_ctr233: sm->cs = 209; goto f9;
		_ctr239: sm->cs = 210; goto _again;
		_ctr234: sm->cs = 210; goto f9;
		_ctr828: sm->cs = 211; goto _again;
		_ctr241: sm->cs = 212; goto _again;
		_ctr242: sm->cs = 213; goto _again;
		_ctr243: sm->cs = 214; goto _again;
		_ctr244: sm->cs = 215; goto _again;
		_ctr245: sm->cs = 216; goto _again;
		_ctr246: sm->cs = 217; goto _again;
		_ctr247: sm->cs = 218; goto _again;
		_ctr268: sm->cs = 219; goto _again;
		_ctr248: sm->cs = 219; goto f9;
		_ctr250: sm->cs = 220; goto _again;
		_ctr253: sm->cs = 221; goto _again;
		_ctr251: sm->cs = 222; goto _again;
		_ctr252: sm->cs = 223; goto _again;
		_ctr254: sm->cs = 224; goto f4;
		_ctr255: sm->cs = 225; goto _again;
		_ctr257: sm->cs = 226; goto _again;
		_ctr256: sm->cs = 226; goto f3;
		_ctr258: sm->cs = 227; goto f8;
		_ctr259: sm->cs = 228; goto _again;
		_ctr260: sm->cs = 229; goto _again;
		_ctr249: sm->cs = 230; goto f9;
		_ctr262: sm->cs = 231; goto _again;
		_ctr263: sm->cs = 232; goto _again;
		_ctr264: sm->cs = 233; goto _again;
		_ctr265: sm->cs = 234; goto _again;
		_ctr267: sm->cs = 235; goto _again;
		_ctr266: sm->cs = 236; goto _again;
		_ctr829: sm->cs = 237; goto _again;
		_ctr270: sm->cs = 238; goto _again;
		_ctr271: sm->cs = 239; goto _again;
		_ctr272: sm->cs = 240; goto _again;
		_ctr273: sm->cs = 241; goto _again;
		_ctr274: sm->cs = 242; goto _again;
		_ctr275: sm->cs = 243; goto _again;
		_ctr276: sm->cs = 244; goto _again;
		_ctr277: sm->cs = 245; goto _again;
		_ctr278: sm->cs = 246; goto _again;
		_ctr830: sm->cs = 247; goto _again;
		_ctr280: sm->cs = 248; goto _again;
		_ctr281: sm->cs = 249; goto _again;
		_ctr282: sm->cs = 250; goto _again;
		_ctr831: sm->cs = 251; goto _again;
		_ctr284: sm->cs = 252; goto _again;
		_ctr285: sm->cs = 253; goto _again;
		_ctr287: sm->cs = 254; goto _again;
		_ctr288: sm->cs = 255; goto _again;
		_ctr289: sm->cs = 256; goto _again;
		_ctr290: sm->cs = 257; goto _again;
		_ctr832: sm->cs = 258; goto _again;
		_ctr292: sm->cs = 259; goto _again;
		_ctr293: sm->cs = 260; goto _again;
		_ctr294: sm->cs = 261; goto _again;
		_ctr295: sm->cs = 262; goto _again;
		_ctr296: sm->cs = 263; goto _again;
		_ctr297: sm->cs = 264; goto _again;
		_ctr833: sm->cs = 265; goto _again;
		_ctr300: sm->cs = 266; goto _again;
		_ctr302: sm->cs = 267; goto _again;
		_ctr303: sm->cs = 268; goto _again;
		_ctr304: sm->cs = 269; goto _again;
		_ctr305: sm->cs = 270; goto _again;
		_ctr306: sm->cs = 271; goto _again;
		_ctr308: sm->cs = 272; goto _again;
		_ctr301: sm->cs = 273; goto _again;
		_ctr309: sm->cs = 274; goto _again;
		_ctr310: sm->cs = 275; goto _again;
		_ctr311: sm->cs = 276; goto _again;
		_ctr312: sm->cs = 277; goto _again;
		_ctr834: sm->cs = 278; goto _again;
		_ctr313: sm->cs = 279; goto _again;
		_ctr835: sm->cs = 280; goto _again;
		_ctr836: sm->cs = 281; goto _again;
		_ctr316: sm->cs = 282; goto _again;
		_ctr317: sm->cs = 283; goto _again;
		_ctr318: sm->cs = 284; goto _again;
		_ctr319: sm->cs = 285; goto _again;
		_ctr321: sm->cs = 286; goto _again;
		_ctr322: sm->cs = 287; goto _again;
		_ctr323: sm->cs = 288; goto _again;
		_ctr326: sm->cs = 289; goto _again;
		_ctr324: sm->cs = 290; goto _again;
		_ctr325: sm->cs = 291; goto _again;
		_ctr320: sm->cs = 292; goto _again;
		_ctr329: sm->cs = 293; goto _again;
		_ctr838: sm->cs = 293; goto f9;
		_ctr330: sm->cs = 294; goto _again;
		_ctr839: sm->cs = 294; goto f9;
		_ctr843: sm->cs = 295; goto _again;
		_ctr840: sm->cs = 295; goto f9;
		_ctr846: sm->cs = 296; goto _again;
		_ctr331: sm->cs = 297; goto _again;
		_ctr332: sm->cs = 298; goto _again;
		_ctr333: sm->cs = 299; goto _again;
		_ctr334: sm->cs = 300; goto _again;
		_ctr335: sm->cs = 301; goto _again;
		_ctr847: sm->cs = 302; goto _again;
		_ctr337: sm->cs = 303; goto _again;
		_ctr338: sm->cs = 304; goto _again;
		_ctr339: sm->cs = 305; goto _again;
		_ctr340: sm->cs = 306; goto _again;
		_ctr341: sm->cs = 307; goto _again;
		_ctr342: sm->cs = 308; goto _again;
		_ctr848: sm->cs = 309; goto _again;
		_ctr344: sm->cs = 310; goto _again;
		_ctr345: sm->cs = 311; goto _again;
		_ctr347: sm->cs = 312; goto _again;
		_ctr348: sm->cs = 313; goto _again;
		_ctr349: sm->cs = 314; goto _again;
		_ctr350: sm->cs = 315; goto _again;
		_ctr346: sm->cs = 316; goto _again;
		_ctr352: sm->cs = 317; goto _again;
		_ctr353: sm->cs = 318; goto _again;
		_ctr354: sm->cs = 319; goto _again;
		_ctr355: sm->cs = 320; goto _again;
		_ctr356: sm->cs = 321; goto _again;
		_ctr357: sm->cs = 322; goto _again;
		_ctr358: sm->cs = 323; goto _again;
		_ctr359: sm->cs = 324; goto _again;
		_ctr857: sm->cs = 325; goto _again;
		_ctr361: sm->cs = 326; goto _again;
		_ctr362: sm->cs = 327; goto _again;
		_ctr363: sm->cs = 328; goto _again;
		_ctr858: sm->cs = 329; goto _again;
		_ctr365: sm->cs = 330; goto _again;
		_ctr366: sm->cs = 331; goto _again;
		_ctr367: sm->cs = 332; goto _again;
		_ctr863: sm->cs = 333; goto _again;
		_ctr369: sm->cs = 334; goto _again;
		_ctr370: sm->cs = 335; goto _again;
		_ctr371: sm->cs = 336; goto _again;
		_ctr372: sm->cs = 337; goto _again;
		_ctr373: sm->cs = 338; goto _again;
		_ctr374: sm->cs = 339; goto _again;
		_ctr375: sm->cs = 340; goto _again;
		_ctr866: sm->cs = 341; goto _again;
		_ctr377: sm->cs = 342; goto _again;
		_ctr378: sm->cs = 343; goto _again;
		_ctr379: sm->cs = 344; goto _again;
		_ctr380: sm->cs = 345; goto _again;
		_ctr381: sm->cs = 346; goto _again;
		_ctr382: sm->cs = 347; goto _again;
		_ctr383: sm->cs = 348; goto _again;
		_ctr384: sm->cs = 349; goto _again;
		_ctr385: sm->cs = 350; goto _again;
		_ctr386: sm->cs = 351; goto _again;
		_ctr867: sm->cs = 352; goto _again;
		_ctr388: sm->cs = 353; goto _again;
		_ctr389: sm->cs = 354; goto _again;
		_ctr390: sm->cs = 355; goto _again;
		_ctr391: sm->cs = 356; goto _again;
		_ctr392: sm->cs = 357; goto _again;
		_ctr871: sm->cs = 358; goto f4;
		_ctr875: sm->cs = 359; goto _again;
		_ctr396: sm->cs = 360; goto _again;
		_ctr397: sm->cs = 361; goto _again;
		_ctr398: sm->cs = 362; goto _again;
		_ctr399: sm->cs = 363; goto _again;
		_ctr400: sm->cs = 364; goto _again;
		_ctr401: sm->cs = 365; goto _again;
		_ctr402: sm->cs = 366; goto _again;
		_ctr403: sm->cs = 367; goto _again;
		_ctr876: sm->cs = 368; goto _again;
		_ctr405: sm->cs = 369; goto _again;
		_ctr406: sm->cs = 370; goto _again;
		_ctr407: sm->cs = 371; goto _again;
		_ctr408: sm->cs = 372; goto _again;
		_ctr409: sm->cs = 373; goto _again;
		_ctr410: sm->cs = 374; goto _again;
		_ctr411: sm->cs = 375; goto _again;
		_ctr412: sm->cs = 376; goto _again;
		_ctr877: sm->cs = 377; goto _again;
		_ctr414: sm->cs = 378; goto _again;
		_ctr415: sm->cs = 379; goto _again;
		_ctr416: sm->cs = 380; goto _again;
		_ctr417: sm->cs = 381; goto _again;
		_ctr878: sm->cs = 382; goto _again;
		_ctr419: sm->cs = 383; goto _again;
		_ctr420: sm->cs = 384; goto _again;
		_ctr421: sm->cs = 385; goto _again;
		_ctr422: sm->cs = 386; goto _again;
		_ctr423: sm->cs = 387; goto _again;
		_ctr887: sm->cs = 388; goto _again;
		_ctr425: sm->cs = 389; goto _again;
		_ctr426: sm->cs = 390; goto _again;
		_ctr427: sm->cs = 391; goto _again;
		_ctr428: sm->cs = 392; goto _again;
		_ctr429: sm->cs = 393; goto _again;
		_ctr430: sm->cs = 394; goto _again;
		_ctr431: sm->cs = 395; goto _again;
		_ctr432: sm->cs = 396; goto _again;
		_ctr890: sm->cs = 397; goto _again;
		_ctr434: sm->cs = 398; goto _again;
		_ctr435: sm->cs = 399; goto _again;
		_ctr436: sm->cs = 400; goto _again;
		_ctr437: sm->cs = 401; goto _again;
		_ctr438: sm->cs = 402; goto _again;
		_ctr439: sm->cs = 403; goto _again;
		_ctr440: sm->cs = 404; goto _again;
		_ctr441: sm->cs = 405; goto _again;
		_ctr442: sm->cs = 406; goto _again;
		_ctr443: sm->cs = 407; goto _again;
		_ctr444: sm->cs = 408; goto _again;
		_ctr891: sm->cs = 409; goto _again;
		_ctr446: sm->cs = 410; goto _again;
		_ctr447: sm->cs = 411; goto _again;
		_ctr448: sm->cs = 412; goto _again;
		_ctr449: sm->cs = 413; goto _again;
		_ctr450: sm->cs = 414; goto _again;
		_ctr896: sm->cs = 415; goto _again;
		_ctr452: sm->cs = 416; goto _again;
		_ctr453: sm->cs = 417; goto _again;
		_ctr455: sm->cs = 418; goto _again;
		_ctr456: sm->cs = 419; goto _again;
		_ctr457: sm->cs = 420; goto _again;
		_ctr458: sm->cs = 421; goto _again;
		_ctr459: sm->cs = 422; goto _again;
		_ctr460: sm->cs = 423; goto _again;
		_ctr461: sm->cs = 424; goto _again;
		_ctr462: sm->cs = 425; goto _again;
		_ctr454: sm->cs = 426; goto _again;
		_ctr464: sm->cs = 427; goto _again;
		_ctr465: sm->cs = 428; goto _again;
		_ctr466: sm->cs = 429; goto _again;
		_ctr467: sm->cs = 430; goto _again;
		_ctr468: sm->cs = 431; goto _again;
		_ctr469: sm->cs = 432; goto _again;
		_ctr470: sm->cs = 433; goto _again;
		_ctr901: sm->cs = 434; goto _again;
		_ctr472: sm->cs = 435; goto _again;
		_ctr473: sm->cs = 436; goto _again;
		_ctr474: sm->cs = 437; goto _again;
		_ctr475: sm->cs = 438; goto _again;
		_ctr476: sm->cs = 439; goto _again;
		_ctr902: sm->cs = 440; goto _again;
		_ctr478: sm->cs = 441; goto _again;
		_ctr479: sm->cs = 442; goto _again;
		_ctr480: sm->cs = 443; goto _again;
		_ctr481: sm->cs = 444; goto _again;
		_ctr907: sm->cs = 445; goto _again;
		_ctr483: sm->cs = 446; goto _again;
		_ctr484: sm->cs = 447; goto _again;
		_ctr485: sm->cs = 448; goto _again;
		_ctr486: sm->cs = 449; goto _again;
		_ctr487: sm->cs = 450; goto _again;
		_ctr908: sm->cs = 451; goto _again;
		_ctr489: sm->cs = 452; goto _again;
		_ctr490: sm->cs = 453; goto _again;
		_ctr491: sm->cs = 454; goto _again;
		_ctr492: sm->cs = 455; goto _again;
		_ctr493: sm->cs = 456; goto _again;
		_ctr913: sm->cs = 457; goto f4;
		_ctr496: sm->cs = 458; goto _again;
		_ctr909: sm->cs = 459; goto _again;
		_ctr498: sm->cs = 460; goto _again;
		_ctr500: sm->cs = 461; goto _again;
		_ctr501: sm->cs = 462; goto _again;
		_ctr502: sm->cs = 463; goto _again;
		_ctr499: sm->cs = 464; goto _again;
		_ctr504: sm->cs = 465; goto _again;
		_ctr505: sm->cs = 466; goto _again;
		_ctr506: sm->cs = 467; goto _again;
		_ctr921: sm->cs = 468; goto _again;
		_ctr508: sm->cs = 469; goto _again;
		_ctr509: sm->cs = 470; goto _again;
		_ctr510: sm->cs = 471; goto _again;
		_ctr511: sm->cs = 472; goto _again;
		_ctr512: sm->cs = 473; goto _again;
		_ctr513: sm->cs = 474; goto _again;
		_ctr514: sm->cs = 475; goto _again;
		_ctr922: sm->cs = 476; goto _again;
		_ctr516: sm->cs = 477; goto _again;
		_ctr517: sm->cs = 478; goto _again;
		_ctr518: sm->cs = 479; goto _again;
		_ctr519: sm->cs = 480; goto _again;
		_ctr520: sm->cs = 481; goto _again;
		_ctr927: sm->cs = 482; goto _again;
		_ctr522: sm->cs = 483; goto _again;
		_ctr523: sm->cs = 484; goto _again;
		_ctr524: sm->cs = 485; goto _again;
		_ctr525: sm->cs = 486; goto _again;
		_ctr526: sm->cs = 487; goto _again;
		_ctr930: sm->cs = 488; goto f4;
		_ctr529: sm->cs = 489; goto _again;
		_ctr928: sm->cs = 490; goto _again;
		_ctr531: sm->cs = 491; goto _again;
		_ctr532: sm->cs = 492; goto _again;
		_ctr533: sm->cs = 493; goto _again;
		_ctr534: sm->cs = 494; goto _again;
		_ctr535: sm->cs = 495; goto _again;
		_ctr536: sm->cs = 496; goto _again;
		_ctr537: sm->cs = 497; goto _again;
		_ctr936: sm->cs = 498; goto _again;
		_ctr539: sm->cs = 499; goto _again;
		_ctr540: sm->cs = 500; goto _again;
		_ctr541: sm->cs = 501; goto _again;
		_ctr542: sm->cs = 502; goto _again;
		_ctr939: sm->cs = 503; goto _again;
		_ctr544: sm->cs = 504; goto _again;
		_ctr545: sm->cs = 505; goto _again;
		_ctr546: sm->cs = 506; goto _again;
		_ctr547: sm->cs = 507; goto _again;
		_ctr942: sm->cs = 508; goto _again;
		_ctr549: sm->cs = 509; goto _again;
		_ctr550: sm->cs = 510; goto _again;
		_ctr551: sm->cs = 511; goto _again;
		_ctr552: sm->cs = 512; goto _again;
		_ctr553: sm->cs = 513; goto _again;
		_ctr554: sm->cs = 514; goto _again;
		_ctr555: sm->cs = 515; goto _again;
		_ctr945: sm->cs = 516; goto _again;
		_ctr557: sm->cs = 517; goto _again;
		_ctr558: sm->cs = 518; goto _again;
		_ctr564: sm->cs = 519; goto _again;
		_ctr565: sm->cs = 520; goto _again;
		_ctr566: sm->cs = 521; goto _again;
		_ctr567: sm->cs = 522; goto _again;
		_ctr568: sm->cs = 523; goto _again;
		_ctr559: sm->cs = 524; goto _again;
		_ctr560: sm->cs = 525; goto _again;
		_ctr569: sm->cs = 526; goto _again;
		_ctr570: sm->cs = 527; goto _again;
		_ctr571: sm->cs = 528; goto _again;
		_ctr572: sm->cs = 529; goto _again;
		_ctr561: sm->cs = 530; goto _again;
		_ctr573: sm->cs = 531; goto _again;
		_ctr574: sm->cs = 532; goto _again;
		_ctr575: sm->cs = 533; goto _again;
		_ctr576: sm->cs = 534; goto _again;
		_ctr577: sm->cs = 535; goto _again;
		_ctr578: sm->cs = 536; goto _again;
		_ctr579: sm->cs = 537; goto _again;
		_ctr562: sm->cs = 538; goto _again;
		_ctr580: sm->cs = 539; goto _again;
		_ctr581: sm->cs = 540; goto _again;
		_ctr582: sm->cs = 541; goto _again;
		_ctr563: sm->cs = 542; goto _again;
		_ctr946: sm->cs = 543; goto _again;
		_ctr947: sm->cs = 544; goto _again;
		_ctr583: sm->cs = 545; goto _again;
		_ctr584: sm->cs = 546; goto _again;
		_ctr585: sm->cs = 547; goto _again;
		_ctr948: sm->cs = 548; goto _again;
		_ctr586: sm->cs = 549; goto _again;
		_ctr587: sm->cs = 550; goto _again;
		_ctr588: sm->cs = 551; goto _again;
		_ctr589: sm->cs = 552; goto _again;
		_ctr590: sm->cs = 553; goto _again;
		_ctr949: sm->cs = 554; goto _again;
		_ctr950: sm->cs = 555; goto _again;
		_ctr591: sm->cs = 556; goto _again;
		_ctr592: sm->cs = 557; goto _again;
		_ctr593: sm->cs = 558; goto _again;
		_ctr594: sm->cs = 559; goto _again;
		_ctr595: sm->cs = 560; goto _again;
		_ctr596: sm->cs = 561; goto _again;
		_ctr951: sm->cs = 562; goto _again;
		_ctr597: sm->cs = 563; goto _again;
		_ctr598: sm->cs = 564; goto _again;
		_ctr599: sm->cs = 565; goto _again;
		_ctr600: sm->cs = 566; goto _again;
		_ctr952: sm->cs = 567; goto _again;
		_ctr601: sm->cs = 568; goto _again;
		_ctr602: sm->cs = 569; goto _again;
		_ctr603: sm->cs = 570; goto _again;
		_ctr604: sm->cs = 571; goto _again;
		_ctr605: sm->cs = 572; goto _again;
		_ctr606: sm->cs = 573; goto _again;
		_ctr607: sm->cs = 574; goto _again;
		_ctr953: sm->cs = 575; goto _again;
		_ctr608: sm->cs = 576; goto _again;
		_ctr954: sm->cs = 577; goto _again;
		_ctr955: sm->cs = 578; goto f9;
		_ctr609: sm->cs = 579; goto _again;
		_ctr610: sm->cs = 580; goto _again;
		_ctr611: sm->cs = 581; goto _again;
		_ctr612: sm->cs = 582; goto _again;
		_ctr614: sm->cs = 583; goto _again;
		_ctr615: sm->cs = 584; goto _again;
		_ctr616: sm->cs = 585; goto _again;
		_ctr619: sm->cs = 586; goto _again;
		_ctr617: sm->cs = 587; goto _again;
		_ctr618: sm->cs = 588; goto _again;
		_ctr620: sm->cs = 589; goto f4;
		_ctr621: sm->cs = 590; goto _again;
		_ctr623: sm->cs = 591; goto _again;
		_ctr622: sm->cs = 591; goto f3;
		_ctr613: sm->cs = 592; goto _again;
		_ctr956: sm->cs = 593; goto _again;
		_ctr625: sm->cs = 594; goto _again;
		_ctr626: sm->cs = 595; goto _again;
		_ctr627: sm->cs = 596; goto _again;
		_ctr629: sm->cs = 597; goto _again;
		_ctr630: sm->cs = 598; goto _again;
		_ctr631: sm->cs = 599; goto _again;
		_ctr632: sm->cs = 600; goto _again;
		_ctr633: sm->cs = 601; goto _again;
		_ctr628: sm->cs = 602; goto _again;
		_ctr958: sm->cs = 603; goto _again;
		_ctr636: sm->cs = 604; goto _again;
		_ctr635: sm->cs = 604; goto f9;
		_ctr637: sm->cs = 605; goto f4;
		_ctr964: sm->cs = 606; goto _again;
		_ctr640: sm->cs = 607; goto _again;
		_ctr641: sm->cs = 608; goto _again;
		_ctr642: sm->cs = 609; goto _again;
		_ctr643: sm->cs = 610; goto _again;
		_ctr965: sm->cs = 611; goto _again;
		_ctr645: sm->cs = 612; goto _again;
		_ctr646: sm->cs = 613; goto _again;
		_ctr647: sm->cs = 614; goto _again;
		_ctr648: sm->cs = 615; goto _again;
		_ctr971: sm->cs = 616; goto _again;
		_ctr650: sm->cs = 617; goto _again;
		_ctr651: sm->cs = 618; goto _again;
		_ctr652: sm->cs = 619; goto _again;
		_ctr653: sm->cs = 620; goto _again;
		_ctr654: sm->cs = 621; goto _again;
		_ctr655: sm->cs = 622; goto _again;
		_ctr656: sm->cs = 623; goto _again;
		_ctr972: sm->cs = 624; goto _again;
		_ctr658: sm->cs = 625; goto _again;
		_ctr659: sm->cs = 626; goto _again;
		_ctr660: sm->cs = 627; goto _again;
		_ctr661: sm->cs = 628; goto _again;
		_ctr662: sm->cs = 629; goto _again;
		_ctr663: sm->cs = 630; goto _again;
		_ctr664: sm->cs = 631; goto _again;
		_ctr978: sm->cs = 632; goto _again;
		_ctr666: sm->cs = 633; goto _again;
		_ctr667: sm->cs = 634; goto _again;
		_ctr671: sm->cs = 635; goto _again;
		_ctr672: sm->cs = 636; goto _again;
		_ctr673: sm->cs = 637; goto _again;
		_ctr668: sm->cs = 638; goto _again;
		_ctr675: sm->cs = 639; goto _again;
		_ctr676: sm->cs = 640; goto _again;
		_ctr677: sm->cs = 641; goto _again;
		_ctr669: sm->cs = 642; goto _again;
		_ctr679: sm->cs = 643; goto _again;
		_ctr680: sm->cs = 644; goto _again;
		_ctr681: sm->cs = 645; goto _again;
		_ctr670: sm->cs = 646; goto _again;
		_ctr979: sm->cs = 647; goto _again;
		_ctr684: sm->cs = 648; goto _again;
		_ctr688: sm->cs = 649; goto _again;
		_ctr689: sm->cs = 650; goto _again;
		_ctr690: sm->cs = 651; goto _again;
		_ctr685: sm->cs = 652; goto _again;
		_ctr686: sm->cs = 653; goto _again;
		_ctr694: sm->cs = 654; goto _again;
		_ctr695: sm->cs = 655; goto _again;
		_ctr696: sm->cs = 656; goto _again;
		_ctr687: sm->cs = 657; goto _again;
		_ctr980: sm->cs = 658; goto _again;
		_ctr699: sm->cs = 659; goto _again;
		_ctr700: sm->cs = 660; goto _again;
		_ctr704: sm->cs = 661; goto _again;
		_ctr705: sm->cs = 662; goto _again;
		_ctr706: sm->cs = 663; goto _again;
		_ctr701: sm->cs = 664; goto _again;
		_ctr707: sm->cs = 665; goto _again;
		_ctr708: sm->cs = 666; goto _again;
		_ctr709: sm->cs = 667; goto _again;
		_ctr702: sm->cs = 668; goto _again;
		_ctr710: sm->cs = 669; goto _again;
		_ctr711: sm->cs = 670; goto _again;
		_ctr712: sm->cs = 671; goto _again;
		_ctr703: sm->cs = 672; goto _again;
		_ctr981: sm->cs = 673; goto _again;
		_ctr713: sm->cs = 674; goto _again;
		_ctr717: sm->cs = 675; goto _again;
		_ctr718: sm->cs = 676; goto _again;
		_ctr719: sm->cs = 677; goto _again;
		_ctr714: sm->cs = 678; goto _again;
		_ctr715: sm->cs = 679; goto _again;
		_ctr720: sm->cs = 680; goto _again;
		_ctr721: sm->cs = 681; goto _again;
		_ctr722: sm->cs = 682; goto _again;
		_ctr716: sm->cs = 683; goto _again;
		_ctr987: sm->cs = 684; goto _again;
		_ctr728: sm->cs = 685; goto f4;
		_ctr729: sm->cs = 686; goto _again;
		_ctr730: sm->cs = 687; goto _again;
		_ctr0: sm->cs = 687; goto f0;
		_ctr2: sm->cs = 687; goto f2;
		_ctr14: sm->cs = 687; goto f5;
		_ctr56: sm->cs = 687; goto f6;
		_ctr57: sm->cs = 687; goto f7;
		_ctr731: sm->cs = 687; goto f77;
		_ctr739: sm->cs = 687; goto f80;
		_ctr740: sm->cs = 687; goto f81;
		_ctr749: sm->cs = 687; goto f82;
		_ctr750: sm->cs = 687; goto f83;
		_ctr751: sm->cs = 687; goto f84;
		_ctr752: sm->cs = 687; goto f85;
		_ctr753: sm->cs = 687; goto f86;
		_ctr755: sm->cs = 687; goto f87;
		_ctr757: sm->cs = 687; goto f88;
		_ctr766: sm->cs = 687; goto f89;
		_ctr1: sm->cs = 688; goto f1;
		_ctr732: sm->cs = 688; goto f78;
		_ctr733: sm->cs = 689; goto _again;
		_ctr734: sm->cs = 690; goto f51;
		_ctr741: sm->cs = 691; goto _again;
		_ctr3: sm->cs = 691; goto f3;
		_ctr4: sm->cs = 692; goto f3;
		_ctr735: sm->cs = 693; goto f79;
		_ctr25: sm->cs = 694; goto _again;
		_ctr29: sm->cs = 695; goto _again;
		_ctr35: sm->cs = 696; goto _again;
		_ctr42: sm->cs = 697; goto _again;
		_ctr49: sm->cs = 698; goto _again;
		_ctr736: sm->cs = 699; goto f79;
		_ctr756: sm->cs = 700; goto _again;
		_ctr62: sm->cs = 700; goto f8;
		_ctr758: sm->cs = 701; goto _again;
		_ctr59: sm->cs = 701; goto f4;
		_ctr737: sm->cs = 702; goto f79;
		_ctr767: sm->cs = 703; goto _again;
		_ctr82: sm->cs = 703; goto f4;
		_ctr768: sm->cs = 704; goto _again;
		_ctr105: sm->cs = 704; goto f10;
		_ctr111: sm->cs = 704; goto f11;
		_ctr112: sm->cs = 704; goto f12;
		_ctr113: sm->cs = 704; goto f13;
		_ctr118: sm->cs = 704; goto f14;
		_ctr119: sm->cs = 704; goto f15;
		_ctr121: sm->cs = 704; goto f16;
		_ctr122: sm->cs = 704; goto f17;
		_ctr128: sm->cs = 704; goto f18;
		_ctr769: sm->cs = 704; goto f90;
		_ctr772: sm->cs = 704; goto f91;
		_ctr770: sm->cs = 705; goto f79;
		_ctr771: sm->cs = 706; goto f79;
		_ctr782: sm->cs = 707; goto _again;
		_ctr133: sm->cs = 707; goto f19;
		_ctr135: sm->cs = 707; goto f21;
		_ctr140: sm->cs = 707; goto f22;
		_ctr157: sm->cs = 707; goto f24;
		_ctr194: sm->cs = 707; goto f28;
		_ctr205: sm->cs = 707; goto f29;
		_ctr210: sm->cs = 707; goto f30;
		_ctr211: sm->cs = 707; goto f31;
		_ctr219: sm->cs = 707; goto f32;
		_ctr228: sm->cs = 707; goto f33;
		_ctr229: sm->cs = 707; goto f34;
		_ctr230: sm->cs = 707; goto f35;
		_ctr231: sm->cs = 707; goto f36;
		_ctr240: sm->cs = 707; goto f37;
		_ctr261: sm->cs = 707; goto f38;
		_ctr269: sm->cs = 707; goto f39;
		_ctr279: sm->cs = 707; goto f40;
		_ctr283: sm->cs = 707; goto f41;
		_ctr286: sm->cs = 707; goto f42;
		_ctr291: sm->cs = 707; goto f43;
		_ctr298: sm->cs = 707; goto f44;
		_ctr299: sm->cs = 707; goto f45;
		_ctr307: sm->cs = 707; goto f46;
		_ctr314: sm->cs = 707; goto f47;
		_ctr315: sm->cs = 707; goto f48;
		_ctr327: sm->cs = 707; goto f49;
		_ctr394: sm->cs = 707; goto f52;
		_ctr495: sm->cs = 707; goto f53;
		_ctr528: sm->cs = 707; goto f54;
		_ctr624: sm->cs = 707; goto f55;
		_ctr638: sm->cs = 707; goto f57;
		_ctr783: sm->cs = 707; goto f92;
		_ctr808: sm->cs = 707; goto f97;
		_ctr811: sm->cs = 707; goto f98;
		_ctr812: sm->cs = 707; goto f99;
		_ctr814: sm->cs = 707; goto f100;
		_ctr815: sm->cs = 707; goto f101;
		_ctr817: sm->cs = 707; goto f102;
		_ctr818: sm->cs = 707; goto f103;
		_ctr820: sm->cs = 707; goto f104;
		_ctr822: sm->cs = 707; goto f105;
		_ctr824: sm->cs = 707; goto f107;
		_ctr837: sm->cs = 707; goto f108;
		_ctr842: sm->cs = 707; goto f110;
		_ctr844: sm->cs = 707; goto f111;
		_ctr849: sm->cs = 707; goto f113;
		_ctr851: sm->cs = 707; goto f114;
		_ctr853: sm->cs = 707; goto f115;
		_ctr855: sm->cs = 707; goto f116;
		_ctr859: sm->cs = 707; goto f117;
		_ctr861: sm->cs = 707; goto f118;
		_ctr864: sm->cs = 707; goto f119;
		_ctr868: sm->cs = 707; goto f120;
		_ctr870: sm->cs = 707; goto f121;
		_ctr873: sm->cs = 707; goto f122;
		_ctr879: sm->cs = 707; goto f123;
		_ctr881: sm->cs = 707; goto f124;
		_ctr883: sm->cs = 707; goto f125;
		_ctr885: sm->cs = 707; goto f126;
		_ctr888: sm->cs = 707; goto f127;
		_ctr892: sm->cs = 707; goto f128;
		_ctr894: sm->cs = 707; goto f129;
		_ctr897: sm->cs = 707; goto f130;
		_ctr899: sm->cs = 707; goto f131;
		_ctr903: sm->cs = 707; goto f132;
		_ctr905: sm->cs = 707; goto f133;
		_ctr910: sm->cs = 707; goto f134;
		_ctr912: sm->cs = 707; goto f135;
		_ctr915: sm->cs = 707; goto f136;
		_ctr917: sm->cs = 707; goto f137;
		_ctr919: sm->cs = 707; goto f138;
		_ctr923: sm->cs = 707; goto f139;
		_ctr925: sm->cs = 707; goto f140;
		_ctr929: sm->cs = 707; goto f141;
		_ctr932: sm->cs = 707; goto f142;
		_ctr934: sm->cs = 707; goto f143;
		_ctr937: sm->cs = 707; goto f144;
		_ctr940: sm->cs = 707; goto f145;
		_ctr943: sm->cs = 707; goto f146;
		_ctr957: sm->cs = 707; goto f147;
		_ctr784: sm->cs = 708; goto f93;
		_ctr134: sm->cs = 709; goto f20;
		_ctr813: sm->cs = 710; goto _again;
		_ctr138: sm->cs = 710; goto f3;
		_ctr139: sm->cs = 711; goto f3;
		_ctr785: sm->cs = 712; goto _again;
		_ctr786: sm->cs = 713; goto f94;
		_ctr150: sm->cs = 714; goto f23;
		_ctr787: sm->cs = 715; goto f51;
		_ctr180: sm->cs = 716; goto _again;
		_ctr821: sm->cs = 717; goto _again;
		_ctr819: sm->cs = 717; goto f25;
		_ctr185: sm->cs = 718; goto _again;
		_ctr825: sm->cs = 719; goto _again;
		_ctr823: sm->cs = 719; goto f106;
		_ctr788: sm->cs = 720; goto f79;
		_ctr203: sm->cs = 721; goto _again;
		_ctr789: sm->cs = 722; goto f94;
		_ctr328: sm->cs = 723; goto f50;
		_ctr845: sm->cs = 723; goto f112;
		_ctr841: sm->cs = 724; goto f109;
		_ctr790: sm->cs = 725; goto f51;
		_ctr850: sm->cs = 726; goto _again;
		_ctr336: sm->cs = 726; goto f9;
		_ctr852: sm->cs = 727; goto _again;
		_ctr343: sm->cs = 727; goto f9;
		_ctr854: sm->cs = 728; goto _again;
		_ctr351: sm->cs = 728; goto f9;
		_ctr856: sm->cs = 729; goto _again;
		_ctr360: sm->cs = 729; goto f9;
		_ctr791: sm->cs = 730; goto f51;
		_ctr860: sm->cs = 731; goto _again;
		_ctr364: sm->cs = 731; goto f9;
		_ctr862: sm->cs = 732; goto _again;
		_ctr368: sm->cs = 732; goto f9;
		_ctr792: sm->cs = 733; goto f51;
		_ctr865: sm->cs = 734; goto _again;
		_ctr376: sm->cs = 734; goto f9;
		_ctr793: sm->cs = 735; goto f51;
		_ctr869: sm->cs = 736; goto _again;
		_ctr387: sm->cs = 736; goto f9;
		_ctr393: sm->cs = 737; goto f51;
		_ctr872: sm->cs = 737; goto f79;
		_ctr874: sm->cs = 738; goto _again;
		_ctr395: sm->cs = 738; goto f3;
		_ctr794: sm->cs = 739; goto f51;
		_ctr880: sm->cs = 740; goto _again;
		_ctr404: sm->cs = 740; goto f9;
		_ctr882: sm->cs = 741; goto _again;
		_ctr413: sm->cs = 741; goto f9;
		_ctr884: sm->cs = 742; goto _again;
		_ctr418: sm->cs = 742; goto f9;
		_ctr886: sm->cs = 743; goto _again;
		_ctr424: sm->cs = 743; goto f9;
		_ctr795: sm->cs = 744; goto f51;
		_ctr889: sm->cs = 745; goto _again;
		_ctr433: sm->cs = 745; goto f9;
		_ctr796: sm->cs = 746; goto f51;
		_ctr893: sm->cs = 747; goto _again;
		_ctr445: sm->cs = 747; goto f9;
		_ctr895: sm->cs = 748; goto _again;
		_ctr451: sm->cs = 748; goto f9;
		_ctr797: sm->cs = 749; goto f51;
		_ctr898: sm->cs = 750; goto _again;
		_ctr463: sm->cs = 750; goto f9;
		_ctr900: sm->cs = 751; goto _again;
		_ctr471: sm->cs = 751; goto f9;
		_ctr798: sm->cs = 752; goto f51;
		_ctr904: sm->cs = 753; goto _again;
		_ctr477: sm->cs = 753; goto f9;
		_ctr906: sm->cs = 754; goto _again;
		_ctr482: sm->cs = 754; goto f9;
		_ctr799: sm->cs = 755; goto f51;
		_ctr911: sm->cs = 756; goto _again;
		_ctr488: sm->cs = 756; goto f9;
		_ctr494: sm->cs = 757; goto f51;
		_ctr914: sm->cs = 757; goto f79;
		_ctr916: sm->cs = 758; goto _again;
		_ctr497: sm->cs = 758; goto f3;
		_ctr918: sm->cs = 759; goto _again;
		_ctr503: sm->cs = 759; goto f9;
		_ctr920: sm->cs = 760; goto _again;
		_ctr507: sm->cs = 760; goto f9;
		_ctr800: sm->cs = 761; goto f51;
		_ctr924: sm->cs = 762; goto _again;
		_ctr515: sm->cs = 762; goto f9;
		_ctr926: sm->cs = 763; goto _again;
		_ctr521: sm->cs = 763; goto f9;
		_ctr801: sm->cs = 764; goto f51;
		_ctr527: sm->cs = 765; goto f51;
		_ctr931: sm->cs = 765; goto f79;
		_ctr933: sm->cs = 766; goto _again;
		_ctr530: sm->cs = 766; goto f3;
		_ctr935: sm->cs = 767; goto _again;
		_ctr538: sm->cs = 767; goto f9;
		_ctr802: sm->cs = 768; goto f51;
		_ctr938: sm->cs = 769; goto _again;
		_ctr543: sm->cs = 769; goto f9;
		_ctr803: sm->cs = 770; goto f51;
		_ctr941: sm->cs = 771; goto _again;
		_ctr548: sm->cs = 771; goto f9;
		_ctr804: sm->cs = 772; goto f51;
		_ctr944: sm->cs = 773; goto _again;
		_ctr556: sm->cs = 773; goto f9;
		_ctr805: sm->cs = 774; goto f95;
		_ctr806: sm->cs = 775; goto f96;
		_ctr634: sm->cs = 776; goto f56;
		_ctr807: sm->cs = 777; goto f79;
		_ctr959: sm->cs = 778; goto _again;
		_ctr639: sm->cs = 778; goto f58;
		_ctr644: sm->cs = 778; goto f59;
		_ctr960: sm->cs = 778; goto f148;
		_ctr963: sm->cs = 778; goto f149;
		_ctr961: sm->cs = 779; goto f79;
		_ctr962: sm->cs = 780; goto f79;
		_ctr966: sm->cs = 781; goto _again;
		_ctr649: sm->cs = 781; goto f60;
		_ctr657: sm->cs = 781; goto f61;
		_ctr967: sm->cs = 781; goto f150;
		_ctr970: sm->cs = 781; goto f151;
		_ctr968: sm->cs = 782; goto f79;
		_ctr969: sm->cs = 783; goto f79;
		_ctr973: sm->cs = 784; goto _again;
		_ctr665: sm->cs = 784; goto f62;
		_ctr674: sm->cs = 784; goto f63;
		_ctr678: sm->cs = 784; goto f64;
		_ctr682: sm->cs = 784; goto f65;
		_ctr683: sm->cs = 784; goto f66;
		_ctr691: sm->cs = 784; goto f67;
		_ctr692: sm->cs = 784; goto f68;
		_ctr693: sm->cs = 784; goto f69;
		_ctr697: sm->cs = 784; goto f70;
		_ctr698: sm->cs = 784; goto f71;
		_ctr974: sm->cs = 784; goto f152;
		_ctr977: sm->cs = 784; goto f153;
		_ctr975: sm->cs = 785; goto f79;
		_ctr976: sm->cs = 786; goto f79;
		_ctr982: sm->cs = 787; goto _again;
		_ctr723: sm->cs = 787; goto f72;
		_ctr725: sm->cs = 787; goto f74;
		_ctr983: sm->cs = 787; goto f154;
		_ctr988: sm->cs = 787; goto f156;
		_ctr989: sm->cs = 787; goto f157;
		_ctr724: sm->cs = 788; goto f73;
		_ctr984: sm->cs = 788; goto f155;
		_ctr985: sm->cs = 789; goto _again;
		_ctr986: sm->cs = 790; goto f51;
		_ctr990: sm->cs = 791; goto _again;
		_ctr726: sm->cs = 791; goto f3;
		_ctr727: sm->cs = 792; goto f3;
		
		f9:
		{
#line 72 "ext/dtext/dtext.rl"
			
			sm->a1 = sm->p;
		}
		
#line 15546 "ext/dtext/dtext.c"
		goto _again;
		f4:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 15555 "ext/dtext/dtext.c"
		goto _again;
		f3:
		{
#line 80 "ext/dtext/dtext.rl"
			
			sm->b1 = sm->p;
		}
		
#line 15564 "ext/dtext/dtext.c"
		goto _again;
		f8:
		{
#line 84 "ext/dtext/dtext.rl"
			
			sm->b2 = sm->p;
		}
		
#line 15573 "ext/dtext/dtext.c"
		goto _again;
		f25:
		{
#line 88 "ext/dtext/dtext.rl"
			
			sm->c1 = sm->p;
		}
		
#line 15582 "ext/dtext/dtext.c"
		goto _again;
		f27:
		{
#line 92 "ext/dtext/dtext.rl"
			
			sm->c2 = sm->p;
		}
		
#line 15591 "ext/dtext/dtext.c"
		goto _again;
		f106:
		{
#line 96 "ext/dtext/dtext.rl"
			
			sm->d1 = sm->p;
		}
		
#line 15600 "ext/dtext/dtext.c"
		goto _again;
		f79:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 15607 "ext/dtext/dtext.c"
		goto _again;
		f15:
		{
#line 186 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 186 "ext/dtext/dtext.rl"
					dstack_open_inline(sm,  INLINE_B, "<strong>"); }
			}}
		
#line 15617 "ext/dtext/dtext.c"
		goto _again;
		f11:
		{
#line 187 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 187 "ext/dtext/dtext.rl"
					dstack_close_inline(sm, INLINE_B, "</strong>"); }
			}}
		
#line 15627 "ext/dtext/dtext.c"
		goto _again;
		f16:
		{
#line 188 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 188 "ext/dtext/dtext.rl"
					dstack_open_inline(sm,  INLINE_I, "<em>"); }
			}}
		
#line 15637 "ext/dtext/dtext.c"
		goto _again;
		f12:
		{
#line 189 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 189 "ext/dtext/dtext.rl"
					dstack_close_inline(sm, INLINE_I, "</em>"); }
			}}
		
#line 15647 "ext/dtext/dtext.c"
		goto _again;
		f17:
		{
#line 190 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 190 "ext/dtext/dtext.rl"
					dstack_open_inline(sm,  INLINE_S, "<s>"); }
			}}
		
#line 15657 "ext/dtext/dtext.c"
		goto _again;
		f13:
		{
#line 191 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 191 "ext/dtext/dtext.rl"
					dstack_close_inline(sm, INLINE_S, "</s>"); }
			}}
		
#line 15667 "ext/dtext/dtext.c"
		goto _again;
		f18:
		{
#line 192 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 192 "ext/dtext/dtext.rl"
					dstack_open_inline(sm,  INLINE_U, "<u>"); }
			}}
		
#line 15677 "ext/dtext/dtext.c"
		goto _again;
		f14:
		{
#line 193 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 193 "ext/dtext/dtext.rl"
					dstack_close_inline(sm, INLINE_U, "</u>"); }
			}}
		
#line 15687 "ext/dtext/dtext.c"
		goto _again;
		f90:
		{
#line 194 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 194 "ext/dtext/dtext.rl"
					append_c_html_escaped(sm, (( (*( ( sm->p)))))); }
			}}
		
#line 15697 "ext/dtext/dtext.c"
		goto _again;
		f91:
		{
#line 194 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 194 "ext/dtext/dtext.rl"
					append_c_html_escaped(sm, (( (*( ( sm->p)))))); }
			}}
		
#line 15707 "ext/dtext/dtext.c"
		goto _again;
		f10:
		{
#line 194 "ext/dtext/dtext.rl"
			{( sm->p) = ((( sm->te)))-1;
				{
#line 194 "ext/dtext/dtext.rl"
					append_c_html_escaped(sm, (( (*( ( sm->p)))))); }
			}}
		
#line 15718 "ext/dtext/dtext.c"
		goto _again;
		f57:
		{
#line 237 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 237 "ext/dtext/dtext.rl"
					
					append(sm, "<a class=\"dtext-link dtext-post-search-link\" href=\"/posts?tags=");
					append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
					append(sm, "\">");
					append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
					append(sm, "</a>");
				}
			}}
		
#line 15734 "ext/dtext/dtext.c"
		goto _again;
		f24:
		{
#line 267 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 267 "ext/dtext/dtext.rl"
					
					if (!append_named_url(sm, sm->b1, sm->b2, sm->a1, sm->a2)) {
						{( sm->p) += 1; goto _out; }
					}
				}
			}}
		
#line 15748 "ext/dtext/dtext.c"
		goto _again;
		f38:
		{
#line 273 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 273 "ext/dtext/dtext.rl"
					
					if (!append_named_url(sm, sm->a1, sm->a2 - 1, sm->b1, sm->b2)) {
						{( sm->p) += 1; goto _out; }
					}
				}
			}}
		
#line 15762 "ext/dtext/dtext.c"
		goto _again;
		f49:
		{
#line 291 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 291 "ext/dtext/dtext.rl"
					
					append_url(sm, sm->ts + 1, sm->te - 2, sm->ts + 1, sm->te - 2);
				}
			}}
		
#line 15774 "ext/dtext/dtext.c"
		goto _again;
		f39:
		{
#line 357 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 357 "ext/dtext/dtext.rl"
					dstack_open_inline(sm,  INLINE_B, "<strong>"); }
			}}
		
#line 15784 "ext/dtext/dtext.c"
		goto _again;
		f28:
		{
#line 358 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 358 "ext/dtext/dtext.rl"
					dstack_close_inline(sm, INLINE_B, "</strong>"); }
			}}
		
#line 15794 "ext/dtext/dtext.c"
		goto _again;
		f42:
		{
#line 359 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 359 "ext/dtext/dtext.rl"
					dstack_open_inline(sm,  INLINE_I, "<em>"); }
			}}
		
#line 15804 "ext/dtext/dtext.c"
		goto _again;
		f29:
		{
#line 360 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 360 "ext/dtext/dtext.rl"
					dstack_close_inline(sm, INLINE_I, "</em>"); }
			}}
		
#line 15814 "ext/dtext/dtext.c"
		goto _again;
		f45:
		{
#line 361 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 361 "ext/dtext/dtext.rl"
					dstack_open_inline(sm,  INLINE_S, "<s>"); }
			}}
		
#line 15824 "ext/dtext/dtext.c"
		goto _again;
		f31:
		{
#line 362 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 362 "ext/dtext/dtext.rl"
					dstack_close_inline(sm, INLINE_S, "</s>"); }
			}}
		
#line 15834 "ext/dtext/dtext.c"
		goto _again;
		f48:
		{
#line 363 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 363 "ext/dtext/dtext.rl"
					dstack_open_inline(sm,  INLINE_U, "<u>"); }
			}}
		
#line 15844 "ext/dtext/dtext.c"
		goto _again;
		f36:
		{
#line 364 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 364 "ext/dtext/dtext.rl"
					dstack_close_inline(sm, INLINE_U, "</u>"); }
			}}
		
#line 15854 "ext/dtext/dtext.c"
		goto _again;
		f47:
		{
#line 366 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 366 "ext/dtext/dtext.rl"
					
					dstack_open_inline(sm, INLINE_TN, "<span class=\"tn\">");
				}
			}}
		
#line 15866 "ext/dtext/dtext.c"
		goto _again;
		f35:
		{
#line 370 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 370 "ext/dtext/dtext.rl"
					
					dstack_close_before_block(sm);
					
					if (dstack_check(sm, INLINE_TN)) {
						dstack_close_inline(sm, INLINE_TN, "</span>");
					} else if (dstack_close_block(sm, BLOCK_TN, "</p>")) {
						{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
					}
				}
			}}
		
#line 15884 "ext/dtext/dtext.c"
		goto _again;
		f41:
		{
#line 380 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 380 "ext/dtext/dtext.rl"
					
					dstack_open_inline(sm, INLINE_CODE, "<code>");
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 778; goto _again;}}
			}}
		
#line 15911 "ext/dtext/dtext.c"
		goto _again;
		f46:
		{
#line 385 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 385 "ext/dtext/dtext.rl"
					
					dstack_open_inline(sm, INLINE_SPOILER, "<span class=\"spoiler\">");
				}
			}}
		
#line 15923 "ext/dtext/dtext.c"
		goto _again;
		f32:
		{
#line 389 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 389 "ext/dtext/dtext.rl"
					
					g_debug("inline [/spoiler]");
					dstack_close_before_block(sm);
					
					if (dstack_check(sm, INLINE_SPOILER)) {
						dstack_close_inline(sm, INLINE_SPOILER, "</span>");
					} else if (dstack_close_block(sm, BLOCK_SPOILER, "</div>")) {
						{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
					}
				}
			}}
		
#line 15942 "ext/dtext/dtext.c"
		goto _again;
		f44:
		{
#line 400 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 400 "ext/dtext/dtext.rl"
					
					dstack_open_inline(sm, INLINE_NODTEXT, "");
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 781; goto _again;}}
			}}
		
#line 15969 "ext/dtext/dtext.c"
		goto _again;
		f40:
		{
#line 408 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 408 "ext/dtext/dtext.rl"
					
					g_debug("inline [quote]");
					dstack_close_before_block(sm);
					{( sm->p) = (( sm->ts))-1;}
					
					{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
				}
			}}
		
#line 15985 "ext/dtext/dtext.c"
		goto _again;
		f43:
		{
#line 431 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 431 "ext/dtext/dtext.rl"
					
					g_debug("inline [expand]");
					dstack_rewind(sm);
					{( sm->p) = (((sm->p - 7)))-1;}
					
					{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
				}
			}}
		
#line 16001 "ext/dtext/dtext.c"
		goto _again;
		f30:
		{
#line 438 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 438 "ext/dtext/dtext.rl"
					
					dstack_close_before_block(sm);
					
					if (dstack_close_block(sm, BLOCK_EXPAND, "</div></div>")) {
						{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
					}
				}
			}}
		
#line 16017 "ext/dtext/dtext.c"
		goto _again;
		f34:
		{
#line 446 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 446 "ext/dtext/dtext.rl"
					
					if (dstack_close_block(sm, BLOCK_TH, "</th>")) {
						{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
					}
				}
			}}
		
#line 16031 "ext/dtext/dtext.c"
		goto _again;
		f33:
		{
#line 452 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 452 "ext/dtext/dtext.rl"
					
					if (dstack_close_block(sm, BLOCK_TD, "</td>")) {
						{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
					}
				}
			}}
		
#line 16045 "ext/dtext/dtext.c"
		goto _again;
		f92:
		{
#line 486 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 486 "ext/dtext/dtext.rl"
					
					g_debug("inline char: %c", (( (*( ( sm->p))))));
					append_c_html_escaped(sm, (( (*( ( sm->p))))));
				}
			}}
		
#line 16058 "ext/dtext/dtext.c"
		goto _again;
		f102:
		{
#line 253 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 253 "ext/dtext/dtext.rl"
					
					const char* match_end = sm->b2;
					const char* url_start = sm->b1;
					const char* url_end = find_boundary_c(match_end);
					
					if (!append_named_url(sm, url_start, url_end, sm->a1, sm->a2)) {
						{( sm->p) += 1; goto _out; }
					}
					
					if (url_end < match_end) {
						append_segment_html_escaped(sm, url_end + 1, match_end);
					}
				}
			}}
		
#line 16080 "ext/dtext/dtext.c"
		goto _again;
		f147:
		{
#line 279 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 279 "ext/dtext/dtext.rl"
					
					const char* match_end = sm->te - 1;
					const char* url_start = sm->ts;
					const char* url_end = find_boundary_c(match_end);
					
					append_url(sm, url_start, url_end, url_start, url_end);
					
					if (url_end < match_end) {
						append_segment_html_escaped(sm, url_end + 1, match_end);
					}
				}
			}}
		
#line 16100 "ext/dtext/dtext.c"
		goto _again;
		f108:
		{
#line 415 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 415 "ext/dtext/dtext.rl"
					
					g_debug("inline [/quote]");
					dstack_close_before_block(sm);
					
					if (dstack_check(sm, BLOCK_LI)) {
						dstack_close_list(sm);
					}
					
					if (dstack_check(sm, BLOCK_QUOTE)) {
						dstack_rewind(sm);
						{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
					} else {
						append_block(sm, "[/quote]");
					}
				}
			}}
		
#line 16124 "ext/dtext/dtext.c"
		goto _again;
		f98:
		{
#line 458 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 458 "ext/dtext/dtext.rl"
					
					g_debug("inline newline2");
					g_debug("  return");
					
					if (sm->list_mode) {
						dstack_close_list(sm);
					}
					
					{( sm->p) = (( sm->ts))-1;}
					
					{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
				}
			}}
		
#line 16145 "ext/dtext/dtext.c"
		goto _again;
		f97:
		{
#line 470 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 470 "ext/dtext/dtext.rl"
					
					g_debug("inline newline");
					
					if (sm->header_mode) {
						sm->header_mode = false;
						dstack_rewind(sm);
						{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
					} else {
						append(sm, "<br>");
					}
				}
			}}
		
#line 16165 "ext/dtext/dtext.c"
		goto _again;
		f100:
		{
#line 482 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 482 "ext/dtext/dtext.rl"
					
					append_c(sm, ' ');
				}
			}}
		
#line 16177 "ext/dtext/dtext.c"
		goto _again;
		f101:
		{
#line 486 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 486 "ext/dtext/dtext.rl"
					
					g_debug("inline char: %c", (( (*( ( sm->p))))));
					append_c_html_escaped(sm, (( (*( ( sm->p))))));
				}
			}}
		
#line 16190 "ext/dtext/dtext.c"
		goto _again;
		f54:
		{
#line 203 "ext/dtext/dtext.rl"
			{( sm->p) = ((( sm->te)))-1;
				{
#line 203 "ext/dtext/dtext.rl"
					append_id_link(sm, "topic", "forum-topic", "/forum_topics/"); }
			}}
		
#line 16201 "ext/dtext/dtext.c"
		goto _again;
		f52:
		{
#line 205 "ext/dtext/dtext.rl"
			{( sm->p) = ((( sm->te)))-1;
				{
#line 205 "ext/dtext/dtext.rl"
					append_id_link(sm, "dmail", "dmail", "/dmails/"); }
			}}
		
#line 16212 "ext/dtext/dtext.c"
		goto _again;
		f53:
		{
#line 224 "ext/dtext/dtext.rl"
			{( sm->p) = ((( sm->te)))-1;
				{
#line 224 "ext/dtext/dtext.rl"
					append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/"); }
			}}
		
#line 16223 "ext/dtext/dtext.c"
		goto _again;
		f21:
		{
#line 470 "ext/dtext/dtext.rl"
			{( sm->p) = ((( sm->te)))-1;
				{
#line 470 "ext/dtext/dtext.rl"
					
					g_debug("inline newline");
					
					if (sm->header_mode) {
						sm->header_mode = false;
						dstack_rewind(sm);
						{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
					} else {
						append(sm, "<br>");
					}
				}
			}}
		
#line 16244 "ext/dtext/dtext.c"
		goto _again;
		f22:
		{
#line 486 "ext/dtext/dtext.rl"
			{( sm->p) = ((( sm->te)))-1;
				{
#line 486 "ext/dtext/dtext.rl"
					
					g_debug("inline char: %c", (( (*( ( sm->p))))));
					append_c_html_escaped(sm, (( (*( ( sm->p))))));
				}
			}}
		
#line 16258 "ext/dtext/dtext.c"
		goto _again;
		f19:
		{
#line 1 "NONE"
			{switch( ( sm->act) ) {
					case 47:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 253 "ext/dtext/dtext.rl"
							
							const char* match_end = sm->b2;
							const char* url_start = sm->b1;
							const char* url_end = find_boundary_c(match_end);
							
							if (!append_named_url(sm, url_start, url_end, sm->a1, sm->a2)) {
								{( sm->p) += 1; goto _out; }
							}
							
							if (url_end < match_end) {
								append_segment_html_escaped(sm, url_end + 1, match_end);
							}
						}
						break; 
					}
					case 50:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 279 "ext/dtext/dtext.rl"
							
							const char* match_end = sm->te - 1;
							const char* url_start = sm->ts;
							const char* url_end = find_boundary_c(match_end);
							
							append_url(sm, url_start, url_end, url_start, url_end);
							
							if (url_end < match_end) {
								append_segment_html_escaped(sm, url_end + 1, match_end);
							}
						}
						break; 
					}
					case 52:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 296 "ext/dtext/dtext.rl"
							
							append_segment_html_escaped(sm, sm->ts, sm->te - 1);
						}
						break; 
					}
					case 53:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 300 "ext/dtext/dtext.rl"
							
							if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
								// handle emails
								append_c(sm, '@');
								{( sm->p) = (( sm->a1))-1;}
								
							} else {
								const char* match_end = sm->a2 - 1;
								const char* name_start = sm->a1;
								const char* name_end = find_boundary_c(match_end);
								
								append(sm, "<a class=\"dtext-link dtext-user-mention-link\" data-user-name=\"");
								append_segment_html_escaped(sm, name_start, name_end);
								append(sm, "\" href=\"/users?name=");
								append_segment_uri_escaped(sm, name_start, name_end);
								append(sm, "\">");
								append_c(sm, '@');
								append_segment_html_escaped(sm, name_start, name_end);
								append(sm, "</a>");
								
								if (name_end < match_end) {
									append_segment_html_escaped(sm, name_end + 1, match_end);
								}
							}
						}
						break; 
					}
					case 76:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 458 "ext/dtext/dtext.rl"
							
							g_debug("inline newline2");
							g_debug("  return");
							
							if (sm->list_mode) {
								dstack_close_list(sm);
							}
							
							{( sm->p) = (( sm->ts))-1;}
							
							{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
						}
						break; 
					}
					case 77:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 470 "ext/dtext/dtext.rl"
							
							g_debug("inline newline");
							
							if (sm->header_mode) {
								sm->header_mode = false;
								dstack_rewind(sm);
								{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
							} else {
								append(sm, "<br>");
							}
						}
						break; 
					}
					case 79:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 486 "ext/dtext/dtext.rl"
							
							g_debug("inline char: %c", (( (*( ( sm->p))))));
							append_c_html_escaped(sm, (( (*( ( sm->p))))));
						}
						break; 
					}
				}}
		}
		
#line 16388 "ext/dtext/dtext.c"
		goto _again;
		f59:
		{
#line 493 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 493 "ext/dtext/dtext.rl"
					
					dstack_rewind(sm);
					{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
				}
			}}
		
#line 16401 "ext/dtext/dtext.c"
		goto _again;
		f148:
		{
#line 498 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 498 "ext/dtext/dtext.rl"
					
					append_c_html_escaped(sm, (( (*( ( sm->p))))));
				}
			}}
		
#line 16413 "ext/dtext/dtext.c"
		goto _again;
		f149:
		{
#line 498 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 498 "ext/dtext/dtext.rl"
					
					append_c_html_escaped(sm, (( (*( ( sm->p))))));
				}
			}}
		
#line 16425 "ext/dtext/dtext.c"
		goto _again;
		f58:
		{
#line 498 "ext/dtext/dtext.rl"
			{( sm->p) = ((( sm->te)))-1;
				{
#line 498 "ext/dtext/dtext.rl"
					
					append_c_html_escaped(sm, (( (*( ( sm->p))))));
				}
			}}
		
#line 16438 "ext/dtext/dtext.c"
		goto _again;
		f61:
		{
#line 504 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 504 "ext/dtext/dtext.rl"
					
					if (dstack_check2(sm, BLOCK_NODTEXT)) {
						g_debug("block dstack check");
						dstack_pop(sm);
						dstack_pop(sm);
						append_block(sm, "</p>");
						{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
					} else if (dstack_check(sm, INLINE_NODTEXT)) {
						g_debug("inline dstack check");
						dstack_pop(sm);
						{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
					} else {
						g_debug("else dstack check");
						append(sm, "[/nodtext]");
					}
				}
			}}
		
#line 16463 "ext/dtext/dtext.c"
		goto _again;
		f150:
		{
#line 521 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 521 "ext/dtext/dtext.rl"
					
					append_c_html_escaped(sm, (( (*( ( sm->p))))));
				}
			}}
		
#line 16475 "ext/dtext/dtext.c"
		goto _again;
		f151:
		{
#line 521 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 521 "ext/dtext/dtext.rl"
					
					append_c_html_escaped(sm, (( (*( ( sm->p))))));
				}
			}}
		
#line 16487 "ext/dtext/dtext.c"
		goto _again;
		f60:
		{
#line 521 "ext/dtext/dtext.rl"
			{( sm->p) = ((( sm->te)))-1;
				{
#line 521 "ext/dtext/dtext.rl"
					
					append_c_html_escaped(sm, (( (*( ( sm->p))))));
				}
			}}
		
#line 16500 "ext/dtext/dtext.c"
		goto _again;
		f70:
		{
#line 527 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 527 "ext/dtext/dtext.rl"
					
					dstack_open_block(sm, BLOCK_THEAD, "<thead>");
				}
			}}
		
#line 16512 "ext/dtext/dtext.c"
		goto _again;
		f65:
		{
#line 531 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 531 "ext/dtext/dtext.rl"
					
					dstack_close_block(sm, BLOCK_THEAD, "</thead>");
				}
			}}
		
#line 16524 "ext/dtext/dtext.c"
		goto _again;
		f67:
		{
#line 535 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 535 "ext/dtext/dtext.rl"
					
					dstack_open_block(sm, BLOCK_TBODY, "<tbody>");
				}
			}}
		
#line 16536 "ext/dtext/dtext.c"
		goto _again;
		f64:
		{
#line 539 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 539 "ext/dtext/dtext.rl"
					
					dstack_close_block(sm, BLOCK_TBODY, "</tbody>");
				}
			}}
		
#line 16548 "ext/dtext/dtext.c"
		goto _again;
		f69:
		{
#line 543 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 543 "ext/dtext/dtext.rl"
					
					dstack_open_block(sm, BLOCK_TH, "<th>");
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 707; goto _again;}}
			}}
		
#line 16575 "ext/dtext/dtext.c"
		goto _again;
		f71:
		{
#line 548 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 548 "ext/dtext/dtext.rl"
					
					dstack_open_block(sm, BLOCK_TR, "<tr>");
				}
			}}
		
#line 16587 "ext/dtext/dtext.c"
		goto _again;
		f66:
		{
#line 552 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 552 "ext/dtext/dtext.rl"
					
					dstack_close_block(sm, BLOCK_TR, "</tr>");
				}
			}}
		
#line 16599 "ext/dtext/dtext.c"
		goto _again;
		f68:
		{
#line 556 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 556 "ext/dtext/dtext.rl"
					
					dstack_open_block(sm, BLOCK_TD, "<td>");
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 707; goto _again;}}
			}}
		
#line 16626 "ext/dtext/dtext.c"
		goto _again;
		f63:
		{
#line 561 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 561 "ext/dtext/dtext.rl"
					
					if (dstack_close_block(sm, BLOCK_TABLE, "</table>")) {
						{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
					}
				}
			}}
		
#line 16640 "ext/dtext/dtext.c"
		goto _again;
		f152:
		{
#line 1 "-"
			{( sm->te) = ( sm->p)+1;}}
		
#line 16647 "ext/dtext/dtext.c"
		goto _again;
		f153:
		{
#line 1 "-"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;}}
		
#line 16654 "ext/dtext/dtext.c"
		goto _again;
		f62:
		{
#line 1 "-"
			{( sm->p) = ((( sm->te)))-1;
			}}
		
#line 16662 "ext/dtext/dtext.c"
		goto _again;
		f154:
		{
#line 612 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 612 "ext/dtext/dtext.rl"
					
					dstack_rewind(sm);
					{( sm->p) = ( sm->p) - 1; }
					{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
				}
			}}
		
#line 16676 "ext/dtext/dtext.c"
		goto _again;
		f156:
		{
#line 612 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 612 "ext/dtext/dtext.rl"
					
					dstack_rewind(sm);
					{( sm->p) = ( sm->p) - 1; }
					{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
				}
			}}
		
#line 16690 "ext/dtext/dtext.c"
		goto _again;
		f74:
		{
#line 612 "ext/dtext/dtext.rl"
			{( sm->p) = ((( sm->te)))-1;
				{
#line 612 "ext/dtext/dtext.rl"
					
					dstack_rewind(sm);
					{( sm->p) = ( sm->p) - 1; }
					{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
				}
			}}
		
#line 16705 "ext/dtext/dtext.c"
		goto _again;
		f72:
		{
#line 1 "NONE"
			{switch( ( sm->act) ) {
					case 95:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 604 "ext/dtext/dtext.rl"
							
							dstack_close_list(sm);
							{( sm->p) = (( sm->ts))-1;}
							
							{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
						}
						break; 
					}
					default: {
						( sm->p) = ((( sm->te)))-1;
						break; 
					}
				}}
		}
		
#line 16730 "ext/dtext/dtext.c"
		goto _again;
		f5:
		{
#line 730 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 730 "ext/dtext/dtext.rl"
					
					g_debug("block [/spoiler]");
					dstack_close_before_block(sm);
					if (dstack_check(sm, BLOCK_SPOILER)) {
						g_debug("  rewind");
						dstack_rewind(sm);
					}
				}
			}}
		
#line 16747 "ext/dtext/dtext.c"
		goto _again;
		f6:
		{
#line 772 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 772 "ext/dtext/dtext.rl"
					
					dstack_close_before_block(sm);
					dstack_open_block(sm, BLOCK_TABLE, "<table class=\"striped\">");
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 784; goto _again;}}
			}}
		
#line 16775 "ext/dtext/dtext.c"
		goto _again;
		f7:
		{
#line 778 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 778 "ext/dtext/dtext.rl"
					
					dstack_open_block(sm, BLOCK_TN, "<p class=\"tn\">");
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 707; goto _again;}}
			}}
		
#line 16802 "ext/dtext/dtext.c"
		goto _again;
		f77:
		{
#line 810 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 810 "ext/dtext/dtext.rl"
					
					g_debug("block char: %c", (( (*( ( sm->p))))));
					{( sm->p) = ( sm->p) - 1; }
					
					if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
						dstack_open_block(sm, BLOCK_P, "<p>");
					}
					
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 707; goto _again;}}
			}}
		
#line 16835 "ext/dtext/dtext.c"
		goto _again;
		f87:
		{
#line 620 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 620 "ext/dtext/dtext.rl"
					
					char header = *sm->a1;
					g_autoptr(GString) id_name = g_string_new_len(sm->b1, sm->b2 - sm->b1);
					id_name = g_string_prepend(id_name, "dtext-");
					
					if (sm->f_inline) {
						header = '6';
					}
					
					switch (header) {
						case '1':
						dstack_push(sm, BLOCK_H1);
						append_block(sm, "<h1 id=\"");
						append_block(sm, id_name->str);
						append_block(sm, "\">");
						break;
						
						case '2':
						dstack_push(sm, BLOCK_H2);
						append_block(sm, "<h2 id=\"");
						append_block(sm, id_name->str);
						append_block(sm, "\">");
						break;
						
						case '3':
						dstack_push(sm, BLOCK_H3);
						append_block(sm, "<h3 id=\"");
						append_block(sm, id_name->str);
						append_block(sm, "\">");
						break;
						
						case '4':
						dstack_push(sm, BLOCK_H4);
						append_block(sm, "<h4 id=\"");
						append_block(sm, id_name->str);
						append_block(sm, "\">");
						break;
						
						case '5':
						dstack_push(sm, BLOCK_H5);
						append_block(sm, "<h5 id=\"");
						append_block(sm, id_name->str);
						append_block(sm, "\">");
						break;
						
						case '6':
						dstack_push(sm, BLOCK_H6);
						append_block(sm, "<h6 id=\"");
						append_block(sm, id_name->str);
						append_block(sm, "\">");
						break;
					}
					
					sm->header_mode = true;
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 707; goto _again;}}
			}}
		
#line 16914 "ext/dtext/dtext.c"
		goto _again;
		f88:
		{
#line 677 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 677 "ext/dtext/dtext.rl"
					
					char header = *sm->a1;
					
					if (sm->f_inline) {
						header = '6';
					}
					
					switch (header) {
						case '1':
						dstack_push(sm, BLOCK_H1);
						append_block(sm, "<h1>");
						break;
						
						case '2':
						dstack_push(sm, BLOCK_H2);
						append_block(sm, "<h2>");
						break;
						
						case '3':
						dstack_push(sm, BLOCK_H3);
						append_block(sm, "<h3>");
						break;
						
						case '4':
						dstack_push(sm, BLOCK_H4);
						append_block(sm, "<h4>");
						break;
						
						case '5':
						dstack_push(sm, BLOCK_H5);
						append_block(sm, "<h5>");
						break;
						
						case '6':
						dstack_push(sm, BLOCK_H6);
						append_block(sm, "<h6>");
						break;
					}
					
					sm->header_mode = true;
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 707; goto _again;}}
			}}
		
#line 16979 "ext/dtext/dtext.c"
		goto _again;
		f82:
		{
#line 720 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 720 "ext/dtext/dtext.rl"
					
					dstack_close_before_block(sm);
					dstack_open_block(sm, BLOCK_QUOTE, "<blockquote>");
				}
			}}
		
#line 16992 "ext/dtext/dtext.c"
		goto _again;
		f86:
		{
#line 725 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 725 "ext/dtext/dtext.rl"
					
					dstack_close_before_block(sm);
					dstack_open_block(sm, BLOCK_SPOILER, "<div class=\"spoiler\">");
				}
			}}
		
#line 17005 "ext/dtext/dtext.c"
		goto _again;
		f83:
		{
#line 739 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 739 "ext/dtext/dtext.rl"
					
					dstack_close_before_block(sm);
					dstack_open_block(sm, BLOCK_CODE, "<pre>");
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 778; goto _again;}}
			}}
		
#line 17033 "ext/dtext/dtext.c"
		goto _again;
		f84:
		{
#line 745 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 745 "ext/dtext/dtext.rl"
					
					dstack_close_before_block(sm);
					const char* html = "<div class=\"expandable\"><div class=\"expandable-header\">"
					"<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>"
					"<div class=\"expandable-content\">";
					dstack_open_block(sm, BLOCK_EXPAND, html);
				}
			}}
		
#line 17049 "ext/dtext/dtext.c"
		goto _again;
		f89:
		{
#line 753 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 753 "ext/dtext/dtext.rl"
					
					g_debug("block [expand=]");
					dstack_close_before_block(sm);
					dstack_push(sm, BLOCK_EXPAND);
					append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
					append(sm, "<span>");
					append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
					append(sm, "</span>");
					append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
					append_block(sm, "<div class=\"expandable-content\">");
				}
			}}
		
#line 17069 "ext/dtext/dtext.c"
		goto _again;
		f85:
		{
#line 765 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 765 "ext/dtext/dtext.rl"
					
					dstack_close_before_block(sm);
					dstack_open_block(sm, BLOCK_NODTEXT, "");
					dstack_open_block(sm, BLOCK_P, "<p>");
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 781; goto _again;}}
			}}
		
#line 17098 "ext/dtext/dtext.c"
		goto _again;
		f80:
		{
#line 810 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 810 "ext/dtext/dtext.rl"
					
					g_debug("block char: %c", (( (*( ( sm->p))))));
					{( sm->p) = ( sm->p) - 1; }
					
					if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
						dstack_open_block(sm, BLOCK_P, "<p>");
					}
					
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 707; goto _again;}}
			}}
		
#line 17131 "ext/dtext/dtext.c"
		goto _again;
		f2:
		{
#line 810 "ext/dtext/dtext.rl"
			{( sm->p) = ((( sm->te)))-1;
				{
#line 810 "ext/dtext/dtext.rl"
					
					g_debug("block char: %c", (( (*( ( sm->p))))));
					{( sm->p) = ( sm->p) - 1; }
					
					if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
						dstack_open_block(sm, BLOCK_P, "<p>");
					}
					
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 707; goto _again;}}
			}}
		
#line 17165 "ext/dtext/dtext.c"
		goto _again;
		f0:
		{
#line 1 "NONE"
			{switch( ( sm->act) ) {
					case 110:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 793 "ext/dtext/dtext.rl"
							
							g_debug("block newline2");
							
							if (sm->header_mode) {
								sm->header_mode = false;
								dstack_rewind(sm);
							} else if (sm->list_mode) {
								dstack_close_list(sm);
							} else {
								dstack_close_before_block(sm);
							}
						}
						break; 
					}
					case 111:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 806 "ext/dtext/dtext.rl"
							
							g_debug("block newline");
						}
						break; 
					}
				}}
		}
		
#line 17201 "ext/dtext/dtext.c"
		goto _again;
		f37:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17210 "ext/dtext/dtext.c"
		{
#line 325 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 325 "ext/dtext/dtext.rl"
					
					if (sm->f_mentions) {
						append(sm, "<a class=\"dtext-link dtext-user-mention-link\" data-user-name=\"");
						append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
						append(sm, "\" href=\"/users?name=");
						append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
						append(sm, "\">");
						append_c(sm, '@');
						append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
						append(sm, "</a>");
					}
				}
			}}
		
#line 17229 "ext/dtext/dtext.c"
		goto _again;
		f138:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17238 "ext/dtext/dtext.c"
		{
#line 198 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 198 "ext/dtext/dtext.rl"
					append_id_link(sm, "post", "post", "/posts/"); }
			}}
		
#line 17246 "ext/dtext/dtext.c"
		goto _again;
		f114:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17255 "ext/dtext/dtext.c"
		{
#line 199 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 199 "ext/dtext/dtext.rl"
					append_id_link(sm, "appeal", "post-appeal", "/post_appeals/"); }
			}}
		
#line 17263 "ext/dtext/dtext.c"
		goto _again;
		f125:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17272 "ext/dtext/dtext.c"
		{
#line 200 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 200 "ext/dtext/dtext.rl"
					append_id_link(sm, "flag", "post-flag", "/post_flags/"); }
			}}
		
#line 17280 "ext/dtext/dtext.c"
		goto _again;
		f133:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17289 "ext/dtext/dtext.c"
		{
#line 201 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 201 "ext/dtext/dtext.rl"
					append_id_link(sm, "note", "note", "/notes/"); }
			}}
		
#line 17297 "ext/dtext/dtext.c"
		goto _again;
		f126:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17306 "ext/dtext/dtext.c"
		{
#line 202 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 202 "ext/dtext/dtext.rl"
					append_id_link(sm, "forum", "forum-post", "/forum_posts/"); }
			}}
		
#line 17314 "ext/dtext/dtext.c"
		goto _again;
		f141:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17323 "ext/dtext/dtext.c"
		{
#line 203 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 203 "ext/dtext/dtext.rl"
					append_id_link(sm, "topic", "forum-topic", "/forum_topics/"); }
			}}
		
#line 17331 "ext/dtext/dtext.c"
		goto _again;
		f119:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17340 "ext/dtext/dtext.c"
		{
#line 204 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 204 "ext/dtext/dtext.rl"
					append_id_link(sm, "comment", "comment", "/comments/"); }
			}}
		
#line 17348 "ext/dtext/dtext.c"
		goto _again;
		f121:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17357 "ext/dtext/dtext.c"
		{
#line 205 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 205 "ext/dtext/dtext.rl"
					append_id_link(sm, "dmail", "dmail", "/dmails/"); }
			}}
		
#line 17365 "ext/dtext/dtext.c"
		goto _again;
		f137:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17374 "ext/dtext/dtext.c"
		{
#line 206 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 206 "ext/dtext/dtext.rl"
					append_id_link(sm, "pool", "pool", "/pools/"); }
			}}
		
#line 17382 "ext/dtext/dtext.c"
		goto _again;
		f144:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17391 "ext/dtext/dtext.c"
		{
#line 207 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 207 "ext/dtext/dtext.rl"
					append_id_link(sm, "user", "user", "/users/"); }
			}}
		
#line 17399 "ext/dtext/dtext.c"
		goto _again;
		f115:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17408 "ext/dtext/dtext.c"
		{
#line 208 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 208 "ext/dtext/dtext.rl"
					append_id_link(sm, "artist", "artist", "/artists/"); }
			}}
		
#line 17416 "ext/dtext/dtext.c"
		goto _again;
		f117:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17425 "ext/dtext/dtext.c"
		{
#line 209 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 209 "ext/dtext/dtext.rl"
					append_id_link(sm, "ban", "ban", "/bans/"); }
			}}
		
#line 17433 "ext/dtext/dtext.c"
		goto _again;
		f118:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17442 "ext/dtext/dtext.c"
		{
#line 210 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 210 "ext/dtext/dtext.rl"
					append_id_link(sm, "BUR", "bulk-update-request", "/bulk_update_requests/"); }
			}}
		
#line 17450 "ext/dtext/dtext.c"
		goto _again;
		f113:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17459 "ext/dtext/dtext.c"
		{
#line 211 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 211 "ext/dtext/dtext.rl"
					append_id_link(sm, "alias", "tag-alias", "/tag_aliases/"); }
			}}
		
#line 17467 "ext/dtext/dtext.c"
		goto _again;
		f128:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17476 "ext/dtext/dtext.c"
		{
#line 212 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 212 "ext/dtext/dtext.rl"
					append_id_link(sm, "implication", "tag-implication", "/tag_implications/"); }
			}}
		
#line 17484 "ext/dtext/dtext.c"
		goto _again;
		f123:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17493 "ext/dtext/dtext.c"
		{
#line 213 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 213 "ext/dtext/dtext.rl"
					append_id_link(sm, "favgroup", "favorite-group", "/favorite_groups/"); }
			}}
		
#line 17501 "ext/dtext/dtext.c"
		goto _again;
		f130:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17510 "ext/dtext/dtext.c"
		{
#line 214 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 214 "ext/dtext/dtext.rl"
					append_id_link(sm, "mod action", "mod-action", "/mod_actions/"); }
			}}
		
#line 17518 "ext/dtext/dtext.c"
		goto _again;
		f131:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17527 "ext/dtext/dtext.c"
		{
#line 215 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 215 "ext/dtext/dtext.rl"
					append_id_link(sm, "modreport", "moderation-report", "/moderation_reports/"); }
			}}
		
#line 17535 "ext/dtext/dtext.c"
		goto _again;
		f124:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17544 "ext/dtext/dtext.c"
		{
#line 216 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 216 "ext/dtext/dtext.rl"
					append_id_link(sm, "feedback", "user-feedback", "/user_feedbacks/"); }
			}}
		
#line 17552 "ext/dtext/dtext.c"
		goto _again;
		f145:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17561 "ext/dtext/dtext.c"
		{
#line 217 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 217 "ext/dtext/dtext.rl"
					append_id_link(sm, "wiki", "wiki-page", "/wiki_pages/"); }
			}}
		
#line 17569 "ext/dtext/dtext.c"
		goto _again;
		f129:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17578 "ext/dtext/dtext.c"
		{
#line 219 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 219 "ext/dtext/dtext.rl"
					append_id_link(sm, "issue", "github", "https://github.com/r888888888/danbooru/issues/"); }
			}}
		
#line 17586 "ext/dtext/dtext.c"
		goto _again;
		f116:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17595 "ext/dtext/dtext.c"
		{
#line 220 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 220 "ext/dtext/dtext.rl"
					append_id_link(sm, "artstation", "artstation", "https://www.artstation.com/artwork/"); }
			}}
		
#line 17603 "ext/dtext/dtext.c"
		goto _again;
		f120:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17612 "ext/dtext/dtext.c"
		{
#line 221 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 221 "ext/dtext/dtext.rl"
					append_id_link(sm, "deviantart", "deviantart", "https://www.deviantart.com/deviation/"); }
			}}
		
#line 17620 "ext/dtext/dtext.c"
		goto _again;
		f132:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17629 "ext/dtext/dtext.c"
		{
#line 222 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 222 "ext/dtext/dtext.rl"
					append_id_link(sm, "nijie", "nijie", "https://nijie.info/view.php?id="); }
			}}
		
#line 17637 "ext/dtext/dtext.c"
		goto _again;
		f134:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17646 "ext/dtext/dtext.c"
		{
#line 223 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 223 "ext/dtext/dtext.rl"
					append_id_link(sm, "pawoo", "pawoo", "https://pawoo.net/web/statuses/"); }
			}}
		
#line 17654 "ext/dtext/dtext.c"
		goto _again;
		f135:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17663 "ext/dtext/dtext.c"
		{
#line 224 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 224 "ext/dtext/dtext.rl"
					append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/"); }
			}}
		
#line 17671 "ext/dtext/dtext.c"
		goto _again;
		f140:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17680 "ext/dtext/dtext.c"
		{
#line 225 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 225 "ext/dtext/dtext.rl"
					append_id_link(sm, "seiga", "seiga", "https://seiga.nicovideo.jp/seiga/im"); }
			}}
		
#line 17688 "ext/dtext/dtext.c"
		goto _again;
		f143:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17697 "ext/dtext/dtext.c"
		{
#line 226 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 226 "ext/dtext/dtext.rl"
					append_id_link(sm, "twitter", "twitter", "https://twitter.com/i/web/status/"); }
			}}
		
#line 17705 "ext/dtext/dtext.c"
		goto _again;
		f146:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17714 "ext/dtext/dtext.c"
		{
#line 228 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 228 "ext/dtext/dtext.rl"
					append_id_link(sm, "yandere", "yandere", "https://yande.re/post/show/"); }
			}}
		
#line 17722 "ext/dtext/dtext.c"
		goto _again;
		f139:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17731 "ext/dtext/dtext.c"
		{
#line 229 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 229 "ext/dtext/dtext.rl"
					append_id_link(sm, "sankaku", "sankaku", "https://chan.sankakucomplex.com/post/show/"); }
			}}
		
#line 17739 "ext/dtext/dtext.c"
		goto _again;
		f127:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17748 "ext/dtext/dtext.c"
		{
#line 230 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 230 "ext/dtext/dtext.rl"
					append_id_link(sm, "gelbooru", "gelbooru", "https://gelbooru.com/index.php?page=post&s=view&id="); }
			}}
		
#line 17756 "ext/dtext/dtext.c"
		goto _again;
		f111:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17765 "ext/dtext/dtext.c"
		{
#line 300 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 300 "ext/dtext/dtext.rl"
					
					if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
						// handle emails
						append_c(sm, '@');
						{( sm->p) = (( sm->a1))-1;}
						
					} else {
						const char* match_end = sm->a2 - 1;
						const char* name_start = sm->a1;
						const char* name_end = find_boundary_c(match_end);
						
						append(sm, "<a class=\"dtext-link dtext-user-mention-link\" data-user-name=\"");
						append_segment_html_escaped(sm, name_start, name_end);
						append(sm, "\" href=\"/users?name=");
						append_segment_uri_escaped(sm, name_start, name_end);
						append(sm, "\">");
						append_c(sm, '@');
						append_segment_html_escaped(sm, name_start, name_end);
						append(sm, "</a>");
						
						if (name_end < match_end) {
							append_segment_html_escaped(sm, name_end + 1, match_end);
						}
					}
				}
			}}
		
#line 17797 "ext/dtext/dtext.c"
		goto _again;
		f110:
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 17806 "ext/dtext/dtext.c"
		{
#line 1 "NONE"
			{switch( ( sm->act) ) {
					case 47:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 253 "ext/dtext/dtext.rl"
							
							const char* match_end = sm->b2;
							const char* url_start = sm->b1;
							const char* url_end = find_boundary_c(match_end);
							
							if (!append_named_url(sm, url_start, url_end, sm->a1, sm->a2)) {
								{( sm->p) += 1; goto _out; }
							}
							
							if (url_end < match_end) {
								append_segment_html_escaped(sm, url_end + 1, match_end);
							}
						}
						break; 
					}
					case 50:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 279 "ext/dtext/dtext.rl"
							
							const char* match_end = sm->te - 1;
							const char* url_start = sm->ts;
							const char* url_end = find_boundary_c(match_end);
							
							append_url(sm, url_start, url_end, url_start, url_end);
							
							if (url_end < match_end) {
								append_segment_html_escaped(sm, url_end + 1, match_end);
							}
						}
						break; 
					}
					case 52:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 296 "ext/dtext/dtext.rl"
							
							append_segment_html_escaped(sm, sm->ts, sm->te - 1);
						}
						break; 
					}
					case 53:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 300 "ext/dtext/dtext.rl"
							
							if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
								// handle emails
								append_c(sm, '@');
								{( sm->p) = (( sm->a1))-1;}
								
							} else {
								const char* match_end = sm->a2 - 1;
								const char* name_start = sm->a1;
								const char* name_end = find_boundary_c(match_end);
								
								append(sm, "<a class=\"dtext-link dtext-user-mention-link\" data-user-name=\"");
								append_segment_html_escaped(sm, name_start, name_end);
								append(sm, "\" href=\"/users?name=");
								append_segment_uri_escaped(sm, name_start, name_end);
								append(sm, "\">");
								append_c(sm, '@');
								append_segment_html_escaped(sm, name_start, name_end);
								append(sm, "</a>");
								
								if (name_end < match_end) {
									append_segment_html_escaped(sm, name_end + 1, match_end);
								}
							}
						}
						break; 
					}
					case 76:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 458 "ext/dtext/dtext.rl"
							
							g_debug("inline newline2");
							g_debug("  return");
							
							if (sm->list_mode) {
								dstack_close_list(sm);
							}
							
							{( sm->p) = (( sm->ts))-1;}
							
							{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
						}
						break; 
					}
					case 77:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 470 "ext/dtext/dtext.rl"
							
							g_debug("inline newline");
							
							if (sm->header_mode) {
								sm->header_mode = false;
								dstack_rewind(sm);
								{( sm->top)-= 1;sm->cs = ( ((int *)sm->stack->data))[( sm->top)];goto _again;}
							} else {
								append(sm, "<br>");
							}
						}
						break; 
					}
					case 79:  {
						( sm->p) = ((( sm->te)))-1;
						{
#line 486 "ext/dtext/dtext.rl"
							
							g_debug("inline char: %c", (( (*( ( sm->p))))));
							append_c_html_escaped(sm, (( (*( ( sm->p))))));
						}
						break; 
					}
				}}
		}
		
#line 17934 "ext/dtext/dtext.c"
		goto _again;
		f55:
		{
#line 84 "ext/dtext/dtext.rl"
			
			sm->b2 = sm->p;
		}
		
#line 17943 "ext/dtext/dtext.c"
		{
#line 273 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p)+1;{
#line 273 "ext/dtext/dtext.rl"
					
					if (!append_named_url(sm, sm->a1, sm->a2 - 1, sm->b1, sm->b2)) {
						{( sm->p) += 1; goto _out; }
					}
				}
			}}
		
#line 17955 "ext/dtext/dtext.c"
		goto _again;
		f122:
		{
#line 84 "ext/dtext/dtext.rl"
			
			sm->b2 = sm->p;
		}
		
#line 17964 "ext/dtext/dtext.c"
		{
#line 232 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 232 "ext/dtext/dtext.rl"
					append_dmail_key_link(sm); }
			}}
		
#line 17972 "ext/dtext/dtext.c"
		goto _again;
		f142:
		{
#line 84 "ext/dtext/dtext.rl"
			
			sm->b2 = sm->p;
		}
		
#line 17981 "ext/dtext/dtext.c"
		{
#line 234 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 234 "ext/dtext/dtext.rl"
					append_paged_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"/forum_topics/", "?page="); }
			}}
		
#line 17989 "ext/dtext/dtext.c"
		goto _again;
		f136:
		{
#line 84 "ext/dtext/dtext.rl"
			
			sm->b2 = sm->p;
		}
		
#line 17998 "ext/dtext/dtext.c"
		{
#line 235 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 235 "ext/dtext/dtext.rl"
					append_paged_link(sm, "pixiv #", "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"https://www.pixiv.net/artworks/", "#"); }
			}}
		
#line 18006 "ext/dtext/dtext.c"
		goto _again;
		f99:
		{
#line 84 "ext/dtext/dtext.rl"
			
			sm->b2 = sm->p;
		}
		
#line 18015 "ext/dtext/dtext.c"
		{
#line 338 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 338 "ext/dtext/dtext.rl"
					
					g_debug("inline list");
					
					if (dstack_check(sm, BLOCK_LI)) {
						g_debug("  rewind li");
						dstack_rewind(sm);
					} else if (dstack_check(sm, BLOCK_P)) {
						g_debug("  rewind p");
						dstack_rewind(sm);
					} else if (sm->header_mode) {
						g_debug("  rewind header");
						dstack_rewind(sm);
					}
					
					g_debug("  next list");
					{( sm->p) = (( sm->ts + 1))-1;}
					
					sm->cs = 787;}
			}}
		
#line 18040 "ext/dtext/dtext.c"
		goto _again;
		f157:
		{
#line 84 "ext/dtext/dtext.rl"
			
			sm->b2 = sm->p;
		}
		
#line 18049 "ext/dtext/dtext.c"
		{
#line 571 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 571 "ext/dtext/dtext.rl"
					
					int prev_nest = sm->list_nest;
					append_closing_p_if(sm);
					g_debug("list start");
					sm->list_mode = true;
					sm->list_nest = sm->a2 - sm->a1;
					{( sm->p) = (( sm->b1))-1;}
					
					
					if (sm->list_nest > prev_nest) {
						int i=0;
						for (i=prev_nest; i<sm->list_nest; ++i) {
							dstack_open_block(sm, BLOCK_UL, "<ul>");
						}
					} else if (sm->list_nest < prev_nest) {
						int i=0;
						for (i=sm->list_nest; i<prev_nest; ++i) {
							if (dstack_check(sm, BLOCK_UL)) {
								g_debug("  dstack pop");
								g_debug("  print </ul>");
								dstack_pop(sm);
								append_block(sm, "</ul>");
							}
						}
					}
					
					dstack_open_block(sm, BLOCK_LI, "<li>");
					
					g_debug("  call inline");
					
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 707; goto _again;}}
			}}
		
#line 18102 "ext/dtext/dtext.c"
		goto _again;
		f81:
		{
#line 84 "ext/dtext/dtext.rl"
			
			sm->b2 = sm->p;
		}
		
#line 18111 "ext/dtext/dtext.c"
		{
#line 783 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 783 "ext/dtext/dtext.rl"
					
					g_debug("block list");
					g_debug("  call list");
					sm->list_nest = 0;
					sm->list_mode = true;
					append_closing_p_if(sm);
					{( sm->p) = (( sm->ts))-1;}
					
					{{
#line 58 "ext/dtext/dtext.rl"
							
							size_t len = sm->stack->len;
							
							if (len > MAX_STACK_DEPTH) {
								g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
								{( sm->p) += 1; goto _out; }
							}
							
							if (sm->top >= len) {
								g_debug("growing sm->stack %zi\n", len + 16);
								sm->stack = g_array_set_size(sm->stack, len + 16);
							}
						}
						( ((int *)sm->stack->data))[( sm->top)] = sm->cs; ( sm->top) += 1;sm->cs = 787; goto _again;}}
			}}
		
#line 18142 "ext/dtext/dtext.c"
		goto _again;
		f26:
		{
#line 88 "ext/dtext/dtext.rl"
			
			sm->c1 = sm->p;
		}
		
#line 18151 "ext/dtext/dtext.c"
		{
#line 92 "ext/dtext/dtext.rl"
			
			sm->c2 = sm->p;
		}
		
#line 18158 "ext/dtext/dtext.c"
		goto _again;
		f104:
		{
#line 92 "ext/dtext/dtext.rl"
			
			sm->c2 = sm->p;
		}
		
#line 18167 "ext/dtext/dtext.c"
		{
#line 245 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 245 "ext/dtext/dtext.rl"
					
					append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->b1, sm->b2 - sm->b1, sm->a1, sm->a2 - sm->a1, sm->c1, sm->c2 - sm->c1);
				}
			}}
		
#line 18177 "ext/dtext/dtext.c"
		goto _again;
		f107:
		{
#line 100 "ext/dtext/dtext.rl"
			
			sm->d2 = sm->p;
		}
		
#line 18186 "ext/dtext/dtext.c"
		{
#line 249 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 249 "ext/dtext/dtext.rl"
					
					append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->c1, sm->c2 - sm->c1, sm->a1, sm->a2 - sm->a1, sm->d1, sm->d2 - sm->d1);
				}
			}}
		
#line 18196 "ext/dtext/dtext.c"
		goto _again;
		f51:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18203 "ext/dtext/dtext.c"
		{
#line 72 "ext/dtext/dtext.rl"
			
			sm->a1 = sm->p;
		}
		
#line 18210 "ext/dtext/dtext.c"
		goto _again;
		f56:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18217 "ext/dtext/dtext.c"
		{
#line 279 "ext/dtext/dtext.rl"
			{( sm->act) = 50;}}
		
#line 18222 "ext/dtext/dtext.c"
		goto _again;
		f112:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18229 "ext/dtext/dtext.c"
		{
#line 296 "ext/dtext/dtext.rl"
			{( sm->act) = 52;}}
		
#line 18234 "ext/dtext/dtext.c"
		goto _again;
		f50:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18241 "ext/dtext/dtext.c"
		{
#line 300 "ext/dtext/dtext.rl"
			{( sm->act) = 53;}}
		
#line 18246 "ext/dtext/dtext.c"
		goto _again;
		f20:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18253 "ext/dtext/dtext.c"
		{
#line 458 "ext/dtext/dtext.rl"
			{( sm->act) = 76;}}
		
#line 18258 "ext/dtext/dtext.c"
		goto _again;
		f93:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18265 "ext/dtext/dtext.c"
		{
#line 470 "ext/dtext/dtext.rl"
			{( sm->act) = 77;}}
		
#line 18270 "ext/dtext/dtext.c"
		goto _again;
		f94:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18277 "ext/dtext/dtext.c"
		{
#line 486 "ext/dtext/dtext.rl"
			{( sm->act) = 79;}}
		
#line 18282 "ext/dtext/dtext.c"
		goto _again;
		f73:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18289 "ext/dtext/dtext.c"
		{
#line 604 "ext/dtext/dtext.rl"
			{( sm->act) = 95;}}
		
#line 18294 "ext/dtext/dtext.c"
		goto _again;
		f155:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18301 "ext/dtext/dtext.c"
		{
#line 1 "-"
			{( sm->act) = 96;}}
		
#line 18306 "ext/dtext/dtext.c"
		goto _again;
		f1:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18313 "ext/dtext/dtext.c"
		{
#line 793 "ext/dtext/dtext.rl"
			{( sm->act) = 110;}}
		
#line 18318 "ext/dtext/dtext.c"
		goto _again;
		f78:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18325 "ext/dtext/dtext.c"
		{
#line 806 "ext/dtext/dtext.rl"
			{( sm->act) = 111;}}
		
#line 18330 "ext/dtext/dtext.c"
		goto _again;
		f103:
		{
#line 88 "ext/dtext/dtext.rl"
			
			sm->c1 = sm->p;
		}
		
#line 18339 "ext/dtext/dtext.c"
		{
#line 92 "ext/dtext/dtext.rl"
			
			sm->c2 = sm->p;
		}
		
#line 18346 "ext/dtext/dtext.c"
		{
#line 245 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 245 "ext/dtext/dtext.rl"
					
					append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->b1, sm->b2 - sm->b1, sm->a1, sm->a2 - sm->a1, sm->c1, sm->c2 - sm->c1);
				}
			}}
		
#line 18356 "ext/dtext/dtext.c"
		goto _again;
		f105:
		{
#line 96 "ext/dtext/dtext.rl"
			
			sm->d1 = sm->p;
		}
		
#line 18365 "ext/dtext/dtext.c"
		{
#line 100 "ext/dtext/dtext.rl"
			
			sm->d2 = sm->p;
		}
		
#line 18372 "ext/dtext/dtext.c"
		{
#line 249 "ext/dtext/dtext.rl"
			{( sm->te) = ( sm->p);( sm->p) = ( sm->p) - 1;{
#line 249 "ext/dtext/dtext.rl"
					
					append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->c1, sm->c2 - sm->c1, sm->a1, sm->a2 - sm->a1, sm->d1, sm->d2 - sm->d1);
				}
			}}
		
#line 18382 "ext/dtext/dtext.c"
		goto _again;
		f95:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18389 "ext/dtext/dtext.c"
		{
#line 72 "ext/dtext/dtext.rl"
			
			sm->a1 = sm->p;
		}
		
#line 18396 "ext/dtext/dtext.c"
		{
#line 76 "ext/dtext/dtext.rl"
			
			sm->a2 = sm->p;
		}
		
#line 18403 "ext/dtext/dtext.c"
		goto _again;
		f109:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18410 "ext/dtext/dtext.c"
		{
#line 72 "ext/dtext/dtext.rl"
			
			sm->a1 = sm->p;
		}
		
#line 18417 "ext/dtext/dtext.c"
		{
#line 300 "ext/dtext/dtext.rl"
			{( sm->act) = 53;}}
		
#line 18422 "ext/dtext/dtext.c"
		goto _again;
		f96:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18429 "ext/dtext/dtext.c"
		{
#line 72 "ext/dtext/dtext.rl"
			
			sm->a1 = sm->p;
		}
		
#line 18436 "ext/dtext/dtext.c"
		{
#line 486 "ext/dtext/dtext.rl"
			{( sm->act) = 79;}}
		
#line 18441 "ext/dtext/dtext.c"
		goto _again;
		f23:
		{
#line 1 "NONE"
			{( sm->te) = ( sm->p)+1;}}
		
#line 18448 "ext/dtext/dtext.c"
		{
#line 84 "ext/dtext/dtext.rl"
			
			sm->b2 = sm->p;
		}
		
#line 18455 "ext/dtext/dtext.c"
		{
#line 253 "ext/dtext/dtext.rl"
			{( sm->act) = 47;}}
		
#line 18460 "ext/dtext/dtext.c"
		goto _again;
		
		_again: {}
		if ( ( sm->p) == ( sm->eof) ) {
			if ( sm->cs >= 687 )
				goto _out;
		}
		else {
			switch ( _dtext_to_state_actions[sm->cs] ) {
				case 76: {
					{
#line 1 "NONE"
						{( sm->ts) = 0;}}
					
#line 18475 "ext/dtext/dtext.c"
					
					break; 
				}
			}
			
			( sm->p) += 1;
			goto _resume;
		}
		_out: {}
	}
	
#line 1253 "ext/dtext/dtext.rl"
	
	
	dstack_close(sm);
	
	return sm->error == NULL;
}

/* Everything below is optional, it's only needed to build bin/cdtext.exe. */
#ifdef CDTEXT

static void parse_file(FILE* input, FILE* output, gboolean opt_inline, gboolean opt_mentions) {
	g_autofree char* dtext = NULL;
	size_t n = 0;
	
	ssize_t length = getdelim(&dtext, &n, '\0', input);
	if (length == -1) {
		if (ferror(input)) {
			perror("getdelim failed");
			exit(1);
		} else /* EOF (file was empty, continue with the empty string) */ {
			dtext = NULL;
			length = 0;
		}
	}
	
	StateMachine* sm = init_machine(dtext, length, opt_inline, opt_mentions);
	if (!parse_helper(sm)) {
		fprintf(stderr, "dtext parse error: %s\n", sm->error->message);
		exit(1);
	}
	
	if (fwrite(sm->output->str, 1, sm->output->len, output) != sm->output->len) {
		perror("fwrite failed");
		exit(1);
	}
	
	free_machine(sm);
}

int main(int argc, char* argv[]) {
	GError* error = NULL;
	gboolean opt_verbose = FALSE;
	gboolean opt_inline = FALSE;
	gboolean opt_no_mentions = FALSE;
	
	GOptionEntry options[] = {
		{ "no-mentions", 'm', 0, G_OPTION_ARG_NONE, &opt_no_mentions, "Don't parse @mentions", NULL },
		{ "inline",      'i', 0, G_OPTION_ARG_NONE, &opt_inline,      "Parse in inline mode", NULL },
		{ "verbose",     'v', 0, G_OPTION_ARG_NONE, &opt_verbose,     "Print debug output", NULL },
		{ NULL }
	};
	
	g_autoptr(GOptionContext) context = g_option_context_new("[FILE...]");
	g_option_context_add_main_entries(context, options, NULL);
	
	if (!g_option_context_parse(context, &argc, &argv, &error)) {
		fprintf(stderr, "option parsing failed: %s\n", error->message);
		g_clear_error(&error);
		return 1;
	}
	
	if (opt_verbose) {
		g_setenv("G_MESSAGES_DEBUG", "all", TRUE);
	}
	
	/* skip first argument (progname) */
	argc--, argv++;
	
	if (argc == 0) {
		parse_file(stdin, stdout, opt_inline, !opt_no_mentions);
		return 0;
	}
	
	for (const char* filename = *argv; argc > 0; argc--, argv++) {
		FILE* input = fopen(filename, "r");
		if (!input) {
			perror("fopen failed");
			return 1;
		}
		
		parse_file(input, stdout, opt_inline, !opt_no_mentions);
		fclose(input);
	}
	
	return 0;
}

#endif
