SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgstattuple; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgstattuple WITH SCHEMA public;


--
-- Name: EXTENSION pgstattuple; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgstattuple IS 'show tuple-level statistics';


--
-- Name: reverse_textregexeq(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reverse_textregexeq(text, text) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$ SELECT textregexeq($2, $1); $_$;


--
-- Name: ~<<; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.~<< (
    FUNCTION = public.reverse_textregexeq,
    LEFTARG = text,
    RIGHTARG = text
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_keys (
    id integer NOT NULL,
    user_id integer NOT NULL,
    key character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    permissions character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    permitted_ip_addresses inet[] DEFAULT '{}'::inet[] NOT NULL,
    uses integer DEFAULT 0 NOT NULL,
    last_used_at timestamp without time zone,
    last_ip_address inet
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_keys_id_seq OWNED BY public.api_keys.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: artist_commentaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_commentaries (
    id integer NOT NULL,
    post_id integer NOT NULL,
    original_title text DEFAULT ''::text NOT NULL,
    original_description text DEFAULT ''::text NOT NULL,
    translated_title text DEFAULT ''::text NOT NULL,
    translated_description text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: artist_commentaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_commentaries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_commentaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_commentaries_id_seq OWNED BY public.artist_commentaries.id;


--
-- Name: artist_commentary_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_commentary_versions (
    id integer NOT NULL,
    post_id integer NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    original_title text DEFAULT ''::text NOT NULL,
    original_description text DEFAULT ''::text NOT NULL,
    translated_title text DEFAULT ''::text NOT NULL,
    translated_description text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: artist_commentary_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_commentary_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_commentary_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_commentary_versions_id_seq OWNED BY public.artist_commentary_versions.id;


--
-- Name: artist_urls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_urls (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    url text NOT NULL,
    normalized_url text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: artist_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_urls_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_urls_id_seq OWNED BY public.artist_urls.id;


--
-- Name: artist_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_versions (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    name character varying NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    group_name character varying DEFAULT ''::character varying NOT NULL,
    urls text[] DEFAULT '{}'::text[] NOT NULL,
    is_banned boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: artist_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_versions_id_seq OWNED BY public.artist_versions.id;


--
-- Name: artists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artists (
    id integer NOT NULL,
    name character varying NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    is_banned boolean DEFAULT false NOT NULL,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    group_name character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: artists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artists_id_seq OWNED BY public.artists.id;


--
-- Name: bans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bans (
    id integer NOT NULL,
    user_id integer NOT NULL,
    reason text NOT NULL,
    banner_id integer NOT NULL,
    duration interval NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bans_id_seq OWNED BY public.bans.id;


--
-- Name: bulk_update_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bulk_update_requests (
    id integer NOT NULL,
    user_id integer NOT NULL,
    forum_topic_id integer,
    script text NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approver_id integer,
    forum_post_id integer,
    tags text[] DEFAULT '{}'::text[] NOT NULL
);


--
-- Name: bulk_update_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bulk_update_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bulk_update_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bulk_update_requests_id_seq OWNED BY public.bulk_update_requests.id;


--
-- Name: comment_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_votes (
    id integer NOT NULL,
    comment_id integer NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: comment_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comment_votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comment_votes_id_seq OWNED BY public.comment_votes.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    body text NOT NULL,
    creator_ip_addr inet NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    updater_id integer,
    updater_ip_addr inet,
    do_not_bump_post boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: dmails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dmails (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    from_id integer NOT NULL,
    to_id integer NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    creator_ip_addr inet NOT NULL,
    is_spam boolean DEFAULT false NOT NULL
);


--
-- Name: dmails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dmails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dmails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dmails_id_seq OWNED BY public.dmails.id;


--
-- Name: dtext_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dtext_links (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    model_type character varying NOT NULL,
    model_id bigint NOT NULL,
    link_type integer NOT NULL,
    link_target character varying NOT NULL
);


--
-- Name: dtext_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dtext_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dtext_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dtext_links_id_seq OWNED BY public.dtext_links.id;


--
-- Name: email_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_addresses (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL,
    address character varying NOT NULL,
    normalized_address character varying NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    is_deliverable boolean DEFAULT true NOT NULL
);


--
-- Name: email_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_addresses_id_seq OWNED BY public.email_addresses.id;


--
-- Name: favorite_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorite_groups (
    id integer NOT NULL,
    name text NOT NULL,
    creator_id integer NOT NULL,
    post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_public boolean DEFAULT true NOT NULL
);


--
-- Name: favorite_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorite_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorite_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorite_groups_id_seq OWNED BY public.favorite_groups.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL
);


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorites_id_seq OWNED BY public.favorites.id;


--
-- Name: forum_post_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_post_votes (
    id bigint NOT NULL,
    forum_post_id integer NOT NULL,
    creator_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: forum_post_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_post_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_post_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_post_votes_id_seq OWNED BY public.forum_post_votes.id;


--
-- Name: forum_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_posts (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    body text NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: forum_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_posts_id_seq OWNED BY public.forum_posts.id;


--
-- Name: forum_topic_visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_topic_visits (
    id integer NOT NULL,
    user_id integer NOT NULL,
    forum_topic_id integer NOT NULL,
    last_read_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: forum_topic_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_topic_visits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_topic_visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_topic_visits_id_seq OWNED BY public.forum_topic_visits.id;


--
-- Name: forum_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_topics (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    title character varying NOT NULL,
    response_count integer DEFAULT 0 NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category_id integer DEFAULT 0 NOT NULL,
    min_level integer DEFAULT 0 NOT NULL
);


--
-- Name: forum_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_topics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_topics_id_seq OWNED BY public.forum_topics.id;


--
-- Name: good_job_processes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.good_job_processes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    state jsonb
);


--
-- Name: good_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.good_jobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    queue_name text,
    priority integer,
    serialized_params jsonb,
    scheduled_at timestamp without time zone,
    performed_at timestamp without time zone,
    finished_at timestamp without time zone,
    error text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    active_job_id uuid,
    concurrency_key text,
    cron_key text,
    retried_good_job_id uuid,
    cron_at timestamp without time zone
);


--
-- Name: note_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.note_versions (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    body text NOT NULL,
    updater_ip_addr inet NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    note_id integer NOT NULL,
    post_id integer NOT NULL,
    updater_id integer NOT NULL,
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    uploader_id integer NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    source character varying DEFAULT ''::character varying NOT NULL,
    md5 character varying NOT NULL,
    last_comment_bumped_at timestamp without time zone,
    rating character(1) DEFAULT 'q'::bpchar NOT NULL,
    image_width integer NOT NULL,
    image_height integer NOT NULL,
    uploader_ip_addr inet NOT NULL,
    tag_string text DEFAULT ''::text NOT NULL,
    fav_count integer DEFAULT 0 NOT NULL,
    file_ext character varying NOT NULL,
    last_noted_at timestamp without time zone,
    parent_id integer,
    has_children boolean DEFAULT false NOT NULL,
    approver_id integer,
    tag_count_general integer DEFAULT 0 NOT NULL,
    tag_count_artist integer DEFAULT 0 NOT NULL,
    tag_count_character integer DEFAULT 0 NOT NULL,
    tag_count_copyright integer DEFAULT 0 NOT NULL,
    file_size integer NOT NULL,
    up_score integer DEFAULT 0 NOT NULL,
    down_score integer DEFAULT 0 NOT NULL,
    is_pending boolean DEFAULT false NOT NULL,
    is_flagged boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    tag_count integer DEFAULT 0 NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_banned boolean DEFAULT false NOT NULL,
    pixiv_id integer,
    last_commented_at timestamp without time zone,
    has_active_children boolean DEFAULT false,
    bit_flags bigint DEFAULT 0 NOT NULL,
    tag_count_meta integer DEFAULT 0 NOT NULL,
    tag_count_deprecated integer DEFAULT 0 NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying NOT NULL,
    level integer NOT NULL,
    inviter_id integer,
    created_at timestamp without time zone NOT NULL,
    last_logged_in_at timestamp without time zone,
    last_forum_read_at timestamp without time zone,
    comment_threshold integer NOT NULL,
    updated_at timestamp without time zone,
    default_image_size character varying NOT NULL,
    favorite_tags text,
    blacklisted_tags text,
    time_zone character varying NOT NULL,
    post_update_count integer NOT NULL,
    note_update_count integer NOT NULL,
    favorite_count integer NOT NULL,
    post_upload_count integer NOT NULL,
    bcrypt_password_hash text NOT NULL,
    per_page integer NOT NULL,
    custom_style text,
    bit_prefs bigint NOT NULL,
    last_ip_addr inet,
    unread_dmail_count integer NOT NULL,
    theme integer NOT NULL,
    upload_points integer NOT NULL
);


--
-- Name: wiki_page_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wiki_page_versions (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    wiki_page_id integer NOT NULL,
    is_locked boolean NOT NULL,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: ip_addresses; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ip_addresses AS
 SELECT 'ArtistVersion'::text AS model_type,
    artist_versions.id AS model_id,
    artist_versions.updater_id AS user_id,
    artist_versions.updater_ip_addr AS ip_addr,
    artist_versions.created_at
   FROM public.artist_versions
UNION ALL
 SELECT 'ArtistCommentaryVersion'::text AS model_type,
    artist_commentary_versions.id AS model_id,
    artist_commentary_versions.updater_id AS user_id,
    artist_commentary_versions.updater_ip_addr AS ip_addr,
    artist_commentary_versions.created_at
   FROM public.artist_commentary_versions
UNION ALL
 SELECT 'Comment'::text AS model_type,
    comments.id AS model_id,
    comments.creator_id AS user_id,
    comments.creator_ip_addr AS ip_addr,
    comments.created_at
   FROM public.comments
UNION ALL
 SELECT 'Dmail'::text AS model_type,
    dmails.id AS model_id,
    dmails.from_id AS user_id,
    dmails.creator_ip_addr AS ip_addr,
    dmails.created_at
   FROM public.dmails
UNION ALL
 SELECT 'NoteVersion'::text AS model_type,
    note_versions.id AS model_id,
    note_versions.updater_id AS user_id,
    note_versions.updater_ip_addr AS ip_addr,
    note_versions.created_at
   FROM public.note_versions
UNION ALL
 SELECT 'Post'::text AS model_type,
    posts.id AS model_id,
    posts.uploader_id AS user_id,
    posts.uploader_ip_addr AS ip_addr,
    posts.created_at
   FROM public.posts
UNION ALL
 SELECT 'User'::text AS model_type,
    users.id AS model_id,
    users.id AS user_id,
    users.last_ip_addr AS ip_addr,
    users.created_at
   FROM public.users
  WHERE (users.last_ip_addr IS NOT NULL)
UNION ALL
 SELECT 'WikiPageVersion'::text AS model_type,
    wiki_page_versions.id AS model_id,
    wiki_page_versions.updater_id AS user_id,
    wiki_page_versions.updater_ip_addr AS ip_addr,
    wiki_page_versions.created_at
   FROM public.wiki_page_versions;


--
-- Name: ip_bans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ip_bans (
    creator_id integer NOT NULL,
    ip_addr inet NOT NULL,
    reason text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id integer NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    category integer DEFAULT 0 NOT NULL,
    hit_count integer DEFAULT 0 NOT NULL,
    last_hit_at timestamp without time zone
);


--
-- Name: ip_bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ip_bans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ip_bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ip_bans_id_seq OWNED BY public.ip_bans.id;


--
-- Name: ip_geolocations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ip_geolocations (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    ip_addr inet NOT NULL,
    network inet,
    asn integer,
    is_proxy boolean NOT NULL,
    latitude double precision,
    longitude double precision,
    organization character varying,
    time_zone character varying,
    continent character varying,
    country character varying,
    region character varying,
    city character varying,
    carrier character varying
);


--
-- Name: ip_geolocations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ip_geolocations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ip_geolocations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ip_geolocations_id_seq OWNED BY public.ip_geolocations.id;


--
-- Name: media_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_assets (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    md5 character varying NOT NULL,
    file_ext character varying NOT NULL,
    file_size integer NOT NULL,
    image_width integer NOT NULL,
    image_height integer NOT NULL,
    duration double precision,
    status integer DEFAULT 200 NOT NULL
);


--
-- Name: media_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.media_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.media_assets_id_seq OWNED BY public.media_assets.id;


--
-- Name: media_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_metadata (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    media_asset_id bigint NOT NULL,
    metadata jsonb DEFAULT '"{}"'::jsonb NOT NULL
);


--
-- Name: media_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.media_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.media_metadata_id_seq OWNED BY public.media_metadata.id;


--
-- Name: mod_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_actions (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category integer NOT NULL
);


--
-- Name: mod_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_actions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_actions_id_seq OWNED BY public.mod_actions.id;


--
-- Name: moderation_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_reports (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    model_type character varying NOT NULL,
    model_id bigint NOT NULL,
    creator_id integer NOT NULL,
    reason text NOT NULL,
    status integer DEFAULT 0 NOT NULL
);


--
-- Name: moderation_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.moderation_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moderation_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.moderation_reports_id_seq OWNED BY public.moderation_reports.id;


--
-- Name: news_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news_updates (
    id integer NOT NULL,
    message text NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: news_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.news_updates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.news_updates_id_seq OWNED BY public.news_updates.id;


--
-- Name: note_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.note_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: note_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.note_versions_id_seq OWNED BY public.note_versions.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id integer NOT NULL,
    post_id integer NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: pixiv_ugoira_frame_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pixiv_ugoira_frame_data (
    id integer NOT NULL,
    post_id integer,
    data text NOT NULL,
    content_type character varying NOT NULL,
    md5 character varying
);


--
-- Name: pixiv_ugoira_frame_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pixiv_ugoira_frame_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pixiv_ugoira_frame_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pixiv_ugoira_frame_data_id_seq OWNED BY public.pixiv_ugoira_frame_data.id;


--
-- Name: pool_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pool_versions (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pool_id bigint NOT NULL,
    updater_id bigint NOT NULL,
    updater_ip_addr inet NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    category character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    description_changed boolean DEFAULT false NOT NULL,
    name_changed boolean DEFAULT false NOT NULL,
    post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    added_post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    removed_post_ids integer[] DEFAULT '{}'::integer[] NOT NULL
);


--
-- Name: pool_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pool_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pool_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pool_versions_id_seq OWNED BY public.pool_versions.id;


--
-- Name: pools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pools (
    id integer NOT NULL,
    name character varying NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category character varying DEFAULT 'series'::character varying NOT NULL
);


--
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pools_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pools_id_seq OWNED BY public.pools.id;


--
-- Name: post_appeals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_appeals (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    reason text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 0 NOT NULL
);


--
-- Name: post_appeals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_appeals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_appeals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_appeals_id_seq OWNED BY public.post_appeals.id;


--
-- Name: post_approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_approvals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_approvals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_approvals_id_seq OWNED BY public.post_approvals.id;


--
-- Name: post_disapprovals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_disapprovals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reason character varying NOT NULL,
    message text
);


--
-- Name: post_disapprovals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_disapprovals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_disapprovals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_disapprovals_id_seq OWNED BY public.post_disapprovals.id;


--
-- Name: post_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_flags (
    id integer NOT NULL,
    post_id integer NOT NULL,
    reason text NOT NULL,
    creator_id integer NOT NULL,
    is_resolved boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 0 NOT NULL
);


--
-- Name: post_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_flags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_flags_id_seq OWNED BY public.post_flags.id;


--
-- Name: post_replacements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_replacements (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    original_url text NOT NULL,
    replacement_url text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    old_file_ext character varying,
    old_file_size integer,
    old_image_width integer,
    old_image_height integer,
    old_md5 character varying,
    file_ext character varying,
    file_size integer,
    image_width integer,
    image_height integer,
    md5 character varying
);


--
-- Name: post_replacements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_replacements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_replacements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_replacements_id_seq OWNED BY public.post_replacements.id;


--
-- Name: post_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_versions (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    post_id bigint NOT NULL,
    updater_id bigint NOT NULL,
    updater_ip_addr inet NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    parent_changed boolean DEFAULT false NOT NULL,
    rating_changed boolean DEFAULT false NOT NULL,
    source_changed boolean DEFAULT false NOT NULL,
    parent_id integer,
    rating character varying(1) NOT NULL,
    source text DEFAULT ''::text NOT NULL,
    tags text DEFAULT ''::text NOT NULL,
    added_tags text[] DEFAULT '{}'::text[] NOT NULL,
    removed_tags text[] DEFAULT '{}'::text[] NOT NULL
);


--
-- Name: post_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_versions_id_seq OWNED BY public.post_versions.id;


--
-- Name: post_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_votes (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_deleted boolean DEFAULT false
);


--
-- Name: post_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_votes_id_seq OWNED BY public.post_votes.id;


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: rate_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.rate_limits (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    limited boolean DEFAULT false NOT NULL,
    points double precision NOT NULL,
    action character varying NOT NULL,
    key character varying NOT NULL
)
WITH (fillfactor='50');


--
-- Name: rate_limits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rate_limits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rate_limits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rate_limits_id_seq OWNED BY public.rate_limits.id;


--
-- Name: saved_searches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.saved_searches (
    id integer NOT NULL,
    user_id integer NOT NULL,
    query text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    labels text[] DEFAULT '{}'::text[] NOT NULL
);


--
-- Name: saved_searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.saved_searches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saved_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.saved_searches_id_seq OWNED BY public.saved_searches.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: tag_aliases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_aliases (
    id integer NOT NULL,
    antecedent_name character varying NOT NULL,
    consequent_name character varying NOT NULL,
    creator_id integer NOT NULL,
    forum_topic_id integer,
    status text DEFAULT 'active'::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approver_id integer,
    forum_post_id integer,
    reason text DEFAULT ''::text NOT NULL
);


--
-- Name: tag_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_aliases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_aliases_id_seq OWNED BY public.tag_aliases.id;


--
-- Name: tag_implications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_implications (
    id integer NOT NULL,
    antecedent_name character varying NOT NULL,
    consequent_name character varying NOT NULL,
    creator_id integer NOT NULL,
    forum_topic_id integer,
    status text DEFAULT 'active'::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approver_id integer,
    forum_post_id integer,
    reason text DEFAULT ''::text NOT NULL
);


--
-- Name: tag_implications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_implications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_implications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_implications_id_seq OWNED BY public.tag_implications.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    name character varying NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    category integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_locked boolean DEFAULT false NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: upload_media_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upload_media_assets (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    upload_id bigint NOT NULL,
    media_asset_id bigint,
    status integer DEFAULT 0 NOT NULL,
    source_url character varying DEFAULT ''::character varying NOT NULL,
    error character varying,
    page_url character varying
);


--
-- Name: upload_media_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upload_media_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upload_media_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upload_media_assets_id_seq OWNED BY public.upload_media_assets.id;


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploads (
    id integer NOT NULL,
    source text,
    uploader_id integer NOT NULL,
    uploader_ip_addr inet NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    referer_url text,
    error text,
    media_asset_count integer DEFAULT 0 NOT NULL
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.uploads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.uploads_id_seq OWNED BY public.uploads.id;


--
-- Name: user_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_events (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL,
    user_session_id bigint NOT NULL,
    category integer NOT NULL
);


--
-- Name: user_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_events_id_seq OWNED BY public.user_events.id;


--
-- Name: user_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_feedback (
    id integer NOT NULL,
    user_id integer NOT NULL,
    creator_id integer NOT NULL,
    category character varying NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: user_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_feedback_id_seq OWNED BY public.user_feedback.id;


--
-- Name: user_name_change_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_name_change_requests (
    id integer NOT NULL,
    user_id integer NOT NULL,
    original_name character varying NOT NULL,
    desired_name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_name_change_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_name_change_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_name_change_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_name_change_requests_id_seq OWNED BY public.user_name_change_requests.id;


--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_sessions (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    ip_addr inet NOT NULL,
    session_id character varying NOT NULL,
    user_agent character varying
);


--
-- Name: user_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_sessions_id_seq OWNED BY public.user_sessions.id;


--
-- Name: user_upgrades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_upgrades (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    recipient_id bigint NOT NULL,
    purchaser_id bigint NOT NULL,
    upgrade_type integer NOT NULL,
    status integer NOT NULL,
    stripe_id character varying
);


--
-- Name: user_upgrades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_upgrades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_upgrades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_upgrades_id_seq OWNED BY public.user_upgrades.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wiki_page_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wiki_page_versions_id_seq OWNED BY public.wiki_page_versions.id;


--
-- Name: wiki_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wiki_pages (
    id integer NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wiki_pages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wiki_pages_id_seq OWNED BY public.wiki_pages.id;


--
-- Name: api_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys ALTER COLUMN id SET DEFAULT nextval('public.api_keys_id_seq'::regclass);


--
-- Name: artist_commentaries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentaries ALTER COLUMN id SET DEFAULT nextval('public.artist_commentaries_id_seq'::regclass);


--
-- Name: artist_commentary_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentary_versions ALTER COLUMN id SET DEFAULT nextval('public.artist_commentary_versions_id_seq'::regclass);


--
-- Name: artist_urls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls ALTER COLUMN id SET DEFAULT nextval('public.artist_urls_id_seq'::regclass);


--
-- Name: artist_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_versions ALTER COLUMN id SET DEFAULT nextval('public.artist_versions_id_seq'::regclass);


--
-- Name: artists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists ALTER COLUMN id SET DEFAULT nextval('public.artists_id_seq'::regclass);


--
-- Name: bans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bans ALTER COLUMN id SET DEFAULT nextval('public.bans_id_seq'::regclass);


--
-- Name: bulk_update_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_update_requests ALTER COLUMN id SET DEFAULT nextval('public.bulk_update_requests_id_seq'::regclass);


--
-- Name: comment_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_votes ALTER COLUMN id SET DEFAULT nextval('public.comment_votes_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: dmails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmails ALTER COLUMN id SET DEFAULT nextval('public.dmails_id_seq'::regclass);


--
-- Name: dtext_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dtext_links ALTER COLUMN id SET DEFAULT nextval('public.dtext_links_id_seq'::regclass);


--
-- Name: email_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_addresses ALTER COLUMN id SET DEFAULT nextval('public.email_addresses_id_seq'::regclass);


--
-- Name: favorite_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_groups ALTER COLUMN id SET DEFAULT nextval('public.favorite_groups_id_seq'::regclass);


--
-- Name: favorites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: forum_post_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_post_votes ALTER COLUMN id SET DEFAULT nextval('public.forum_post_votes_id_seq'::regclass);


--
-- Name: forum_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts ALTER COLUMN id SET DEFAULT nextval('public.forum_posts_id_seq'::regclass);


--
-- Name: forum_topic_visits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topic_visits ALTER COLUMN id SET DEFAULT nextval('public.forum_topic_visits_id_seq'::regclass);


--
-- Name: forum_topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topics ALTER COLUMN id SET DEFAULT nextval('public.forum_topics_id_seq'::regclass);


--
-- Name: ip_bans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ip_bans ALTER COLUMN id SET DEFAULT nextval('public.ip_bans_id_seq'::regclass);


--
-- Name: ip_geolocations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ip_geolocations ALTER COLUMN id SET DEFAULT nextval('public.ip_geolocations_id_seq'::regclass);


--
-- Name: media_assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_assets ALTER COLUMN id SET DEFAULT nextval('public.media_assets_id_seq'::regclass);


--
-- Name: media_metadata id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_metadata ALTER COLUMN id SET DEFAULT nextval('public.media_metadata_id_seq'::regclass);


--
-- Name: mod_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_actions ALTER COLUMN id SET DEFAULT nextval('public.mod_actions_id_seq'::regclass);


--
-- Name: moderation_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_reports ALTER COLUMN id SET DEFAULT nextval('public.moderation_reports_id_seq'::regclass);


--
-- Name: news_updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_updates ALTER COLUMN id SET DEFAULT nextval('public.news_updates_id_seq'::regclass);


--
-- Name: note_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_versions ALTER COLUMN id SET DEFAULT nextval('public.note_versions_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: pixiv_ugoira_frame_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pixiv_ugoira_frame_data ALTER COLUMN id SET DEFAULT nextval('public.pixiv_ugoira_frame_data_id_seq'::regclass);


--
-- Name: pool_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pool_versions ALTER COLUMN id SET DEFAULT nextval('public.pool_versions_id_seq'::regclass);


--
-- Name: pools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools ALTER COLUMN id SET DEFAULT nextval('public.pools_id_seq'::regclass);


--
-- Name: post_appeals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_appeals ALTER COLUMN id SET DEFAULT nextval('public.post_appeals_id_seq'::regclass);


--
-- Name: post_approvals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_approvals ALTER COLUMN id SET DEFAULT nextval('public.post_approvals_id_seq'::regclass);


--
-- Name: post_disapprovals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_disapprovals ALTER COLUMN id SET DEFAULT nextval('public.post_disapprovals_id_seq'::regclass);


--
-- Name: post_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_flags ALTER COLUMN id SET DEFAULT nextval('public.post_flags_id_seq'::regclass);


--
-- Name: post_replacements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacements ALTER COLUMN id SET DEFAULT nextval('public.post_replacements_id_seq'::regclass);


--
-- Name: post_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_versions ALTER COLUMN id SET DEFAULT nextval('public.post_versions_id_seq'::regclass);


--
-- Name: post_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes ALTER COLUMN id SET DEFAULT nextval('public.post_votes_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: rate_limits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rate_limits ALTER COLUMN id SET DEFAULT nextval('public.rate_limits_id_seq'::regclass);


--
-- Name: saved_searches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches ALTER COLUMN id SET DEFAULT nextval('public.saved_searches_id_seq'::regclass);


--
-- Name: tag_aliases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_aliases ALTER COLUMN id SET DEFAULT nextval('public.tag_aliases_id_seq'::regclass);


--
-- Name: tag_implications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_implications ALTER COLUMN id SET DEFAULT nextval('public.tag_implications_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: upload_media_assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upload_media_assets ALTER COLUMN id SET DEFAULT nextval('public.upload_media_assets_id_seq'::regclass);


--
-- Name: uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads ALTER COLUMN id SET DEFAULT nextval('public.uploads_id_seq'::regclass);


--
-- Name: user_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_events ALTER COLUMN id SET DEFAULT nextval('public.user_events_id_seq'::regclass);


--
-- Name: user_feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback ALTER COLUMN id SET DEFAULT nextval('public.user_feedback_id_seq'::regclass);


--
-- Name: user_name_change_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_name_change_requests ALTER COLUMN id SET DEFAULT nextval('public.user_name_change_requests_id_seq'::regclass);


--
-- Name: user_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions ALTER COLUMN id SET DEFAULT nextval('public.user_sessions_id_seq'::regclass);


--
-- Name: user_upgrades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_upgrades ALTER COLUMN id SET DEFAULT nextval('public.user_upgrades_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: wiki_page_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_page_versions ALTER COLUMN id SET DEFAULT nextval('public.wiki_page_versions_id_seq'::regclass);


--
-- Name: wiki_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_pages ALTER COLUMN id SET DEFAULT nextval('public.wiki_pages_id_seq'::regclass);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: artist_commentaries artist_commentaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentaries
    ADD CONSTRAINT artist_commentaries_pkey PRIMARY KEY (id);


--
-- Name: artist_commentary_versions artist_commentary_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentary_versions
    ADD CONSTRAINT artist_commentary_versions_pkey PRIMARY KEY (id);


--
-- Name: artist_urls artist_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls
    ADD CONSTRAINT artist_urls_pkey PRIMARY KEY (id);


--
-- Name: artist_versions artist_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_versions
    ADD CONSTRAINT artist_versions_pkey PRIMARY KEY (id);


--
-- Name: artists artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- Name: bans bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bans
    ADD CONSTRAINT bans_pkey PRIMARY KEY (id);


--
-- Name: bulk_update_requests bulk_update_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_update_requests
    ADD CONSTRAINT bulk_update_requests_pkey PRIMARY KEY (id);


--
-- Name: comment_votes comment_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_votes
    ADD CONSTRAINT comment_votes_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: dmails dmails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmails
    ADD CONSTRAINT dmails_pkey PRIMARY KEY (id);


--
-- Name: dtext_links dtext_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dtext_links
    ADD CONSTRAINT dtext_links_pkey PRIMARY KEY (id);


--
-- Name: email_addresses email_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_addresses
    ADD CONSTRAINT email_addresses_pkey PRIMARY KEY (id);


--
-- Name: favorite_groups favorite_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_groups
    ADD CONSTRAINT favorite_groups_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: forum_post_votes forum_post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_post_votes
    ADD CONSTRAINT forum_post_votes_pkey PRIMARY KEY (id);


--
-- Name: forum_posts forum_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts
    ADD CONSTRAINT forum_posts_pkey PRIMARY KEY (id);


--
-- Name: forum_topic_visits forum_topic_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topic_visits
    ADD CONSTRAINT forum_topic_visits_pkey PRIMARY KEY (id);


--
-- Name: forum_topics forum_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topics
    ADD CONSTRAINT forum_topics_pkey PRIMARY KEY (id);


--
-- Name: good_job_processes good_job_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.good_job_processes
    ADD CONSTRAINT good_job_processes_pkey PRIMARY KEY (id);


--
-- Name: good_jobs good_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.good_jobs
    ADD CONSTRAINT good_jobs_pkey PRIMARY KEY (id);


--
-- Name: ip_bans ip_bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ip_bans
    ADD CONSTRAINT ip_bans_pkey PRIMARY KEY (id);


--
-- Name: ip_geolocations ip_geolocations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ip_geolocations
    ADD CONSTRAINT ip_geolocations_pkey PRIMARY KEY (id);


--
-- Name: media_assets media_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_assets
    ADD CONSTRAINT media_assets_pkey PRIMARY KEY (id);


--
-- Name: media_metadata media_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_metadata
    ADD CONSTRAINT media_metadata_pkey PRIMARY KEY (id);


--
-- Name: mod_actions mod_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_actions
    ADD CONSTRAINT mod_actions_pkey PRIMARY KEY (id);


--
-- Name: moderation_reports moderation_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_reports
    ADD CONSTRAINT moderation_reports_pkey PRIMARY KEY (id);


--
-- Name: news_updates news_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_updates
    ADD CONSTRAINT news_updates_pkey PRIMARY KEY (id);


--
-- Name: note_versions note_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_versions
    ADD CONSTRAINT note_versions_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: pixiv_ugoira_frame_data pixiv_ugoira_frame_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pixiv_ugoira_frame_data
    ADD CONSTRAINT pixiv_ugoira_frame_data_pkey PRIMARY KEY (id);


--
-- Name: pool_versions pool_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pool_versions
    ADD CONSTRAINT pool_versions_pkey PRIMARY KEY (id);


--
-- Name: pools pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id);


--
-- Name: post_appeals post_appeals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_appeals
    ADD CONSTRAINT post_appeals_pkey PRIMARY KEY (id);


--
-- Name: post_approvals post_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_approvals
    ADD CONSTRAINT post_approvals_pkey PRIMARY KEY (id);


--
-- Name: post_disapprovals post_disapprovals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_disapprovals
    ADD CONSTRAINT post_disapprovals_pkey PRIMARY KEY (id);


--
-- Name: post_flags post_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_flags
    ADD CONSTRAINT post_flags_pkey PRIMARY KEY (id);


--
-- Name: post_replacements post_replacements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacements
    ADD CONSTRAINT post_replacements_pkey PRIMARY KEY (id);


--
-- Name: post_versions post_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_versions
    ADD CONSTRAINT post_versions_pkey PRIMARY KEY (id);


--
-- Name: post_votes post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes
    ADD CONSTRAINT post_votes_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: rate_limits rate_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rate_limits
    ADD CONSTRAINT rate_limits_pkey PRIMARY KEY (id);


--
-- Name: saved_searches saved_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches
    ADD CONSTRAINT saved_searches_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tag_aliases tag_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_aliases
    ADD CONSTRAINT tag_aliases_pkey PRIMARY KEY (id);


--
-- Name: tag_implications tag_implications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_implications
    ADD CONSTRAINT tag_implications_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: upload_media_assets upload_media_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upload_media_assets
    ADD CONSTRAINT upload_media_assets_pkey PRIMARY KEY (id);


--
-- Name: uploads uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_events user_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT user_events_pkey PRIMARY KEY (id);


--
-- Name: user_feedback user_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback
    ADD CONSTRAINT user_feedback_pkey PRIMARY KEY (id);


--
-- Name: user_name_change_requests user_name_change_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_name_change_requests
    ADD CONSTRAINT user_name_change_requests_pkey PRIMARY KEY (id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: user_upgrades user_upgrades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_upgrades
    ADD CONSTRAINT user_upgrades_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wiki_page_versions wiki_page_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_page_versions
    ADD CONSTRAINT wiki_page_versions_pkey PRIMARY KEY (id);


--
-- Name: wiki_pages wiki_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_pages
    ADD CONSTRAINT wiki_pages_pkey PRIMARY KEY (id);


--
-- Name: index_api_keys_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_api_keys_on_key ON public.api_keys USING btree (key);


--
-- Name: index_api_keys_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_keys_on_user_id ON public.api_keys USING btree (user_id);


--
-- Name: index_artist_commentaries_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_artist_commentaries_on_post_id ON public.artist_commentaries USING btree (post_id);


--
-- Name: index_artist_commentary_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_created_at ON public.artist_commentary_versions USING btree (created_at);


--
-- Name: index_artist_commentary_versions_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_post_id ON public.artist_commentary_versions USING btree (post_id);


--
-- Name: index_artist_commentary_versions_on_updater_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_updater_id_and_post_id ON public.artist_commentary_versions USING btree (updater_id, post_id);


--
-- Name: index_artist_commentary_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_updater_ip_addr ON public.artist_commentary_versions USING btree (updater_ip_addr);


--
-- Name: index_artist_urls_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_artist_id ON public.artist_urls USING btree (artist_id);


--
-- Name: index_artist_urls_on_normalized_url_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_normalized_url_pattern ON public.artist_urls USING btree (normalized_url text_pattern_ops);


--
-- Name: index_artist_urls_on_normalized_url_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_normalized_url_trgm ON public.artist_urls USING gin (normalized_url public.gin_trgm_ops);


--
-- Name: index_artist_urls_on_url_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_url_trgm ON public.artist_urls USING gin (url public.gin_trgm_ops);


--
-- Name: index_artist_versions_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_artist_id ON public.artist_versions USING btree (artist_id);


--
-- Name: index_artist_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_created_at ON public.artist_versions USING btree (created_at);


--
-- Name: index_artist_versions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_name ON public.artist_versions USING btree (name);


--
-- Name: index_artist_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_updater_id ON public.artist_versions USING btree (updater_id);


--
-- Name: index_artist_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_updater_ip_addr ON public.artist_versions USING btree (updater_ip_addr);


--
-- Name: index_artists_on_array_to_tsvector_other_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_array_to_tsvector_other_names ON public.artists USING gin (array_to_tsvector(other_names));


--
-- Name: index_artists_on_group_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_group_name ON public.artists USING btree (group_name);


--
-- Name: index_artists_on_group_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_group_name_trgm ON public.artists USING gin (group_name public.gin_trgm_ops);


--
-- Name: index_artists_on_is_banned; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_is_banned ON public.artists USING btree (is_banned);


--
-- Name: index_artists_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_is_deleted ON public.artists USING btree (is_deleted);


--
-- Name: index_artists_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_artists_on_name ON public.artists USING btree (name);


--
-- Name: index_artists_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_name_trgm ON public.artists USING gin (name public.gin_trgm_ops);


--
-- Name: index_artists_on_other_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_other_names ON public.artists USING gin (other_names);


--
-- Name: index_bans_on_banner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_banner_id ON public.bans USING btree (banner_id);


--
-- Name: index_bans_on_duration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_duration ON public.bans USING btree (duration);


--
-- Name: index_bans_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_user_id ON public.bans USING btree (user_id);


--
-- Name: index_bulk_update_requests_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bulk_update_requests_on_forum_post_id ON public.bulk_update_requests USING btree (forum_post_id);


--
-- Name: index_bulk_update_requests_on_tags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bulk_update_requests_on_tags ON public.bulk_update_requests USING gin (tags);


--
-- Name: index_comment_votes_on_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_comment_id ON public.comment_votes USING btree (comment_id);


--
-- Name: index_comment_votes_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_created_at ON public.comment_votes USING btree (created_at);


--
-- Name: index_comment_votes_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_is_deleted ON public.comment_votes USING btree (is_deleted) WHERE (is_deleted = true);


--
-- Name: index_comment_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_user_id ON public.comment_votes USING btree (user_id);


--
-- Name: index_comment_votes_on_user_id_and_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_comment_votes_on_user_id_and_comment_id ON public.comment_votes USING btree (user_id, comment_id) WHERE (is_deleted = false);


--
-- Name: index_comments_on_body_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_body_tsvector ON public.comments USING gin (to_tsvector('english'::regconfig, body));


--
-- Name: index_comments_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_created_at ON public.comments USING btree (created_at);


--
-- Name: index_comments_on_creator_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_creator_id_and_post_id ON public.comments USING btree (creator_id, post_id);


--
-- Name: index_comments_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_creator_ip_addr ON public.comments USING btree (creator_ip_addr);


--
-- Name: index_comments_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_post_id ON public.comments USING btree (post_id);


--
-- Name: index_dmails_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_created_at ON public.dmails USING btree (created_at);


--
-- Name: index_dmails_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_creator_ip_addr ON public.dmails USING btree (creator_ip_addr);


--
-- Name: index_dmails_on_from_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_from_id ON public.dmails USING btree (from_id);


--
-- Name: index_dmails_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_is_deleted ON public.dmails USING btree (is_deleted);


--
-- Name: index_dmails_on_is_read; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_is_read ON public.dmails USING btree (is_read);


--
-- Name: index_dmails_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_owner_id ON public.dmails USING btree (owner_id);


--
-- Name: index_dmails_on_title_and_body_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_title_and_body_tsvector ON public.dmails USING gin (((to_tsvector('english'::regconfig, title) || to_tsvector('english'::regconfig, body))));


--
-- Name: index_dtext_links_on_link_target; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dtext_links_on_link_target ON public.dtext_links USING btree (link_target text_pattern_ops);


--
-- Name: index_dtext_links_on_link_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dtext_links_on_link_type ON public.dtext_links USING btree (link_type);


--
-- Name: index_dtext_links_on_model_type_and_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dtext_links_on_model_type_and_model_id ON public.dtext_links USING btree (model_type, model_id);


--
-- Name: index_email_addresses_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_addresses_on_address ON public.email_addresses USING btree (address);


--
-- Name: index_email_addresses_on_address_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_addresses_on_address_trgm ON public.email_addresses USING gin (address public.gin_trgm_ops);


--
-- Name: index_email_addresses_on_normalized_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_addresses_on_normalized_address ON public.email_addresses USING btree (normalized_address);


--
-- Name: index_email_addresses_on_normalized_address_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_addresses_on_normalized_address_trgm ON public.email_addresses USING gin (normalized_address public.gin_trgm_ops);


--
-- Name: index_email_addresses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_email_addresses_on_user_id ON public.email_addresses USING btree (user_id);


--
-- Name: index_favorite_groups_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_groups_on_creator_id ON public.favorite_groups USING btree (creator_id);


--
-- Name: index_favorite_groups_on_is_public; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_groups_on_is_public ON public.favorite_groups USING btree (is_public);


--
-- Name: index_favorite_groups_on_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_groups_on_lower_name ON public.favorite_groups USING btree (lower(name));


--
-- Name: index_favorite_groups_on_post_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_groups_on_post_ids ON public.favorite_groups USING gin (post_ids);


--
-- Name: index_favorites_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_post_id ON public.favorites USING btree (post_id);


--
-- Name: index_favorites_on_user_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_user_id_and_id ON public.favorites USING btree (user_id, id);


--
-- Name: index_favorites_on_user_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_favorites_on_user_id_and_post_id ON public.favorites USING btree (user_id, post_id);


--
-- Name: index_forum_post_votes_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_post_votes_on_forum_post_id ON public.forum_post_votes USING btree (forum_post_id);


--
-- Name: index_forum_post_votes_on_forum_post_id_and_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_forum_post_votes_on_forum_post_id_and_creator_id ON public.forum_post_votes USING btree (forum_post_id, creator_id);


--
-- Name: index_forum_posts_on_body_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_body_tsvector ON public.forum_posts USING gin (to_tsvector('english'::regconfig, body));


--
-- Name: index_forum_posts_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_creator_id ON public.forum_posts USING btree (creator_id);


--
-- Name: index_forum_posts_on_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_topic_id ON public.forum_posts USING btree (topic_id);


--
-- Name: index_forum_posts_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_updated_at ON public.forum_posts USING btree (updated_at);


--
-- Name: index_forum_topic_visits_on_forum_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_forum_topic_id ON public.forum_topic_visits USING btree (forum_topic_id);


--
-- Name: index_forum_topic_visits_on_last_read_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_last_read_at ON public.forum_topic_visits USING btree (last_read_at);


--
-- Name: index_forum_topic_visits_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_user_id ON public.forum_topic_visits USING btree (user_id);


--
-- Name: index_forum_topics_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_creator_id ON public.forum_topics USING btree (creator_id);


--
-- Name: index_forum_topics_on_is_sticky_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_is_sticky_and_updated_at ON public.forum_topics USING btree (is_sticky, updated_at);


--
-- Name: index_forum_topics_on_title_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_title_tsvector ON public.forum_topics USING gin (to_tsvector('english'::regconfig, (title)::text));


--
-- Name: index_forum_topics_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_updated_at ON public.forum_topics USING btree (updated_at);


--
-- Name: index_good_jobs_jobs_on_finished_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_jobs_on_finished_at ON public.good_jobs USING btree (finished_at) WHERE ((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL));


--
-- Name: index_good_jobs_on_active_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_active_job_id ON public.good_jobs USING btree (active_job_id);


--
-- Name: index_good_jobs_on_active_job_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_active_job_id_and_created_at ON public.good_jobs USING btree (active_job_id, created_at);


--
-- Name: index_good_jobs_on_concurrency_key_when_unfinished; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_concurrency_key_when_unfinished ON public.good_jobs USING btree (concurrency_key) WHERE (finished_at IS NULL);


--
-- Name: index_good_jobs_on_cron_key_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_cron_key_and_created_at ON public.good_jobs USING btree (cron_key, created_at);


--
-- Name: index_good_jobs_on_cron_key_and_cron_at; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_good_jobs_on_cron_key_and_cron_at ON public.good_jobs USING btree (cron_key, cron_at);


--
-- Name: index_good_jobs_on_queue_name_and_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_queue_name_and_scheduled_at ON public.good_jobs USING btree (queue_name, scheduled_at) WHERE (finished_at IS NULL);


--
-- Name: index_good_jobs_on_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_scheduled_at ON public.good_jobs USING btree (scheduled_at) WHERE (finished_at IS NULL);


--
-- Name: index_ip_bans_on_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_bans_on_category ON public.ip_bans USING btree (category);


--
-- Name: index_ip_bans_on_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_bans_on_ip_addr ON public.ip_bans USING btree (ip_addr);


--
-- Name: index_ip_bans_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_bans_on_is_deleted ON public.ip_bans USING btree (is_deleted);


--
-- Name: index_ip_geolocations_on_asn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_asn ON public.ip_geolocations USING btree (asn);


--
-- Name: index_ip_geolocations_on_carrier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_carrier ON public.ip_geolocations USING btree (carrier);


--
-- Name: index_ip_geolocations_on_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_city ON public.ip_geolocations USING btree (city);


--
-- Name: index_ip_geolocations_on_continent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_continent ON public.ip_geolocations USING btree (continent);


--
-- Name: index_ip_geolocations_on_country; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_country ON public.ip_geolocations USING btree (country);


--
-- Name: index_ip_geolocations_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_created_at ON public.ip_geolocations USING btree (created_at);


--
-- Name: index_ip_geolocations_on_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ip_geolocations_on_ip_addr ON public.ip_geolocations USING btree (ip_addr);


--
-- Name: index_ip_geolocations_on_is_proxy; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_is_proxy ON public.ip_geolocations USING btree (is_proxy);


--
-- Name: index_ip_geolocations_on_latitude; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_latitude ON public.ip_geolocations USING btree (latitude);


--
-- Name: index_ip_geolocations_on_longitude; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_longitude ON public.ip_geolocations USING btree (longitude);


--
-- Name: index_ip_geolocations_on_network; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_network ON public.ip_geolocations USING btree (network);


--
-- Name: index_ip_geolocations_on_organization; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_organization ON public.ip_geolocations USING btree (organization);


--
-- Name: index_ip_geolocations_on_region; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_region ON public.ip_geolocations USING btree (region);


--
-- Name: index_ip_geolocations_on_time_zone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_time_zone ON public.ip_geolocations USING btree (time_zone);


--
-- Name: index_ip_geolocations_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_geolocations_on_updated_at ON public.ip_geolocations USING btree (updated_at);


--
-- Name: index_media_assets_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_assets_on_created_at ON public.media_assets USING btree (created_at);


--
-- Name: index_media_assets_on_duration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_assets_on_duration ON public.media_assets USING btree (duration) WHERE (duration IS NOT NULL);


--
-- Name: index_media_assets_on_file_ext; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_assets_on_file_ext ON public.media_assets USING btree (file_ext);


--
-- Name: index_media_assets_on_file_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_assets_on_file_size ON public.media_assets USING btree (file_size);


--
-- Name: index_media_assets_on_image_height; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_assets_on_image_height ON public.media_assets USING btree (image_height);


--
-- Name: index_media_assets_on_image_width; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_assets_on_image_width ON public.media_assets USING btree (image_width);


--
-- Name: index_media_assets_on_md5; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_assets_on_md5 ON public.media_assets USING btree (md5);


--
-- Name: index_media_assets_on_md5_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_media_assets_on_md5_and_status ON public.media_assets USING btree (md5) WHERE (status = ANY (ARRAY[100, 200]));


--
-- Name: index_media_assets_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_assets_on_status ON public.media_assets USING btree (status) WHERE (status <> 200);


--
-- Name: index_media_assets_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_assets_on_updated_at ON public.media_assets USING btree (updated_at);


--
-- Name: index_media_metadata_on_media_asset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_media_metadata_on_media_asset_id ON public.media_metadata USING btree (media_asset_id);


--
-- Name: index_media_metadata_on_metadata; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_metadata_on_metadata ON public.media_metadata USING gin (metadata);


--
-- Name: index_mod_actions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mod_actions_on_created_at ON public.mod_actions USING btree (created_at);


--
-- Name: index_mod_actions_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mod_actions_on_creator_id ON public.mod_actions USING btree (creator_id);


--
-- Name: index_moderation_reports_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_reports_on_creator_id ON public.moderation_reports USING btree (creator_id);


--
-- Name: index_moderation_reports_on_model_type_and_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_reports_on_model_type_and_model_id ON public.moderation_reports USING btree (model_type, model_id);


--
-- Name: index_moderation_reports_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_reports_on_status ON public.moderation_reports USING btree (status);


--
-- Name: index_news_updates_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_updates_on_created_at ON public.news_updates USING btree (created_at);


--
-- Name: index_note_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_created_at ON public.note_versions USING btree (created_at);


--
-- Name: index_note_versions_on_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_note_id ON public.note_versions USING btree (note_id);


--
-- Name: index_note_versions_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_post_id ON public.note_versions USING btree (post_id);


--
-- Name: index_note_versions_on_updater_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_updater_id_and_post_id ON public.note_versions USING btree (updater_id, post_id);


--
-- Name: index_note_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_updater_ip_addr ON public.note_versions USING btree (updater_ip_addr);


--
-- Name: index_notes_on_body_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_body_tsvector ON public.notes USING gin (to_tsvector('english'::regconfig, body));


--
-- Name: index_notes_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_post_id ON public.notes USING btree (post_id);


--
-- Name: index_pixiv_ugoira_frame_data_on_md5; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pixiv_ugoira_frame_data_on_md5 ON public.pixiv_ugoira_frame_data USING btree (md5);


--
-- Name: index_pixiv_ugoira_frame_data_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pixiv_ugoira_frame_data_on_post_id ON public.pixiv_ugoira_frame_data USING btree (post_id);


--
-- Name: index_pool_versions_on_added_post_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pool_versions_on_added_post_ids ON public.pool_versions USING btree (added_post_ids);


--
-- Name: index_pool_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pool_versions_on_created_at ON public.pool_versions USING btree (created_at);


--
-- Name: index_pool_versions_on_description_changed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pool_versions_on_description_changed ON public.pool_versions USING btree (description_changed);


--
-- Name: index_pool_versions_on_name_changed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pool_versions_on_name_changed ON public.pool_versions USING btree (name_changed);


--
-- Name: index_pool_versions_on_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pool_versions_on_pool_id ON public.pool_versions USING btree (pool_id);


--
-- Name: index_pool_versions_on_post_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pool_versions_on_post_ids ON public.pool_versions USING btree (post_ids);


--
-- Name: index_pool_versions_on_removed_post_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pool_versions_on_removed_post_ids ON public.pool_versions USING btree (removed_post_ids);


--
-- Name: index_pool_versions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pool_versions_on_updated_at ON public.pool_versions USING btree (updated_at);


--
-- Name: index_pool_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pool_versions_on_updater_id ON public.pool_versions USING btree (updater_id);


--
-- Name: index_pools_on_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_category ON public.pools USING btree (category);


--
-- Name: index_pools_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_is_deleted ON public.pools USING btree (is_deleted);


--
-- Name: index_pools_on_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_lower_name ON public.pools USING btree (lower((name)::text));


--
-- Name: index_pools_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_name_trgm ON public.pools USING gin (name public.gin_trgm_ops);


--
-- Name: index_pools_on_post_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_post_ids ON public.pools USING gin (post_ids);


--
-- Name: index_pools_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_updated_at ON public.pools USING btree (updated_at);


--
-- Name: index_post_appeals_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_created_at ON public.post_appeals USING btree (created_at);


--
-- Name: index_post_appeals_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_creator_id ON public.post_appeals USING btree (creator_id);


--
-- Name: index_post_appeals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_post_id ON public.post_appeals USING btree (post_id);


--
-- Name: index_post_appeals_on_reason_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_reason_tsvector ON public.post_appeals USING gin (to_tsvector('english'::regconfig, reason));


--
-- Name: index_post_appeals_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_status ON public.post_appeals USING btree (status);


--
-- Name: index_post_approvals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_approvals_on_post_id ON public.post_approvals USING btree (post_id);


--
-- Name: index_post_approvals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_approvals_on_user_id ON public.post_approvals USING btree (user_id);


--
-- Name: index_post_disapprovals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_disapprovals_on_post_id ON public.post_disapprovals USING btree (post_id);


--
-- Name: index_post_disapprovals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_disapprovals_on_user_id ON public.post_disapprovals USING btree (user_id);


--
-- Name: index_post_disapprovals_on_user_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_post_disapprovals_on_user_id_and_post_id ON public.post_disapprovals USING btree (user_id, post_id);


--
-- Name: index_post_flags_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_creator_id ON public.post_flags USING btree (creator_id);


--
-- Name: index_post_flags_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_post_id ON public.post_flags USING btree (post_id);


--
-- Name: index_post_flags_on_reason_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_reason_tsvector ON public.post_flags USING gin (to_tsvector('english'::regconfig, reason));


--
-- Name: index_post_flags_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_status ON public.post_flags USING btree (status);


--
-- Name: index_post_replacements_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_replacements_on_creator_id ON public.post_replacements USING btree (creator_id);


--
-- Name: index_post_replacements_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_replacements_on_post_id ON public.post_replacements USING btree (post_id);


--
-- Name: index_post_versions_on_added_tags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_added_tags ON public.post_versions USING btree (added_tags);


--
-- Name: index_post_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_created_at ON public.post_versions USING btree (created_at);


--
-- Name: index_post_versions_on_parent_changed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_parent_changed ON public.post_versions USING btree (parent_changed);


--
-- Name: index_post_versions_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_post_id ON public.post_versions USING btree (post_id);


--
-- Name: index_post_versions_on_rating_changed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_rating_changed ON public.post_versions USING btree (rating_changed);


--
-- Name: index_post_versions_on_removed_tags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_removed_tags ON public.post_versions USING btree (removed_tags);


--
-- Name: index_post_versions_on_source_changed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_source_changed ON public.post_versions USING btree (source_changed);


--
-- Name: index_post_versions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_updated_at ON public.post_versions USING btree (updated_at);


--
-- Name: index_post_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_updater_id ON public.post_versions USING btree (updater_id);


--
-- Name: index_post_versions_on_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_version ON public.post_versions USING btree (version);


--
-- Name: index_post_votes_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_created_at ON public.post_votes USING btree (created_at);


--
-- Name: index_post_votes_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_is_deleted ON public.post_votes USING btree (is_deleted) WHERE (is_deleted = true);


--
-- Name: index_post_votes_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_post_id ON public.post_votes USING btree (post_id);


--
-- Name: index_post_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_user_id ON public.post_votes USING btree (user_id);


--
-- Name: index_post_votes_on_user_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_post_votes_on_user_id_and_post_id ON public.post_votes USING btree (user_id, post_id) WHERE (is_deleted = false);


--
-- Name: index_posts_on_approver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_approver_id ON public.posts USING btree (approver_id) WHERE (approver_id IS NOT NULL);


--
-- Name: index_posts_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_created_at ON public.posts USING btree (created_at);


--
-- Name: index_posts_on_file_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_file_size ON public.posts USING btree (file_size);


--
-- Name: index_posts_on_image_height; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_image_height ON public.posts USING btree (image_height);


--
-- Name: index_posts_on_image_width; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_image_width ON public.posts USING btree (image_width);


--
-- Name: index_posts_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_is_deleted ON public.posts USING btree (is_deleted) WHERE (is_deleted = true);


--
-- Name: index_posts_on_is_flagged; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_is_flagged ON public.posts USING btree (is_flagged) WHERE (is_flagged = true);


--
-- Name: index_posts_on_is_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_is_pending ON public.posts USING btree (is_pending) WHERE (is_pending = true);


--
-- Name: index_posts_on_last_comment_bumped_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_last_comment_bumped_at ON public.posts USING btree (last_comment_bumped_at DESC NULLS LAST);


--
-- Name: index_posts_on_last_noted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_last_noted_at ON public.posts USING btree (last_noted_at DESC NULLS LAST);


--
-- Name: index_posts_on_md5; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_posts_on_md5 ON public.posts USING btree (md5);


--
-- Name: index_posts_on_mpixels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_mpixels ON public.posts USING btree (((((image_width * image_height))::numeric / 1000000.0)));


--
-- Name: index_posts_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_parent_id ON public.posts USING btree (parent_id) WHERE (parent_id IS NOT NULL);


--
-- Name: index_posts_on_pixiv_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_pixiv_id ON public.posts USING btree (pixiv_id) WHERE (pixiv_id IS NOT NULL);


--
-- Name: index_posts_on_rating; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_rating ON public.posts USING btree (rating) WHERE (rating <> 's'::bpchar);


--
-- Name: index_posts_on_source_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_source_trgm ON public.posts USING gin (source public.gin_trgm_ops);


--
-- Name: index_posts_on_string_to_array_tag_string; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_string_to_array_tag_string ON public.posts USING gin (string_to_array(tag_string, ' '::text));
ALTER INDEX public.index_posts_on_string_to_array_tag_string ALTER COLUMN 1 SET STATISTICS 3000;


--
-- Name: index_posts_on_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_uploader_id ON public.posts USING btree (uploader_id) WHERE (uploader_id IS NOT NULL);


--
-- Name: index_posts_on_uploader_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_uploader_ip_addr ON public.posts USING btree (uploader_ip_addr);


--
-- Name: index_rate_limits_on_key_and_action; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_rate_limits_on_key_and_action ON public.rate_limits USING btree (key, action);


--
-- Name: index_saved_searches_on_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_saved_searches_on_labels ON public.saved_searches USING gin (labels);


--
-- Name: index_saved_searches_on_query; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_saved_searches_on_query ON public.saved_searches USING btree (query);


--
-- Name: index_saved_searches_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_saved_searches_on_user_id ON public.saved_searches USING btree (user_id);


--
-- Name: index_tag_aliases_on_antecedent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_antecedent_name ON public.tag_aliases USING btree (antecedent_name);


--
-- Name: index_tag_aliases_on_antecedent_name_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_antecedent_name_pattern ON public.tag_aliases USING btree (antecedent_name text_pattern_ops);


--
-- Name: index_tag_aliases_on_consequent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_consequent_name ON public.tag_aliases USING btree (consequent_name);


--
-- Name: index_tag_aliases_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_forum_post_id ON public.tag_aliases USING btree (forum_post_id);


--
-- Name: index_tag_implications_on_antecedent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_antecedent_name ON public.tag_implications USING btree (antecedent_name);


--
-- Name: index_tag_implications_on_consequent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_consequent_name ON public.tag_implications USING btree (consequent_name);


--
-- Name: index_tag_implications_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_forum_post_id ON public.tag_implications USING btree (forum_post_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_tags_on_name_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_pattern ON public.tags USING btree (name text_pattern_ops);


--
-- Name: index_tags_on_name_prefix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_prefix ON public.tags USING gin (regexp_replace((name)::text, '([a-z0-9])[a-z0-9'']*($|[^a-z0-9'']+)'::text, '\1'::text, 'g'::text) public.gin_trgm_ops);


--
-- Name: index_tags_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_trgm ON public.tags USING gin (name public.gin_trgm_ops);


--
-- Name: index_tags_on_post_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_post_count ON public.tags USING btree (post_count);


--
-- Name: index_upload_media_assets_on_error; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upload_media_assets_on_error ON public.upload_media_assets USING btree (error) WHERE (error IS NOT NULL);


--
-- Name: index_upload_media_assets_on_media_asset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upload_media_assets_on_media_asset_id ON public.upload_media_assets USING btree (media_asset_id);


--
-- Name: index_upload_media_assets_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upload_media_assets_on_status ON public.upload_media_assets USING btree (status);


--
-- Name: index_upload_media_assets_on_upload_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upload_media_assets_on_upload_id ON public.upload_media_assets USING btree (upload_id);


--
-- Name: index_uploads_on_error; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_error ON public.uploads USING btree (error) WHERE (error IS NOT NULL);


--
-- Name: index_uploads_on_media_asset_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_media_asset_count ON public.uploads USING btree (media_asset_count);


--
-- Name: index_uploads_on_referer_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_referer_url ON public.uploads USING btree (referer_url);


--
-- Name: index_uploads_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_source ON public.uploads USING btree (source);


--
-- Name: index_uploads_on_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_uploader_id ON public.uploads USING btree (uploader_id);


--
-- Name: index_uploads_on_uploader_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_uploader_ip_addr ON public.uploads USING btree (uploader_ip_addr);


--
-- Name: index_user_events_on_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_events_on_category ON public.user_events USING btree (category);


--
-- Name: index_user_events_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_events_on_created_at ON public.user_events USING btree (created_at);


--
-- Name: index_user_events_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_events_on_updated_at ON public.user_events USING btree (updated_at);


--
-- Name: index_user_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_events_on_user_id ON public.user_events USING btree (user_id);


--
-- Name: index_user_events_on_user_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_events_on_user_session_id ON public.user_events USING btree (user_session_id);


--
-- Name: index_user_feedback_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_created_at ON public.user_feedback USING btree (created_at);


--
-- Name: index_user_feedback_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_creator_id ON public.user_feedback USING btree (creator_id);


--
-- Name: index_user_feedback_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_user_id ON public.user_feedback USING btree (user_id);


--
-- Name: index_user_name_change_requests_on_original_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_name_change_requests_on_original_name ON public.user_name_change_requests USING btree (original_name);


--
-- Name: index_user_name_change_requests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_name_change_requests_on_user_id ON public.user_name_change_requests USING btree (user_id);


--
-- Name: index_user_sessions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_sessions_on_created_at ON public.user_sessions USING btree (created_at);


--
-- Name: index_user_sessions_on_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_sessions_on_ip_addr ON public.user_sessions USING btree (ip_addr);


--
-- Name: index_user_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_sessions_on_session_id ON public.user_sessions USING btree (session_id);


--
-- Name: index_user_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_sessions_on_updated_at ON public.user_sessions USING btree (updated_at);


--
-- Name: index_user_upgrades_on_purchaser_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_upgrades_on_purchaser_id ON public.user_upgrades USING btree (purchaser_id);


--
-- Name: index_user_upgrades_on_recipient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_upgrades_on_recipient_id ON public.user_upgrades USING btree (recipient_id);


--
-- Name: index_user_upgrades_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_upgrades_on_status ON public.user_upgrades USING btree (status);


--
-- Name: index_user_upgrades_on_stripe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_upgrades_on_stripe_id ON public.user_upgrades USING btree (stripe_id);


--
-- Name: index_user_upgrades_on_upgrade_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_upgrades_on_upgrade_type ON public.user_upgrades USING btree (upgrade_type);


--
-- Name: index_users_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_created_at ON public.users USING btree (created_at);


--
-- Name: index_users_on_inviter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_inviter_id ON public.users USING btree (inviter_id) WHERE (inviter_id IS NOT NULL);


--
-- Name: index_users_on_last_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_last_ip_addr ON public.users USING btree (last_ip_addr) WHERE (last_ip_addr IS NOT NULL);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_name ON public.users USING btree (lower((name)::text));


--
-- Name: index_users_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_name_trgm ON public.users USING gin (name public.gin_trgm_ops);


--
-- Name: index_wiki_page_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_created_at ON public.wiki_page_versions USING btree (created_at);


--
-- Name: index_wiki_page_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_updater_id ON public.wiki_page_versions USING btree (updater_id);


--
-- Name: index_wiki_page_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_updater_ip_addr ON public.wiki_page_versions USING btree (updater_ip_addr);


--
-- Name: index_wiki_page_versions_on_wiki_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_wiki_page_id ON public.wiki_page_versions USING btree (wiki_page_id);


--
-- Name: index_wiki_pages_on_array_to_tsvector_other_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_array_to_tsvector_other_names ON public.wiki_pages USING gin (array_to_tsvector(other_names));


--
-- Name: index_wiki_pages_on_other_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_other_names ON public.wiki_pages USING gin (other_names);


--
-- Name: index_wiki_pages_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_wiki_pages_on_title ON public.wiki_pages USING btree (title);


--
-- Name: index_wiki_pages_on_title_and_body_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_title_and_body_tsvector ON public.wiki_pages USING gin (((to_tsvector('english'::regconfig, (title)::text) || to_tsvector('english'::regconfig, body))));


--
-- Name: index_wiki_pages_on_title_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_title_pattern ON public.wiki_pages USING btree (title text_pattern_ops);


--
-- Name: index_wiki_pages_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_updated_at ON public.wiki_pages USING btree (updated_at);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: tag_aliases fk_rails_0157a2fd88; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_aliases
    ADD CONSTRAINT fk_rails_0157a2fd88 FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bans fk_rails_070022cd76; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bans
    ADD CONSTRAINT fk_rails_070022cd76 FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: comment_votes fk_rails_0873e64a40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_votes
    ADD CONSTRAINT fk_rails_0873e64a40 FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: upload_media_assets fk_rails_171271f781; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upload_media_assets
    ADD CONSTRAINT fk_rails_171271f781 FOREIGN KEY (upload_id) REFERENCES public.uploads(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bulk_update_requests fk_rails_1773ada54d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_update_requests
    ADD CONSTRAINT fk_rails_1773ada54d FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_name_change_requests fk_rails_18d9682b1c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_name_change_requests
    ADD CONSTRAINT fk_rails_18d9682b1c FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bans fk_rails_2234692cb1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bans
    ADD CONSTRAINT fk_rails_2234692cb1 FOREIGN KEY (banner_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bulk_update_requests fk_rails_22b3b2a525; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_update_requests
    ADD CONSTRAINT fk_rails_22b3b2a525 FOREIGN KEY (forum_post_id) REFERENCES public.forum_posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dmails fk_rails_22dbb958ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmails
    ADD CONSTRAINT fk_rails_22dbb958ad FOREIGN KEY (from_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_appeals fk_rails_2794bb6745; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_appeals
    ADD CONSTRAINT fk_rails_2794bb6745 FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_replacements fk_rails_286111af77; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacements
    ADD CONSTRAINT fk_rails_286111af77 FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: mod_actions fk_rails_290059ebb5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_actions
    ADD CONSTRAINT fk_rails_290059ebb5 FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: posts fk_rails_299f071108; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk_rails_299f071108 FOREIGN KEY (uploader_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: forum_topic_visits fk_rails_2c7f47773d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topic_visits
    ADD CONSTRAINT fk_rails_2c7f47773d FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: forum_posts fk_rails_2ddd2b5687; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts
    ADD CONSTRAINT fk_rails_2ddd2b5687 FOREIGN KEY (topic_id) REFERENCES public.forum_topics(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: wiki_page_versions fk_rails_2fc7c35d5a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_page_versions
    ADD CONSTRAINT fk_rails_2fc7c35d5a FOREIGN KEY (wiki_page_id) REFERENCES public.wiki_pages(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: comments fk_rails_2fd19c0db7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_2fd19c0db7 FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: api_keys fk_rails_32c28d0dc2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT fk_rails_32c28d0dc2 FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: artist_commentary_versions fk_rails_3b1402ddb3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentary_versions
    ADD CONSTRAINT fk_rails_3b1402ddb3 FOREIGN KEY (updater_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_replacements fk_rails_3ddcb25767; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacements
    ADD CONSTRAINT fk_rails_3ddcb25767 FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users fk_rails_3e95061862; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_3e95061862 FOREIGN KEY (inviter_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: posts fk_rails_3eb11ec3aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk_rails_3eb11ec3aa FOREIGN KEY (parent_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_disapprovals fk_rails_408a205f48; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_disapprovals
    ADD CONSTRAINT fk_rails_408a205f48 FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_appeals fk_rails_4153b9e5a4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_appeals
    ADD CONSTRAINT fk_rails_4153b9e5a4 FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_events fk_rails_41fefee740; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT fk_rails_41fefee740 FOREIGN KEY (user_session_id) REFERENCES public.user_sessions(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: forum_post_votes fk_rails_43fb736f24; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_post_votes
    ADD CONSTRAINT fk_rails_43fb736f24 FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dmails fk_rails_46910c4d2c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmails
    ADD CONSTRAINT fk_rails_46910c4d2c FOREIGN KEY (to_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_flags fk_rails_4a92b4b725; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_flags
    ADD CONSTRAINT fk_rails_4a92b4b725 FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: comments fk_rails_4b8a638a8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_4b8a638a8b FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_approvals fk_rails_4cda56c76c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_approvals
    ADD CONSTRAINT fk_rails_4cda56c76c FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: news_updates fk_rails_502e0a41d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_updates
    ADD CONSTRAINT fk_rails_502e0a41d1 FOREIGN KEY (updater_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: forum_topics fk_rails_53d4e863cd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topics
    ADD CONSTRAINT fk_rails_53d4e863cd FOREIGN KEY (updater_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_upgrades fk_rails_55b7770fa9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_upgrades
    ADD CONSTRAINT fk_rails_55b7770fa9 FOREIGN KEY (recipient_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tag_implications fk_rails_567423c3a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_implications
    ADD CONSTRAINT fk_rails_567423c3a3 FOREIGN KEY (approver_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: comments fk_rails_56c1cf09bc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_56c1cf09bc FOREIGN KEY (updater_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: forum_posts fk_rails_5badbb08d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts
    ADD CONSTRAINT fk_rails_5badbb08d8 FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: forum_post_votes fk_rails_5c3f90ef3f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_post_votes
    ADD CONSTRAINT fk_rails_5c3f90ef3f FOREIGN KEY (forum_post_id) REFERENCES public.forum_posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: artist_commentaries fk_rails_6110874871; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentaries
    ADD CONSTRAINT fk_rails_6110874871 FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: note_versions fk_rails_611f87a5ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_versions
    ADD CONSTRAINT fk_rails_611f87a5ae FOREIGN KEY (note_id) REFERENCES public.notes(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: saved_searches fk_rails_63c5382842; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches
    ADD CONSTRAINT fk_rails_63c5382842 FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_flags fk_rails_68fe8072b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_flags
    ADD CONSTRAINT fk_rails_68fe8072b5 FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_events fk_rails_717ccf5f73; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT fk_rails_717ccf5f73 FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: note_versions fk_rails_71b80cd026; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_versions
    ADD CONSTRAINT fk_rails_71b80cd026 FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: moderation_reports fk_rails_7221bfc52f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_reports
    ADD CONSTRAINT fk_rails_7221bfc52f FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: ip_bans fk_rails_73e3027d29; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ip_bans
    ADD CONSTRAINT fk_rails_73e3027d29 FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_approvals fk_rails_74f76ef71e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_approvals
    ADD CONSTRAINT fk_rails_74f76ef71e FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: favorite_groups fk_rails_796204a5e3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_groups
    ADD CONSTRAINT fk_rails_796204a5e3 FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_feedback fk_rails_81884ec765; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback
    ADD CONSTRAINT fk_rails_81884ec765 FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bulk_update_requests fk_rails_87084cb039; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_update_requests
    ADD CONSTRAINT fk_rails_87084cb039 FOREIGN KEY (approver_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tag_aliases fk_rails_90fd158a45; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_aliases
    ADD CONSTRAINT fk_rails_90fd158a45 FOREIGN KEY (forum_topic_id) REFERENCES public.forum_topics(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: media_metadata fk_rails_93a4b916bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_metadata
    ADD CONSTRAINT fk_rails_93a4b916bd FOREIGN KEY (media_asset_id) REFERENCES public.media_assets(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: comment_votes fk_rails_a0196e2ef9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_votes
    ADD CONSTRAINT fk_rails_a0196e2ef9 FOREIGN KEY (comment_id) REFERENCES public.comments(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: forum_topics fk_rails_a0e236112e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topics
    ADD CONSTRAINT fk_rails_a0e236112e FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: notes fk_rails_a167a78679; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_a167a78679 FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tag_implications fk_rails_aa452a83e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_implications
    ADD CONSTRAINT fk_rails_aa452a83e5 FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bulk_update_requests fk_rails_ad41b77f74; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_update_requests
    ADD CONSTRAINT fk_rails_ad41b77f74 FOREIGN KEY (forum_topic_id) REFERENCES public.forum_topics(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: artist_commentary_versions fk_rails_af197b3f45; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentary_versions
    ADD CONSTRAINT fk_rails_af197b3f45 FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: forum_topic_visits fk_rails_b19b04be70; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topic_visits
    ADD CONSTRAINT fk_rails_b19b04be70 FOREIGN KEY (forum_topic_id) REFERENCES public.forum_topics(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_feedback fk_rails_b1c80e6f0a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback
    ADD CONSTRAINT fk_rails_b1c80e6f0a FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: artist_versions fk_rails_b1cda9510c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_versions
    ADD CONSTRAINT fk_rails_b1cda9510c FOREIGN KEY (artist_id) REFERENCES public.artists(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_votes fk_rails_b550730fb8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes
    ADD CONSTRAINT fk_rails_b550730fb8 FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tag_implications fk_rails_bec6ee1cbe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_implications
    ADD CONSTRAINT fk_rails_bec6ee1cbe FOREIGN KEY (forum_post_id) REFERENCES public.forum_posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: news_updates fk_rails_c008307ac5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_updates
    ADD CONSTRAINT fk_rails_c008307ac5 FOREIGN KEY (creator_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dmails fk_rails_c303efc12e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmails
    ADD CONSTRAINT fk_rails_c303efc12e FOREIGN KEY (owner_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: wiki_page_versions fk_rails_c6ed6113f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_page_versions
    ADD CONSTRAINT fk_rails_c6ed6113f4 FOREIGN KEY (updater_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tag_aliases fk_rails_ca93879f64; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_aliases
    ADD CONSTRAINT fk_rails_ca93879f64 FOREIGN KEY (approver_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: favorites fk_rails_d15744e438; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_rails_d15744e438 FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: uploads fk_rails_d29b037216; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT fk_rails_d29b037216 FOREIGN KEY (uploader_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tag_implications fk_rails_dba2c19f93; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_implications
    ADD CONSTRAINT fk_rails_dba2c19f93 FOREIGN KEY (forum_topic_id) REFERENCES public.forum_topics(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: favorites fk_rails_dcaf44a136; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_rails_dcaf44a136 FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: email_addresses fk_rails_de643267e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_addresses
    ADD CONSTRAINT fk_rails_de643267e7 FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: note_versions fk_rails_e4a6971555; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_versions
    ADD CONSTRAINT fk_rails_e4a6971555 FOREIGN KEY (updater_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: artist_urls fk_rails_e4e6c00d41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls
    ADD CONSTRAINT fk_rails_e4e6c00d41 FOREIGN KEY (artist_id) REFERENCES public.artists(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tag_aliases fk_rails_e5a732a43b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_aliases
    ADD CONSTRAINT fk_rails_e5a732a43b FOREIGN KEY (forum_post_id) REFERENCES public.forum_posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_disapprovals fk_rails_e6a71f8147; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_disapprovals
    ADD CONSTRAINT fk_rails_e6a71f8147 FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: forum_posts fk_rails_eef947df00; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts
    ADD CONSTRAINT fk_rails_eef947df00 FOREIGN KEY (updater_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: posts fk_rails_f23dabc609; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk_rails_f23dabc609 FOREIGN KEY (approver_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pixiv_ugoira_frame_data fk_rails_f249d093cc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pixiv_ugoira_frame_data
    ADD CONSTRAINT fk_rails_f249d093cc FOREIGN KEY (post_id) REFERENCES public.posts(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: artist_versions fk_rails_f37d58ea23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_versions
    ADD CONSTRAINT fk_rails_f37d58ea23 FOREIGN KEY (updater_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_votes fk_rails_f3edc07390; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes
    ADD CONSTRAINT fk_rails_f3edc07390 FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: upload_media_assets fk_rails_f6bce0ea3f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upload_media_assets
    ADD CONSTRAINT fk_rails_f6bce0ea3f FOREIGN KEY (media_asset_id) REFERENCES public.media_assets(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_upgrades fk_rails_f9349ed07b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_upgrades
    ADD CONSTRAINT fk_rails_f9349ed07b FOREIGN KEY (purchaser_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20100204211522'),
('20100204214746'),
('20100205162521'),
('20100205163027'),
('20100205224030'),
('20100211025616'),
('20100211181944'),
('20100211191709'),
('20100211191716'),
('20100213181847'),
('20100213183712'),
('20100214080549'),
('20100214080557'),
('20100214080605'),
('20100215182234'),
('20100215213756'),
('20100215223541'),
('20100215224629'),
('20100215224635'),
('20100215225710'),
('20100215230642'),
('20100219230537'),
('20100221003655'),
('20100221005812'),
('20100223001012'),
('20100224171915'),
('20100224172146'),
('20100307073438'),
('20100309211553'),
('20100318213503'),
('20100826232512'),
('20110328215652'),
('20110328215701'),
('20110607194023'),
('20110717010705'),
('20110722211855'),
('20110815233456'),
('20111101212358'),
('20130106210658'),
('20130114154400'),
('20130219171111'),
('20130219184743'),
('20130221032344'),
('20130221035518'),
('20130221214811'),
('20130302214500'),
('20130305005138'),
('20130307225324'),
('20130308204213'),
('20130318002652'),
('20130318012517'),
('20130318030619'),
('20130318231740'),
('20130320070700'),
('20130322162059'),
('20130322173202'),
('20130322173859'),
('20130323160259'),
('20130326035904'),
('20130328092739'),
('20130331180246'),
('20130331182719'),
('20130401013601'),
('20130409191950'),
('20130417221643'),
('20130424121410'),
('20130506154136'),
('20130606224559'),
('20130618230158'),
('20130620215658'),
('20130712162600'),
('20130914175431'),
('20131006193238'),
('20131117150705'),
('20131118153503'),
('20131130190411'),
('20131209181023'),
('20131217025233'),
('20131225002748'),
('20140111191413'),
('20140204233337'),
('20140221213349'),
('20140428015134'),
('20140505000956'),
('20140603225334'),
('20140604002414'),
('20140613004559'),
('20140701224800'),
('20140722225753'),
('20140725003232'),
('20141009231234'),
('20141017231608'),
('20141120045943'),
('20150119191042'),
('20150120005624'),
('20150128005954'),
('20150403224949'),
('20150613010904'),
('20150623191904'),
('20150629235905'),
('20150705014135'),
('20150721214646'),
('20150728170433'),
('20150805010245'),
('20151217213321'),
('20160219004022'),
('20160219010854'),
('20160219172840'),
('20160222211328'),
('20160526174848'),
('20160820003534'),
('20160822230752'),
('20160919234407'),
('20161018221128'),
('20161024220345'),
('20161101003139'),
('20161221225849'),
('20161227003428'),
('20161229001201'),
('20170106012138'),
('20170112021922'),
('20170112060921'),
('20170117233040'),
('20170218104710'),
('20170302014435'),
('20170314235626'),
('20170316224630'),
('20170319000519'),
('20170329185605'),
('20170330230231'),
('20170413000209'),
('20170414005856'),
('20170414233426'),
('20170414233617'),
('20170416224142'),
('20170428220448'),
('20170512221200'),
('20170515235205'),
('20170519204506'),
('20170526183928'),
('20170608043651'),
('20170613200356'),
('20170709190409'),
('20170914200122'),
('20171106075030'),
('20171127195124'),
('20171218213037'),
('20171219001521'),
('20171230220225'),
('20180113211343'),
('20180116001101'),
('20180403231351'),
('20180413224239'),
('20180425194016'),
('20180516222413'),
('20180517190048'),
('20180518175154'),
('20180804203201'),
('20180816230604'),
('20180912185624'),
('20180913184128'),
('20180916002448'),
('20181108162204'),
('20181108205842'),
('20181113174914'),
('20181114180205'),
('20181114185032'),
('20181114202744'),
('20181130004740'),
('20181202172145'),
('20190109210822'),
('20190129012253'),
('20190712174818'),
('20190827013252'),
('20190827014726'),
('20190827233235'),
('20190827234625'),
('20190828005453'),
('20190829052629'),
('20190829055758'),
('20190902224045'),
('20190908031103'),
('20190908035317'),
('20190919175836'),
('20190923071044'),
('20190926000912'),
('20191023191749'),
('20191024194544'),
('20191111004329'),
('20191111024520'),
('20191116001441'),
('20191116021759'),
('20191116224228'),
('20191117074642'),
('20191117080647'),
('20191117081229'),
('20191117200404'),
('20191119061018'),
('20191223032633'),
('20200114204550'),
('20200115010442'),
('20200117220602'),
('20200118015014'),
('20200119184442'),
('20200119193110'),
('20200123184743'),
('20200217044719'),
('20200223042415'),
('20200223234015'),
('20200306202253'),
('20200307021204'),
('20200309035334'),
('20200309043653'),
('20200318224633'),
('20200325073456'),
('20200325074859'),
('20200403210353'),
('20200406054838'),
('20200427190519'),
('20200803022359'),
('20200816175151'),
('20201201211748'),
('20201213052805'),
('20201219201007'),
('20201224101208'),
('20210106212805'),
('20210108030722'),
('20210108030723'),
('20210108030724'),
('20210110015410'),
('20210110090656'),
('20210115015308'),
('20210123112752'),
('20210127000201'),
('20210127012303'),
('20210214095121'),
('20210214101614'),
('20210303195217'),
('20210310221248'),
('20210330003356'),
('20210330093133'),
('20210901230931'),
('20210908015203'),
('20210921164936'),
('20210921170444'),
('20210926123414'),
('20210926125826'),
('20211008091234'),
('20211010181657'),
('20211011044400'),
('20211013011619'),
('20211014063943'),
('20211015223510'),
('20211018045429'),
('20211018062916'),
('20211023225730'),
('20211121080239'),
('20220101224048'),
('20220104214319'),
('20220106171727'),
('20220106172910'),
('20220107014433'),
('20220109032042'),
('20220109163815'),
('20220110171021'),
('20220110171022'),
('20220110171023'),
('20220110171024'),
('20220120233850'),
('20220124195900'),
('20220203040648'),
('20220204075610'),
('20220207195123'),
('20220210171310'),
('20220210200157'),
('20220211075129'),
('20220311093552');


