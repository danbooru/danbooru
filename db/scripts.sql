-- table and index bloat
WITH constants AS (
   SELECT current_setting('block_size')::numeric AS bs, 23 AS hdr, 4 AS ma
 ), bloat_info AS (
   SELECT
     ma,bs,schemaname,tablename,
     (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
     (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
   FROM (
     SELECT
       schemaname, tablename, hdr, ma, bs,
       SUM((1-null_frac)*avg_width) AS datawidth,
       MAX(null_frac) AS maxfracsum,
       hdr+(
         SELECT 1+count(*)/8
         FROM pg_stats s2
         WHERE null_frac<>0 AND s2.schemaname = s.schemaname AND s2.tablename = s.tablename
       ) AS nullhdr
     FROM pg_stats s, constants
     GROUP BY 1,2,3,4,5
   ) AS foo
 ), table_bloat AS (
   SELECT
     schemaname, tablename, cc.relpages, bs,
     CEIL((cc.reltuples*((datahdr+ma-
       (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)) AS otta
   FROM bloat_info
   JOIN pg_class cc ON cc.relname = bloat_info.tablename
   JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = bloat_info.schemaname AND nn.nspname <> 'information_schema'
 ), index_bloat AS (
   SELECT
     schemaname, tablename, bs,
     COALESCE(c2.relname,'?') AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
     COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols
   FROM bloat_info
   JOIN pg_class cc ON cc.relname = bloat_info.tablename
   JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = bloat_info.schemaname AND nn.nspname <> 'information_schema'
   JOIN pg_index i ON indrelid = cc.oid
   JOIN pg_class c2 ON c2.oid = i.indexrelid
 )
 SELECT
   type, schemaname, object_name, bloat, pg_size_pretty(raw_waste) as waste
 FROM
 (SELECT
   'table' as type,
   schemaname,
   tablename as object_name,
   ROUND(CASE WHEN otta=0 THEN 0.0 ELSE table_bloat.relpages/otta::numeric END,1) AS bloat,
   CASE WHEN relpages < otta THEN '0' ELSE (bs*(table_bloat.relpages-otta)::bigint)::bigint END AS raw_waste
 FROM
   table_bloat
     UNION
 SELECT
   'index' as type,
   schemaname,
   tablename || '::' || iname as object_name,
   ROUND(CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages/iotta::numeric END,1) AS bloat,
   CASE WHEN ipages < iotta THEN '0' ELSE (bs*(ipages-iotta))::bigint END AS raw_waste
 FROM
   index_bloat) bloat_summary
 ORDER BY raw_waste DESC, bloat DESC;


-- autovacuum stats
SELECT relname, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze  
FROM pg_stat_all_tables  
WHERE schemaname = 'public'
and relname = 'posts';


-- cache hit rate
SELECT
'index hit rate' AS name,
(sum(idx_blks_hit)) / nullif(sum(idx_blks_hit + idx_blks_read),0) AS ratio
FROM pg_statio_user_indexes
UNION ALL
SELECT
'table hit rate' AS name,
sum(heap_blks_hit) / nullif(sum(heap_blks_hit) + sum(heap_blks_read),0) AS ratio
FROM pg_statio_user_tables;


-- index hit rate
SELECT relname,
CASE idx_scan
WHEN 0 THEN 'Insufficient data'
ELSE (100 * idx_scan / (seq_scan + idx_scan))::text
END percent_of_times_index_used,
n_live_tup rows_in_table
FROM
pg_stat_user_tables
ORDER BY
n_live_tup DESC;


-- index size/usage
SELECT
    t.tablename,
    indexname,
    c.reltuples AS num_rows,
    pg_size_pretty(pg_relation_size(quote_ident(t.tablename)::text)) AS table_size,
    pg_size_pretty(pg_relation_size(quote_ident(indexrelname)::text)) AS index_size,
    CASE WHEN indisunique THEN 'Y'
       ELSE 'N'
    END AS UNIQUE,
    idx_scan AS number_of_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM pg_tables t
LEFT OUTER JOIN pg_class c ON t.tablename=c.relname
LEFT OUTER JOIN
    ( SELECT c.relname AS ctablename, ipg.relname AS indexname, x.indnatts AS number_of_columns, idx_scan, idx_tup_read, idx_tup_fetch, indexrelname, indisunique FROM pg_index x
           JOIN pg_class c ON c.oid = x.indrelid
           JOIN pg_class ipg ON ipg.oid = x.indexrelid
           JOIN pg_stat_all_indexes psai ON x.indexrelid = psai.indexrelid )
    AS foo
    ON t.tablename = foo.ctablename
WHERE t.schemaname='public'
ORDER BY 1,2;


-- index summary
SELECT
    pg_class.relname,
    pg_size_pretty(pg_class.reltuples::BIGINT) AS rows_in_bytes,
    pg_class.reltuples AS num_rows,
    COUNT(indexname) AS number_of_indexes,
    CASE WHEN x.is_unique = 1 THEN 'Y'
       ELSE 'N'
    END AS UNIQUE,
    SUM(CASE WHEN number_of_columns = 1 THEN 1
              ELSE 0
            END) AS single_column,
    SUM(CASE WHEN number_of_columns IS NULL THEN 0
             WHEN number_of_columns = 1 THEN 0
             ELSE 1
           END) AS multi_column
FROM pg_namespace 
LEFT OUTER JOIN pg_class ON pg_namespace.oid = pg_class.relnamespace
LEFT OUTER JOIN
       (SELECT indrelid,
           MAX(CAST(indisunique AS INTEGER)) AS is_unique
       FROM pg_index
       GROUP BY indrelid) x
       ON pg_class.oid = x.indrelid
LEFT OUTER JOIN
    ( SELECT c.relname AS ctablename, ipg.relname AS indexname, x.indnatts AS number_of_columns FROM pg_index x
           JOIN pg_class c ON c.oid = x.indrelid
           JOIN pg_class ipg ON ipg.oid = x.indexrelid  )
    AS foo
    ON pg_class.relname = foo.ctablename
WHERE 
     pg_namespace.nspname='public'
AND  pg_class.relkind = 'r'
GROUP BY pg_class.relname, pg_class.reltuples, x.is_unique
ORDER BY 2;


-- sequential scans
SELECT relname AS name,
seq_scan as count
FROM
pg_stat_user_tables
ORDER BY seq_scan DESC;


-- long running queries
SELECT
pid,
now() - pg_stat_activity.query_start AS duration,
query
FROM
pg_stat_activity
WHERE
pg_stat_activity.query <> ''::text
AND state <> 'idle'
AND now() - pg_stat_activity.query_start > interval '5 minutes'
ORDER BY
now() - pg_stat_activity.query_start DESC;


-- unused indexes
SELECT
schemaname || '.' || relname AS table,
indexrelname AS index,
pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
idx_scan as index_scans
FROM pg_stat_user_indexes ui
JOIN pg_index i ON ui.indexrelid = i.indexrelid
WHERE NOT indisunique AND idx_scan < 50 AND pg_relation_size(relid) > 5 * 8192
ORDER BY pg_relation_size(i.indexrelid) / nullif(idx_scan, 0) DESC NULLS FIRST,
pg_relation_size(i.indexrelid) DESC;


-- total table size
SELECT c.relname AS name,
pg_size_pretty(pg_total_relation_size(c.oid)) AS size
FROM pg_class c
LEFT JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
AND n.nspname !~ '^pg_toast'
AND c.relkind='r'
ORDER BY pg_total_relation_size(c.oid) DESC;


-- total index size
SELECT c.relname AS table,
pg_size_pretty(pg_indexes_size(c.oid)) AS index_size
FROM pg_class c
LEFT JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
AND n.nspname !~ '^pg_toast'
AND c.relkind='r'
ORDER BY pg_indexes_size(c.oid) DESC;


-- queries with active locks
SELECT
pg_stat_activity.pid,
pg_class.relname,
pg_locks.transactionid,
pg_locks.granted,
pg_stat_activity.query AS query_snippet,
age(now(),pg_stat_activity.query_start) AS "age"
FROM pg_stat_activity,pg_locks left
OUTER JOIN pg_class
ON (pg_locks.relation = pg_class.oid)
WHERE pg_stat_activity.query <> '<insufficient privilege>'
AND pg_locks.pid = pg_stat_activity.pid
AND pg_locks.mode = 'ExclusiveLock'
AND pg_stat_activity.pid <> pg_backend_pid() order by query_start;


-- queries holding locks other queries are waiting to be released
SELECT bl.pid AS blocked_pid,
ka.query AS blocking_statement,
now() - ka.query_start AS blocking_duration,
kl.pid AS blocking_pid,
a.query AS blocked_statement,
now() - a.query_start AS blocked_duration
FROM pg_catalog.pg_locks bl
JOIN pg_catalog.pg_stat_activity a
ON bl.pid = a.pid
JOIN pg_catalog.pg_locks kl
JOIN pg_catalog.pg_stat_activity ka
ON kl.pid = ka.pid
ON bl.transactionid = kl.transactionid AND bl.pid != kl.pid
WHERE NOT bl.granted;


-- vacuum stats
WITH table_opts AS (
  SELECT
    pg_class.oid, relname, nspname, array_to_string(reloptions, '') AS relopts
  FROM
     pg_class INNER JOIN pg_namespace ns ON relnamespace = ns.oid
), vacuum_settings AS (
  SELECT
    oid, relname, nspname,
    CASE
      WHEN relopts LIKE '%autovacuum_vacuum_threshold%'
        THEN regexp_replace(relopts, '.*autovacuum_vacuum_threshold=([0-9.]+).*', E'\\\\\\1')::integer
        ELSE current_setting('autovacuum_vacuum_threshold')::integer
      END AS autovacuum_vacuum_threshold,
    CASE
      WHEN relopts LIKE '%autovacuum_vacuum_scale_factor%'
        THEN regexp_replace(relopts, '.*autovacuum_vacuum_scale_factor=([0-9.]+).*', E'\\\\\\1')::real
        ELSE current_setting('autovacuum_vacuum_scale_factor')::real
      END AS autovacuum_vacuum_scale_factor
  FROM
    table_opts
)
SELECT
  vacuum_settings.nspname AS schema,
  vacuum_settings.relname AS table,
  to_char(psut.last_vacuum, 'YYYY-MM-DD HH24:MI') AS last_vacuum,
  to_char(psut.last_autovacuum, 'YYYY-MM-DD HH24:MI') AS last_autovacuum,
  to_char(pg_class.reltuples, '9G999G999G999') AS rowcount,
  to_char(psut.n_dead_tup, '9G999G999G999') AS dead_rowcount,
  to_char(autovacuum_vacuum_threshold
       + (autovacuum_vacuum_scale_factor::numeric * pg_class.reltuples), '9G999G999G999') AS autovacuum_threshold,
  CASE
    WHEN autovacuum_vacuum_threshold + (autovacuum_vacuum_scale_factor::numeric * pg_class.reltuples) < psut.n_dead_tup
    THEN 'yes'
  END AS expect_autovacuum
FROM
  pg_stat_user_tables psut INNER JOIN pg_class ON psut.relid = pg_class.oid
    INNER JOIN vacuum_settings ON pg_class.oid = vacuum_settings.oid
ORDER BY 1;
