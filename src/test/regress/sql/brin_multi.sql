CREATE TABLE brintest_multi (
	int8col bigint,
	int2col smallint,
	int4col integer,
	oidcol oid,
	tidcol tid,
	float4col real,
	float8col double precision,
	macaddrcol macaddr,
	inetcol inet,
	cidrcol cidr,
	datecol date,
	timecol time without time zone,
	timestampcol timestamp without time zone,
	timestamptzcol timestamp with time zone,
	intervalcol interval,
	timetzcol time with time zone,
	numericcol numeric,
	uuidcol uuid,
	lsncol pg_lsn
) WITH (fillfactor=10);

INSERT INTO brintest_multi SELECT
	142857 * tenthous,
	thousand,
	twothousand,
	unique1::oid,
	format('(%s,%s)', tenthous, twenty)::tid,
	(four + 1.0)/(hundred+1),
	odd::float8 / (tenthous + 1),
	format('%s:00:%s:00:%s:00', to_hex(odd), to_hex(even), to_hex(hundred))::macaddr,
	inet '10.2.3.4/24' + tenthous,
	cidr '10.2.3/24' + tenthous,
	date '1995-08-15' + tenthous,
	time '01:20:30' + thousand * interval '18.5 second',
	timestamp '1942-07-23 03:05:09' + tenthous * interval '36.38 hours',
	timestamptz '1972-10-10 03:00' + thousand * interval '1 hour',
	justify_days(justify_hours(tenthous * interval '12 minutes')),
	timetz '01:30:20+02' + hundred * interval '15 seconds',
	tenthous::numeric(36,30) * fivethous * even / (hundred + 1),
	format('%s%s-%s-%s-%s-%s%s%s', to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'))::uuid,
	format('%s/%s%s', odd, even, tenthous)::pg_lsn
FROM tenk1 ORDER BY unique2 LIMIT 100;

-- throw in some NULL's and different values
INSERT INTO brintest_multi (inetcol, cidrcol) SELECT
	inet 'fe80::6e40:8ff:fea9:8c46' + tenthous,
	cidr 'fe80::6e40:8ff:fea9:8c46' + tenthous
FROM tenk1 ORDER BY thousand, tenthous LIMIT 25;

-- test minmax-multi specific index options
-- number of values must be >= 16
CREATE INDEX brinidx_multi ON brintest_multi USING brin (
	int8col int8_minmax_multi_ops(values_per_range = 7)
);
-- number of values must be <= 256
CREATE INDEX brinidx_multi ON brintest_multi USING brin (
	int8col int8_minmax_multi_ops(values_per_range = 257)
);

-- first create an index with a single page range, to force compaction
-- due to exceeding the number of values per summary
CREATE INDEX brinidx_multi ON brintest_multi USING brin (
	int8col int8_minmax_multi_ops,
	int2col int2_minmax_multi_ops,
	int4col int4_minmax_multi_ops,
	oidcol oid_minmax_multi_ops,
	tidcol tid_minmax_multi_ops,
	float4col float4_minmax_multi_ops,
	float8col float8_minmax_multi_ops,
	macaddrcol macaddr_minmax_multi_ops,
	inetcol inet_minmax_multi_ops,
	cidrcol inet_minmax_multi_ops,
	datecol date_minmax_multi_ops,
	timecol time_minmax_multi_ops,
	timestampcol timestamp_minmax_multi_ops,
	timestamptzcol timestamptz_minmax_multi_ops,
	intervalcol interval_minmax_multi_ops,
	timetzcol timetz_minmax_multi_ops,
	numericcol numeric_minmax_multi_ops,
	uuidcol uuid_minmax_multi_ops,
	lsncol pg_lsn_minmax_multi_ops
);

DROP INDEX brinidx_multi;

CREATE INDEX brinidx_multi ON brintest_multi USING brin (
	int8col int8_minmax_multi_ops,
	int2col int2_minmax_multi_ops,
	int4col int4_minmax_multi_ops,
	oidcol oid_minmax_multi_ops,
	tidcol tid_minmax_multi_ops,
	float4col float4_minmax_multi_ops,
	float8col float8_minmax_multi_ops,
	macaddrcol macaddr_minmax_multi_ops,
	inetcol inet_minmax_multi_ops,
	cidrcol inet_minmax_multi_ops,
	datecol date_minmax_multi_ops,
	timecol time_minmax_multi_ops,
	timestampcol timestamp_minmax_multi_ops,
	timestamptzcol timestamptz_minmax_multi_ops,
	intervalcol interval_minmax_multi_ops,
	timetzcol timetz_minmax_multi_ops,
	numericcol numeric_minmax_multi_ops,
	uuidcol uuid_minmax_multi_ops,
	lsncol pg_lsn_minmax_multi_ops
) with (pages_per_range = 1);

CREATE TABLE brinopers_multi (colname name, typ text,
	op text[], value text[], matches int[],
	check (cardinality(op) = cardinality(value)),
	check (cardinality(op) = cardinality(matches)));

INSERT INTO brinopers_multi VALUES
	('int2col', 'int2',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 800, 999, 999}',
	 '{100, 100, 1, 100, 100}'),
	('int2col', 'int4',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 800, 999, 1999}',
	 '{100, 100, 1, 100, 100}'),
	('int2col', 'int8',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 800, 999, 1428427143}',
	 '{100, 100, 1, 100, 100}'),
	('int4col', 'int2',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 800, 1999, 1999}',
	 '{100, 100, 1, 100, 100}'),
	('int4col', 'int4',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 800, 1999, 1999}',
	 '{100, 100, 1, 100, 100}'),
	('int4col', 'int8',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 800, 1999, 1428427143}',
	 '{100, 100, 1, 100, 100}'),
	('int8col', 'int2',
	 '{>, >=}',
	 '{0, 0}',
	 '{100, 100}'),
	('int8col', 'int4',
	 '{>, >=}',
	 '{0, 0}',
	 '{100, 100}'),
	('int8col', 'int8',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 1257141600, 1428427143, 1428427143}',
	 '{100, 100, 1, 100, 100}'),
	('oidcol', 'oid',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 8800, 9999, 9999}',
	 '{100, 100, 1, 100, 100}'),
	('tidcol', 'tid',
	 '{>, >=, =, <=, <}',
	 '{"(0,0)", "(0,0)", "(8800,0)", "(9999,19)", "(9999,19)"}',
	 '{100, 100, 1, 100, 100}'),
	('float4col', 'float4',
	 '{>, >=, =, <=, <}',
	 '{0.0103093, 0.0103093, 1, 1, 1}',
	 '{100, 100, 4, 100, 96}'),
	('float4col', 'float8',
	 '{>, >=, =, <=, <}',
	 '{0.0103093, 0.0103093, 1, 1, 1}',
	 '{100, 100, 4, 100, 96}'),
	('float8col', 'float4',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 0, 1.98, 1.98}',
	 '{99, 100, 1, 100, 100}'),
	('float8col', 'float8',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 0, 1.98, 1.98}',
	 '{99, 100, 1, 100, 100}'),
	('macaddrcol', 'macaddr',
	 '{>, >=, =, <=, <}',
	 '{00:00:01:00:00:00, 00:00:01:00:00:00, 2c:00:2d:00:16:00, ff:fe:00:00:00:00, ff:fe:00:00:00:00}',
	 '{99, 100, 2, 100, 100}'),
	('inetcol', 'inet',
	 '{=, <, <=, >, >=}',
	 '{10.2.14.231/24, 255.255.255.255, 255.255.255.255, 0.0.0.0, 0.0.0.0}',
	 '{1, 100, 100, 125, 125}'),
	('inetcol', 'cidr',
	 '{<, <=, >, >=}',
	 '{255.255.255.255, 255.255.255.255, 0.0.0.0, 0.0.0.0}',
	 '{100, 100, 125, 125}'),
	('cidrcol', 'inet',
	 '{=, <, <=, >, >=}',
	 '{10.2.14/24, 255.255.255.255, 255.255.255.255, 0.0.0.0, 0.0.0.0}',
	 '{2, 100, 100, 125, 125}'),
	('cidrcol', 'cidr',
	 '{=, <, <=, >, >=}',
	 '{10.2.14/24, 255.255.255.255, 255.255.255.255, 0.0.0.0, 0.0.0.0}',
	 '{2, 100, 100, 125, 125}'),
	('datecol', 'date',
	 '{>, >=, =, <=, <}',
	 '{1995-08-15, 1995-08-15, 2009-12-01, 2022-12-30, 2022-12-30}',
	 '{100, 100, 1, 100, 100}'),
	('timecol', 'time',
	 '{>, >=, =, <=, <}',
	 '{01:20:30, 01:20:30, 02:28:57, 06:28:31.5, 06:28:31.5}',
	 '{100, 100, 1, 100, 100}'),
	('timestampcol', 'timestamp',
	 '{>, >=, =, <=, <}',
	 '{1942-07-23 03:05:09, 1942-07-23 03:05:09, 1964-03-24 19:26:45, 1984-01-20 22:42:21, 1984-01-20 22:42:21}',
	 '{100, 100, 1, 100, 100}'),
	('timestampcol', 'timestamptz',
	 '{>, >=, =, <=, <}',
	 '{1942-07-23 03:05:09, 1942-07-23 03:05:09, 1964-03-24 19:26:45, 1984-01-20 22:42:21, 1984-01-20 22:42:21}',
	 '{100, 100, 1, 100, 100}'),
	('timestamptzcol', 'timestamptz',
	 '{>, >=, =, <=, <}',
	 '{1972-10-10 03:00:00-04, 1972-10-10 03:00:00-04, 1972-10-19 09:00:00-07, 1972-11-20 19:00:00-03, 1972-11-20 19:00:00-03}',
	 '{100, 100, 1, 100, 100}'),
	('intervalcol', 'interval',
	 '{>, >=, =, <=, <}',
	 '{00:00:00, 00:00:00, 1 mons 13 days 12:24, 2 mons 23 days 07:48:00, 1 year}',
	 '{100, 100, 1, 100, 100}'),
	('timetzcol', 'timetz',
	 '{>, >=, =, <=, <}',
	 '{01:30:20+02, 01:30:20+02, 01:35:50+02, 23:55:05+02, 23:55:05+02}',
	 '{99, 100, 2, 100, 100}'),
	('numericcol', 'numeric',
	 '{>, >=, =, <=, <}',
	 '{0.00, 0.01, 2268164.347826086956521739130434782609, 99470151.9, 99470151.9}',
	 '{100, 100, 1, 100, 100}'),
	('uuidcol', 'uuid',
	 '{>, >=, =, <=, <}',
	 '{00040004-0004-0004-0004-000400040004, 00040004-0004-0004-0004-000400040004, 52225222-5222-5222-5222-522252225222, 99989998-9998-9998-9998-999899989998, 99989998-9998-9998-9998-999899989998}',
	 '{100, 100, 1, 100, 100}'),
	('lsncol', 'pg_lsn',
	 '{>, >=, =, <=, <, IS, IS NOT}',
	 '{0/1200, 0/1200, 44/455222, 198/1999799, 198/1999799, NULL, NULL}',
	 '{100, 100, 1, 100, 100, 25, 100}');

DO $x$
DECLARE
	r record;
	r2 record;
	cond text;
	idx_ctids tid[];
	ss_ctids tid[];
	count int;
	plan_ok bool;
	plan_line text;
BEGIN
	FOR r IN SELECT colname, oper, typ, value[ordinality], matches[ordinality] FROM brinopers_multi, unnest(op) WITH ORDINALITY AS oper LOOP

		-- prepare the condition
		IF r.value IS NULL THEN
			cond := format('%I %s %L', r.colname, r.oper, r.value);
		ELSE
			cond := format('%I %s %L::%s', r.colname, r.oper, r.value, r.typ);
		END IF;

		-- run the query using the brin index
		SET enable_seqscan = 0;
		SET enable_bitmapscan = 1;

		plan_ok := false;
		FOR plan_line IN EXECUTE format($y$EXPLAIN SELECT array_agg(ctid) FROM brintest_multi WHERE %s $y$, cond) LOOP
			IF plan_line LIKE '%Bitmap Heap Scan on brintest_multi%' THEN
				plan_ok := true;
			END IF;
		END LOOP;
		IF NOT plan_ok THEN
			RAISE WARNING 'did not get bitmap indexscan plan for %', r;
		END IF;

		EXECUTE format($y$SELECT array_agg(ctid) FROM brintest_multi WHERE %s $y$, cond)
			INTO idx_ctids;

		-- run the query using a seqscan
		SET enable_seqscan = 1;
		SET enable_bitmapscan = 0;

		plan_ok := false;
		FOR plan_line IN EXECUTE format($y$EXPLAIN SELECT array_agg(ctid) FROM brintest_multi WHERE %s $y$, cond) LOOP
			IF plan_line LIKE '%Seq Scan on brintest_multi%' THEN
				plan_ok := true;
			END IF;
		END LOOP;
		IF NOT plan_ok THEN
			RAISE WARNING 'did not get seqscan plan for %', r;
		END IF;

		EXECUTE format($y$SELECT array_agg(ctid) FROM brintest_multi WHERE %s $y$, cond)
			INTO ss_ctids;

		-- make sure both return the same results
		count := array_length(idx_ctids, 1);

		IF NOT (count = array_length(ss_ctids, 1) AND
				idx_ctids @> ss_ctids AND
				idx_ctids <@ ss_ctids) THEN
			-- report the results of each scan to make the differences obvious
			RAISE WARNING 'something not right in %: count %', r, count;
			SET enable_seqscan = 1;
			SET enable_bitmapscan = 0;
			FOR r2 IN EXECUTE 'SELECT ' || r.colname || ' FROM brintest_multi WHERE ' || cond LOOP
				RAISE NOTICE 'seqscan: %', r2;
			END LOOP;

			SET enable_seqscan = 0;
			SET enable_bitmapscan = 1;
			FOR r2 IN EXECUTE 'SELECT ' || r.colname || ' FROM brintest_multi WHERE ' || cond LOOP
				RAISE NOTICE 'bitmapscan: %', r2;
			END LOOP;
		END IF;

		-- make sure we found expected number of matches
		IF count != r.matches THEN RAISE WARNING 'unexpected number of results % for %', count, r; END IF;
	END LOOP;
END;
$x$;

RESET enable_seqscan;
RESET enable_bitmapscan;

INSERT INTO brintest_multi SELECT
	142857 * tenthous,
	thousand,
	twothousand,
	unique1::oid,
	format('(%s,%s)', tenthous, twenty)::tid,
	(four + 1.0)/(hundred+1),
	odd::float8 / (tenthous + 1),
	format('%s:00:%s:00:%s:00', to_hex(odd), to_hex(even), to_hex(hundred))::macaddr,
	inet '10.2.3.4' + tenthous,
	cidr '10.2.3/24' + tenthous,
	date '1995-08-15' + tenthous,
	time '01:20:30' + thousand * interval '18.5 second',
	timestamp '1942-07-23 03:05:09' + tenthous * interval '36.38 hours',
	timestamptz '1972-10-10 03:00' + thousand * interval '1 hour',
	justify_days(justify_hours(tenthous * interval '12 minutes')),
	timetz '01:30:20' + hundred * interval '15 seconds',
	tenthous::numeric(36,30) * fivethous * even / (hundred + 1),
	format('%s%s-%s-%s-%s-%s%s%s', to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'))::uuid,
	format('%s/%s%s', odd, even, tenthous)::pg_lsn
FROM tenk1 ORDER BY unique2 LIMIT 5 OFFSET 5;

SELECT brin_desummarize_range('brinidx_multi', 0);
VACUUM brintest_multi;  -- force a summarization cycle in brinidx

UPDATE brintest_multi SET int8col = int8col * int4col;

-- Tests for brin_summarize_new_values
SELECT brin_summarize_new_values('brintest_multi'); -- error, not an index
SELECT brin_summarize_new_values('tenk1_unique1'); -- error, not a BRIN index
SELECT brin_summarize_new_values('brinidx_multi'); -- ok, no change expected

-- Tests for brin_desummarize_range
SELECT brin_desummarize_range('brinidx_multi', -1); -- error, invalid range
SELECT brin_desummarize_range('brinidx_multi', 0);
SELECT brin_desummarize_range('brinidx_multi', 0);
SELECT brin_desummarize_range('brinidx_multi', 100000000);

-- test building an index with many values, to force compaction of the buffer
CREATE TABLE brin_large_range (a int4);
INSERT INTO brin_large_range SELECT i FROM generate_series(1,10000) s(i);
CREATE INDEX brin_large_range_idx ON brin_large_range USING brin (a int4_minmax_multi_ops);
DROP TABLE brin_large_range;

-- Test brin_summarize_range
CREATE TABLE brin_summarize_multi (
    value int
) WITH (fillfactor=10, autovacuum_enabled=false);
CREATE INDEX brin_summarize_multi_idx ON brin_summarize_multi USING brin (value) WITH (pages_per_range=2);
-- Fill a few pages
DO $$
DECLARE curtid tid;
BEGIN
  LOOP
    INSERT INTO brin_summarize_multi VALUES (1) RETURNING ctid INTO curtid;
    EXIT WHEN curtid > tid '(2, 0)';
  END LOOP;
END;
$$;

-- summarize one range
SELECT brin_summarize_range('brin_summarize_multi_idx', 0);
-- nothing: already summarized
SELECT brin_summarize_range('brin_summarize_multi_idx', 1);
-- summarize one range
SELECT brin_summarize_range('brin_summarize_multi_idx', 2);
-- nothing: page doesn't exist in table
SELECT brin_summarize_range('brin_summarize_multi_idx', 4294967295);
-- invalid block number values
SELECT brin_summarize_range('brin_summarize_multi_idx', -1);
SELECT brin_summarize_range('brin_summarize_multi_idx', 4294967296);


-- test brin cost estimates behave sanely based on correlation of values
CREATE TABLE brin_test_multi (a INT, b INT);
INSERT INTO brin_test_multi SELECT x/100,x%100 FROM generate_series(1,10000) x(x);
CREATE INDEX brin_test_multi_a_idx ON brin_test_multi USING brin (a) WITH (pages_per_range = 2);
CREATE INDEX brin_test_multi_b_idx ON brin_test_multi USING brin (b) WITH (pages_per_range = 2);
VACUUM ANALYZE brin_test_multi;

-- Ensure brin index is used when columns are perfectly correlated
EXPLAIN (COSTS OFF) SELECT * FROM brin_test_multi WHERE a = 1;
-- Ensure brin index is not used when values are not correlated
EXPLAIN (COSTS OFF) SELECT * FROM brin_test_multi WHERE b = 1;
